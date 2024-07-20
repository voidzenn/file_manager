# frozen_string_literal: true

class Api::V1::FileUploadsController < Api::V1::BaseController
  before_action :find_file, only: %i[view_file rename remove_file]
  before_action :find_folder, only: %i[index]

  def index
    @pagy, @file_uploads = pagy(FileUpload.where(index_query))

    return render_jsonapi [] if @file_uploads.empty?

    render_jsonapi(
      ActiveModel::Serializer::CollectionSerializer.new(
        @file_uploads,
        serializer: Api::V1::FileUploadSerializer
      )
    )
  end

  def view_file
    full_path = @file.full_path.nil? ? @file.name : @file.full_path

    @file_url = Api::V1::GetFileUrlMinioService.new(
      current_user_bucket_token,
      full_path
    ).perform

    render_jsonapi view_file_details
  end

  def create
    return upload_file_to_root if file_upload_params[:folder_unique_token].blank?

    find_folder

    Timeout.timeout REQUEST_TIMEOUT do
      ActiveRecord::Base.transaction do
        Api::V1::CreateFileUploadService.new(
          current_user,
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
    end

    render_jsonapi success_response
  end

  def rename
    return rename_root_file if @file.folder_id.nil?

    @folder = @file.folder

    ActiveRecord::Base.transaction do
      @old_file_name = @file.name
      name_with_extension = file_rename_params[:new_name] + "." + @old_file_name.split(".").last

      if @old_file_name == name_with_extension
        raise Api::Error::RenameFileError.new :same_as_previous_name
      end

      @full_path = @folder.full_path.present? ? @folder.full_path : @folder.path
      @file.update(
        name: name_with_extension,
        full_path: @full_path + name_with_extension
      )

      Api::V1::RenameFileJob.perform_later(
        current_user_bucket_token,
        @full_path + @old_file_name,
        @full_path + name_with_extension
      )

      broadcast_rename
    end

    render_jsonapi Api::V1::FileUploadSerializer.new(@file).serializable_hash
  end

  def remove_file
    ActiveRecord::Base.transaction do
      @file.destroy!

      file_path = @file.full_path.nil? ? @file.name : @file.full_path

      Api::V1::RemoveFileMinioJob.perform_later(
        current_user_bucket_token,
        file_path
      )

      FileChannel.broadcast(
        current_user,
        FILE_REMOVED,
        [Api::V1::FileUploadSerializer.new(@file).serializable_hash]
      )
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
    params.require(:file_upload).permit(:folder_unique_token, :unique_token, :new_name)
  end

  def find_file
    @file = FileUpload.find_by!(unique_token: params[:unique_token] || params[:file_upload][:unique_token])
  end

  def find_folder
    return unless params[:folder_unique_token].present? ||
      (params[:file_upload] && params[:file_upload][:folder_unique_token].present?)

    @folder = Folder.find_by(
      unique_token: params[:folder_unique_token] || (params[:file_upload] && params[:file_upload][:folder_unique_token])
    )
  end

  def uploaded_filename
    @uploaded_filename = file_upload_params[:file_upload].original_filename
  end

  def index_query
    query = {
      user_id:   current_user.id
    }

    return query if @folder.nil?

    query.merge({ folder_id: @folder.id })
  end

  def view_file_details
    {
      file_url: @file_url,
      file_name: @file.name,
      file_extension: @file.name&.split('.')&.last
    }
  end

  def upload_file_to_root
    Timeout.timeout REQUEST_TIMEOUT do
      ActiveRecord::Base.transaction do
        Api::V1::CreateFileUploadService.new(
          current_user,
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
    end

    render_jsonapi success_response
  end

  def rename_root_file
    old_file_name = @file.name
    name_with_extension = file_rename_params[:new_name] + "." + old_file_name.split(".").last

    if old_file_name == name_with_extension
      raise Api::Error::RenameFileError.new :same_as_previous_name
    end

    ActiveRecord::Base.transaction do
      @file.update!(name: name_with_extension)

      Api::V1::RenameRootFileJob.perform_later(
        current_user_bucket_token,
        old_file_name,
        name_with_extension
      )

      broadcast_rename
    end

    render_jsonapi Api::V1::FileUploadSerializer.new(@file).serializable_hash
  end

  def file_upload_paths
    folder_path = is_folder_root? ? @folder.path : @folder.full_path

    {
      old_full_path: folder_path + @old_file_name,
      new_full_path: folder_path + @file.name
    }
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

  def is_folder_root?
    @folder.parent_folder_id.nil?
  end

  def broadcast_rename
    FileChannel.broadcast(
      current_user,
      FILE_RENAMED,
      [Api::V1::FileUploadSerializer.new(@file).serializable_hash]
    )
  end
end
