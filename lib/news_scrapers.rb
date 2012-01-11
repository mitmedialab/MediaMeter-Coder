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
  
  # Main Public API - scrape everything for all dates!
  def self.scrape_all
    dates = []
    (Date.new(1979,3,5)..Date.new(1979,3,9)).each { |d| dates << d }
    (Date.new(1989,3,6)..Date.new(1989,3,10)).each { |d| dates << d }
    (Date.new(1999,3,1)..Date.new(1999,3,5)).each { |d| dates << d }
    (Date.new(2009,3,2)..Date.new(2009,3,6)).each { |d| dates << d }
    NewsScrapers.logger.info "Starting to scrape:"
    scrapers = []
    scrapers.push( NewsScrapers::WashPoScraper.new )
    scrapers.push( NewsScrapers::ChicagoTribuneScraper.new )
    scrapers.push( NewsScrapers::LaTimesScraper.new )
    scrapers.push( NewsScrapers::NewYorkTimesScraper.new )
    dates.each do |d|
      NewsScrapers.logger.info"  #{d}"
      scrapers.each do |scraper|
        scraper.scrape(d)
      end
    end
  end
  
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