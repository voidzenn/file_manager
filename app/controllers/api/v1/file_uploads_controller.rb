# frozen_string_literal: true

class Api::V1::FileUploadsController < Api::V1::BaseController
  before_action :find_file, only: %i[view_file rename remove_file]
  before_action :find_folder, only: %i[index create]

  def index
    @pagy, @file_uploads = pagy(file_list)

    return render_jsonapi [] if @file_uploads.empty?

    render_jsonapi(
      ActiveModel::Serializer::CollectionSerializer.new(
        @file_uploads,
        serializer: Api::V1::FileUploadSerializer
      )
    )
  end

  def view_file
    @file_url = Api::V1::GetFileUrlMinioService.new(
      current_user_bucket_token,
      @file.full_path
    ).perform

    render_jsonapi view_file_details
  end

  def create
    Timeout.timeout REQUEST_TIMEOUT do
      ActiveRecord::Base.transaction do
        @file_upload = Api::V1::CreateFileUploadService.new(
          current_user,
          @folder&.id,
          uploaded_filename,
          folder_file_full_path
        ).perform

        broadcast_file FILE_CREATED

        # For now we call directly the upload service
        # In the future there will be condition to check if files is large then use jobs
        Api::V1::UploadFileMinioService.new(
          current_user_bucket_token,
          folder_file_full_path,
          file_upload_params[:file_upload]
        ).perform
      end
    end

    render_jsonapi(
      Api::V1::FileUploadSerializer.new(@file_upload).serializable_hash,
      status: :created
    )
  end

  def rename
    ActiveRecord::Base.transaction do
      @old_file_name = @file_upload.name
      name_with_extension = file_rename_params[:name] + "." + @old_file_name.split(".").last

      if @old_file_name == name_with_extension
        raise Api::Error::RenameFileError.new :same_as_previous_name
      end

      folder_full_path = @file_upload.folder&.full_path || ""
      full_new_file_path = folder_full_path + name_with_extension
      @file_upload.update(
        name: name_with_extension,
        full_path: full_new_file_path
      )

      Api::V1::RenameFileJob.perform_later(
        current_user_bucket_token,
        folder_full_path + @old_file_name,
        full_new_file_path
      )

      broadcast_file FILE_RENAMED
    end

    render_jsonapi(
      Api::V1::FileUploadSerializer.new(@file_upload).serializable_hash
    )
  end

  def remove_file
    ActiveRecord::Base.transaction do
      @file_upload.destroy!

      Api::V1::RemoveFileMinioJob.perform_later(
        current_user_bucket_token,
        @file_upload.full_path
      )

      broadcast_file FILE_REMOVED
    end

    render_jsonapi Api::V1::FileUploadSerializer.new(@file).serializable_hash
  end

  private

  def view_file_params
    params.permit(:unique_token)
  end

  def file_upload_params
    params.require(:file_upload).permit(:folder_unique_token, :file_upload)
  end

  def file_rename_params
    params.require(:file_upload).permit(:folder_unique_token, :unique_token, :name)
  end

  def find_file
    @file_upload = FileUpload.find_by!(unique_token: params[:unique_token] || params[:file_upload][:unique_token])
  end

  def find_folder
    return unless params[:folder_unique_token].present? ||
      (params[:file_upload] && params[:file_upload][:folder_unique_token].present?)

    @folder = Folder.find_by(
      unique_token: params[:folder_unique_token] || (params[:file_upload] && params[:file_upload][:folder_unique_token])
    )
  end

  def file_list
    @file_list ||= FileUpload.where(index_query)
  end

  def uploaded_filename
    file_upload_params[:file_upload].original_filename
  end

  def index_query
    query = {
      user_id:   current_user.id,
      folder_id: @folder&.id
    }
  end

  def view_file_details
    {
      file_url: @file_url,
      file_name: @file_upload.name,
      file_extension: @file_upload.name&.split('.')&.last
    }
  end

  def file_upload_paths
    folder_path = is_folder_root? ? @folder.path : @folder.full_path

    {
      old_full_path: folder_path + @old_file_name,
      new_full_path: folder_path + @file.name
    }
  end

  def folder_file_full_path
    return uploaded_filename if @folder.nil?

    @folder.full_path + uploaded_filename
  end

  def is_folder_root?
    @folder.parent_folder_id.nil?
  end

  def broadcast_file type
    FileChannel.broadcast(
      current_user,
      type,
      [Api::V1::FileUploadSerializer.new(@file_upload).serializable_hash]
    )
  end
end
