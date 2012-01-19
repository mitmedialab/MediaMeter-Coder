class AddSourceToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :source, :string, { :default => "CrowdFlower" }
  end
end
