# app/jobs/document_processor_job.rb
class DocumentProcessorJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    Rails.logger.info
    document = Document.find(document_id)
    xml_data = Nokogiri::XML(document.file.download)
    xml_data.remove_namespaces!
    series = xml_data.xpath('//serie').text
    nNF = xml_data.xpath('//nNF').text
    dhEmi = xml_data.xpath('//dhEmi').text
    emitente = {
      nome: xml_data.xpath('//emit/xNome').text,
      cnpj: xml_data.xpath('//emit/CNPJ').text,
      endereco: {
        logradouro: xml_data.xpath('//emit/enderEmit/xLgr').text,
        numero: xml_data.xpath('//emit/enderEmit/nro').text,
        bairro: xml_data.xpath('//emit/enderEmit/xBairro').text,
        uf: xml_data.xpath('//emit/enderEmit/UF').text,
        cep: xml_data.xpath('//emit/enderEmit/CEP').text,
        pais: xml_data.xpath('//emit/enderEmit/xPais').text
      }
    }
    destinatario = {
      nome: xml_data.xpath('//dest/xNome').text,
      cnpj: xml_data.xpath('//dest/CNPJ').text,
      endereco: {
        logradouro: xml_data.xpath('//emit/enderEmit/xLgr').text,
        numero: xml_data.xpath('//dest/enderDest/nro').text,
        bairro: xml_data.xpath('//dest/enderDest/xBairro').text,
        uf: xml_data.xpath('//dest/enderDest/UF').text,
        cep: xml_data.xpath('//dest/enderDest/CEP').text,
        pais: xml_data.xpath('//dest/enderDest/xPais').text
      }
    }

    products = []
    xml_data.xpath('//det').each do |det|
      products << {
        nome: det.xpath('prod/xProd').text,
        ncm: det.xpath('prod/NCM').text,
        cfop: det.xpath('prod/CFOP').text,
        unidade: det.xpath('prod/uCom').text,
        quantidade: det.xpath('prod/qCom').text,
        valor_unitario: det.xpath('prod/vUnCom').text
      }
    end

    taxes = {
      icms: xml_data.xpath('//ICMS/ICMS00/vICMS').text,
      ipi: xml_data.xpath('//IPI/IPITrib/vIPI').text,
      pis: xml_data.xpath('//PIS/PISNT/vPIS').text,
      cofins: xml_data.xpath('//COFINS/CONFINSNT/vCOFINS').text
    }

    total_produtos = products.sum { |p| p[:valor_unitario].to_f * p[:quantidade].to_f }
    total_impostos = taxes.values.map(&:to_f).sum

    document.update!(
      serie: series,
      nNF:,
      dhEmi:,
      emit: emitente,
      dest: destinatario,
      products:,
      taxes:,
      total_values: { total_produtos:, total_impostos: },
      processed: true
    )
  end
end
