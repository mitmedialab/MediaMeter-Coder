class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.text :description
      t.text :key
      t.text :answer_one
      t.text :answer_two
      t.text :answer_three
      t.text :answer_four
      t.text :answer_five

      t.timestamps
    end
  end
end
