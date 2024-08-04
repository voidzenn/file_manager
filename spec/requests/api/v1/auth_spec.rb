# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  AUTH_SPEC_TAG = "Auth"

  shared_context :missing_field_errors do |field_name|
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "Password12!",
        fname: "John",
        lname: "Doe"
      }.except(field_name)
    end
    let(:params) do
      { user: valid_params }
    end

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
      tags AUTH_SPEC_TAG
      consumes "application/json"
      produces "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              fname: { type: :string },
              lname: { type: :string }
            }
          },
          required: [ :email, :password, :fname, :lname ]
        },
        require: [ :user ]
      }

      response 201, "created" do
        let(:params) do
          { user: valid_params }
        end

        example "application/json", :created, {
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

      response 422, "unprocessable_entity" do
        context "when parameter missing" do
          example "application/json", :parameter_missing, {
            success: false,
            error: [{"<attribute_name>":"cannot be blank"}]
          }

          it_behaves_like :missing_field_errors, :email
          it_behaves_like :missing_field_errors, :password
          it_behaves_like :missing_field_errors, :fname
          it_behaves_like :missing_field_errors, :lname
        end

        context "when email is invalid" do
          example "application/json", :email_invalid, {
            success: false,
            error: [{email: "is invalid"}]
          }

          let(:invalid_params) do
            valid_params[:email] = "user.com"
            valid_params
          end
          let(:params) do
            { user: invalid_params }
          end

          run_test! "returns email is invalid error message" do
            expect(response_body[:error][0][:email]).to eq "is invalid"
          end
        end

        context "when email already exists" do
          example "application/json", :email_exists, {
            success: false,
            error: "Parameter missing"
          }

          let!(:new_user) { create(:user, email: valid_params[:email]) }
          let(:params) do
            { user: valid_params }
          end

          run_test! "returns emails exists error message" do
            expect(response_body[:error][0][:email]).to eq "already exists"
          end
        end
      end
    end
  end

  path "/api/v1/auth/sign_in" do
    post "Sign In" do
      tags AUTH_SPEC_TAG
      consumes "application/json"
      produces "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ :email, :password ]
      }

      response 200, "ok" do
        let!(:new_user) { create :user }
        let(:params) do
          {
            email: new_user.email,
            password: new_user.password
          }
        end

        example "application/json", :ok, {
          success: true,
          data: {
            email: "email@example.com",
            fname: "John",
            lname: "Doe"
          },
          meta: {
            token: "abcde",
            refresh_token: "abcde"
          }
        }

        run_test! do
          expect(response_body[:success]).to eq true
          expect(response_body[:meta][:token]).to eq assigns(:token)
          expect(response_body[:data][:email]).to eq new_user.email
          expect(response_body[:data][:fname]).to eq new_user.fname
          expect(response_body[:data][:lname]).to eq new_user.lname
        end
      end

      response 404, "not_found" do
        let(:params) do
          { email: "user@user.com" }
        end

        before do
          allow(User).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)
        end

        example "application/json", :not_found, {
          success: false,
          error: "Not found"
        }

        run_test! do
          expect(response).to have_http_status(:not_found)
          expect(response_body[:success]).to eq false
        end
      end

      response 400, "unprocessable_entity" do
        context "when parameter is missing" do
          let(:params) {}

          example "application/json", :parameter_missing, {
            success: false,
            error: "Parameter missing"
          }

          run_test! do
            expect(response).to have_http_status(:bad_request)
            expect(response_body[:error]).to eq "Parameter missing"
          end
        end
      end

      response 401, "unauthorized" do
        context "when email params missing" do
          let(:params) do
            { password: "admin123" }
          end

          example "application/json", :unauthorized, {
            success: false,
            error: "Email or Password is invalid"
          }

          run_test! do
            expect(response).to have_http_status(:unauthorized)
            expect(response_body[:error]).to eq "Email or Password is invalid"
          end
        end

        context "when password params missing" do
          let(:params) do
            { email: "user@user.com" }
          end

          example "application/json", :unauthorized, {
            success: false,
            error: "Email or Password is invalid"
          }

          run_test! do
            expect(response).to have_http_status(:unauthorized)
            expect(response_body[:error]).to eq "Email or Password is invalid"
          end
        end
      end
    end
  end

  path "/api/v1/auth/refresh_token" do
    post "Refresh token" do
      tags AUTH_SPEC_TAG
      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Token"

      let!(:user) { create :user }
      let(:user_refresh_token) { JsonWebToken.encode_refresh_token user.unique_token }

      response 200, :ok do
        let(:Authorization) { user_refresh_token }

        example "application/json", :ok, {
          success: true,
          data: [],
          meta: {
            token: "abcde"
          }
        }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response_body[:meta][:token]).to_not be_empty
        end
      end

      response 401, :unauthorized do
        context "when token not valid" do
          let(:Authorization) { "invalid_token" }

          example "application/json", :invalid_token, {
            success: false,
            error: "Invalid Token"
          }

          run_test! do
            expect(response).to have_http_status(:unauthorized)
            expect(response_body[:success]).to eq(false)
          end
        end

        context "when valid token but user not found" do
          let(:Authorization) { JsonWebToken.encode_refresh_token "not_user" }

          example "application/json", :unauthorized, {
            success: false,
            error: "Unauthorized"
          }

          run_test! do
            expect(response).to have_http_status(:unauthorized)
            expect(response_body[:success]).to eq(false)
          end
        end
      end
    end
  end
end
