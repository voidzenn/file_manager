# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FoldersController, type: :controller do
  shared_context "mock allow create folder instance" do
    before do
      allow_any_instance_of(Api::V1::CreateFolderService).to receive(:perform).and_raise(Api::Error::InternalServerError)
    end
  end

  describe "POST #create" do
    include_context :authentication_grant

    context "when created folder successfully" do
      let(:params) do
        { path: "new_path/" }
      end

      include_context :initialize_aws_s3

      subject{ post :create, params: { folder: params } }

      it do
        expect(subject).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq params[:path]
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

      context "when path is blank" do
        let(:params) do
          { path: "" }
        end

        subject{ post :create, params: { folder: params } }

        it do
          expect(subject).to have_http_status(:bad_request)
          expect(response_body[:success]).to eq false
          expect(response_body[:errors][0]).to eq "Path cannot be blank"
        end
      end

      context 'when path starts with "/" and ends with "/"' do
        let(:params) do
          { path: "/new_path/" }
        end

        include_context "mock allow create folder instance"

        subject{ post :create, params: { folder: params } }

        it 'returns "must not allow / and must end with /"' do
          expect(subject).to have_http_status(:bad_request)
          expect(response_body[:success]).to eq false
          expect(response_body[:errors][0]).to eq I18n.t("errors.models.folder.path.format")
        end
      end

      context 'when path starts with "/"' do
        let(:params) do
          { path: "/new_path" }
        end

        include_context "mock allow create folder instance"

        subject{ post :create, params: { folder: params } }

        it 'returns "must not allow / and must end with /"' do
          expect(subject).to have_http_status(:bad_request)
          expect(response_body[:success]).to eq false
          expect(response_body[:errors][0]).to eq I18n.t("errors.models.folder.path.format")
        end
      end

      context 'when path has no "/" at the end' do
        let(:params) do
          { path: "new_path" }
        end

        include_context "mock allow create folder instance"

        subject{ post :create, params: { folder: params } }

        it 'returns "must not allow / and must end with /"' do
          expect(subject).to have_http_status(:bad_request)
          expect(response_body[:success]).to eq false
          expect(response_body[:errors][0]).to eq I18n.t("errors.models.folder.path.format")
        end
      end
    end
  end
end
