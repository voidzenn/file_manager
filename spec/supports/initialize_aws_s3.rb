# frozen_string_literal: true

RSpec.shared_context :initialize_aws_s3 do
  before do
    allow(ENV).to receive(:fetch).with("AWS_BUCKET_NAME", "users").and_return("test_bucket")
    allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: true)))
  end
end
