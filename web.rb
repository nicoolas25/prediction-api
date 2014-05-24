require 'slim'
require 'coffee-script'
require 'sinatra/base'

require './app/domain'
require './lib/locale_middleware'

WEB_CONFIG  = YAML.load_file('./config/web.yml')
CONFIG      = YAML.load_file('./config/admin.yml')[ENV['RACK_ENV'] || 'app']
ADMIN_TOKEN = CONFIG['key'].freeze

module Prediction
  class Web < Sinatra::Base
    set :views, './app/views'

    helpers do
      def locale
        env['rack.locale']
      end
    end

    get '/' do
      @sections = %w(intro make win badges bonus)
      @t = WEB_CONFIG[locale]['home']
      slim :home
    end

    get '/badges/:identifier/:level' do
      @identifier = params[:identifier]
      @level = params[:level] =~ /[1-5]/ ? params[:level] : 1
      @badge = WEB_CONFIG[locale]['badges'][@identifier]
      @t = WEB_CONFIG[locale]['badges']['shared']
      slim :badge_details
    end

    before '/admin/*' do
      halt 401 unless params[:token] == ADMIN_TOKEN
    end

    get '/admin/questions/new' do
      slim :questions_new
    end

    get '/admin/questions' do
      slim :questions_list
    end

    get '/admin/questions/:id' do
      slim :questions_details
    end

    get '/admin/questions/:id/edit' do
      slim :questions_edit
    end

    get '/admin/players' do
      slim :players_list
    end

    get '/admin/players/:nickname' do
      slim :players_details
    end

    get '/admin/scripts.js' do
      content_type "text/javascript"
      coffee :scripts
    end
  end
end

