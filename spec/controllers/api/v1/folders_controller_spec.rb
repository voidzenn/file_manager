# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FoldersController, type: :controller do
  include_context :authentication_grant

  shared_context :allow_get_current_bucket do
    before do
      allow_any_instance_of(Api::V1::GetCurrentBucketService).to receive(:perform).and_return(double(object: double(upload_file: true)))
    end
  end

  describe "GET #index" do
    context "when folder successfully retrieved" do
      let!(:parent_folder) { create(:folder, path: "test/", user_id: user.id) }
      let!(:nested_folder) { create(:folder, path: "test2/", user_id: user.id, parent_folder_id: parent_folder.id) }

      it "returns data with no parent folder" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data].first[:id]).to eq(parent_folder.id)
        expect(response_body[:data].first[:path]).to eq(parent_folder.path.chop)
      end

      it "returns data with parent folder" do
        get :index, params: { unique_token: parent_folder.unique_token }

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data].first[:id]).to eq(nested_folder.id)
        expect(response_body[:data].first[:path]).to eq(nested_folder.path.chop)
      end

      it "return empty data" do
        Folder.destroy_all
        get :index

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data]).to eq([])
      end
    end
  end

  describe "POST #create" do
    context "when created root folder successfully" do
      let(:valid_params) do
        {
          folder: {
            path: "new_path/"
          }
        }
      end

      include_context :initialize_aws_s3
      include_context :allow_get_current_bucket

      it do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq valid_params[:folder][:path].chop
        expect(response_body[:data][:full_path]).to eq valid_params[:folder][:path]
      end
    end

    context "when created nested 1 deep folder successfully" do
      let!(:parent_folder) { create(:folder, user_id: user.id) }
      let(:valid_params) do
        {
          folder: {
            parent_unique_token: parent_folder.unique_token,
            path: "new_path/"
          }
        }
      end

      include_context :initialize_aws_s3
      include_context :allow_get_current_bucket

      it do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq valid_params[:folder][:path].chop
        expect(response_body[:data][:full_path]).to eq(parent_folder.path + valid_params[:folder][:path])
      end
    end

    context "when created nested 2 deep folder successfully" do
      let(:path) { "test/" }
      let!(:parent_folder) { create(:folder, user_id: user.id, full_path: "test/") }
      let(:nested_path) { "new_path/" }
      let!(:nested_folder) { create(:folder, user_id: user.id, parent_folder_id: parent_folder.id, path: nested_path, full_path: path + nested_path) }
      let(:valid_params) do
        {
          folder: {
            parent_unique_token: nested_folder.unique_token,
            path: "new_path2/"
          }
        }
      end

      include_context :initialize_aws_s3
      include_context :allow_get_current_bucket

      it do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq valid_params[:folder][:path].chop
        expect(response_body[:data][:full_path]).to eq(parent_folder.path + nested_folder.path  + valid_params[:folder][:path])
      end
    end

    context "when create folder fails" do
      context "when parameter missing" do
        it do
          post :create, params: {}

          expect(response).to have_http_status(:bad_request)
          expect(response_body[:error]).to eq "Parameter missing"
        end
      end

      context "when path is blank" do
        let(:params) do
          { path: "" }
        end

        it do
          post :create, params: { folder: params }

          expect(response).to have_http_status(:unprocessable_entity)
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

        it 'should return an error message' do
          post :create, params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body[:success]).to eq false
          expect(response_body[:error][0][:path]).to eq I18n.t("errors.models.folder.format.message")
        end
      end
    end
  end

  describe 'PUT #rename' do
    include_context :initialize_aws_s3

    context 'when renaming root folder successfully' do
      let!(:parent_folder) { create(:folder, user_id: user.id) }
      let!(:folder) { create(:folder, path: 'new path/', parent_folder_id: parent_folder.id, user_id: user.id) }
      let(:valid_params) do
        {
          folder: {
            unique_token: folder.unique_token,
            path: 'new folder path/'
          }
        }
      end

      before do
        allow_any_instance_of(Api::V1::RenameFolderMinioService).to receive(:perform).with(any_args).and_return(true)
        put :rename, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq(valid_params[:folder][:path].chop)
        expect(response_body[:data][:full_path]).to eq(parent_folder.path + valid_params[:folder][:path])
      end
    end

    context 'when renaming nested 1 deep folder successfully' do
      let(:path) { "test/" }
      let!(:parent_folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
      let(:nested_path) { "new_path/" }
      let!(:nested_folder) { create(:folder, path: nested_path, full_path: path + nested_path, parent_folder_id: parent_folder.id, user_id: user.id) }
      let(:valid_params) do
        {
          folder: {
            unique_token: nested_folder.unique_token,
            path: "new folder path/"
          }
        }
      end

      before do
        put :rename, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq(valid_params[:folder][:path].chop)
        expect(response_body[:data][:full_path]).to eq(parent_folder.full_path + valid_params[:folder][:path])
      end
    end

    context 'when renaming nested 2 deep folder successfully' do
      let(:path) { "test/" }
      let!(:parent_folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
      let(:nested_path) { "new_path/" }
      let!(:nested_folder) { create(:folder, user_id: user.id, path: nested_path, full_path: path + nested_path, parent_folder_id: parent_folder.id) }
      let(:nested_nested_path) { "new_path2/" }
      let!(:nested_nested_folder) { create(:folder, user_id: user.id, path: nested_nested_path, full_path: path + nested_path + nested_nested_path, parent_folder_id: nested_folder.id) }
      let(:valid_params) do
        {
          folder: {
            unique_token: nested_nested_folder.unique_token,
            path: "new folder path/"
          }
        }
      end

      before do
        put :rename, params: valid_params
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:path]).to eq(valid_params[:folder][:path].chop)
        expect(response_body[:data][:full_path]).to eq(nested_folder.full_path + valid_params[:folder][:path])
      end
    end

    context 'when renaming root folder fails' do
      it "returns not_found when parameter missing or folder not exist" do
        put :rename, params: {}
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE #remove_folder" do
    context "when removing folder successfully" do
      let!(:folder) { create(:folder, user_id: user.id) }
      let(:nested_folder) { create(:folder, user_id: user.id, parent_folder_id: folder.id) }
      let(:valid_params) do
        {
          unique_token: folder.unique_token
        }
      end

      it "removes root folder" do
        delete :remove_folder, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:id]).to eq folder.id
      end

      it "removes nested folder" do
        new_params = valid_params
        new_params[:unique_token] = nested_folder.unique_token
        delete :remove_folder, params: new_params

        expect(response).to have_http_status(:ok)
        expect(response_body[:success]).to eq true
        expect(response_body[:data][:id]).to eq nested_folder.id
      end
    end

    context "when removing folder fails" do
      it "returns not_found when parameter missing or folder not exist" do
        delete :remove_folder, params: {}

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
