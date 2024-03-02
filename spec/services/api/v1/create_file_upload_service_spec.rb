# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CreateFileUploadService do
  include_examples :sample_file

  describe '#perform' do
    let!(:file_upload) { create :file_upload }
    let(:full_path) { 'test/' }
    let(:filename) { File.basename(file_path) }
    let(:service) { described_class.new(file_upload.folder.id, filename, full_path) }

    context do
      it 'should create file_upload record' do
        expect(service.perform).to be_a(FileUpload)
      end

      it 'should handle exception' do
        service = described_class.new(file_upload.folder.id, '', '')
        expect{service.perform}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
