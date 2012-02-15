class CreateUsers < ActiveRecord::Migration
  def change
    add_column(:answers, :user_id, :integer, {:null=>false})
    create_table :users do |t|
      t.string :username
      t.timestamps
    end
  end
end
