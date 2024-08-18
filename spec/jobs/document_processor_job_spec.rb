require 'rails_helper'

RSpec.describe DocumentProcessorJob, type: :job do
  let(:job) { described_class.new }
  let(:user) { create(:user) }
  let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'sample.xml'), 'application/xml') }
  let(:document) { create(:document, user:, file:) }

  before do
    allow(Document).to receive(:find).and_return(document)
  end

  describe '#perform' do
    it 'parses the XML and updates the document with correct values' do
      expect(document).to receive(:update!)

      job.perform(document.id)
    end
  end
end
