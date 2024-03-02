# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folder, type: :model do
  describe 'relationships' do
    it do
      is_expected.to belong_to(:user)
    end
  end

  describe 'validations' do
    let!(:root_folder) { described_class.create(user_id: user.id, path: 'root path/') }
    let!(:user) { create :user }

    context 'attribute path' do
      it do
        is_expected.to validate_presence_of(:path)
      end

      context 'root path uniqueness' do
        let!(:folder) { described_class.create(user_id: user.id, path: 'old path/') }

        it 'should allow new path name' do
          expect(described_class.new(user_id: user.id, path: 'new path/')).to be_valid
        end

        it 'should not allow same path name' do
          new_folder = described_class.new(user_id: user.id, path: 'old path/')

          expect(new_folder).to_not be_valid
          expect(new_folder.errors[:path]).to include(I18n.t('errors.models.folder.uniqueness.message'))
        end
      end

      context 'child path uniqueness' do
        let!(:user) { create :user }
        let!(:parent_folder) { described_class.create(user_id: user.id, parent_folder_id: root_folder.id, path: 'parent path/') }
        let!(:current_folder) { described_class.create(user_id: user.id, parent_folder_id: parent_folder.id, path: 'current path/') }

        it 'should allow new path name' do
          expect(described_class.new(user_id: user.id, parent_folder_id: parent_folder.id, path: 'new child path/')).to be_valid
        end

        it 'should allow same name path with different parent_folder_id' do
          expect(described_class.new(user_id: user.id, parent_folder_id: current_folder.id, path: 'current path/')).to be_valid
        end

        it 'should not allow same path name' do
          new_folder = described_class.create(user_id: user.id, parent_folder_id: parent_folder.id, path: 'current path/')

          expect(new_folder).to_not be_valid
          expect(new_folder.errors[:path]).to include(I18n.t('errors.models.folder.uniqueness.message'))
        end
      end

      it 'should accept valid alphanumeric' do
        expect(described_class.new(user_id: user.id, path: 'abc123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'Abc123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123Abc/')).to be_valid
      end

      it 'should accept valid spaces' do
        expect(described_class.new(user_id: user.id, path: 'abc 123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'Abc 123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123 Abc/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123 Abc /')).to be_valid
      end

      it 'should accept valid underscores' do
        expect(described_class.new(user_id: user.id, path: 'abc_123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'Abc_123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123_Abc/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123_Abc_/')).to be_valid
      end

      it 'should accept valid hyphens' do
        expect(described_class.new(user_id: user.id, path: 'abc-123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'Abc-123/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123-Abc/')).to be_valid
        expect(described_class.new(user_id: user.id, path: '123-Abc-/')).to be_valid
      end

      it 'should accept valid symbols' do
        expect(described_class.new(user_id: user.id, path: 'abc!/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc@/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc#/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc$/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc%/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc^/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc&/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc*/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc+/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc,/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc-/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc./')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc:/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc;/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc</')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc=/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc>/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc?/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc@/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc[/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc\\/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc]/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc^/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc_/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc`/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc{/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc|/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc}/')).to be_valid
        expect(described_class.new(user_id: user.id, path: 'abc~/')).to be_valid
      end

      it 'should not accept without names' do
        expect(described_class.new(user_id: user.id, path: '/')).to_not be_valid
        expect(described_class.new(user_id: user.id, path: './')).to_not be_valid
        expect(described_class.new(user_id: user.id, path: '//')).to_not be_valid
      end

      it 'should not accept regular expression' do
        expect(described_class.new(user_id: user.id, path: "'\\n/'")).to_not be_valid
        expect(described_class.new(user_id: user.id, path: "'\\r/'")).to_not be_valid
        expect(described_class.new(user_id: user.id, path: "'\\t/'")).to_not be_valid
      end

      it 'should not accept space as last name character' do
        expect(described_class.new(user_id: user.id, path: ' 123 Abc /')).to_not be_valid
      end

      it 'should not accept if no forward slash as last character' do
        expect(described_class.new(user_id: user.id, path: '/abc')).to_not be_valid
      end

      it 'should not accept double slashes' do
        expect(described_class.new(user_id: user.id, path: '123123/abc/')).to_not be_valid
      end
    end

    context 'attribute full_path' do
      it do
        is_expected.to validate_uniqueness_of(:full_path)
      end
    end
  end
end
