# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
UsWorldCoverage::Application.initialize!

# WTF: need this to see scraper log msgs on the production server
Rails.logger.auto_flushing = 1
