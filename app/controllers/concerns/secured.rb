# frozen_string_literal: true

module Secured
  extend ActiveSupport::Concern

  included do
    def authenticate_request!
      @current_user = load_user
    end
  end

  private

  def load_user
    raise Api::Error::UnauthorizedError, nil if token_expired?

    User.find(jwt_token["user_id"])
  end

  def jwt_token
    JsonWebToken.decode(load_jwt_token)
  end

  def load_jwt_token
    request.headers["Authorization"].split(" ").last
  end

  def token_expired?
    Time.now.to_i >= jwt_token["exp"]
  end
end
