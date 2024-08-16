require 'nokogiri'

class DocumentProcessingJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    xml_content = Nokogiri::XML(document.file.download)

    # Extração dos dados XML
    serie = xml_content.xpath("//serie").text
    nNF = xml_content.xpath("//nNF").text
    # Continue extraindo outras informações necessárias...
    
    # Salvar as informações processadas
    document.update(
      serie: serie,
      nNF: nNF,
      # Outros campos...
    )
  end
end
