module Validator
  class AuthenticationToken < Grape::Validations::Validator
    ADMIN_TOKEN = "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB".freeze

    def validate_param!(attr_name, params)
      unless params[attr_name] == ADMIN_TOKEN
        raise Controllers::Failure.new(:not_found, 404)
      end
    end
  end

  class BadgeLevel < Grape::Validations::Validator
    def validate_param!(attr_name, params)
      unless params[attr_name] =~ /^[1-9]$/
        raise Grape::Exceptions::Validation, param: @scope.full_name(attr_name), message: "must be a valid badge level"
      end
    end
  end
end
