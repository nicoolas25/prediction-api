require 'slim'
require 'coffee-script'
require 'sinatra/base'
require 'sinatra/reloader' if ENV['RELOAD'].present?

require './app/domain'

module Prediction
  class Web < Sinatra::Base
    ADMIN_TOKEN = "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB".freeze

    set :views, './app/views'

    get '/' do
      slim :home
    end

    get '/questions' do
      @valid_token = (params[:token] == ADMIN_TOKEN)
      @questions = Domain::Question.global.open_for(:all).all
      slim :questions_list
    end

    get '/questions/:id' do
      @question = Domain::Question.where(id: params[:id]).first if params[:token] != ADMIN_TOKEN
      return 404 unless @question
      slim :questions_details
    end

    get '/questions/new' do
      slim :questions_new
    end

    post '/questions' do
      return 404 if params[:token] != ADMIN_TOKEN

      qparams = params[:question]
      question = Domain::Question.new
      question.labels = qparams[:labels]
      question.expires_at = Time.parse(qparams[:expires_at])
      components = qparams[:components].values.map do |attrs|
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

