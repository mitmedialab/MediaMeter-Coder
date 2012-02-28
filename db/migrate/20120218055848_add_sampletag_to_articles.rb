class AddSampletagToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :sampletag, :string, :default=>nil
  end
end
