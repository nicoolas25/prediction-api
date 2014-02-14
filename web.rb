require 'slim'
require 'coffee-script'
require 'sinatra/base'

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
      slim :questions_list
    end

    get '/questions/:id' do
      slim :questions_details
    end

    get '/players' do
      slim :players_list
    end

    get '/players/:nickname' do
      slim :players_details
    end

    get '/scripts.js' do
      content_type "text/javascript"
      coffee :scripts
    end
  end
end

