require 'active_support'
require 'active_support/core_ext'

def parse_teams(path)
  teams = YAML.load_file(path)
  teams.each_with_object({}) do |team, hash|
    hash[team['small']] = team
  end
end

def parse_questions(path)
  YAML.load_file(path)
end

def parse_matches(path)
  YAML.load_file(path)
end

def match_tag_for(match)
  group = match['group'].to_s

  if group =~ /[A-Z]/
    "r/#{group}"
  else
    "f/#{group}"
  end
end

def find_question(params, tags, ref_lang)
  query = Domain::Question.
    select_all(:questions).
    join(:questions_tags, question_id: :id).
    where(event_at: params[:event_at]).
    # where(:"label_#{ref_lang}" => params[:labels][ref_lang]).
    # Use the qid parameter instead of the language
    where(identifier: params[:identifier]).
    where(questions_tags__tag_id: tags.map(&:id)).
    group(:questions__id).
    having(Sequel.function(:count, '*') => tags.size)
  query.eager(:components, :tags).first || Domain::Question.new
end

def compute_choice(ref_lang, component, choice, lang)
  if component
    if existing_choices = component.choices[lang]
      existing_choices.join(',')
    else
      choices = choice.split(',')
      reference_choices = component.choices[ref_lang]
      (reference_choices.reverse.drop(choices.size).reverse + choices).join(',')
    end
  else
    choice
  end
end

def build_components(ref_lang, teams, question, components)
  components.map do |ct|
    c = {}.with_indifferent_access

    c[:kind] = Domain::QuestionComponent::KINDS.index(ct['kind']).to_s

    c[:labels] = ct['choices'].each_with_object({}) do |(lang, _), h|
      unless lang == 'dev'
        h[lang] = teams.map { |t| "c/#{t['small']}" }.join(' - ')
      end
    end

    if qc = question.components.find { |qc| qc.labels[ref_lang] == c[:labels][ref_lang] }
      c[:id] = qc.id.to_s
    end

    c[:choices] = ct['choices'].each_with_object({}) do |(lang, choice), h|
      choice = choice.gsub("__C1__", "c/#{teams.first['small']}").gsub("__C2__", "c/#{teams.last['small']}")
      h[lang] = compute_choice(ref_lang, qc, choice, lang)
    end

    c
  end
end

def create_question(question_params, tags, teams, template, ref_lang)
  question_params = question_params.merge(pending: true) if template['template'] == 'player'
  question_params = question_params.merge(labels: template['labels'], identifier: template['qid'], order: template['order'])

  q = find_question(question_params, tags, ref_lang)

  unless q.new?
    # Existing questions keep their pending status
    question_params.delete(:pending)
  end

  q.set(question_params)

  components = build_components(ref_lang, teams, q, template['components'])
  q.update_components(components)

  # Set the tags
  tags.each { |t| q.add_tag(t) unless q.tags.include?(t) }
end

namespace :import do
  desc "Import questions"
  task :questions do
    require './api'

    teams_path     = ENV['TEAMS']     || './resources/teams.yml'
    questions_path = ENV['QUESTIONS'] || './resources/questions.yml'
    matches_path   = ENV['MATCHES']   || './resources/matches.yml'
    ref_lang       = ENV['REF_LANG']  || 'fr'

    teams = parse_teams(teams_path)
    questions = parse_questions(questions_path)
    matches = parse_matches(matches_path)

    matches.each do |match|
      # Timestamps, show all the imported questions
      event_at = Time.parse("#{match['date']} #{match['time']}")
      question_params = {
        event_at: event_at,
        reveals_at: event_at - 7.days,
        expires_at: event_at,
      }

      # Teams
      current_teams = match['teams'].map { |small| teams[small] }

      # Tags
      match_tag = match_tag_for(match)
      tags = [match_tag] + current_teams.map { |t| "c/#{t['small']}" }
      tags = tags.map { |kw| Domain::Tag.first(keyword: kw) || Domain::Tag.create(keyword: kw) }

      questions.each do |template|
        create_question(question_params, tags, current_teams, template, ref_lang)
      end
    end
  end
end
