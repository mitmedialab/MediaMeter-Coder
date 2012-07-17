require 'logger'
require 'date'

require 'news_scrapers/webpage_cache'
require 'news_scrapers/historical_news_scraper'
require 'news_scrapers/pro_quest_scraper'
require 'news_scrapers/wash_po_scraper'
require 'news_scrapers/la_times_scraper'
require 'news_scrapers/chicago_tribune_scraper'
require 'news_scrapers/new_york_times_scraper'

module NewsScrapers

  @@logger_instance = nil
  
  @@requester_instance = nil
  
  @@cache = nil
    
  class << self
    # static @@public_base_url attr_accessor, as described here http://www.ruby-forum.com/topic/72967
    attr_accessor 'public_base_url'
  end
  
  def self.all_dates
    dates = []
    (Date.new(1979,3,5)..Date.new(1979,3,9)).each { |d| dates << d }
    (Date.new(1989,3,6)..Date.new(1989,3,10)).each { |d| dates << d }
    (Date.new(1999,3,1)..Date.new(1999,3,5)).each { |d| dates << d }
    (Date.new(2009,3,2)..Date.new(2009,3,6)).each { |d| dates << d }
    dates    
  end
  
  def self.scrape_washington_post
    NewsScrapers.logger.info "---------------------------------------------------------------"
    NewsScrapers.logger.info "Starting to scrape Washingon Post:"
    self.scrape(self.all_dates, [NewsScrapers::WashPoScraper.new])
  end

  def self.scrape_chicago_tribune
    NewsScrapers.logger.info "---------------------------------------------------------------"
    NewsScrapers.logger.info "Starting to scrape Chicago Tribune"
    self.scrape(self.all_dates, [NewsScrapers::ChicagoTribuneScraper.new])
  end

  def self.scrape_los_angeles_times
    NewsScrapers.logger.info "---------------------------------------------------------------"
    self.scrape(self.all_dates, [NewsScrapers::LaTimesScraper.new])
  end

  def self.scrape_new_york_times
    NewsScrapers.logger.info "---------------------------------------------------------------"
    self.scrape(self.all_dates, [NewsScrapers::NewYorkTimesScraper.new])
  end
  
  # Main Public API - scrape everything for all dates!
  def self.scrape_all
    NewsScrapers.logger.info "---------------------------------------------------------------"
    NewsScrapers.logger.info "Starting to scrape all:"
    scrapers = []
    scrapers.push( NewsScrapers::WashPoScraper.new )
    scrapers.push( NewsScrapers::ChicagoTribuneScraper.new )
    scrapers.push( NewsScrapers::LaTimesScraper.new )
    scrapers.push( NewsScrapers::NewYorkTimesScraper.new )
    self.scrape(self.all_dates, scrapers)
  end
  
  def self.scrape(dates,scrapers)
    dates.each do |d|
      scrapers.each do |scraper|
        #note: this is inefficient, since it scrapes all individual articles
        #including ones which will be later blaclisted
        NewsScrapers.logger.info"  Scraping #{d} from the #{scraper.get_source_name}"
        scraper.scrape(d)
        NewsScrapers.logger.flush
        scraper.blacklist_scrape(d)
        NewsScrapers.logger.flush
      end
    end
  end
  
  # we lost all the scans in a hard drive crash, so this method will re-download them
  # ASSUMPTIONS: all are from proquest
  def self.download_all_scans
    r = NewsScrapers::requester
    # iterate over all articles with scans
    total = Article.with_scans.count
    current = 1
    NewsScrapers.logger.info "Ready to download #{total} scans"
    NewsScrapers.logger.flush # for production (hopefully)
    Article.with_scans.each do |article|
      NewsScrapers.logger.info "  [ #{current} of #{total} ] Downloading for article #{article.id}"
      NewsScrapers.logger.flush # for production (hopefully)
      if article.scan_local_file_exists?
        NewsScrapers.logger.info "    scan local file already exists, not going to redownload it!"
      else
        doc = Nokogiri::HTML(r.get(article.scan_src_url).body)
        new_scan_file_url = "http://proquest.umi.com.libproxy.mit.edu" + doc.css("frame")[1].attribute('src').value
        article.scan_file_url = new_scan_file_url
        article.save
        article.download_scan
        sleep(rand(5)+5) # sleep between 5 and 10 seconds... to not tax their server
      end
      NewsScrapers.logger.flush # for production (hopefully)
      current = current + 1
    end
    NewsScrapers.logger.info "Done!"
  end
  
  # public API to fetch one static instance of the mechanize downloader 
  def self.requester
    if @@requester_instance == nil
      @@requester_instance = Mechanize.new
      @@requester_instance.log = Logger.new "log/mechanize.log"
      @@requester_instance.user_agent_alias = 'Mac Safari'
    end
    @@requester_instance
  end  
  
  # TODO: replace with sprintf (this is dumb, but was quick and easy)
  def self.prefix_with_zero number
    fixed = number.to_s
    fixed = "0" + number.to_s if number < 10
    fixed
  end
  
  # Have the cache here at the top level so it is shared across all scraping
  def self.cache
    if @@cache == nil
      @@cache = NewsScrapers::WebpageCache.new( File.join("/tmp","scraper") )
    end
    @@cache
  end
  
  # Be smart about logging whiel running inside or outside of Rails
  def self.logger
    return Rails.logger if defined? Rails
    if @@logger_instance == nil
      @@logger_instance = Logger.new("news_scrapers_#{Rails.env}.log")
    end
    @@logger_instance
  end
  
end

# for debugging in standalone mode
#NewsScrapers::scrape_all
