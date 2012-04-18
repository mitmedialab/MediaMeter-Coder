class AddGenderFieldsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :gender, "char(1)"
    add_column :articles, :gender_prob, :float
  end
end
