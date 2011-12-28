require 'digest/md5'


# helper to encrypt the content of one colunm into another before saving
class EncryptionWrapper

  def before_save(record)
    return if record.src_url_md5 !=nil
    if record.has_url?
      url = record.src_url
    else 
      url = record.fake_url   
    end
    record.src_url_md5 = encrypt( url )
  end
  
  private

    def encrypt(value)
      Digest::MD5.hexdigest(value)
    end

end

class Article < ActiveRecord::Base

  before_save   EncryptionWrapper.new

  # HACK for NYT edge case where some articles from the API don't have URLs :-(
  def fake_url
    return source.to_s + pub_date.to_s + headline.to_s
  end
  
  def has_url?
    return src_url!=nil &&  !src_url.empty?
  end

  def self.scraped_already? src_url
    src_url_md5 = Digest::MD5.hexdigest(src_url)
    where("src_url_md5 = ?",src_url_md5).first
  end
  
  def self.count_without_abstracts
    where("abstract is null").count
  end

end
