# frozen_string_literal: true

class Api::V1::FileUploadsController < Api::V1::BaseController
  before_action :find_folder, only: :create

  def create
    @filename = file_upload_params[:file_upload].original_filename

    ActiveRecord::Base.transaction do
      Api::V1::CreateFileUploadService.new(
        @folder.id,
        @filename,
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
    @folder = Folder.find_by!(unique_token: file_upload_params[:folder_unique_token])
  end

  def success_response
    {
      filename: @filename,
      full_path: folder_full_path
    }
  end

  def folder_full_path
    folder_path = @folder.full_path.present? ? @folder.full_path : @folder.path

    folder_path + @filename.to_s
  end
end
