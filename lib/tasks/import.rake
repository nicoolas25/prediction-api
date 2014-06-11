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

def find_question(params, tags, ref_lang)
  query = Domain::Question.
    select_all(:questions).
    join(:questions_tags, question_id: :id).
    where(event_at: params[:event_at]).
    where(:"label_#{ref_lang}" => params[:labels][ref_lang]).
    where(questions_tags__tag_id: tags.map(&:id)).
    group(:questions__id).
    having(Sequel.function(:count, '*') => tags.size)
  query.first || Domain::Question.new
end

def create_question(question_params, tags, teams, template, ref_lang)
  question_params = question_params.merge(pending: true) if template['template'] == 'player'
  question_params = question_params.merge(labels: template['labels'])

  q = find_question(question_params, tags, ref_lang)
  q.set(question_params)

  if q.new?
    components = template['components'].map do |ct|
      c = {}

      c[:kind] = Domain::QuestionComponent::KINDS.index(ct['kind']).to_s

      c[:labels] = ct['choices'].each_with_object({}) do |(lang, _), h|
        unless lang == 'dev'
          h[lang] = teams.map { |t| "c/#{t['small']}" }.join(' - ')
        end
      end

      c[:choices] = ct['choices'].each_with_object({}) do |(lang, choice), h|
        h[lang] = choice.gsub("__C1__", "c/#{teams.first['small']}").gsub("__C2__", "c/#{teams.last['small']}")
      end

      if qc = q.components.find { |qc| qc.label_fr == c[:labels]['fr'] }
        c[:id] = qc.id
      end

      c
    end

    q.update_components(components)

    # Set the tags
    tags.each { |t| q.add_tag(t) }
  else
    q.save
  end
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
        reveals_at: event_at - 2.days,
        expires_at: event_at
      }

      # Teams
      current_teams = match['teams'].map { |small| teams[small] }

      # Tags
      tags = ["r/#{match['group']}"] + current_teams.map { |t| "c/#{t['small']}" }
      tags = tags.map { |kw| Domain::Tag.first(keyword: kw) || Domain::Tag.create(keyword: kw) }

      questions.each do |template|
        create_question(question_params, tags, current_teams, template, ref_lang)
      end
    end
  end
end
