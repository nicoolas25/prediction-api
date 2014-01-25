require 'slim'
require 'sinatra/base'

module Prediction
  class Web < Sinatra::Base
    set :views, './app/views'

    get '/' do
      slim :home
    end
  end
end

