class AddScanFileUrlToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :scan_file_url, :string
  end
end
