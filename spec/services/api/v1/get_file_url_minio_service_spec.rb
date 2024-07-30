# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GetFileUrlMinioService do
  describe "#perform" do
    let(:bucket) { create(:user).bucket_token }
    let(:sample_url) { "test_url" }
    let(:service) { described_class.new bucket, "sample_path/" }

    context "when getting url file successfully" do
      before do
        allow_any_instance_of(Api::V1::GetCurrentBucketService).to receive(:perform).and_return(double(object: double(presigned_url: sample_url)))
      end

      it do
        expect(service.perform).to eq sample_url
      end
    end
  end
end
