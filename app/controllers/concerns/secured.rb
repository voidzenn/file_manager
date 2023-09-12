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
    raise Api::Error::UnauthorizedError, nil if token_expired?

    User.find(jwt_token["user_id"])
  rescue ActiveRecord::RecordNotFound
    raise Api::Error::UnauthorizedError, nil
  end

  def jwt_token
    authorization = request.headers["Authorization"].split(" ").last
    decoded_token = JsonWebToken.decode authorization

    raise Api::Error::UnauthorizedError, nil if decoded_token.nil?

    decoded_token
  end

  def token_expired?
    Time.now.to_i >= jwt_token["exp"]
  end
end
