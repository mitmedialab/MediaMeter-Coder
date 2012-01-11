require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'cgi'
require 'nokogiri'
require 'pp'

module NewsScrapers

  class HistoricalNewsScraper
    
    MECHANIZE_LOG_FILE = "log/mechanize.log"
    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/534.52.7 (KHTML, like Gecko) Version/5.1.2 Safari/534.52.7"
    
    def initialize
      @requester = Mechanize.new
      @requester.log = Logger.new MECHANIZE_LOG_FILE
      @requester.user_agent_alias = 'Mac Safari'
    end
  
    def scrape(d)
      raise NotImplementedError.new("Hey! You gotta implement a public scrape method in your subclass!")
    end
  
    def fetch_url(base_url, params={}, bypass_cache=false)
      full_url = base_url + "?" + encode_url_params(params)
      NewsScrapers.logger.info("      fetch_url #{full_url}")

      if !bypass_cache && NewsScrapers.cache.exists?(full_url)
        NewsScrapers.logger.debug("      from cache ("+NewsScrapers.cache.path_for(full_url)+")")
        contents = NewsScrapers.cache.get(full_url)
      else
        NewsScrapers.logger.debug("      from interwebs")
        page = @requester.get(full_url)
        contents = page.body
        NewsScrapers.logger.debug("      fetched")
        NewsScrapers.cache.put(full_url,contents)
      end
      NewsScrapers.logger.debug("      about to parse")
      Nokogiri::HTML(contents)
    end
    
    private
      
      # needed to write my own to allow multiple parameteres with the same name (key maps to an array or values, not just one)
      def encode_url_params(value, key = nil)
        case value
        when Hash then value.map { |k,v| 
          str = ""
          if v.is_a? Array
            str = v.map { |v2| encode_url_params(v2, "#{k}") }.join('&')
          else 
            str = encode_url_params(v, append_key(key,k)) 
          end
          str
        }.join('&')
        when Array then value.map { |v| encode_url_params(v, "#{key}[]") }.join('&')
        when nil   then ''
        else            
          "#{key}=#{CGI.escape(value.to_s)}" 
        end
      end
    
      def append_key(root_key, key)
        root_key.nil? ? key : "#{root_key}[#{key.to_s}]"
      end

  end

end
