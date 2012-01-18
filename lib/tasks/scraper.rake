require 'news_scrapers'

namespace :scraper do
	
	desc "Control the newspaper article scraper"

  task :all =>:environment do
    NewsScrapers::scrape_all
  end

  task :washpo =>:environment do
    NewsScrapers::scrape_washington_post
  end

  task :chictrib =>:environment do
    NewsScrapers::scrape_chicago_tribune
  end

  task :latimes =>:environment do
    NewsScrapers::scrape_los_angeles_times
  end

  task :nytimes =>:environment do
    NewsScrapers::scrape_new_york_times
  end


end