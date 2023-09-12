# frozen_string_litera: true

require "rails_helper"

RSpec.describe Api::V1::CreateFolderService do
  shared_context "initialize aws s3" do
    before do
      allow(ENV).to receive(:fetch).with("AWS_BUCKET_NAME", "users").and_return("test_bucket")
      allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: true)))
    end
  end

  describe "#perform" do
    let(:user) { create :user }

    context "when folder create successfully" do
      let(:path) { "new_path/" }
      let(:service) { Api::V1::CreateFolderService.new(user.id, path) }

      include_context "initialize aws s3"

      it do
        expect(service.perform).to eq true
      end
    end

    context "when folder create fails" do
      context "when path starts with /" do
        let(:path) { "/new_path/" }
        let(:service) { Api::V1::CreateFolderService.new(user.id, path) }

        include_context "initialize aws s3"

        it do
          expect(service.perform).to be_nil
        end
      end

      context "when path not ends with /" do
        let(:path) { "new_path" }
        let(:service) { Api::V1::CreateFolderService.new(user.id, path) }

        include_context "initialize aws s3"

        it do
          expect(service.perform).to be_nil
        end
      end
    end
  end
end
