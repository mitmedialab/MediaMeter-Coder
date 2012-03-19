class AddReasonToGolds < ActiveRecord::Migration
  def change
    add_column :golds, :reason, :string, :limit=>1000
  end
end
