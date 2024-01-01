# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FoldersController, type: :controller do
  describe "POST #create" do
    include_context :authentication_grant

    context "when created root folder successfully" do
      let(:valid_params) do
        {
          folder: {
            path: "new_path/"
          }
        }
      end

      include_context :initialize_aws_s3

      before do
        allow_any_instance_of(Api::V1::CreateRootFolderJob).to receive(:perform_now).with(any_args).and_return(true)
        post :create, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq valid_params[:folder][:path]
      end
    end

    context "when created folder successfully" do
      let!(:parent_folder) { create :folder }
      let(:valid_params) do
        {
          folder: {
            parent_unique_token: parent_folder.unique_token,
            path: "new_path/"
          }
        }
      end

      include_context :initialize_aws_s3

      before do
        # allow_any_instance_of(Api::V1::CreateFolderService).to receive(:perform).and_return(true)
        # allow_any_instance_of(Api::V1::CreateFolderMinioService).to receive(:perform).and_return(true)
        allow_any_instance_of(Api::V1::CreateFolderJob).to receive(:perform_now).with(any_args).and_return(true)
        post :create, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq valid_params[:folder][:path]
      end
    end

    context "when create folder fails" do
      context "when parameter missing" do
        subject{ post :create, params: {} }

        it do
          expect(subject).to have_http_status(:bad_request)
          expect(response_body[:error]).to eq "Parameter missing"
        end
      end

      context "when path is blank" do
        let(:params) do
          { path: "" }
        end

        subject{ post :create, params: { folder: params } }

        it do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(response_body[:success]).to eq false
          expect(response_body[:error][0][:path]).to eq "cannot be blank"
        end
      end

      context 'when path name is invalid' do
        let(:invalid_params) do
          { 
            folder: {
              path: "/new_path/"
            }
          }
        end

        subject{ post :create, params: invalid_params }

        it 'should return an error message' do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(response_body[:success]).to eq false
          expect(response_body[:error][0][:path]).to eq I18n.t("errors.models.folder.format.message")
        end
      end
    end
  end
end
