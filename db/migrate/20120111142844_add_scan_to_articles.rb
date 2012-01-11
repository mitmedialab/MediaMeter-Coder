class AddScanToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :scan_src_url, :string
    add_column :articles, :scan_local_filename, :string
  end
end
