# frozen_string_literal: true

class JsonWebToken
  SECRET_KEY = ENV['SECRET_KEY']
  DEFAULT_EXPIRATION_TIME_HOURS = 24

  def self.encode payload, exp = DEFAULT_EXPIRATION_TIME_HOURS.hours.from_now
    payload[:exp] = exp.to_i
    JWT.encode payload, SECRET_KEY
  end

  def self.decode token
    decoded = JWT.decode(token, SECRET_KEY).first
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
