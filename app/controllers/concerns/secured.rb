# frozen_string_literal: true

module Secured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    @current_user = load_user
  end

  def load_user
    User.find(jwt_token.id)
  rescue ActiveRecord::RecordNotFound
    raise Api::Error::UnauthorizedError, nil
  end

  def jwt_token
    token = request.headers["Authorization"].split(" ").last
    decoded = decode_token token

    raise Api::Error::UnauthorizedError, nil if decoded.nil?

    decoded
  end

  def decode_token token
    JsonWebToken.decode token
  rescue JWT::DecodeError
    render_error_response 'Invalid token'
  rescue  JWT::ExpiredSignature
    render_error_response 'Token has expired'
  end

  def render_error_response message
    render json: {
      success: false,
      token: message,
    }, status: :unauthorized
  end
end
