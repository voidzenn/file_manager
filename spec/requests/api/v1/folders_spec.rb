# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Folders API", type: :request do
  FOLDER_SPEC_TAG = "Folders"

  shared_context :common_methods do
    tags FOLDER_SPEC_TAG
    consumes "application/json"
    produces "application/json"

    parameter name: :Authorization, in: :header, type: :string, required: true, description: "Token"
  end

  shared_context :allow_get_current_bucket do
    before do
      allow_any_instance_of(Api::V1::GetCurrentBucketService).to receive(:perform).and_return(double(object: double(upload_file: true)))
    end
  end

  path "/api/v1/folders" do
    get "Folder list" do
      include_context :common_methods

      parameter name: :unique_token, in: :query, type: :string, description: "Parent folder unique_token"

      include_context :authentication_grant_swag

      response 200, :ok do
        context "when retrieved folders list successfully without parent folder" do
          let!(:parent_folder) { create(:folder, path: "test/", user_id: user.id) }
          let(:unique_token) {}

          example "application/json", :without_parent_folder, {
            success: true,
            data: [
              {
                id: 1,
                unique_token: "abcde123",
                path: "test",
                full_path: nil,
                parent_folder_id: nil,
                created_at: "2024-08-03T11:44:59.257Z"
              }
            ],
            meta: {
              prev_url: "/api/v1/folders?unique_token=&page=",
              next_url: "/api/v1/folders?unique_token=&page=",
              count: 1,
              page: 1,
              last_url: "/api/v1/folders?unique_token=&page=1",
              page_url: "/api/v1/folders?unique_token=&page=1"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data].first[:id]).to eq(parent_folder.id)
            expect(response_body[:data].first[:path]).to eq(parent_folder.path.chop)
          end
        end

        context "when retrieved folders list successfully with parent folder" do
          let!(:parent_folder) { create(:folder, path: "test/", user_id: user.id) }
          let!(:nested_folder) { create(:folder, path: "test2/", user_id: user.id, parent_folder_id: parent_folder.id) }
          let(:unique_token) { parent_folder.unique_token }

          example "application/json", :with_parent_folder, {
            success: true,
            data: [
              {
                id: 3,
                unique_token: "0a6e26022f16176bd012",
                path: "test2",
                full_path: nil,
                parent_folder_id: 2,
                created_at: "2024-08-03T11:47:48.133Z"
              }
            ],
            meta: {
              prev_url: "/api/v1/folders?unique_token=bdf727e59c6c0415bddd&page=",
              next_url: "/api/v1/folders?unique_token=bdf727e59c6c0415bddd&page=",
              count: 1,
              page: 1,
              last_url: "/api/v1/folders?unique_token=bdf727e59c6c0415bddd&page=1",
              page_url: "/api/v1/folders?unique_token=bdf727e59c6c0415bddd&page=1"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data].first[:id]).to eq(nested_folder.id)
            expect(response_body[:data].first[:path]).to eq(nested_folder.path.chop)
          end
        end

        context "when retrieved folders list successfully with empty data" do
          let(:unique_token) {}

          example "application/json", :with_empty_data, {
            success: true,
            data: [],
            meta: {
              prev_url: "/api/v1/folders?unique_token=&page=",
              next_url: "/api/v1/folders?unique_token=&page=",
              count: 0,
              page: 1,
              last_url: "/api/v1/folders?unique_token=&page=1",
              page_url: "/api/v1/folders?unique_token=&page=1"
            }
          }

          run_test! do
            Folder.destroy_all

            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data]).to eq([])
          end
        end
      end
    end

    post "Create folder" do
      include_context :common_methods

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          folder: {
            type: :object,
            properties: {
              path: { type: :string }
            },
            required: [ :path ]
          },
        required: [ :folder ]
        }
      }

      include_context :initialize_aws_s3
      include_context :allow_get_current_bucket
      include_context :authentication_grant_swag

      response 201, :created do
        before(:each) do
          allow_any_instance_of(Api::V1::CreateFolderMinioService).to receive(:perform).and_return(true)
        end

        context "when successfully creates root folder" do
          let(:params) do
            {
              folder: {
                path: "new_path/"
              }
            }
          end

          example "application/json", :root_folder, {
            success: true,
            data: {
              id: 4,
              unique_token: "0555351cf5872ff98a4b",
              path: "new_path",
              full_path: "new_path/",
              parent_folder_id: nil,
              created_at: "2024-08-03T12:10:22.293Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:path]).to eq params[:folder][:path].chop
            expect(response_body[:data][:full_path]).to eq params[:folder][:path]
          end
        end

        context "when successfully creates nested 1 deep folder" do
          let!(:parent_folder) { create(:folder, user_id: user.id) }
          let(:params) do
            {
              folder: {
                parent_unique_token: parent_folder.unique_token,
                path: "new_path/"
              }
            }
          end

          example "application/json", :nested_1_deep_folder, {
            success: true,
            data: {
              id: 6,
              unique_token: "14322b05b833f09a45df",
              path: "new_path",
              full_path: "1/new_path/",
              parent_folder_id: 5,
              created_at: "2024-08-03T12:33:15.434Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:path]).to eq params[:folder][:path].chop
            expect(response_body[:data][:full_path]).to eq(parent_folder.path + params[:folder][:path])
          end
        end

        context "when successfully creates nested 2 deep folder" do
          let(:path) { "test/" }
          let!(:parent_folder) { create(:folder, user_id: user.id, full_path: "test/") }
          let(:nested_path) { "new_path/" }
          let!(:nested_folder) { create(:folder, user_id: user.id, parent_folder_id: parent_folder.id, path: nested_path, full_path: path + nested_path) }
          let(:params) do
            {
              folder: {
                parent_unique_token: nested_folder.unique_token,
                path: "new_path2/"
              }
            }
          end

          example "application/json", :nested_2_deep_folder, {
            success: true,
            data: {
              id: 9,
              unique_token: "997f81e9fa9b24b0c8e2",
              path: "new_path2",
              full_path: "2/new_path/new_path2/",
              parent_folder_id: 8,
              created_at: "2024-08-03T12:37:47.271Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:path]).to eq params[:folder][:path].chop
            expect(response_body[:data][:full_path]).to eq(parent_folder.path + nested_folder.path  + params[:folder][:path])
          end
        end
      end

      response 400, :bad_request do
        context "when parameter missing" do
          let(:params) {}

          example "application/json", :parameter_missing, {
            success: false,
            error: "Parameter missing"
          }

          run_test! do
            expect(response).to have_http_status(:bad_request)
            expect(response_body[:error]).to eq "Parameter missing"
          end
        end
      end

      response 422, :unprocessable_entity do
        context "when path is blank" do
          let(:params) do
            { path: "" }
          end

          example "application/json", :path_blank, {
            success: false,
            error: [ { path: "cannot be blank" } ]
          }

          run_test! do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response_body[:success]).to eq false
            expect(response_body[:error][0][:path]).to eq "cannot be blank"
          end
        end

        context "when path name is invalid" do
          let(:params) do
            {
              folder: {
                path: "/new_path/"
              }
            }
          end

          example "application/json", :invalid_path, {
            success: false,
            error: [ { path: "should only contain alphanumeric characters, spaces, underscores and hyphens for the name, should end with a forward slash." } ]
          }

          run_test! do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response_body[:success]).to eq false
            expect(response_body[:error][0][:path]).to eq I18n.t("errors.models.folder.format.message")
          end
        end
      end
    end
  end

  path "/api/v1/folders/rename" do
    put "Rename folder" do
      include_context :common_methods

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          folder: {
            type: :object,
            properties: {
              unique_token: { type: :string },
              path: { type: :string }
            },
            required: [ :unique_token, :path ]
          },
        required: [ :folder ]
        }
      }

      include_context :initialize_aws_s3
      include_context :allow_get_current_bucket
      include_context :authentication_grant_swag

      response 200, :ok do
        before(:each) do
          allow_any_instance_of(Api::V1::RenameFolderMinioService).to receive(:perform).with(any_args).and_return(true)
        end

        context "when successfully renames root folder" do
          let!(:parent_folder) { create(:folder, user_id: user.id) }
          let!(:folder) { create(:folder, path: 'new path/', parent_folder_id: parent_folder.id, user_id: user.id) }
          let(:params) do
            {
              folder: {
                unique_token: folder.unique_token,
                path: 'new folder path/'
              }
            }
          end

          example "application/json", :root_folder, {
            success: true,
            data: {
              id: 11,
              unique_token: "6500b0d42a3679f37850",
              path: "new folder path",
              full_path: "3/new folder path/",
              parent_folder_id: 10,
              created_at: "2024-08-03T12:53:39.929Z"
            },
            meta: {
              message: "Successfully renamed folder"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:path]).to eq(params[:folder][:path].chop)
            expect(response_body[:data][:full_path]).to eq(parent_folder.path + params[:folder][:path])
          end
        end

        context 'when successfully renames nested 1 deep folder' do
          let(:path) { "test/" }
          let!(:parent_folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
          let(:nested_path) { "new_path/" }
          let!(:nested_folder) { create(:folder, path: nested_path, full_path: path + nested_path, parent_folder_id: parent_folder.id, user_id: user.id) }
          let(:params) do
            {
              folder: {
                unique_token: nested_folder.unique_token,
                path: "new folder path/"
              }
            }
          end

          example "application/json", :nested_1_deep_folder, {
            success: true,
            data: {
              id: 13,
              unique_token: "a6f39b8a07a6af8925ce",
              path: "new folder path",
              full_path: "test/new folder path/",
              parent_folder_id: 12,
              created_at: "2024-08-03T12:57:42.542Z"
            },
            meta: {
              message: "Successfully renamed folder"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:path]).to eq(params[:folder][:path].chop)
            expect(response_body[:data][:full_path]).to eq(parent_folder.full_path + params[:folder][:path])
          end
        end

        context 'when successfully renames nested 2 deep folder' do
          let(:path) { "test/" }
          let!(:parent_folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
          let(:nested_path) { "new_path/" }
          let!(:nested_folder) { create(:folder, user_id: user.id, path: nested_path, full_path: path + nested_path, parent_folder_id: parent_folder.id) }
          let(:nested_nested_path) { "new_path2/" }
          let!(:nested_nested_folder) { create(:folder, user_id: user.id, path: nested_nested_path, full_path: path + nested_path + nested_nested_path, parent_folder_id: nested_folder.id) }
          let(:params) do
            {
              folder: {
                unique_token: nested_nested_folder.unique_token,
                path: "new folder path/"
              }
            }
          end

          example "application/json", :nested_2_deep_folder, {
            success: true,
            data: {
              id: 16,
              unique_token: "d2869c929aabfdbdd9ee",
              path: "new folder path",
              full_path: "test/new_path/new folder path/",
              parent_folder_id: 15,
              created_at: "2024-08-03T12:59:43.376Z"
            },
            meta: {
              message: "Successfully renamed folder"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:path]).to eq(params[:folder][:path].chop)
            expect(response_body[:data][:full_path]).to eq(nested_folder.full_path + params[:folder][:path])
          end
        end
      end

      response 404, :not_found do
        context "when parameter missing or folder not found" do
          let(:path) { "test/" }
          let!(:folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
          let(:params) {}

          example "application/json", :not_found, {
            success: false,
            error: "Not found"
          }

          run_test! do
            expect(response).to have_http_status(:not_found)
            expect(response_body[:success]).to eq false
            expect(response_body[:error]).to eq "Not found"
          end
        end
      end

      response 422, :not_found do
        context "when parameter missing or folder not found" do
          let(:path) { "test/" }
          let!(:folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
          let(:params) do
            {
              folder: {
                unique_token: folder.unique_token,
                path: path
              }
            }
          end

          example "application/json", :same_as_previous_path, {
            success: false,
            error: "should not be the same as previous path name"
          }

          run_test! do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response_body[:success]).to eq false
            expect(response_body[:error]).to eq "should not be the same as previous path name"
          end
        end
      end
    end
  end

  path "/api/v1/folders/remove_folder" do
    delete "Remove folder" do
      include_context :common_methods

      parameter name: :unique_token, in: :query, type: :string, required: true, description: "Folder token"

      include_context :initialize_aws_s3
      include_context :allow_get_current_bucket
      include_context :authentication_grant_swag

      response 200, :ok do
        let!(:folder) { create(:folder, user_id: user.id) }
        let(:unique_token) { folder.unique_token }

        before do
          allow_any_instance_of(Api::V1::RemoveFolderMinioService).to receive(:perform).with(any_args).and_return(true)
        end

        context "when successfully removes root folder" do
          example "application/json", :root_folder, {
            success: true,
            data: {
              id: 19,
              unique_token: "b4fd13b4e82dc4217273",
              path: "4",
              full_path: nil,
              parent_folder_id: nil,
              created_at: "2024-08-03T13:25:41.226Z"
            },
            meta: {
              message: "Successfully deleted folder"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:id]).to eq folder.id
            expect(response_body[:data][:unique_token]).to eq unique_token
            expect(response_body[:meta][:message]).to eq "Successfully deleted folder"
          end
        end

        context "when successfully removes nested folder" do
          let(:nested_folder) { create(:folder, user_id: user.id, parent_folder_id: folder.id) }
          let(:unique_token) { nested_folder.unique_token }

          example "application/json", :nested_folder, {
            success: true,
            data: {
              id: 21,
              unique_token: "fa43d2db8aa8d124bfff",
              path: "6",
              full_path: nil,
              parent_folder_id: 20,
              created_at: "2024-08-03T13:30:01.087Z"
            },
            meta: {
              message: "Successfully deleted folder"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:id]).to eq nested_folder.id
            expect(response_body[:data][:unique_token]).to eq unique_token
            expect(response_body[:meta][:message]).to eq "Successfully deleted folder"
          end
        end
      end

      response 404, :not_found do
        let(:unique_token) { "invalid_token" }

        example "application/json", :not_found, {
          success: false,
          error: "Not found"
        }

        run_test! do
          expect(response).to have_http_status(:not_found)
          expect(response_body[:success]).to eq false
          expect(response_body[:error]).to eq "Not found"
        end
      end
    end
  end
end
