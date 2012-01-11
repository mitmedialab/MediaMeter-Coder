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
    return src_url!=nil && !src_url.empty?
  end
  
  def has_scan_src_url?
    return scan_src_url!=nil && !scan_src_url.empty?
  end
  
  def path_to_scan_dir
    dir = File.join( Rails.public_path , "article_scans" , source.gsub(" ","_").downcase , 
                     pub_date.year.to_s , pub_date.month.to_s , pub_date.day.to_s) 
    FileUtils::makedirs(dir) unless File.exists?(dir)
    dir
  end
  
  def has_scan_file_url?
    return scan_file_url!=nil && !scan_file_url.empty?
  end

  def self.scraped_already? src_url
    src_url_md5 = Digest::MD5.hexdigest(src_url)
    where("src_url_md5 = ?",src_url_md5).first
  end
  
  def self.count_without_abstracts
    where("abstract is null").count
  end

  def set_queue_status(val)
    raise ArgumentError "Argument is not a valid queue status. Received :#{val.to_s}. Valid responses include :queued, :in_progress, :complete" if !([:queued, :in_progress, :complete].include? val)
    self.queue_status = val.to_s
  end

end
