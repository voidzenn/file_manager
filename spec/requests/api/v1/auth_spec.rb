# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  shared_context "missing field errors" do |field_name|
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "Password12!",
        fname: "John",
        lname: "Doe"
      }.except(field_name.to_sym)
    end
    let(:user) { { user: valid_params } }

    run_test! do
      expect(response_body[:success]).to eq false
      expect(response_body[:error][0][field_name.to_sym]).to eq "cannot be blank"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  path "/api/v1/auth/sign_up" do
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

    post "Sign Up" do
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

        examples "application/json" => {
          success: true,
          data: {
            email: "email@example.com",
            fname: "John",
            lname: "Doe"
          },
          meta: {}
        }

        run_test! do
          expect(response).to have_http_status(:created)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:email]).to eq valid_params[:email]
          expect(response_body[:data][:fname]).to eq valid_params[:fname]
          expect(response_body[:data][:lname]).to eq valid_params[:lname]
        end
      end

      response "422", "parameter missing" do
        examples "application/json" => {
          success: false,
          error: [{"<attribute_name>":"cannot be blank"}]
        }

        it_behaves_like "missing field errors", "email"
        it_behaves_like "missing field errors", "password"
        it_behaves_like "missing field errors", "fname"
        it_behaves_like "missing field errors", "lname"
      end

      response "422", "email exists" do
        let!(:new_user) { create(:user, email: valid_params[:email]) }
        let(:user) { { user: valid_params } }

        examples "application/json" => {
          success: false,
          error: "Parameter missing"
        }

        run_test! do
          expect(response_body[:error][0][:email]).to eq "already exists"
        end
      end
    end
  end
end
