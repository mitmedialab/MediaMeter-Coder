require 'digest/md5'


# helper to encrypt the content of one colunm into another before saving
class ArticlePrepper

  def before_save(article)
    # make the cache hash
    return if article.src_url_md5 !=nil
    if article.has_url?
      url = article.src_url
    else 
      url = article.fake_url   
    end
    article.src_url_md5 = encrypt( url )
    # clean some strings
    article.headline.strip!
    article.abstract.strip!
  end
  
  private

    def encrypt(value)
      Digest::MD5.hexdigest(value)
    end

end

class Article < ActiveRecord::Base

  has_many      :arts_answers
  has_many      :foreign_answers
  has_many      :international_answers
  has_many      :local_answers
  has_many      :national_answers
  has_many      :sports_answers 

  before_save   ArticlePrepper.new
  
  def url_to_scan_local_file
    #TODO: how do we figure out the base url of the current server?
    return File.join(scan_dir, scan_local_filename) if has_scan_local_filename?
    return ""  
  end
  
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
    dir = File.join( Rails.public_path , scan_dir) 
    FileUtils::makedirs(dir) unless File.exists?(dir)
    dir
  end
  
  def has_scan_file_url?
    return scan_file_url!=nil && !scan_file_url.empty?
  end

  def has_scan_local_filename?
    return scan_local_filename!=nil && !scan_local_filename.empty?
  end

  def self.scraped_already? src_url
    src_url_md5 = Digest::MD5.hexdigest(src_url)
    where("src_url_md5 = ?",src_url_md5).first
  end
  
  def self.count_without_abstracts
    where("abstract is null").count
  end

  def set_queue_status(val)
    raise ArgumentError.new("Argument is not a valid queue status. Received :#{val.to_s}. Valid responses include :queued, :in_progress, :complete, :blacklisted") if !([:queued, :in_progress, :complete, :blacklisted].include? val)
    self.queue_status = val.to_s
  end

  def add_blacklist_tag(tag)
    if self.blacklist_tag.nil?
      self.blacklist_tag =""
    end
    return nil if get_blacklist_tags.include? tag
    divider =""
    divider ="," if get_blacklist_tags.size > 0
    self.blacklist_tag +="#{divider}#{tag}"
  end

  def get_blacklist_tags()
    return [] if self.blacklist_tag.nil?
    self.blacklist_tag.split(",")
  end

  private 

    def scan_dir
      File.join("article_scans" , source.gsub(" ","_").downcase , 
                       pub_date.year.to_s , pub_date.month.to_s , pub_date.day.to_s)
    end

end
