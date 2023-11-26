# frozen_string_literal: true

class JsonWebToken
  SECRET_KEY = ENV['SECRET_KEY']
  DEFAULT_EXPIRATION_TIME_MINUTES = 15

  def self.encode id, payload = {}, exp = DEFAULT_EXPIRATION_TIME_MINUTES.minutes.from_now
    payload[:id] = id
    payload[:exp] = exp.to_i

    JWT.encode payload, SECRET_KEY
  end

  def self.decode token
    decoded = JWT.decode(token, SECRET_KEY).first

    OpenStruct.new decoded
  end
end
