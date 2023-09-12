class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_request!
  before_action :find_user, only: %i(sign_in)

  def sign_up
    @user = User.new sign_up_params

    raise ActiveRecord::RecordInvalid, @user unless @user.valid?

    # Create new root folder for user
    Api::V1::CreateUserRootFolderService.new(@user.id).perform

    @user.save
    render_jsonapi sign_up_response
  end

  def sign_in
    if @user && @user.authenticate(params[:password])
      payload = { email: @user.email }
      @token = JsonWebToken.encode payload

      render_jsonapi sign_in_response
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
    {
      token: @token,
      email: @user.email,
      fname: @user.fname,
      lname: @user.lname
    }
  end
end
