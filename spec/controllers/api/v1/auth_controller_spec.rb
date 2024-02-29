# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthController, type: :controller do
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

  describe "POST #sign_up" do
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "Password12!",
        fname: "John",
        lname: "Doe"
      }
    end

    context "when user signed up successfully" do
      context "when all fields are valid" do
        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: true)))
          allow_any_instance_of(Api::V1::CreateBucketService).to receive(:perform).and_return(true)
          post :sign_up, params: { user: valid_params }
        end

        it do
          expect(assigns(:user)).to be_persisted

          expect(response).to have_http_status(:created)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:email]).to eq valid_params[:email]
          expect(response_body[:data][:fname]).to eq valid_params[:fname]
          expect(response_body[:data][:lname]).to eq valid_params[:lname]
        end
      end
    end

    context "when user sign up fails" do
      context "when params missing" do
        before do
          post :sign_up, params: {}
        end

        it do
          expect(response).to have_http_status(:bad_request)
          expect(response_body[:error]).to eq I18n.t("errors.params.missing.message")
        end
      end

      context "when missing fields in request body" do
        before do
          post :sign_up, params: { user: valid_params }
        end

        it_behaves_like "missing field errors", "email"
        it_behaves_like "missing field errors", "password"
        it_behaves_like "missing field errors", "fname"
        it_behaves_like "missing field errors", "lname"
      end

      context "when email is invalid" do
        let(:params) do
          valid_params[:email] = "user.com"
          valid_params
        end

        before do
          post :sign_up, params: { user: params }
        end

        it "return email is invalid error message" do
          expect(response_body[:error][0][:email]).to eq "is invalid"
        end
      end

      context "when email exist already" do
        let(:user) { create :user }
        let(:valid_params) do
          {
            email: user.email,
            password: "Password12!",
            fname: "John",
            lname: "Doe"
          }
        end

        before do
          post :sign_up, params: { user: valid_params }
        end

        it do
          expect(response_body[:error][0][:email]).to eq "already exists"
        end
      end
    end
  end

  describe "POST #sign_in" do
    context "when signed in successfully" do
      let(:user) { create :user }
      let(:valid_params) do
        {
          email: user.email,
          password: user.password
        }
      end

      before do
        post :sign_in, params: valid_params
      end

      it do
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:meta][:token]).to eq assigns(:token)
        expect(response_body[:data][:email]).to eq user.email
        expect(response_body[:data][:fname]).to eq user.fname
        expect(response_body[:data][:lname]).to eq user.lname
      end
    end

    context "when sign in fails" do
      context "when user email not found" do
        let(:params) do
          { email: "user@user.com" }
        end

        before do
          allow(User).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)
          post :sign_in, params: params
        end

        it do
          expect(response).to have_http_status(:not_found)
          expect(response_body[:success]).to eq false
        end
      end

      context "when parameter is missing" do
        before do
          post :sign_in, params: {}
        end

        it do
          expect(response).to have_http_status(:bad_request)
          expect(response_body[:error]).to eq "Parameter missing"
        end
      end

      context "when email params missing" do
        let(:params) do
          { password: "admin123" }
        end

        before do
          post :sign_in, params: params
        end

        it do
          expect(response).to have_http_status(:unauthorized)
          expect(response_body[:error]).to eq "Email or Password is invalid"
        end
      end

      context "when password params missing" do
        let(:params) do
          { email: "user@user.com" }
        end

        before do
          post :sign_in, params: params
        end

        it do
          expect(response).to have_http_status(:unauthorized)
          expect(response_body[:error]).to eq "Email or Password is invalid"
        end
      end
    end
  end
end
