class LinkQuestionsToAnswers < ActiveRecord::Migration
  def change
    remove_column(:answers,:type)
    add_column(:answers,:question_id,:integer)
    remove_column(:questions,:key)
  end
end
