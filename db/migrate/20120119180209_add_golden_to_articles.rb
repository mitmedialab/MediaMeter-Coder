class AddGoldenToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :golden, :boolean, { :default => false }
  end
end
