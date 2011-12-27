require 'digest/md5'


# helper to encrypt the content of one colunm into another before saving
class EncryptionWrapper

  def initialize(src,dest)
    @src_col = src
    @dest_col = dest
  end

  def before_save(record)
    record.send("#{@dest_col}=",encrypt(record.send("#{@src_col}")))
  end
  
  private

    def encrypt(value)
      Digest::MD5.hexdigest(value)
    end

end

class Article < ActiveRecord::Base

  before_save   EncryptionWrapper.new('src_url','src_url_md5')

  # auto populate some generated columns before save
  def self.scraped_already? src_url
    src_url_md5 = Digest::MD5.hexdigest(src_url)
    where("src_url_md5 = ?",src_url_md5).first
  end
  
  def self.count_without_abstracts
    where("abstract is null").count
  end

end
