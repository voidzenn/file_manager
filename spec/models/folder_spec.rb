# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folder, type: :model do
  describe "validations" do
    describe "#user_id" do
      it do
        is_expected.to validate_numericality_of(:user_id).only_integer.is_greater_than(0)
      end
    end

    describe "#path" do
      it do
        is_expected.to validate_presence_of(:path)
      end
    end
  end
end
