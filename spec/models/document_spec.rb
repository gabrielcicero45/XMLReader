require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:user) { create(:user) }
  let(:valid_file) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'sample.xml'), 'application/xml')
  end
  let(:invalid_file) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'invalid_file.txt'), 'text/plain')
  end
  let(:document) { build(:document, user:, file: valid_file) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:file) }

    context 'when the file is attached' do
      it 'is valid with a valid XML file' do
        expect(document).to be_valid
      end

      it 'is invalid with a non-XML file' do
        document.file = invalid_file
        document.validate
        expect(document.errors[:file]).to include('must be an XML file')
      end
    end
  end

  describe '#processed?' do
    it 'returns the value of the processed attribute' do
      document.processed = true
      expect(document.processed?).to be true

      document.processed = false
      expect(document.processed?).to be false
    end
  end
end
