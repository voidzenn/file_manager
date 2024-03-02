# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GetCurrentBucketService do
  describe "#perform" do
    let(:service) { Api::V1::GetCurrentBucketService.new.perform }

    context "when bucket retrieved successfully" do
      before do
        allow(ENV).to receive(:fetch).with("AWS_BUCKET_NAME", "users").and_return("test_bucket")
      end

      it do
        expect(service).to be_an_instance_of(Aws::S3::Bucket)
        expect(service.name).to eq "test_bucket"
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
