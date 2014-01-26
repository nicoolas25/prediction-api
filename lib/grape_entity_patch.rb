module Grape
  class Entity
    def serializable_hash(runtime_options = {})
      return nil if object.nil?
      opts = options.merge(runtime_options || {})
      exposures.inject({}) do |output, (attribute, exposure_options)|
        if (exposure_options.has_key?(:proc) || object.respond_to?(attribute)) && conditions_met?(exposure_options, opts)
          partial_output = value_for(attribute, opts)
          next output if exposure_options[:exclude_nil] && partial_output.nil?
          output[key_for(attribute)] =
            if partial_output.respond_to? :serializable_hash
              partial_output.serializable_hash(runtime_options)
            elsif partial_output.kind_of?(Array) && !partial_output.map {|o| o.respond_to? :serializable_hash}.include?(false)
              partial_output.map {|o| o.serializable_hash}
            else
              partial_output
            end
        end
        output
      end
    end
  end
end
