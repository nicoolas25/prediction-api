require 'slim'
require 'coffee-script'
require 'sinatra/base'
require 'sinatra/reloader' if ENV['RELOAD'].present?

require './app/collections'

module Prediction
  class Web < Sinatra::Base
    set :views, './app/views'

    get '/' do
      slim :home
    end

    get '/questions/new' do
      slim :questions_new
    end

    post '/questions' do
      return 404 unless params[:token] == "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB"

      question_params = params[:question]
      player = Collections::Players.root
      question = Domain::Question.new(
        author: player,
        labels: question_params[:labels],
        components: question_params[:components].values.map{ |attrs|
          labels = attrs[:labels]
          if attrs[:kind] == 'choices'
            choices = attrs[:choices].each_with_object({}) do |(locale, choices), hash|
              hash[locale] = choices.split(',').map(&:strip)
            end
            Domain::QuestionComponentChoice.new(labels: labels, choices: choices)
          else
            Domain::QuestionComponentExact.new(labels: labels)
          end
        })

      question, err = Collections::Questions.create(question)

      if err
        content_type "text/javascript"
        err.to_json
      else
        "Ok"
      end
    end

    get '/scripts.js' do
      content_type "text/javascript"
      coffee :scripts
    end
  end
end

