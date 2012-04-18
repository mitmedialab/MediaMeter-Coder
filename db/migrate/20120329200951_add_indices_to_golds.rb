class AddIndicesToGolds < ActiveRecord::Migration
  def change
    add_index :golds, :article_id
    add_index :golds, :type
  end
end
