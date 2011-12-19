require 'logger'
require 'date'

require 'news_scrapers/webpage_cache'
require 'news_scrapers/historical_news_scraper'
require 'news_scrapers/wash_po_scraper'

module NewsScrapers

  @@logger_instance = nil
  
  def self.scrape_all
    dates = []
    (Date.new(1979,3,5)..Date.new(1979,3,9)).each { |d| dates << d }
    (Date.new(1989,3,6)..Date.new(1989,3,10)).each { |d| dates << d }
    (Date.new(1999,3,1)..Date.new(1999,3,5)).each { |d| dates << d }
    (Date.new(2009,3,2)..Date.new(2009,3,6)).each { |d| dates << d }
    NewsScrapers.logger.info "Starting to scrape the Washington Post"
    scraper = NewsScrapers::WashPoScraper.new
    NewsScrapers.logger.info "  Starting to Scrape"
    scraper.scrape(dates[0])
  end
  
  def self.logger
    return Rails.logger if defined? Rails
    if @@logger_instance == nil
      @@logger_instance = Logger.new("news_scrapers_development.log")
    end
    @@logger_instance
  end
  
end

#NewsScrapers::scrape_all