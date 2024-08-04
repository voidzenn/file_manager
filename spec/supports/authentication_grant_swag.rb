# frozen_string_literal: true

RSpec.shared_context :authentication_grant_swag do
  let!(:user) { create :user }
  let(:user_token) { JsonWebToken.encode(user.unique_token) }
  let(:Authorization) { "Bearer #{user_token}" }
end
