# frozen_string_literal: true

class Api::V1::FileUploadsController < Api::V1::BaseController
  def index
    find_folder if params[:unique_token].present?

    @pagy, @file_uploads = pagy(FileUpload.where(index_query))

    render_jsonapi(
      ActiveModel::Serializer::CollectionSerializer.new(
        @file_uploads,
        serializer: Api::V1::FileUploadSerializer
      )
    )
  end

  def create
    return upload_file_to_root if file_upload_params[:unique_token].blank?

    find_folder

    ActiveRecord::Base.transaction do
      Api::V1::CreateFileUploadService.new(
        @folder.id,
        uploaded_filename,
        folder_full_path
      ).perform

      # For now we call directly the upload service
      # In the future there will be condition to check if files is large then use jobs
      Api::V1::UploadFileMinioService.new(
        current_user_bucket_token,
        folder_full_path,
        file_upload_params[:file_upload]
      ).perform
    end

    render_jsonapi success_response
  end

  private

  def file_upload_params
    params.require(:data).permit(:folder_unique_token, :file_upload)
  end

  def find_folder
    @folder = Folder.find_by!(
      unique_token: params[:unique_token] || file_upload_params[:folder_unique_token]
    )
  end

  def uploaded_filename
    @uploaded_filename = file_upload_params[:file_upload].original_filename
  end

  def index_query
    query = {
      user_id: current_user_id
    }

    query.merge({ folder_id: @folder.id }) unless @folder.nil?
  end

  def upload_file_to_root
    ActiveRecord::Base.transaction do
      Api::V1::CreateFileUploadService.new(
        current_user_id,
        nil,
        uploaded_filename,
        nil
      ).perform

      Api::V1::UploadFileMinioService.new(
        current_user_bucket_token,
        nil,
        file_upload_params[:file_upload]
      ).perform
    end

    render_jsonapi success_response
  end

  def success_response
    full_path = @folder.nil? ? uploaded_filename : folder_full_path

    {
      filename: uploaded_filename,
      full_path: full_path
    }
  end

  def folder_full_path
    folder_path = @folder.full_path.present? ? @folder.full_path : @folder.path

    folder_path + uploaded_filename.to_s
  end
end
