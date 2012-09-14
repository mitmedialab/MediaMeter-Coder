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

  alias_attribute :name, :headline

  has_many      :answers
  has_many      :golds
  
  before_save   ArticlePrepper.new
  
  scope :completed, where(:queue_status=>:complete).order(:pub_date)
  scope :with_scans, where("scan_src_url IS NOT NULL").order(:pub_date)
  
  GENDERS = {
    'F'=>'Female Author',
    'M'=>'Male Author',
    'U'=>'Unknown Gender Author',
    'X'=>'No Author'
  }
  
  def self.all_genders
    GENDERS.keys.sort
  end
  
  def self.gender_name key
    GENDERS[key]
  end
  
  # get the relative url to the local copy of the PDF file
  def url_to_scan_local_file
    url = ""
    url = File.join(scan_subdir, scan_local_filename) if has_scan_local_filename?
    url
  end
  
  # has the scan file been download already?
  def scan_local_file_exists?
    return false if !has_scan_file_url?
    return File.exists?( File.join( path_to_scan_dir, scan_local_filename ))
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
  def answers_to_question(question_id)
    answers.select do |answer|
      answer.question_id==question_id
    end
  end
  
  def answers_to_question_from_user(question_id,user_id)
    answers.select do |answer|
      answer.question_id==question_id && answer.user_id == user_id
    end
  end
  
  def missing_gold_for_question?(question_id)
    gold_for_question(question_id) == nil
  end
  
  def has_gold_for_question?(question_id)
    !missing_gold_for_question?(question_id)
  end

  # assumes you've loaded the article with the linked has_many :golds
  def gold_for_question(question_id)
    gold = nil
    found_golds = golds.select { |g| g.question_id==question_id }
    gold = found_golds.first if found_golds.count > 0   # there should be only one!
    gold
  end

  # return a summary hash about agreement between the answers already loaded
  def agreement_info_for_question(question_id)
    answers_list = answers_to_question(question_id)

    info = {:count => answers_list.count}
    likely_answer = nil
    likely_answer_count = 0
    (1..5).each do |possible_answer|
      matching_count = answers_list.count {|a| (a.answer==possible_answer)}
      info[possible_answer] = matching_count.to_f / answers_list.count.to_f
      info[possible_answer] = 0 if info[possible_answer].nan?
      if matching_count > likely_answer_count
        likely_answer = possible_answer
        likely_answer_count = matching_count
      end
    end
    
    info[:likely_answer] = likely_answer
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

  def self.all_sampletags
    Article.where("sampletag is not null").pluck(:sampletag).uniq.sort
  end

  def self.all_sources
    Article.group(:source).pluck(:source).sort
  end
  
  def self.all_years
    Article.pluck("YEAR(pub_date)").uniq.sort
  end
  
  def self.counts_by_source_year sampletags
    results = Hash.new
    Article.completed.where(:sampletag=>sampletags).group(:source,"YEAR(pub_date)").
      where('YEAR(articles.pub_date) > 0').count.each do |key, value|
      source = key[0]
      year = key[1]
      article_count = value
      results[source] = Hash.new unless results.has_key? source
      results[source][year] = article_count
    end
    results
  end
  
  def self.gender_counts_by_source_year sampletags
    results = Hash.new
    Article.completed.where(:sampletag=>sampletags).group(:gender,:source,"YEAR(pub_date)").
      where('YEAR(articles.pub_date) > 0').count.each do |key, value|
      gender = key[0]
      source = key[1]
      year = key[2]
      article_count = value
      results[gender] = Hash.new unless results.has_key? gender
      results[gender][source] = Hash.new unless results[gender].has_key? source
      results[gender][source][year] = value
    end
    results
  end

  private 

    def scan_dir
      File.join("article_scans" , scan_subdir)
    end
    
    def scan_subdir
      File.join(source.gsub(" ","_").downcase , pub_date.year.to_s , pub_date.month.to_s , pub_date.day.to_s)
    end

end
