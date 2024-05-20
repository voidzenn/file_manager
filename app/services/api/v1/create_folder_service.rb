# frozen_string_literal: true

class Api::V1::CreateFolderService
  def initialize current_user, params
    @current_user = current_user
    @params = params
  end

  def perform
    create_folder
    broadcast_folder_created
  end

  private

  attr_reader :current_user, :params

  def create_folder
    @folder = Folder.new(params)
    @folder.save!
  end

  def broadcast_folder_created
    FolderChannel.broadcast_folder_created(
      current_user,
      [Api::V1::FolderSerializer.new(@folder).serializable_hash]
    )
  end
end
