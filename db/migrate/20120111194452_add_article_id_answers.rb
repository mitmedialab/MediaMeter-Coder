class AddArticleIdAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :article_id, :int
  end
end
