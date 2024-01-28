# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FolderTraversalService do
  describe '#perform' do
    let!(:user) { create :user }
    let!(:parent_folder) { create(:folder, user_id: user.id, path: 'parent_folder/') }
    let!(:second_level_folder) { create(:folder, user_id: user.id, parent_folder_id: parent_folder.id, path: 'second_level_folder/') }

    context 'when creating new folder' do
      context 'when traversing second level deep' do
        let(:new_prefix) { 'new_prefix/' }
        let(:valid_service_params) do
          {
            user_id: user.id,
            parent_folder_object: second_level_folder,
            new_prefix: new_prefix
          }
        end
        let(:service) { described_class.new(valid_service_params).perform }
        let(:expected_full_path) { parent_folder.path + second_level_folder.path + new_prefix }

        it 'should return only new full path' do
          expect(service[:new_full_path]).to eq expected_full_path
        end
      end
    end

    context 'when renaming folder' do
      context 'when traversing third level deep' do
        let!(:third_level_folder) { create(:folder, user_id: user.id, parent_folder_id: second_level_folder.id, path: 'third_level_folder/') }
        let(:old_prefix) { 'old_prefix/' }
        let(:new_prefix) { 'new_prefix/' }
        let(:valid_service_params) do
          {
            user_id: user.id,
            parent_folder_object: third_level_folder,
            new_prefix: new_prefix,
            old_prefix: old_prefix
          }
        end
        let(:service) { described_class.new(valid_service_params).perform }
        let(:third_level_path) { parent_folder.path + second_level_folder.path + third_level_folder.path }
        let(:expected_new_full_path) { third_level_path + new_prefix }
        let(:expected_old_full_path) { third_level_path + old_prefix }

        it 'should return both old and new full path' do
          expect(service[:new_full_path]).to eq expected_new_full_path
          expect(service[:old_full_path]).to eq expected_old_full_path
        end
      end
    end
  end
end
