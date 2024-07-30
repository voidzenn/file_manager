# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CreateFileUploadService do
  include_examples :sample_file

  describe '#perform' do
    let(:user) { create :user }
    let(:folder) { create(:folder, user_id: user.id) }
    let!(:file_upload) { create(:file_upload, user_id: user.id) }
    let(:full_path) { 'test/' }
    let(:filename) { File.basename(file_path) }
    let(:service) { described_class.new(user, folder.id, filename, full_path).perform }

    context do
      it 'should create file_upload record' do
        expect(service[:name]).to eq filename
      end

      it 'should handle exception' do
        service = described_class.new(user, folder.id, '', '')
        expect{service.perform}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
