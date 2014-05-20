require 'slim'
require 'coffee-script'
require 'sinatra/base'

require './app/domain'

WEB_CONFIG = YAML.load_file('./config/web.yml')

module Prediction
  class Web < Sinatra::Base
    set :views, './app/views'

    get '/' do
      @sections = %w(intro make win badges bonus)
      @t = WEB_CONFIG['home']
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

    get '/questions/:id/edit' do
      slim :questions_edit
    end

    get '/players' do
      slim :players_list
    end

    get '/players/:nickname' do
      slim :players_details
    end

    get '/badges/:identifier/:level' do
      @identifier = params[:identifier]
      @level = params[:level] =~ /[1-5]/ ? params[:level] : 1
      @badge = WEB_CONFIG['badges'][@identifier]
      slim :badge_details
    end

    get '/scripts.js' do
      content_type "text/javascript"
      coffee :scripts
    end
  end
end

