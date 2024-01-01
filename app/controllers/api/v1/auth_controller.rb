class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_request!
  before_action :find_user, only: %i(sign_in)

  def sign_up
    @user = User.new sign_up_params

    raise ActiveRecord::RecordInvalid, @user unless @user.valid?

    ActiveRecord::Base.transaction do
      @user.save

      create_folder = Api::V1::CreateUserRootFolderMinioService.new(@user.unique_token)

      raise ActiveRecord::Rollback && create_folder_error_response unless create_folder.perform

      render_jsonapi sign_up_response
    end
  end

  def sign_in
    if @user && @user.authenticate(params[:password])
      @token = JsonWebToken.encode @user.unique_token

      sign_in_response
    else
      raise Api::Error::UnauthorizedError, :invalid_email_password
    end
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
      meta: { token: @token }
    }

    render_jsonapi response_data, meta
  end

  def create_folder_error_response
    error_message = { message: 'User root folder not created, try again' }

    render_jsonapi error_message, status: :unprocessable_entity
  end
end
