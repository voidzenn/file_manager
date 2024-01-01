# frozen_string_literal: true

class Api::V1::CreateFolderService
  def initialize params
    @params = params
  end

  def perform
    create_folder
  end

  private

  attr_reader :params

  def create_folder
    folder = Folder.create(params)
    folder.save!
  end
end
