module PaymentAPI
  autoload :Google, './lib/payment_apis/google'
  autoload :Apple,  './lib/payment_apis/apple'

  def self.for(provider, payload)
    case provider
    when 'google' then Google.new(payload)
    when 'apple'  then Apple.new(payload)
    else nil
    end
  end
end
