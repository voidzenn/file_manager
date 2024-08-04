# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FileUploadsController, type: :controller do
  include_context :authentication_grant
  include_examples :sample_file

  describe 'GET #index' do
    context 'when retrieving files successful' do
      let!(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }

      it 'should return files list' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(response_body[:data][0][:id]).to eq(file_upload.id)
        expect(response_body[:data][0][:folder_id]).to eq(nil)
        expect(response_body[:data][0][:unique_token]).to eq(file_upload.unique_token)
        expect(response_body[:data][0][:full_path]).to eq(file_upload.full_path)
        expect(response_body[:data][0][:filename]).to eq(file_upload.name.split(".").first)
      end
    end
  end

  describe "GET #view_file" do
    let!(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
    let(:sample_url) { "test_url" }

    it "returns generated file link" do
      allow_any_instance_of(Api::V1::GetFileUrlMinioService).to receive(:perform).and_return(sample_url)
      get :view_file, params: { unique_token: file_upload.unique_token }

      expect(response).to have_http_status(:ok)
      expect(response_body[:success]).to eq true
      expect(response_body[:data][:file_url]).to eq sample_url
    end

    it "return not_found if file_upload not exists or parameter missing" do
      get :view_file

      expect(response).to have_http_status(:not_found)
      expect(response_body[:success]).to eq false
    end
  end

  describe 'POST #create' do
    context 'when uploading successful' do
      let(:parent_path) { 'parent_path/' }
      let!(:parent_folder) { create(:folder, user_id: user.id, path: parent_path, full_path: parent_path) }
      let(:child_path) { 'child_path/' }
      let(:full_path) { parent_folder.full_path + child_path }
      let!(:folder) { create(:folder, user_id: user.id, parent_folder_id: parent_folder.id, path: child_path, full_path: full_path) }
      let(:nested_path) { "new_path/" }
      let!(:nested_folder) { create(:folder, user_id: user.id, parent_folder_id: folder.id, path: nested_path, full_path: folder.full_path + nested_path) }
      let(:valid_params_root) do
        {
          file_upload: {
            file: sample_file
          }
        }
      end
      let(:valid_params_nested) do
        {
          file_upload: {
            folder_unique_token: folder.unique_token,
            file: sample_file
          }
        }
      end
      let(:valid_params_nested_nested) do
        {
          file_upload: {
            folder_unique_token: nested_folder.unique_token,
            file: sample_file
          }
        }
      end
      let(:filename_without_extension) { sample_file.original_filename }

      before do
        allow_any_instance_of(Api::V1::UploadFileMinioService).to receive(:perform).and_return(true)
      end

      it 'should upload file to root folder' do
        post :create, params: valid_params_root

        expect(response).to have_http_status(:created)
        expect(response_body[:success]).to eq(true)
        expect(response_body[:data][:full_path]).to eq(filename_without_extension)
      end

      it 'should upload file to nested folder' do
        post :create, params: valid_params_nested

        expect(response).to have_http_status(:created)
        expect(response_body[:success]).to eq(true)
        expect(response_body[:data][:full_path]).to eq(folder.full_path + filename_without_extension)
      end

      it 'should upload file to nested nested folder' do
        post :create, params: valid_params_nested_nested

        expect(response).to have_http_status(:created)
        expect(response_body[:success]).to eq(true)
        expect(response_body[:data][:full_path]).to eq(nested_folder.full_path + filename_without_extension)
      end
    end

    context 'when missing params' do
      it 'should return missing params message' do
        post :create, params: {}

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:success]).to eq(false)
        expect(response_body[:error]).to eq('Parameter missing')
      end
    end

    context 'when token invalid' do
      it 'should return token invalid message' do
        request.headers['Authorization'] = 'invalid_token'
        post :create, params: {}

        expect(response).to have_http_status(:unauthorized)
        expect(response_body[:success]).to eq(false)
        expect(response_body[:error]).to eq('Invalid Token')
      end
    end
  end

  describe "PUT #rename" do
    before(:each) do
      allow_any_instance_of(Api::V1::RenameFileMinioService).to receive(:perform).and_return(true)
    end

    context "when renaming file successfully without parent folder" do
      let(:path) { "parent_path/" }
      let!(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
      let(:valid_params) do
        {
          file_upload: {
            unique_token: file_upload.unique_token,
            name: "new file"
          }
        }
      end

      it do
        put :rename, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:id]).to eq file_upload.id
        expect(response_body[:data][:unique_token]).to eq file_upload.unique_token
        expect(response_body[:data][:filename]).to eq valid_params[:file_upload][:name]
        expect(response_body[:data][:full_path]).to eq(valid_params[:file_upload][:name] + "." + file_upload.name.split(".").last)
        expect(response_body[:data][:file_extension]).to eq file_upload.name.split(".").last
      end
    end

    context "when renaming file successfully with parent folder 1 deep" do
      let(:path) { "parent_path/" }
      let!(:parent_folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
      let!(:file_upload) do
        file = create(:file_upload, user_id: user.id, folder_id: parent_folder.id)
        file.update(full_path:  path + file.name)
        file
      end
      let(:valid_params) do
        {
          file_upload: {
            unique_token: file_upload.unique_token,
            name: "new file"
          }
        }
      end
      let(:full_new_path) { path + valid_params[:file_upload][:name] + "." + file_upload.name&.split(".").last }

      it do
        put :rename, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:id]).to eq file_upload.id
        expect(response_body[:data][:unique_token]).to eq file_upload.unique_token
        expect(response_body[:data][:filename]).to eq valid_params[:file_upload][:name]
        expect(response_body[:data][:full_path]).to eq(full_new_path)
        expect(response_body[:data][:file_extension]).to eq file_upload.name.split(".").last
      end
    end

    context "when renaming file successfully with parent folder 2 deep" do
      let(:parent_path) { "parent_path/" }
      let!(:parent_folder) { create(:folder, user_id: user.id, path: parent_path, full_path: parent_path) }
      let(:nested_path) { "nested_path/" }
      let!(:nested_folder) { create(:folder, user_id: user.id, path: nested_path, full_path: parent_path + nested_path, parent_folder_id: parent_folder.id) }
      let!(:file_upload) do
        file = create(:file_upload, user_id: user.id, folder_id: nested_folder.id)
        file.update(full_path:  parent_path + nested_path + file.name)
        file
      end
      let(:valid_params) do
        {
          file_upload: {
            unique_token: file_upload.unique_token,
            name: "new file"
          }
        }
      end
      let(:full_new_path) { parent_path + nested_path + valid_params[:file_upload][:name] + "." + file_upload.name&.split(".").last }

      it do
        put :rename, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:id]).to eq file_upload.id
        expect(response_body[:data][:unique_token]).to eq file_upload.unique_token
        expect(response_body[:data][:filename]).to eq valid_params[:file_upload][:name]
        expect(response_body[:data][:full_path]).to eq(full_new_path)
        expect(response_body[:data][:file_extension]).to eq file_upload.name.split(".").last
      end
    end

    context "when renaming file fails" do
      let(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
      let(:filename_without_extension) { file_upload.name.split(".").first }
      let(:invalid_params) do
        {
          file_upload: {
            unique_token: file_upload.unique_token,
            name: filename_without_extension
          }
        }
      end

      it "returns not_found when parameter missing or file not exist" do
        put :rename

        expect(response).to have_http_status(:not_found)
        expect(response_body[:success]).to eq false
      end

      it "returns error when filename same as previous name" do
        put :rename, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:success]).to eq false
      end
    end
  end

  describe "DELETE #remove_file" do
    context "when removing file successfully" do
      before(:each) do
        allow_any_instance_of(Api::V1::RemoveFileMinioService).to receive(:perform).and_return(true)
      end

      context "when file with no parent folder" do
        let(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }

        it do
          delete :remove_file, params: { unique_token: file_upload.unique_token }

          expect(response).to have_http_status(:ok)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:filename]).to eq(file_upload.name.split(".").first)
        end
      end

      context "when file with parent folder" do
        let(:parent_folder) { create(:folder) }
        let(:nested_file_upload) { create(:file_upload, user_id: user.id, folder_id: parent_folder.id) }

        it do
          delete :remove_file, params: { unique_token: nested_file_upload.unique_token }

          expect(response).to have_http_status(:ok)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:filename]).to eq(nested_file_upload.name.split(".").first)
        end
      end

      context "when file with nested parent folder" do
        let(:parent_folder) { create(:folder) }
        let(:nested_folder) { create(:folder, parent_folder_id: parent_folder.id) }
        let(:nested_file_upload) { create(:file_upload, user_id: user.id, folder_id: nested_folder.id) }

        it do
          delete :remove_file, params: { unique_token: nested_file_upload.unique_token }

          expect(response).to have_http_status(:ok)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:filename]).to eq(nested_file_upload.name.split(".").first)
        end
      end
    end

    context "when removing file fails" do
      it "returns not_found when parameter missing or file not exist" do
        delete :remove_file

        expect(response).to have_http_status(:not_found)
        expect(response_body[:success]).to eq false
      end
    end
  end
end
