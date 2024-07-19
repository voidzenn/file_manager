# frozen_string_literal: true

class Api::V1::RenameFolderService
  def initialize args
    @current_user = args[:current_user]
    @unique_token = args[:unique_token]
    @new_path = args[:new_path]
  end

  def perform
    rename_folder
  end

  private

  attr_reader :current_user, :unique_token, :new_path

  def rename_folder
    @folder = Folder.find_by!(
      user_id: current_user.id,
      unique_token: unique_token
    )

    @folder.update!(
      path: new_path,
      full_path: full_path
    )

    @folder
  end

  def full_path
    return new_path if @folder.parent_folder_id.nil?

    full_path = Api::V1::FolderTraversalService.new(
      user_id: current_user.id,
      parent_folder_object: parent_folder,
      new_prefix: new_path
    ).perform

    full_path[:new_full_path]
  end

  def parent_folder
    Folder.find(@folder.parent_folder_id)
  end
end
