# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  def create
    @folder = Folder.create folder_params

    raise ActiveRecord::RecordInvalid, @folder unless @folder.valid?

    @folder.save
    render_jsonapi success_response
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :parent_id, :child_id)
  end

  def success_response
    {
      folder_name: @folder.name
    }
  end
end
