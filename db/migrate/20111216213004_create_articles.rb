class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :source
      t.date :pub_date
      t.string :byline
      t.string :headline
      t.string :page
      t.string :src_url
      t.string :abstract

      t.timestamps
    end
  end
end
