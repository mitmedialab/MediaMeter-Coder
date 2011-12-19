require 'digest/md5'

class AddUrlHashToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :src_url_md5, :string
    Article.all.each { |a|
      a.update_attributes!(:src_url_md5=>Digest::MD5.hexdigest(a.src_url))
    }
    add_index(:articles, :src_url_md5, {:name => 'src_url_md5_index', :unique=>true } )
  end
end
