# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :find_folder, only: :rename

  def create
    @folder = Folder.new(folder_params.merge(user_id: current_user_id))

    @folder.save!

    create_folder = Api::V1::CreateFolderService.new(current_user_unique_token, @folder.path)

    render_jsonapi success_response if create_folder.perform
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
    params.require(:folder).permit(:path)
  end

  def folder_update_params
    params.require(:folder).permit(:unique_token, :new_path)
  end

  def find_folder
    @folder ||= Folder.find_by!(user_id: current_user_id,
                                unique_token: folder_update_params[:unique_token])
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
