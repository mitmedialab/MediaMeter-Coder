class AddSourceIndexToArticles < ActiveRecord::Migration
  def change
    add_index(:articles, :source, {:name => 'source_index' } )
  end
end
