# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UploadFileMinioService do
  describe '#perform' do
    let(:bucket) { create(:user).bucket_token }
    let(:service) { described_class.new "sample_token", "sample_path/", double(path: true) }

    context 'when uploading file successfully' do
      before do
        allow_any_instance_of(Api::V1::GetCurrentBucketService).to receive(:perform).and_return(double(object: double(upload_file: true)))
      end

      it do
        expect(service.perform).to eq(true)
      end
    end
  end
end

