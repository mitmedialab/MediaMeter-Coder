class AddPagesWordCountToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :total_pages, :integer
    add_column :articles, :word_count, :integer
  end
end
