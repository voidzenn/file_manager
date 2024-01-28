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
        allow_any_instance_of(Api::V1::CreateFolderMinioService).to receive(:perform).and_return(true)
        post :create, params: valid_params
      end

      it do
        expect(response).to have_http_status(:created)
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
        allow_any_instance_of(Api::V1::CreateFolderMinioService).to receive(:perform).and_return(true)
        post :create, params: valid_params
      end

      it do
        expect(response).to have_http_status(:created)
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

  describe 'PUT #rename' do
    include_context :authentication_grant
    include_context :initialize_aws_s3

    context 'when renaming root folder successfully' do
      let!(:parent_folder) { create :folder }
      let!(:folder) { create(:folder, path: 'new path/', parent_folder_id: parent_folder.id, user_id: user.id) }
      let(:valid_params) do
        {
          folder: {
            unique_token: folder.unique_token,
            new_path: 'new folder path/'
          }
        }
      end

      before do
        allow_any_instance_of(Api::V1::RenameFolderMinioService).to receive(:perform).with(any_args).and_return(true)
        allow_any_instance_of(Api::V1::RenameFolderJob).to receive(:perform_now).with(any_args).and_return(true)
        put :rename, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:new_path]).to eq(valid_params[:folder][:new_path])
      end
    end

    context 'when renaming folder successfully' do
      let!(:parent_folder) { create :folder }
      let!(:folder) { create(:folder, path: 'new path/', parent_folder_id: parent_folder.id, user_id: user.id) }
      let(:valid_params) do
        {
          folder: {
            parent_unique_token: parent_folder.unique_token,
            unique_token: folder.unique_token,
            new_path: 'new folder path/'
          }
        }
      end
      let(:prefixes) do
        {
          new_path: '',
          old_path: '',
        }
      end

      before do
        allow_any_instance_of(Api::V1::FolderTraversalService).to receive(:perform).with(any_args).and_return(prefixes)
        allow_any_instance_of(Api::V1::RenameFolderMinioService).to receive(:perform).with(any_args).and_return(true)
        put :rename, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:new_path]).to eq(valid_params[:folder][:new_path])
      end
    end

    context 'when renaming root folder fails' do
      context 'when missing params' do
        it do
          put :rename, params: {}
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
