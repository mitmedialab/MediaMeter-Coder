class LinkQuestionsToGolds < ActiveRecord::Migration
  def change
    remove_column(:golds,:type)
    add_column(:golds,:question_id,:integer)
  end
end
