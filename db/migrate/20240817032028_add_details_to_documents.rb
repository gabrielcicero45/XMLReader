class AddDetailsToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :serie, :string
    add_column :documents, :nNF, :string
    add_column :documents, :dhEmi, :datetime
    add_column :documents, :emit, :jsonb
    add_column :documents, :dest, :jsonb
    add_column :documents, :products, :jsonb, array: true, default: []
    add_column :documents, :taxes, :jsonb
    add_column :documents, :total_values, :jsonb
  end
end
