# Be sure to restart your server when you modify this file.
#
# This file contains settings for NewsScrapers module

# make sure the public base url is right, for exporting the url to the local scan PDF
Rails.application.config.after_initialize do 
  if Rails.env.production?
    NewsScrapers::public_base_url = 'mmdev.media.mit.edu:4000'
  else 
    NewsScrapers::public_base_url = 'us-word-coverage.dev'
  end
end
  