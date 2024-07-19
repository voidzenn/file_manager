# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :find_folder, only: [:rename, :remove_folder]

  def index
    find_current_folder if params[:unique_token].present?

    @pagy, @folders = pagy(Folder.where(index_query).order_by_date)

    render_jsonapi(
      ActiveModel::Serializer::CollectionSerializer.new(
        @folders,
        serializer: Api::V1::FolderSerializer
      ),
      meta: folder_meta
    )
  end

  def create
    ActiveRecord::Base.transaction do
      @folder = Api::V1::CreateFolderService.new(
        current_user: current_user,
        parent_unique_token: folder_params[:parent_unique_token],
        path: folder_params[:path],
      ).perform

      broadcast_folder_created

      Api::V1::CreateFolderJob.perform_later(
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
    return rename_root_folder if folder_update_params[:parent_unique_token].blank?

    find_parent_folder

    ActiveRecord::Base.transaction do
      load_full_path

      @folder.update!(path: folder_update_params[:new_path])

      Api::V1::RenameFolderJob.perform_later(
        current_user_bucket_token,
        @full_path
      )
    end

    render_jsonapi success_update_response
  end

  def remove_folder
    ActiveRecord::Base.transaction do
      @folder.destroy!

      folder_path = @folder.full_path.nil? ? @folder.path : @folder.full_path

      Api::V1::RemoveFolderMinioJob.perform_later(
        current_user_bucket_token,
        folder_path
      )

      FolderChannel.broadcast(
        current_user,
        FOLDER_REMOVED,
        [Api::V1::FolderSerializer.new(@folder).serializable_hash]
      )
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
    params.require(:folder).permit(:unique_token, :new_path, :parent_unique_token)
  end

  def folder_params_without_parent_unique_token
    folder_params.merge(user_id: current_user.id, parent_folder_id: @parent_folder.id)
                 .except(:parent_unique_token)
  end

  def find_folder
    @folder = Folder.find_by!(user_id: current_user.id,
                              unique_token: params[:unique_token] || params[:folder][:unique_token])
  end

  def find_current_folder
    @folder = Folder.find_by!(user_id: current_user.id,
                              unique_token: params[:unique_token])
  end

  def find_parent_folder
    return if params[:folder][:parent_unique_token].nil?

    @parent_folder = Folder.find_by!(
      unique_token: params[:folder][:parent_unique_token]
    )
  end

  def index_query
    {
      user_id: current_user.id,
      parent_folder_id: @folder&.id || nil
    }
  end

  def folder_meta
    meta = pagy_metadata(@pagy)

    return meta if @folder.nil?

    meta.merge({
      full_path: @folder.full_path
    })
  end

  def load_full_path
    @full_path = Api::V1::FolderTraversalService.new(
      user_id: current_user.id,
      parent_folder_object: @parent_folder,
      new_prefix: folder_params_without_parent_unique_token[:path]
    ).perform

    folder_params_without_parent_unique_token.merge!(full_path: @full_path[:new_full_path])
  end

  def broadcast_folder_created
    FolderChannel.broadcast(
      current_user,
      FOLDER_CREATED,
      [Api::V1::FolderSerializer.new(@folder).serializable_hash]
    )
  end

  def rename_root_folder
    ActiveRecord::Base.transaction do
      old_path_name = @folder.path

      @folder.update!(path: folder_update_params[:new_path])

      Api::V1::RenameRootFolderJob.perform_later(
        bucket_token: current_user_bucket_token,
        path: old_path_name,
        new_path: folder_update_params[:new_path]
      )

      FolderChannel.broadcast(
        current_user,
        FOLDER_RENAMED,
        [Api::V1::FolderSerializer.new(@folder).serializable_hash]
      )
    end

    render_jsonapi success_update_response
  end

  def success_update_response
    {
      new_path: @folder.path
    }
  end
end
