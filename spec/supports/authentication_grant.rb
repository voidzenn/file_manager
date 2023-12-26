# frozen_string_literal: true

RSpec.shared_context :authentication_grant do
  let!(:user) { create :user }
  let(:user_token) { JsonWebToken.encode(user.unique_token) }

  before do
    request.headers.merge! Authorization: "Bearer #{user_token}"
  end
end
