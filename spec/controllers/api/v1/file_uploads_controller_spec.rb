# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FileUploadsController, type: :controller do
  include_context :authentication_grant
  include_examples :sample_file

  describe 'POST #create' do
    context 'when request successful' do
      let(:parent_path) { 'parent_path/' }
      let!(:parent_folder) { create(:folder, user_id: user.id, path: parent_path, full_path: parent_path) }
      let(:child_path) { 'child_path/' }
      let(:full_path) { parent_folder.full_path + child_path }
      let!(:folder) { create(:folder, user_id: user.id, parent_folder_id: parent_folder.id, path: child_path, full_path: full_path) }
      let(:valid_params) do
        {
          data: {
            folder_unique_token: folder.unique_token,
            file_upload: sample_file
          }
        }
      end
      let(:new_folder_path) { parent_folder.path + folder.path + 'new_path/' }

      before do
        allow_any_instance_of(Api::V1::UploadFileMinioService).to receive(:perform).and_return(true)
      end

      it do
        post :create, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq(true)
        expect(response_body[:data][:filename]).to eq(sample_file.original_filename)
        expect(response_body[:data][:full_path]).to eq(folder.full_path + sample_file.original_filename)
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
end
