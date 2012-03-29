require 'digest/md5'


# helper to encrypt the content of one colunm into another before saving
class ArticlePrepper

  def before_save(article)
    # make the cache hash
    if article.src_url_md5 ==nil
      if article.has_url?
        url = article.src_url
      else 
        url = article.fake_url
      end
      article.src_url_md5 = encrypt( url )
    end
    # clean some strings
    article.headline.strip! if article.headline!=nil
    article.abstract.strip! if article.abstract!=nil 
  end
  
  private

    def encrypt(value)
      Digest::MD5.hexdigest(value)
    end

end

class Article < ActiveRecord::Base

  self.per_page = 100

  has_many      :answers
  has_many      :golds
  
  before_save   ArticlePrepper.new
  
  scope :completed, where(:queue_status=>:complete)
  
  # we need these held here so we can export the CSV for CrowdFlower correcltly
  # @see https://crowdflower.com/solutions/self-service/#learning_resources 
  QUESTIONS = {
    "arts"=>"Is this newspaper clip about the arts or entertainment",
    "foreign"=>"Does this newspaper clip contain International News that does not involve the United States", 
    "international"=>"Is this newspaper clip about International News that involves the United States or NATO", 
    "local"=>"Does this newspaper clip contain local news", 
    "national"=>"Does this newspaper clip contain United States National news", 
    "sports"=>"Is this article about sports"
  }
  
  def self.question_text type
    QUESTIONS[type]
  end
  
  # get the url to the local copy of the PDF file
  def url_to_scan_local_file
    url = ""
    url = "http://"+File.join(NewsScrapers::public_base_url, scan_subdir, scan_local_filename) if has_scan_local_filename?
    url
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
    raise ArgumentError.new("Argument is not a valid queue status. Received :#{val.to_s}. Valid responses include :queued, :in_progress, :complete, :blacklisted, :in_progress_error") if !([:queued, :in_progress, :complete, :blacklisted, :in_progress_error].include? val)
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

  # assumes you've loaded the article with the linked has_many :articles
  def answers_by_type(type)
    answers.select do |answer|
      answer.is_type type
    end
  end

  def missing_gold_by_type(type)
    gold_by_type(type) == nil
  end
  
  def has_gold_by_type(type)
    !missing_gold_by_type(type)
  end

  # assumes you've loaded the article with the linked has_many :golds
  def gold_by_type(type)
    gold = nil
    found_golds = golds.select do |gold|
      gold.is_type type
    end
    if found_golds.count > 0
      gold = found_golds.first    # there should be only one!
    end
    gold
  end

  # return a summary hash about agreement between the answers already loaded
  def agreement_info_for_type(type)
    answers_of_type = answers_by_type(type)
    info = {
      :yes => (answers_of_type.count {|a| (a.answer==true)}).to_f / answers_of_type.count.to_f,
      :no => (answers_of_type.count {|a| (a.answer==false)}).to_f / answers_of_type.count.to_f,
      :count => answers_of_type.count
    }
    info[:yes] = 0 if info[:yes].nan?
    info[:no] = 0 if info[:no].nan?
    if info[:yes] > info[:no]
      info[:is_of_type] = true 
    elsif info[:no] > info[:yes]
      info[:is_of_type] = false
    else 
      info[:is_of_type] = nil
    end
    info
  end   
  
  def self.average_stories_per_day_by_source_and_year
    sources = Article.pluck(:source).uniq
    results = Hash.new
    sources.each do |source|
      results[source] = Hash.new
      totals = Article.where(:source=>source).group("YEAR(pub_date)").count
      totals.each do |year,total_articles|
        results[source][year] = (total_articles / 5).round
      end 
    end
    results
  end
  
  def self.sampletag_counts
    Article.where("sampletag is not null").group(:sampletag).count
  end

  private 

    def scan_dir
      File.join("article_scans" , scan_subdir)
    end
    
    def scan_subdir
      File.join(source.gsub(" ","_").downcase , pub_date.year.to_s , pub_date.month.to_s , pub_date.day.to_s)
    end

end
