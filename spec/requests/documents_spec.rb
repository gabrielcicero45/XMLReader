require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  
  describe "GET /new" do
    before { sign_in user }
    it "returns http success" do
      get "/documents/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/documents/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/documents/index"
      expect(response).to have_http_status(:success)
    end
  end

end
