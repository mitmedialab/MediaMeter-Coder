require 'news_scrapers'

namespace :scraper do
	
	desc "Control the newspaper article scraper"

  task :all =>:environment do
    Rails.logger.info "Starting to scrape all --------------------------------"
    NewsScrapers::scrape_all
  end

end