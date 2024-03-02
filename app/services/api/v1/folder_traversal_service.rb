# frozen_string_literal: true

class Api::V1::FolderTraversalService
  def initialize args = {}
    @user_id = args[:user_id]
    @parent_folder_object = args[:parent_folder_object]
    @new_prefix = args[:new_prefix]
    @old_prefix = args[:old_prefix]
    @full_parent_path = []
  end

  def perform
    load_full_parent_folder_paths
    load_full_path
  end

  private

  attr_accessor :full_parent_path
  attr_reader :user_id, :parent_folder_object, :new_prefix, :old_prefix

  def load_full_parent_folder_paths
    full_parent_path << parent_folder_object.path

    current_parent_folder_object = parent_folder_object

    while current_parent_folder_object&.parent_folder_id&.present?
      current_parent_folder_object = Folder.find_by!(
        id: current_parent_folder_object.parent_folder_id,
        user_id: user_id
      )

      full_parent_path.unshift(current_parent_folder_object.path)
    end
  end

  def load_full_path
    @path = full_parent_path.join("")
    full_paths = {
      new_full_path: new_full_path,
      old_full_path: old_full_path
    }

    full_paths
  end

  def new_full_path
    @path + new_prefix
  end

  def old_full_path
    @path + (old_prefix || '')
  end
end
