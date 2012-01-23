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
  
  @@cache = nil
  
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
        scraper.blacklist_scrape(d)
      end
    end
  end
  
  # TODO: replace with sprintf (this is dumb, but was quick and easy)
  def self.prefix_with_zero number
    fixed = number
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
      @@logger_instance = Logger.new("news_scrapers_development.log")
    end
    @@logger_instance
  end
  
end

# for debugging in standalone mode
#NewsScrapers::scrape_all
