class ChangeFieldLengthsOfArticles < ActiveRecord::Migration

  def up
    change_column :articles, :byline, :string, :limit=>500
    change_column :articles, :headline, :string, :limit=>500
    change_column :articles, :src_url, :string, :limit=>1000
    change_column :articles, :abstract, :string, :limit=>2000
    change_column :articles, :scan_src_url, :string, :limit=>1000
    change_column :articles, :scan_file_url, :string, :limit=>1000
  end

  def down
    change_column :articles, :byline, :string, :limit=>255
    change_column :articles, :headline, :string, :limit=>255
    change_column :articles, :src_url, :string, :limit=>255
    change_column :articles, :abstract, :string, :limit=>255
    change_column :articles, :scan_src_url, :string, :limit=>255
    change_column :articles, :scan_file_url, :string, :limit=>255
  end
  
end
