# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folder, type: :model do
  describe "associations" do
  end

  describe "validations" do
    context "#user_id" do
      it do
        is_expected.to validate_numericality_of(:user_id).only_integer.is_greater_than(0)
      end
    end

    context "#path" do
      # We create user to make sure that the user_id is valid then we assign the user_id to the subject
      let(:user) { create :user }
      # We create folder instance to properly compare and check if case-sensitive unique
      subject{ create(:folder, user_id: user.id, path: "AlphaCharacters/") }

      it do
        is_expected.to validate_presence_of(:path)

        is_expected.to allow_value("new_path/").for(:path)
        is_expected.to_not allow_value("/new_path").for(:path).with_message(I18n.t("errors.models.folder.path.format"))
        is_expected.to_not allow_value("/new_path/").for(:path).with_message(I18n.t("errors.models.folder.path.format"))
        is_expected.to_not allow_value("new_path").for(:path).with_message(I18n.t("errors.models.folder.path.format"))

        is_expected.to validate_uniqueness_of(:path).scoped_to(:user_id).with_message(I18n.t("errors.models.folder.path.uniqueness.message"))
      end
    end
  end
end
