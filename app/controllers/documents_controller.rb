class DocumentsController < ApplicationController
    before_action :authenticate_user!
  
    def new
      @document = Document.new
    end
  
    def create
      @document = current_user.documents.build(document_params)
      if @document.save
        DocumentProcessingJob.perform_later(@document.id)
        redirect_to documents_path, notice: "Documento enviado com sucesso!"
      else
        render :new
      end
    end
  
    private
  
    def document_params
      params.require(:document).permit(:file)
    end
  end
  