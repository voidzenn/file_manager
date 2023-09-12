# frozen_string_literal: true

RSpec.shared_context :authentication_grant do
  let(:user) { create :user }

  before do
    user_id = {user_id: user.id}
    jwt_token = JsonWebToken.encode(user_id)
    request.headers.merge! Authorization: "Bearer #{jwt_token}"
  end
end
