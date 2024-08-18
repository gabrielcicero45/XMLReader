class Document < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :file, presence: true
  validate :file_format

  store_accessor :emitente, :nome, :cnpj, :endereco
  store_accessor :destinatario, :nome, :cpf, :endereco
  store_accessor :products, :nome, :ncm, :cfop, :unidade, :quantidade, :valor_unitario
  store_accessor :taxes, :icms, :ipi, :pis, :cofins
  store_accessor :total_values, :total_produtos, :total_impostos

  def processed?
    processed
  end

  private

  def file_format
    return unless file.attached? && !file.content_type.in?(%w[application/xml text/xml])

    errors.add(:file, 'must be an XML file')
  end
end
