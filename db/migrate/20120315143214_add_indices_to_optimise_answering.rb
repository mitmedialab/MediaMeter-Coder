class AddIndicesToOptimiseAnswering < ActiveRecord::Migration
  def change
    add_index :articles, :sampletag
    add_index :answers, :type
    add_index :answers, :user_id
    add_index :answers, :article_id
  end
end
