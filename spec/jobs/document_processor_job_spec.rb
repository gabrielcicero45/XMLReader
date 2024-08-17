require 'rails_helper'

RSpec.describe DocumentProcessorJob, type: :job do
  let(:document) { create(:document, file: file_fixture('sample.xml').read) }
  let(:xml_data) { Nokogiri::XML(document.file.download) }
  let(:job) { described_class.new }

  before do
    allow(Document).to receive(:find).and_return(document)
    allow(document).to receive(:file).and_return(double(download: xml_data.to_xml))
  end

  describe '#perform' do
    it 'parses the XML and updates the document with correct values' do
      expect(document).to receive(:update!)

      job.perform(document.id)
    end
  end
end
