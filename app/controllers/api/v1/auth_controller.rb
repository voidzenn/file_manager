class Api::V1::AuthController < Api::V1::BaseController
  def sign_up
    @user = User.create sign_up_params

    raise ActiveRecord::RecordInvalid, @user unless @user.valid?

    @user.save
    render_jsonapi success_response
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :fname, :lname)
  end

  def success_response
    {
      message: "Successfully signed up",
      email: @user.email,
      fname: @user.fname,
      lname: @user.lname
    }
  end
end
