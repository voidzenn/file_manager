# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  shared_context :missing_field_errors do |field_name|
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "Password12!",
        fname: "John",
        lname: "Doe"
      }.except(field_name)
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

      response "422", "unprocessable_entity" do
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

          let(:params) do
            valid_params[:email] = "user.com"
            valid_params
          end
          let(:user) { { user: params } }

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
          let(:user) { { user: valid_params } }

          run_test! "returns emails exists error message" do
            expect(response_body[:error][0][:email]).to eq "already exists"
          end
        end
      end
    end
  end

  path "/api/v1/auth/sign_in" do
    post "Sign In" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ :email, :password ]
      }

      response "200", "ok" do
        let!(:new_user) { create :user }
        let(:user) do
          {
            email: new_user.email,
            password: new_user.password
          }
        end

        run_test! do
          expect(response_body[:success]).to eq true
          expect(response_body[:meta][:token]).to eq assigns(:token)
          expect(response_body[:data][:email]).to eq new_user.email
          expect(response_body[:data][:fname]).to eq new_user.fname
          expect(response_body[:data][:lname]).to eq new_user.lname
        end
      end
    end
  end
end
