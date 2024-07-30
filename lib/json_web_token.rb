# frozen_string_literal: true

class JsonWebToken
  SECRET_KEY = ENV['SECRET_KEY']
  DEFAULT_EXPIRATION_TIME_MINUTES = 60.minutes

  class << self
    def encode id, payload = {}, exp = DEFAULT_EXPIRATION_TIME_MINUTES.from_now
      payload[:id] = id
      payload[:token_type] = 'access'

      encode_data payload, exp
    end

    def decode token
      decoded = JWT.decode(token, SECRET_KEY).first

      OpenStruct.new decoded
    end

    def encode_refresh_token id, payload = {}, exp = 1.month.from_now
      payload[:id] = id
      payload[:token_type] = 'refresh'

      encode_data payload, 1.month.from_now
    end

    private

    def encode_data payload, exp
      payload[:exp] = exp.to_i

      JWT.encode payload, SECRET_KEY
    end
  end
end
