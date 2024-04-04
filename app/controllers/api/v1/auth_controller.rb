class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_request!
  before_action :find_user, only: %i(sign_in)

  def sign_up
    @user = User.new sign_up_params

    raise ActiveRecord::RecordInvalid, @user unless @user.valid?

    ActiveRecord::Base.transaction do
      @user.save

      create_folder = Api::V1::CreateBucketService.new(@user.bucket_token)

      raise ActiveRecord::Rollback && create_folder_error_response unless create_folder.perform

      render_jsonapi sign_up_response, status: :created
    end
  end

  def sign_in
    if @user && @user.authenticate(params[:password])
      @token = JsonWebToken.encode @user.unique_token
      @refresh_token = JsonWebToken.encode @user.unique_token, {}, 1.month.from_now

      sign_in_response
    else
      raise Api::Error::UnauthorizedError, :invalid_email_password
    end
  end

  def refresh_token
    token = request.headers["Authorization"].split(" ").last
    decoded = JsonWebToken.decode token

    raise Api::Error::UnauthorizedError, nil unless decoded.token_type == 'refresh'

    user = User.find_by!(unique_token: decoded.id)
    meta_data = {
      meta: {
        token: JsonWebToken.encode(user.unique_token)
      }
    }

    render_jsonapi [], meta_data
  rescue ActiveRecord::RecordNotFound
    raise Api::Error::UnauthorizedError, nil
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :fname, :lname)
  end

  def sign_in_params
    params.permit(:email, :password)
  end

  def find_user
    raise ActionController::ParameterMissing, nil if params[:email].blank? && params[:password].blank?

    @user = User.find_by(email: params[:email])
  end

  def sign_up_response
    {
      email: @user.email,
      fname: @user.fname,
      lname: @user.lname
    }
  end

  def sign_in_response
    response_data = {
      email: @user.email,
      fname: @user.fname,
      lname: @user.lname
    }

    meta = {
      meta: {
        token: @token,
        refresh_token: @refresh_token
      }
    }

    render_jsonapi response_data, meta
  end

  def create_folder_error_response
    error_message = { message: 'User root folder not created, try again' }

    render_jsonapi error_message, status: :unprocessable_entity
  end
end
