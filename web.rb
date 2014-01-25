require 'sinatra/base'

module Prediction
  class Web < Sinatra::Base
    get '/' do
      "Hello world"
    end
  end
end

