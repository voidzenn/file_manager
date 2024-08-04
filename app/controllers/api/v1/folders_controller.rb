# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :find_folder, only: %i[index rename remove_folder]

  def index
    @pagy, @folders = pagy(folder_list)

    render_jsonapi(
      ActiveModel::Serializer::CollectionSerializer.new(
        @folders,
        serializer: Api::V1::FolderSerializer
      ),
      meta: pagy_metadata(@pagy)
    )
  end

  def create
    ActiveRecord::Base.transaction do
      @folder = Api::V1::CreateFolderService.new(
        current_user: current_user,
        parent_unique_token: folder_params[:parent_unique_token],
        path: folder_params[:path],
      ).perform

      broadcast_folder FOLDER_CREATED

      CreateFolderJob.perform_later(
        current_user_bucket_token,
        @folder.full_path
      )
    end

    render_jsonapi(
      Api::V1::FolderSerializer.new(@folder).serializable_hash,
      status: :created
    )
  end

  def rename
    raise ActiveRecord::RecordNotFound if @folder.nil?

    @old_full_path = @folder.full_path

    if @old_full_path == folder_update_params[:path]
      raise Api::Error::RenameFolderError.new :same_as_previous_name
    end

    ActiveRecord::Base.transaction do
      @folder = Api::V1::RenameFolderService.new(
        current_user: current_user,
        unique_token: folder_update_params[:unique_token],
        new_path: folder_update_params[:path]
      ).perform

      RenameFolderJob.perform_later(
        current_user_bucket_token,
        old_new_full_paths
      )

      broadcast_folder FOLDER_RENAMED
    end

    render_jsonapi(
      Api::V1::FolderSerializer.new(@folder).serializable_hash,
      meta: {
        message: "Successfully renamed folder"
      }
    )
  end

  def remove_folder
    raise ActiveRecord::RecordNotFound if @folder.nil?

    ActiveRecord::Base.transaction do
      @folder.destroy!

      RemoveFolderMinioJob.perform_later(
        current_user_bucket_token,
        @folder.full_path
      )

      broadcast_folder FOLDER_REMOVED
    end

    render_jsonapi(
      Api::V1::FolderSerializer.new(@folder).serializable_hash,
      meta: { message: "Successfully deleted folder" }
    )
  end

  private

  def folder_params
    params.require(:folder).permit(:path, :parent_unique_token)
  end

  def folder_update_params
    params.require(:folder).permit(:unique_token, :path, :parent_unique_token)
  end

  def find_folder
    return unless params[:unique_token].present? ||
      (params[:folder] && params[:folder][:unique_token].present?)

    @folder = Folder.find_by!(find_folder_query)
  end

  def find_folder_query
    {
      user_id: current_user.id,
      unique_token: params[:unique_token] || params[:folder][:unique_token]
    }
  end

  def folder_list
    @folder_list ||= Folder.where(index_query).order_by_date
  end

  def index_query
    {
      user_id: current_user.id,
      parent_folder_id: @folder&.id
    }
  end

  def old_new_full_paths
    {
      old_full_path: @old_full_path,
      new_full_path: @folder.full_path
    }
  end

  def broadcast_folder type
    FolderChannel.broadcast(
      current_user,
      type,
      [Api::V1::FolderSerializer.new(@folder).serializable_hash]
    )
  end
end
