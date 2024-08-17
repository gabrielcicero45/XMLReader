class AddProcessedDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :processed, :boolean, default: false, null: false
  end
end
