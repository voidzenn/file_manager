# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  SIGNUP_PATH = "/api/v1/auth/sign_up"

  shared_context "missing field errors" do |field_name|
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "Password12!",
        fname: "John",
        lname: "Doe"
      }.except(field_name.to_sym)
    end

    it "return #{field_name} error message" do
      expect(response_body[:success]).to eq false
      expect(response_body[:error][0][field_name.to_sym]).to eq "cannot be blank"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  path SIGNUP_PATH do
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "Password12!",
        fname: "John",
        lname: "Doe"
      }
    end

    before do
      allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: true)))
      allow_any_instance_of(Api::V1::CreateBucketService).to receive(:perform).and_return(true)
    end

    post SIGNUP_PATH do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          fname: { type: :string },
          lname: { type: :string }
        },
        required: [ 'email', 'password', 'fname', 'lname' ]
      }

      response "201", "created" do
        let(:user) { { user: valid_params } }

        run_test! do
          expect(response).to have_http_status(:created)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:email]).to eq valid_params[:email]
          expect(response_body[:data][:fname]).to eq valid_params[:fname]
          expect(response_body[:data][:lname]).to eq valid_params[:lname]
        end
      end
    end
  end
end
