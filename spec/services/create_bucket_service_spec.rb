# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateBucketService do
  describe "#perform" do
    let(:bucket_name) { "new-bucket" }
    let(:service) { described_class.new(bucket_name) }

    context "when bucket created successfully" do
      before do
        allow_any_instance_of(Aws::S3::Resource).to receive(:create_bucket)
      end

      it do
        expect{ service.perform }.not_to raise_error
      end
    end

    context "when bucket create fails" do
      context "when bucket exists" do
        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:create_bucket).and_raise(Aws::S3::Errors::BucketAlreadyExists.new({}, "BucketAlreadyExists"))
        end

        it do
          expect{ service.perform }.to raise_error(Aws::S3::Errors::BucketAlreadyExists)
        end
      end

      context "when bucket already owned by you" do
        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:create_bucket).and_raise(Aws::S3::Errors::BucketAlreadyOwnedByYou.new({}, "BucketAlreadyOwnedByYou"))
        end

        it do
          expect{ service.perform }.to raise_error(Aws::S3::Errors::BucketAlreadyOwnedByYou)
        end
      end

      context "when bucket name invalid" do
        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:create_bucket).and_raise(Aws::S3::Errors::InvalidBucketName.new({}, "InvalidBucketName"))
        end

        it do
          expect{ service.perform }.to raise_error(Aws::S3::Errors::InvalidBucketName)
        end
      end
    end
  end
end
