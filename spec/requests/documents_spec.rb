require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_file) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'sample.xml'), 'application/xml')
  end
  let(:document) { create(:document, user:, file: valid_file) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns all documents to @documents' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new document to @document' do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested document to @document' do
      get :show, params: { id: document.id }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #export' do
    it 'returns an XLSX file with the document data' do
      get :export, params: { id: document.id }
      expect(response.content_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end

  describe 'DELETE #destroy' do
  it 'deletes the document' do
    expect {
      delete :destroy, params: { id: document.id }
    }.to change(Document, :count).by(0)
  end

  it 'redirects to documents index' do
    delete :destroy, params: { id: document.id }
    expect(response).to redirect_to(documents_path)
    expect(flash[:notice]).to eq('Documento apagado.')
  end
end
end
