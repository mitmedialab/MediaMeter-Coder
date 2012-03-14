class ChangeGoldQuestionToType < ActiveRecord::Migration
  def change
    rename_column :golds, :question, :type
  end
end
