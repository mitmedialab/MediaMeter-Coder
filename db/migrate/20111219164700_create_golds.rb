class CreateGolds < ActiveRecord::Migration
  def change
    create_table :golds do |t|
      t.integer :article_id
      t.string :question
      t.boolean :answer

      t.timestamps
    end
  end
end
