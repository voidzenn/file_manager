# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :find_folder, only: :rename

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
    return create_root_folder if folder_params[:parent_unique_token].blank?

    find_parent_folder

    ActiveRecord::Base.transaction do
      load_full_path

      Api::V1::CreateFolderService.new(
        folder_params_without_parent_unique_token.merge(full_path: @full_path[:old_full_path])
      ).perform

      Api::V1::CreateFolderJob.perform_later(
        current_user_bucket_token,
        @full_path
      )
    end

    render_jsonapi success_response, status: :created
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

  private

  def folder_params
    params.require(:folder).permit(:path, :parent_unique_token)
  end

  def folder_update_params
    params.require(:folder).permit(:unique_token, :new_path, :parent_unique_token)
  end

  def folder_params_without_parent_unique_token
    folder_params.merge(user_id: current_user_id, parent_folder_id: @parent_folder.id)
                 .except(:parent_unique_token)
  end

  def find_folder
    @folder = Folder.find_by!(user_id: current_user_id,
                              unique_token: folder_update_params[:unique_token])
  end

  def find_current_folder
    @folder = Folder.find_by!(user_id: current_user_id,
                              unique_token: params[:unique_token])
  end

  def find_parent_folder
    return if params[:folder][:parent_unique_token].nil?

    @parent_folder = Folder.find_by!(
      unique_token: params[:folder][:parent_unique_token]
    )
  end

  def index_query
    query = {
      user_id: current_user_id,
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

  def create_root_folder
    new_params = folder_params.except(:parent_unique_token)
                              .merge!(user_id: current_user_id)

    ActiveRecord::Base.transaction do
      Api::V1::CreateFolderService.new(
        new_params
      ).perform

      Api::V1::CreateRootFolderJob.perform_later(
        current_user_bucket_token,
        folder_params[:path]
      )
    end

    render_jsonapi success_response, status: :created
  end

  def load_full_path
    @full_path = Api::V1::FolderTraversalService.new(
      user_id: current_user_id,
      parent_folder_object: @parent_folder,
      new_prefix: folder_params_without_parent_unique_token[:path]
    ).perform

    folder_params_without_parent_unique_token.merge!(full_path: @full_path[:new_full_path])
  end

  def rename_root_folder
    ActiveRecord::Base.transaction do
      @folder.update!(path: folder_update_params[:new_path])

      Api::V1::RenameRootFolderJob.perform_later(
        bucket_token: current_user_bucket_token,
        folder_object: @folder,
        path: @folder.path,
        new_path: folder_update_params[:new_path]
      )
    end

    render_jsonapi success_update_response
  end

  def success_response
    {
      path: folder_params[:path] || folder_params_without_parent_unique_token[:path]
    }
  end

  def success_update_response
    {
      new_path: @folder.path
    }
  end
end
