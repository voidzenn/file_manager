# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GetCurrentBucketService do
  describe "#perform" do
    let!(:bucket_token) { create(:user).bucket_token }
    let(:service) { Api::V1::GetCurrentBucketService.new(bucket_token).perform }

    context "when bucket retrieved successfully" do
      before do
        allow(ENV).to receive(:fetch).with("AWS_BUCKET_NAME", bucket_token).and_return(bucket_token)
      end

      it do
        expect(service).to be_an_instance_of(Aws::S3::Bucket)
        expect(service.name).to eq bucket_token
      end
    end

    context "when getting bucket fails" do
      context "when bucket does not exist" do
        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_raise(Aws::S3::Errors::NoSuchBucket.new({}, "NoSuchBucket"))
        end

        it do
          expect{ service }.to raise_error(Aws::S3::Errors::NoSuchBucket)
        end
      end
    end
  end
end
