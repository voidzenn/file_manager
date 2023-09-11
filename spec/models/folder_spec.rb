# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folder, type: :model do
  shared_context "value is greater than 0" do |attribute|
    it do
      is_expected.to allow_value(1).for(attribute)
      is_expected.to_not allow_value(0).for(attribute)
      is_expected.to_not allow_value(-1).for(attribute)
    end
  end

  describe "validations" do
    describe "#name" do
      it do
        is_expected.to validate_presence_of(:name)
      end
    end

    describe "#parent_id" do
      it{is_expected.to validate_numericality_of(:parent_id)}

      it_behaves_like "value is greater than 0", :parent_id
    end

    describe "#child_id" do
      it{is_expected.to validate_numericality_of(:child_id)}

      it_behaves_like "value is greater than 0", :child_id
    end
  end
end
