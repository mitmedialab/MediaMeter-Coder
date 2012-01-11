class AddBlacklistTagToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :blacklist_tag, :string, :default=>nil, :null=>true
  end
end
