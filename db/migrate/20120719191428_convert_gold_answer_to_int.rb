class ConvertGoldAnswerToInt < ActiveRecord::Migration
  def change
    change_column(:golds,:answer,:int)
  end
end
