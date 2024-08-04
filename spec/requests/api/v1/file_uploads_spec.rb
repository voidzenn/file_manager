# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "File uploads API", type: :request do
  FILE_UPLOAD_SPEC_TAG = "File Uploads"

  shared_context :common_methods do
    tags FILE_UPLOAD_SPEC_TAG
    consumes "application/json"
    produces "application/json"

    parameter name: :Authorization, in: :header, type: :string, required: true, description: "Token"
  end

  path "/api/v1/file_uploads" do
    get "File upload list" do
      include_context :common_methods

      parameter name: :folder_unique_token, in: :query, description: "Folder token"

      include_context :authentication_grant_swag

      response 200, :ok do
        context "when successfully retrieved list without parent folder" do
          let!(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
          let(:folder_unique_token) {}

          example "application/json", :without_parent_folder, {
            success: true,
            data: [
              {
                id: 1,
                folder_id: nil,
                unique_token: "db0b7d03f6db5bf17282",
                full_path: "test.doc",
                filename: "test",
                file_extension: "doc",
                created_at: "2024-08-04T12:21:39.395Z"
              }
            ],
            meta: {
              prev_url: "/api/v1/file_uploads?unique_token=&page=",
              next_url: "/api/v1/file_uploads?unique_token=&page=",
              count: 1,
              page: 1,
              last_url: "/api/v1/file_uploads?unique_token=&page=1",
              page_url: "/api/v1/file_uploads?unique_token=&page=1"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:data][0][:id]).to eq(file_upload.id)
            expect(response_body[:data][0][:folder_id]).to eq(nil)
            expect(response_body[:data][0][:unique_token]).to eq(file_upload.unique_token)
            expect(response_body[:data][0][:full_path]).to eq(file_upload.full_path)
            expect(response_body[:data][0][:filename]).to eq(file_upload.name.split(".").first)
          end
        end

        context "when successfully retrieved list with parent folder" do
          let!(:parent_folder) { create(:folder, path: "test/", full_path: "test/", user_id: user.id) }
          let!(:file_upload) do
            file_upload = create(:file_upload, user_id: user.id, folder_id: parent_folder.id) 
            file_upload.update(full_path: parent_folder.path + file_upload.name)
            file_upload
          end
          let(:folder_unique_token) { parent_folder.unique_token }

          example "application/json", :with_parent_folder, {
            success: true,
            data: [
              {
                id: 2,
                folder_id: 1,
                unique_token: "f40c95cbff36b81e66d8",
                full_path: "test/test.doc",
                filename: "test",
                file_extension: "doc",
                created_at: "2024-08-04T12:36:36.897Z"
              }
            ],
            meta: {
              prev_url: "/api/v1/file_uploads?folder_unique_token=c86957b381e5f668217d&page=",
              next_url: "/api/v1/file_uploads?folder_unique_token=c86957b381e5f668217d&page=",
              count: 1,
              page: 1,
              last_url: "/api/v1/file_uploads?folder_unique_token=c86957b381e5f668217d&page=1",
              page_url: "/api/v1/file_uploads?folder_unique_token=c86957b381e5f668217d&page=1"
            }
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:data][0][:id]).to eq(file_upload.id)
            expect(response_body[:data][0][:folder_id]).to eq(parent_folder.id)
            expect(response_body[:data][0][:unique_token]).to eq(file_upload.unique_token)
            expect(response_body[:data][0][:full_path]).to eq(file_upload.full_path)
            expect(response_body[:data][0][:filename]).to eq(file_upload.name.split(".").first)
          end
        end
      end
    end

    post "Create file upload" do
      tags FILE_UPLOAD_SPEC_TAG
      consumes "multipart/form-data"
      produces "application/json"

      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Token"
      parameter name: :"file_upload[file]", in: :formData, required: true, type: :file, description: "File to upload"
      parameter name: :"file_upload[folder_unique_token]", in: :formData, type: :string, description: "Folder token"

      include_context :authentication_grant_swag
      include_examples :sample_file

      response 201, :created do
        let(:parent_path) { 'parent_path/' }
        let!(:parent_folder) { create(:folder, user_id: user.id, path: parent_path, full_path: parent_path) }
        let(:child_path) { 'child_path/' }
        let(:full_path) { parent_folder.full_path + child_path }
        let!(:folder) { create(:folder, user_id: user.id, parent_folder_id: parent_folder.id, path: child_path, full_path: full_path) }
        let(:nested_path) { "new_path/" }
        let(:filename_without_extension) { sample_file.original_filename }

        before do
          allow_any_instance_of(Api::V1::UploadFileMinioService).to receive(:perform).and_return(true)
        end

        context "when successfully creates file to root folder" do
          let(:"file_upload[file]") { sample_file }
          let(:"file_upload[folder_unique_token]") {}

          example "application/json", :root_folder, {
            success: true,
            data: {
              id: 3,
              folder_id: nil,
              unique_token: "42bb75b8524afb4e50e0",
              full_path: "sample.pdf",
              filename: "sample",
              file_extension: "pdf",
              created_at: "2024-08-04T13:23:19.460Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response_body[:success]).to eq(true)
            expect(response_body[:data][:full_path]).to eq(filename_without_extension)
          end
        end

        context "when successfully creates file to nested folder" do
          let(:"file_upload[file]") { sample_file }
          let(:"file_upload[folder_unique_token]") { folder.unique_token }

          example "application/json", :nested_folder, {
            success: true,
            data: {
              id: 4,
              folder_id: 5,
              unique_token: "c3deb6e7f5491119a19d",
              full_path: "parent_path/child_path/sample.pdf",
              filename: "sample",
              file_extension: "pdf",
              created_at: "2024-08-04T14:27:54.647Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response_body[:success]).to eq(true)
            expect(response_body[:data][:full_path]).to eq(folder.full_path + filename_without_extension)
          end
        end

        context "when successfully creates file to nested nested folder" do
          let(:new_folder_path) { parent_folder.path + folder.path + 'new_path/' }
          let(:filename_without_extension) { sample_file.original_filename }
          let!(:nested_folder) { create(:folder, user_id: user.id, parent_folder_id: folder.id, path: nested_path, full_path: folder.full_path + nested_path) }
          let(:"file_upload[file]") { sample_file }
          let(:"file_upload[folder_unique_token]") { nested_folder.unique_token }

          example "application/json", :nested_nested_folder, {
            success: true,
            data: {
              id: 5,
              folder_id: 8,
              unique_token: "58d422d940e9cacbf245",
              full_path: "parent_path/child_path/new_path/sample.pdf",
              filename: "sample",
              file_extension: "pdf",
              created_at: "2024-08-04T14:29:50.280Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response_body[:success]).to eq(true)
            expect(response_body[:data][:full_path]).to eq(nested_folder.full_path + filename_without_extension)
          end
        end
      end

      response 400, :bad_request do
        context "when parameter missing" do
          let(:"file_upload[file]") {}
          let(:"file_upload[folder_unique_token]") {}

          example "application/json", :nested_nested_folder, {
            success: false,
            error: "Parameter missing"
          }

          run_test! do
            expect(response).to have_http_status(:bad_request)
            expect(response_body[:success]).to eq(false)
            expect(response_body[:error]).to eq('Parameter missing')
          end
        end
      end

      response 401, :unauthorized do
        context "when token invalid" do
          let(:Authorization) { "invalid_token"}
          let(:"file_upload[file]") {}
          let(:"file_upload[folder_unique_token]") {}

          example "application/json", :nested_nested_folder, {
            success: false,
            error: "Invalid Token"
          }

          run_test! do
            expect(response).to have_http_status(:unauthorized)
            expect(response_body[:success]).to eq(false)
            expect(response_body[:error]).to eq('Invalid Token')
          end
        end
      end
    end
  end

  path "/api/v1/file_uploads/view_file" do
    get "View file" do
      include_context :common_methods

      parameter name: :unique_token, in: :query, required: true, description: "File upload token"

      include_context :authentication_grant_swag

      let!(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
      let(:sample_url) { "test_url" }

      response 200, :ok do
        let(:unique_token) { file_upload.unique_token }

        before do
          allow_any_instance_of(Api::V1::GetFileUrlMinioService).to receive(:perform).and_return(sample_url)
        end

        example "application/json", :without_parent_folder, {
          success: true,
          data: {
            file_url: "http://test_url/abcde",
            file_name: "test.doc",
            file_extension: "doc"
          },
          meta: {}
        }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response_body[:success]).to eq true
          expect(response_body[:data][:file_url]).to eq sample_url
        end
      end

      response 404, :not_found do
        let(:unique_token) { "invalid_token" }

        example "application/json", :without_parent_folder, {
          success: false,
          error: "Not found"
        }

        run_test! do
          expect(response).to have_http_status(:not_found)
          expect(response_body[:success]).to eq false
        end
      end
    end
  end

  path "/api/v1/file_uploads/rename" do
    put "Rename file" do
      include_context :common_methods

      parameter name: :params, in: :body, required: true, schema: {
        type: :object,
        properties: {
          file_upload: {
            type: :object,
            properties: {
              unique_token: { type: :string },
              name: { type: :string }
            },
            required: [ :unique_token, :name ]
          },
          required: [ :file_upload ]
        }
      }

      include_context :authentication_grant_swag

      response 200, :ok do
        before(:each) do
          allow_any_instance_of(Api::V1::RenameFileMinioService).to receive(:perform).and_return(true)
        end

        context "when successfully renames file without parent folder" do
          let(:path) { "parent_path/" }
          let!(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
          let(:params) do
            {
              file_upload: {
                unique_token: file_upload.unique_token,
                name: "new file"
              }
            }
          end

          example "application/json", :without_folder , {
            success: true,
            data: {
              id: 8,
              folder_id: nil,
              unique_token: "9805776d6cc3b850f9bd",
              full_path: "new file.doc",
              filename: "new file",
              file_extension: "doc",
              created_at: "2024-08-04T14:54:17.671Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:id]).to eq file_upload.id
            expect(response_body[:data][:unique_token]).to eq file_upload.unique_token
            expect(response_body[:data][:filename]).to eq params[:file_upload][:name]
            expect(response_body[:data][:full_path]).to eq(params[:file_upload][:name] + "." + file_upload.name.split(".").last)
            expect(response_body[:data][:file_extension]).to eq file_upload.name.split(".").last
          end
        end

        context "when successfully renames file with parent folder 1 deep" do
          let(:path) { "parent_path/" }
          let!(:parent_folder) { create(:folder, user_id: user.id, path: path, full_path: path) }
          let!(:file_upload) do
            file = create(:file_upload, user_id: user.id, folder_id: parent_folder.id)
            file.update(full_path:  path + file.name)
            file
          end
          let(:params) do
            {
              file_upload: {
                unique_token: file_upload.unique_token,
                name: "new file"
              }
            }
          end
          let(:full_new_path) { path + params[:file_upload][:name] + "." + file_upload.name&.split(".").last }

          example "application/json", :nested_1_deep_folder, {
            success: true,
            data: {
              id: 9,
              folder_id: 9,
              unique_token: "9f17c41e61c011092f83",
              full_path: "parent_path/new file.doc",
              filename: "new file",
              file_extension: "doc",
              created_at: "2024-08-04T14:57:25.562Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:id]).to eq file_upload.id
            expect(response_body[:data][:unique_token]).to eq file_upload.unique_token
            expect(response_body[:data][:filename]).to eq params[:file_upload][:name]
            expect(response_body[:data][:full_path]).to eq(full_new_path)
            expect(response_body[:data][:file_extension]).to eq file_upload.name.split(".").last
          end
        end

        context "when successfully renames file with parent folder 2 deep" do
          let(:parent_path) { "parent_path/" }
          let!(:parent_folder) { create(:folder, user_id: user.id, path: parent_path, full_path: parent_path) }
          let(:nested_path) { "nested_path/" }
          let!(:nested_folder) { create(:folder, user_id: user.id, path: nested_path, full_path: parent_path + nested_path, parent_folder_id: parent_folder.id) }
          let!(:file_upload) do
            file = create(:file_upload, user_id: user.id, folder_id: nested_folder.id)
            file.update(full_path:  parent_path + nested_path + file.name)
            file
          end
          let(:params) do
            {
              file_upload: {
                unique_token: file_upload.unique_token,
                name: "new file"
              }
            }
          end
          let(:full_new_path) { parent_path + nested_path + params[:file_upload][:name] + "." + file_upload.name&.split(".").last }

          example "application/json", :nested_2_deep_folder, {
            success: true,
            data: {
              id: 9,
              folder_id: 9,
              unique_token: "9f17c41e61c011092f83",
              full_path: "parent_path/new file.doc",
              filename: "new file",
              file_extension: "doc",
              created_at: "2024-08-04T14:57:25.562Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:id]).to eq file_upload.id
            expect(response_body[:data][:unique_token]).to eq file_upload.unique_token
            expect(response_body[:data][:filename]).to eq params[:file_upload][:name]
            expect(response_body[:data][:full_path]).to eq(full_new_path)
            expect(response_body[:data][:file_extension]).to eq file_upload.name.split(".").last
          end
        end
      end

      response 404, :not_found do
        let(:params) do
          {
            file_upload: {
              unique_token: "invalid_token"
            }
          }
        end

        example "application/json", :not_found, {
          success: false,
          error: "Not found"
        }

        run_test! do
          expect(response).to have_http_status(:not_found)
          expect(response_body[:success]).to eq false
        end
      end

      response 422, :unprocessable_entity do
        let(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
        let(:filename_without_extension) { file_upload.name.split(".").first }
        let(:params) do
          {
            file_upload: {
              unique_token: file_upload.unique_token,
              name: filename_without_extension
            }
          }
        end

        example "application/json", :same_as_previous_name, {
          success: false,
          error: "should not be the same as previous file name"
        }

        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body[:success]).to eq false
        end
      end
    end
  end

  path "/api/v1/file_uploads/remove_file" do
    delete "Remove file" do
      include_context :common_methods

      parameter name: :unique_token, in: :query, type: :string, required: true, description: "File upload token"

      include_context :authentication_grant_swag

      response 200, :ok do
        before(:each) do
          allow_any_instance_of(Api::V1::RemoveFileMinioService).to receive(:perform).and_return(true)
        end

        context "when successfully removes file without parent folder" do
          let(:file_upload) { create(:file_upload, user_id: user.id, folder_id: nil) }
          let(:unique_token) { file_upload.unique_token }

          example "application/json", :without_parent_folder, {
            success: true,
            data: {
              id: 12,
              folder_id: nil,
              unique_token: "f57d4c664fed9f8565c8",
              full_path: "test.doc",
              filename: "test",
              file_extension: "doc",
              created_at: "2024-08-04T15:09:23.568Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:filename]).to eq(file_upload.name.split(".").first)
          end
        end

        context "when successfully removes file with parent folder" do
          let(:parent_folder) { create(:folder) }
          let(:nested_file_upload) { create(:file_upload, user_id: user.id, folder_id: parent_folder.id) }
          let(:unique_token) { nested_file_upload.unique_token }

          example "application/json", :with_parent_folder, {
            success: true,
            data: {
              id: 13,
              folder_id: 12,
              unique_token: "54c10a7284d4264db087",
              full_path: "test.doc",
              filename: "test",
              file_extension: "doc",
              created_at: "2024-08-04T15:11:42.813Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:filename]).to eq(nested_file_upload.name.split(".").first)
          end
        end

        context "when successfully removes file with nested parent folder" do
          let(:parent_folder) { create(:folder) }
          let(:nested_folder) { create(:folder, parent_folder_id: parent_folder.id) }
          let(:nested_file_upload) { create(:file_upload, user_id: user.id, folder_id: nested_folder.id) }
          let(:unique_token) { nested_file_upload.unique_token }

          example "application/json", :with_parent_folder, {
            success: true,
            data: {
              id: 14,
              folder_id: 14,
              unique_token: "743f4875d5e78ab40d8f",
              full_path: "test.doc",
              filename: "test",
              file_extension: "doc",
              created_at: "2024-08-04T15:13:00.266Z"
            },
            meta: {}
          }

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(response_body[:success]).to eq true
            expect(response_body[:data][:filename]).to eq(nested_file_upload.name.split(".").first)
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
        end
      end
    end
  end
end
