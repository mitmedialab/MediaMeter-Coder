class ChangeAggregatedAnswers < ActiveRecord::Migration
  def change
    remove_column :answers, :time
    remove_column :answers, :user
    add_column :answers, :judgements, :integer
    change_column :answers, :confidence, :float
  end
end
