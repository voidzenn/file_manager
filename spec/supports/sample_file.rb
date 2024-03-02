# frozen_string_literal: true

RSpec.shared_examples :sample_file do
  let(:file_path) { Rails.root.join('spec', 'files', 'sample.pdf') }
  let(:sample_file) { fixture_file_upload(file_path, 'application/pdf') }
end
