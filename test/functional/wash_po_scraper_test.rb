require 'test_helper'

class WashPoScraperTest < ActiveSupport::TestCase

  test "parses out links" do
    scraper = WashPoScraper.new
    scraper.scrape("1979","03","05")
  end
  # test "the truth" do
  #   assert true
  # end
end
