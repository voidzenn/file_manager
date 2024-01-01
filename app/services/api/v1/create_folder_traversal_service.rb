# frozen_string_literal: true

class Api::V1::CreateFolderTraversalService
  def initialize user_id, parent_folder, path_name
    @user_id = user_id
    @parent_folder = parent_folder
    @path_name = path_name
    @paths = []
  end

  def perform
    load_full_parent_folder_paths
    load_full_path_with_path_name
  end

  private

  attr_accessor :paths
  attr_reader :user_id, :parent_folder, :path_name

  def load_full_parent_folder_paths
    paths << parent_folder.path

    current_parent_folder = parent_folder

    while current_parent_folder&.parent_folder_id&.present?
      current_parent_folder = Folder.find_by!(id: current_parent_folder.parent_folder_id,
                                             user_id: user_id)

      paths.unshift(current_parent_folder.path)
    end
  end

  def load_full_path_with_path_name
    paths << path_name

    paths.join("")
  end
end
