require 'slim'
require 'coffee-script'
require 'sinatra/base'
require 'sinatra/reloader' if ENV['RELOAD'].present?

require './app/domain'

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
      return 404 if params[:token] != "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB"

      qparams = params[:question]
      question = Domain::Question.new
      question.labels = qparams[:labels]
      question.expires_at = Time.parse(qparams[:expires_at])
      component = qparams[:components].values.map do |attrs|
        component = Domain::QuestionComponent.new
        component.kind = attrs[:kind].to_i
        component.labels = attrs[:labels]
        component.choices = attrs[:choices] if component.have_choices?
        component
      end

      DB.transaction do
        question.save
        components.each_with_index do |component, index|
          component.position = index
          question.add_component(component)
        end
      end

      if question.id
        "Ok"
      else
        return 403
      end
    end

    get '/scripts.js' do
      content_type "text/javascript"
      coffee :scripts
    end
  end
end

