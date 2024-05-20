module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    protected

    def find_verified_user
      token = request.params[:token]
      decoded_token = JsonWebToken.decode token

      User.find_by!(unique_token: decoded_token)
    rescue => _
      # Handle error
    end
  end
end
