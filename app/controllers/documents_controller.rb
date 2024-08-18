class DocumentsController < ApplicationController
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

  def create
    @document = current_user.documents.build(document_params)
    if @document.save
      DocumentProcessorJob.perform_later(@document.id)
      redirect_to documents_path, notice: 'Documento enviado com sucesso e será processado em breve.'
    else
      render :new
    end
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
