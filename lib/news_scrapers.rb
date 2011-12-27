require 'logger'
require 'date'

require 'news_scrapers/webpage_cache'
require 'news_scrapers/historical_news_scraper'
require 'news_scrapers/pro_quest_scraper'
require 'news_scrapers/wash_po_scraper'
require 'news_scrapers/la_times_scraper'

module NewsScrapers

  @@logger_instance = nil
  
  # Main Public API - scrape everything for all dates!
  def self.scrape_all
    dates = []
    #(Date.new(1979,3,5)..Date.new(1979,3,9)).each { |d| dates << d }
    (Date.new(1989,3,6)..Date.new(1989,3,10)).each { |d| dates << d }
    (Date.new(1999,3,1)..Date.new(1999,3,5)).each { |d| dates << d }
    (Date.new(2009,3,2)..Date.new(2009,3,6)).each { |d| dates << d }
    NewsScrapers.logger.info "Starting to scrape:"
    scraper = NewsScrapers::WashPoScraper.new
    #scraper = NewsScrapers::LaTimesScraper.new
    dates.each do |d|
      NewsScrapers.logger.info"  #{d}"
      scraper.scrape(d)
      exit
    end
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

# for debugging in standalone mode (DEPRECATED)
#NewsScrapers::scrape_all