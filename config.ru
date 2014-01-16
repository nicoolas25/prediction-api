ROOT_PATH = File.dirname(__FILE__)
$:.unshift(ROOT_PATH) unless $:.include?(ROOT_PATH)

require 'grape'
require 'db/connect'

module Prediction
  class API < Grape::API
    version 'v1'
    format :json

    desc "Greet the user."
    params do
      requires :name, type: String, desc: "The user's name."
    end
    get '/hello/:name' do
      { hello: params[:name] }
    end

  end
end

run Prediction::API
