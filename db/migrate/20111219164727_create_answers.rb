class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :type
      t.datetime :time
      t.string :user
      t.integer :confidence
      t.boolean :answer

      t.timestamps
    end
  end
end
