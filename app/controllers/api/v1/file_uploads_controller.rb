# frozen_string_literal: true

class Api::V1::FileUploadsController < Api::V1::BaseController
  before_action :find_folder, only: :create

  def create
    @filename = file_upload_params[:file_upload].original_filename
    @full_path = @folder.full_path.to_s + @filename.to_s

    Api::V1::UploadFileJob.perform_now(
      bucket_token: current_user_bucket_token,
      folder_object: @folder,
      file: file_upload_params[:file_upload],
      filename: @filename,
      full_file_path: @full_path
    )

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
      full_path: @full_path
    }
  end
end
