class DocumentsController < ApplicationController
  require 'caxlsx'
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!

  def index
    @documents = current_user.documents
  end

  def new
    @document = Document.new
  end

  def show
    @document = Document.find(params[:id])
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    if @document.destroy
      redirect_to documents_path, notice: 'Documento apagado.'
    else
      redirect_to documents_path, notice: 'Nao foi possivel deletar este documento.'
    end
  end

  def create
    @document = current_user.documents.build(document_params)
    if @document.save
      DocumentProcessorJob.perform_later(@document.id)
      redirect_to documents_path, notice: 'Documento enviado com sucesso e será processado em breve.'
    else
      render :new
    end
  end

  def export
    @document = Document.find(params[:id])

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Relatório do Documento') do |sheet|
      sheet.add_row ['Relatório do Documento']

      sheet.add_row ['Dados do Documento Fiscal']
      sheet.add_row ['Número de Série:', @document.serie]
      sheet.add_row ['Número da Nota Fiscal:', @document.nNF]
      sheet.add_row ['Data e Hora de Emissão:', @document.dhEmi]

      sheet.add_row ['Emitente:']
      emitente_endereco = if @document.emit.present?
                            "#{@document.emit['endereco']['logradouro']}, #{@document.emit['endereco']['numero']}, #{@document.emit['endereco']['bairro']}, #{@document.emit['endereco']['uf']}, CEP: #{@document.emit['endereco']['cep']}, #{@document.emit['endereco']['pais']}"
                          else
                            'Não disponível'
                          end
      sheet.add_row ['Nome:', @document.emit.present? ? @document.emit['nome'] : 'Não disponível']
      sheet.add_row ['CNPJ:', @document.emit.present? ? @document.emit['cnpj'] : 'Não disponível']
      sheet.add_row ['Endereço:', emitente_endereco]

      sheet.add_row ['Destinatário:']
      destinatario_endereco = if @document.dest.present?
                                "#{@document.dest['endereco']['logradouro']}, #{@document.dest['endereco']['numero']}, #{@document.dest['endereco']['bairro']}, #{@document.dest['endereco']['uf']}, CEP: #{@document.dest['endereco']['cep']}, #{@document.dest['endereco']['pais']}"
                              else
                                'Não disponível'
                              end
      sheet.add_row ['Nome:', @document.dest.present? ? @document.dest['nome'] : 'Não disponível']
      sheet.add_row ['CNPJ:', @document.dest.present? ? @document.dest['cnpj'] : 'Não disponível']
      sheet.add_row ['Endereço:', destinatario_endereco]

      sheet.add_row ['Produtos Listados']
      sheet.add_row ['Nome', 'NCM', 'CFOP', 'Unidade', 'Quantidade', 'Valor Unitário']
      @document.products.each do |product|
        sheet.add_row [product['nome'], product['ncm'], product['cfop'], product['unidade'], product['quantidade'],
                       product['valor_unitario']]
      end

      sheet.add_row ['Impostos Associados']
      sheet.add_row ['ICMS:',
                     @document.taxes.present? && @document.taxes['icms'].present? ? number_to_currency(@document.taxes['icms'].to_f) : 'Não disponível']
      sheet.add_row ['IPI:',
                     @document.taxes.present? && @document.taxes['ipi'].present? ? number_to_currency(@document.taxes['ipi'].to_f) : 'Não disponível']
      sheet.add_row ['PIS:',
                     @document.taxes.present? && @document.taxes['pis'].present? ? number_to_currency(@document.taxes['pis'].to_f) : 'Não disponível']
      sheet.add_row ['COFINS:',
                     @document.taxes.present? && @document.taxes['cofins'].present? ? number_to_currency(@document.taxes['cofins'].to_f) : 'Não disponível']

      sheet.add_row ['Totalizadores']
      sheet.add_row ['Total dos Produtos:',
                     @document.total_values.present? ? number_to_currency(@document.total_values['total_products'].to_f) : 'Não disponível']
      sheet.add_row ['Total dos Impostos:',
                     @document.total_values.present? ? number_to_currency(@document.total_values['total_taxes'].to_f) : 'Não disponível']
    end

    send_data package.to_stream.read, filename: "documento_#{@document.id}.xlsx",
                                      content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
