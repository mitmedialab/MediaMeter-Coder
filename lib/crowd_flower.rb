require 'logger'
require 'csv'
 
module CrowdFlower

  @@logger_instance = nil
  
  # Be smart about logging while running inside or outside of Rails
  def self.logger
    return Rails.logger if defined? Rails
    if @@logger_instance == nil
      @@logger_instance = Logger.new("crowd_flower_development.log")
    end
    @@logger_instance
  end
  
end

# for debugging in standalone mode
#NewsScrapers::scrape_all