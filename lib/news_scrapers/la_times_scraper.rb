module NewsScrapers

  class LaTimesScraper < NewsScrapers::ProQuestScraper
  
    SEARCH_PATH = "/latimes/results.html"
  
    def initialize
      super
    end

    def blacklist_scrape(d)
      if(d.year <= 1984)
        #TODO: PUT HERE
      else
        puts "BLACKLIST SCRAPING"
        puts blacklist_scrape_index(d, {:at_curr=>"Letters to the Editor"}, "Letters to the Editor")
        puts blacklist_scrape_index(d, {:at_curr=>"Recipe"}, "Recipe")
        puts blacklist_scrape_index(d, {:at_curr=>"Recording"}, "Recording")
      end
    end
  
    def get_source_name
      "LA Times"
    end

    private
          
      def get_search_url_and_params(d, additional_params={})
        if(d.year <= 1984)
          params = search_params_pre_1984 d
          
          url = MitProQuestExtractor::BASE_URL + MitProQuestExtractor::SEACH_PATH
        else
          params = search_params_post_1984 d
          params.merge!(additional_params)
          url = PublicProQuestExtractor::BASE_URL + SEARCH_PATH
        end
        return url, params        
      end
  
      # get the params for a more recent search
      def search_params_post_1984(d)
        # http://pqasb.pqarchiver.com/latimes/results.html?st=advanced&QryTxt=*&type=current&sortby=CHRON&datetype=6&frommonth=03&fromday=06&fromyear=1989&tomonth=03&today=06&toyear=1989&By=&Title=&at_curr=ALL&at_hist=article&at_hist=editorial_article&Sect=ALL
        add_default_params( d, {
          :QryTxt=>"*",
          :type=>"current",
          :at_curr=>"ALL",
          :Sect=>"ALL"
        })
      end
    
      # get the params for an archival search
      def search_params_pre_1984(d)
        # http://proquest.umi.com.libproxy.mit.edu/pqdweb?SQ=&DBId=14075&date=ON&onDate=03%2F05%2F1979&beforeDate=&fromDate=&toDate=&FT=1&AT=article&author=&sortby=CHRON&RQT=305&querySyntax=PQ&searchInterface=1&moreOptState=OPEN&TS=1326312163&h_pubtitle=&h_pmid=&clientId=5482&JSEnabled=1
        add_default_params( d, {
          :DBId=>'14075',
        })
      end

  
  end

end
