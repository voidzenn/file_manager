# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :find_folder, only: :rename

  def create
    return create_root_folder if folder_params[:parent_unique_token].nil?

    find_parent_folder

    ActiveRecord::Base.transaction do
      @folder = Folder.new(folder_params_without_parent_unique_token)
      @folder.save!
    end

    create_folder = Api::V1::CreateFolderJob.perform_now(
      user_id: current_user_id,
      user_token: current_user_unique_token,
      parent_folder: @parent_folder,
      path_name: folder_params[:path]
    )

    render_jsonapi success_response if create_folder
  end

  def rename
    @folder.update!(path: folder_update_params[:new_path])

    rename_folder = Api::V1::RenameFolderService.new(current_user_unique_token,
                                                     @folder.path,
                                                     folder_update_params[:new_path])

    render_jsonapi success_update_response if rename_folder.perform
  end

  private

  def folder_params
    permitted_params = params.require(:folder).permit(:path, :parent_unique_token)
    permitted_params[:parent_unique_token] = nil if [:parent_unique_token].blank?
    permitted_params
  end

  def folder_update_params
    params.require(:folder).permit(:unique_token, :new_path)
  end

  def folder_params_without_parent_unique_token
    new_params = folder_params.merge(user_id: current_user_id, parent_folder_id: @parent_folder.id)
    new_params.except(:parent_unique_token)
  end

  def find_folder
    @folder = Folder.find_by!(user_id: current_user_id,
                                unique_token: folder_update_params[:unique_token])
  end

  def find_parent_folder
    @parent_folder = Folder.find_by!(unique_token: folder_params[:parent_unique_token])
  end

  def create_root_folder
    ActiveRecord::Base.transaction do
      @folder = Folder.new(folder_params.merge(user_id: current_user_id))
      @folder.save!
    end

    create_folder = Api::V1::CreateRootFolderJob.perform_now(
      current_user_unique_token,
      folder_params[:path]
    )

    render_jsonapi success_response if create_folder
  end

  def success_response
    {
      path: @folder.path
    }
  end

  def success_update_response
    {
      new_path: @folder.path
    }
  end
end
