# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FoldersController, type: :controller do
  describe "POST #create" do
    include_context :authentication_grant

    context "when created folder successfully" do
      let(:params) do
        { name: "new_folder" }
      end

      subject{ post :create, params: { folder: params } }

      it do
        expect(subject).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:folder_name]).to eq params[:name]
      end
    end

    context "when create folder fails" do
      context "when parameter missing" do
        subject{ post :create, params: {} }

        it do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(response_body[:message]).to eq "Parameter missing"
        end
      end

      context "when name is blank" do
        let(:params) do
          { name: "" }
        end

        subject{ post :create, params: { folder: params } }

        it do
          expect(subject).to have_http_status(:bad_request)
          expect(response_body[:success]).to eq false
          expect(response_body[:errors][0]).to eq "Name cannot be blank"
        end
      end
    end
  end
end
