# frozen_string_literal: true

class Api::V1::CreateFolderService
  def initialize args
    @parent_unique_token = args[:parent_unique_token]
    @current_user = args[:current_user]
    @path = args[:path]
  end

  def perform
    create_folder
  end

  private

  attr_reader :parent_unique_token, :current_user, :path

  def create_folder
    full_path = parent_unique_token.nil? ? path : nested_full_path[:new_full_path]
    @folder = Folder.new(
      user: current_user,
      path: path,
      full_path: full_path,
      parent_folder_id: parent_folder_id
    )
    @folder.save!

    @folder
  end

  def nested_full_path
    Api::V1::FolderTraversalService.new(
      user_id: current_user.id,
      parent_folder_object: parent_folder,
      new_prefix: path
    ).perform
  end

  def parent_folder
    Folder.find_by!(
      user: current_user,
      unique_token: parent_unique_token
    )
  end

  def parent_folder_id
    parent_unique_token.nil? ? nil : parent_folder.id
  end
end
