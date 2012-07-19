class ConvertAnswerToInt < ActiveRecord::Migration
  def change
    change_column(:answers,:answer,:int)
  end
end
