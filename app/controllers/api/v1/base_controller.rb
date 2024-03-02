class Api::V1::BaseController < ApplicationController
  include Secured
  include Api::V1::BaseConcern

  skip_before_action :verify_authenticity_token

  def current_user_id
    @current_user_id = @current_user.id
  end

  def current_user_unique_token
    @current_user_unique_token = @current_user.unique_token
  end

  def current_user_bucket_token
    @current_user_bucket_token = @current_user.bucket_token
  end
end
