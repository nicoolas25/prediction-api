
module Validator
  class AuthenticationToken < Grape::Validations::Validator
    CONFIG      = YAML.load_file('./config/admin.yml')[ENV['RACK_ENV'] || 'app']
    ADMIN_TOKEN = CONFIG['key'].freeze

    def validate_param!(attr_name, params)
      unless params[attr_name] == ADMIN_TOKEN
        raise Controllers::Failure.new(:not_found, 404)
      end
    end
  end
end
