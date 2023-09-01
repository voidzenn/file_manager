# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthController, type: :controller do
  shared_context "missing field errors" do |field_name|
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "admin123",
        fname: "John",
        lname: "Doe"
      }.except(field_name.to_sym)
    end

    it "return #{field_name} error message" do
      expect(response_body[:errors][0]).to eq "#{field_name.humanize} cannot be blank"
    end
  end

  describe "POST #sign_up" do
    let(:valid_params) do
      {
        email: "email@email.com",
        password: "admin123",
        fname: "John",
        lname: "Doe"
      }
    end

    context "when user signed up successfully" do
      context "when all fields are valid" do
        before do
          post :sign_up, params: { user: valid_params }
        end

        it do
          expect(assigns(:user)).to be_persisted

          expect(response).to have_http_status(:ok)
          expect(response_body[:success]).to be_truthy
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
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body[:message]).to eq I18n.t("errors.params.missing.message")
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
          expect(response_body[:errors][0]).to eq "Email is invalid"
        end
      end

      context "when email exist already" do
        let(:user) { create :user }
        let(:valid_params) do
          {
            email: user.email,
            password: "admin123",
            fname: "John",
            lname: "Doe"
          }
        end

        before do
          post :sign_up, params: { user: valid_params }
        end

        it do
          expect(response_body[:errors][0]).to eq "Email already exists"
        end
      end
    end
  end
end
