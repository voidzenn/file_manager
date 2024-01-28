# frozen_string_litera: true

require "rails_helper"

RSpec.describe Api::V1::CreateFolderService do
  describe "#perform" do
    let(:user) { create :user }

    include_context :initialize_aws_s3

    context "when folder create successfully" do
      let(:path) { "new_path/" }
      let(:service) { Api::V1::CreateFolderService.new(user.id, path) }

      it do
        expect(service.perform).to eq true
      end
    end

    context "when folder create fails" do
      context 'when path starts with "/"' do
        let(:path) { "/new_path/" }
        let(:service) { Api::V1::CreateFolderService.new(user.id, path) }

        it do
          expect(service.perform).to be_nil
        end
      end

      context 'when path not ends with "/"' do
        let(:path) { "new_path" }
        let(:service) { Api::V1::CreateFolderService.new(user.id, path) }

        it do
          expect(service.perform).to be_nil
        end
      end
    end
  end
end
