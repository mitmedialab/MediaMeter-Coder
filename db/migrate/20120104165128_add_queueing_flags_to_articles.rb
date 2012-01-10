class AddQueueingFlagsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :queue_status, :string
    add_index  :articles, :queue_status
  end
end
