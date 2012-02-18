class AddSampletagToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :sampletag, :string
  end
end
