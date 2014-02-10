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

    get '/questions/new' do
      slim :questions_new
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

    get '/scripts.js' do
      content_type "text/javascript"
      coffee :scripts
    end
  end
end

