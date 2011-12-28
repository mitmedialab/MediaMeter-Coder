module NewsScrapers

  class WashPoScraper < NewsScrapers::ProQuestScraper
  
    SEARCH_PATH_PRE_1986 = "/washingtonpost_historical/results.html"
    SEARCH_PATH_POST_1986 = "/washingtonpost/results.html"
  
    def initialize
      super
    end
  
    private
    
      def populate_article_before_save(article)
        article.source = "Washington Post"
      end
  
      def get_search_url_and_params(d)
        if(d.year <= 1986)
          search_path = SEARCH_PATH_PRE_1986
          params = search_params_pre_1986 d
        else
          search_path = SEARCH_PATH_POST_1986
          params = search_params_post_1986 d
        end
        return (BASE_URL + search_path), params        
      end
  
      # get the params for a more recent search
      def search_params_post_1986(d)
        # http://pqasb.pqarchiver.com/washingtonpost/results.html?st=advanced&uid=&MAC=50a23aa1f3f5c6104e90e36051420d61&QryTxt=*&sortby=RELEVANCE&datetype=6&frommonth=03&fromday=06&fromyear=1989&tomonth=12&today=03&toyear=2011&By=&Title=&Sect=ALL
        add_default_params( d, {
          :uid=>"",
          :MAC=>"50a23aa1f3f5c6104e90e36051420d61",
          :QryTxt=>"*",
          :Sect=>"ALL",
        })
      end
    
      # get the params for an archival search
      def search_params_pre_1986(d)
        # http://pqasb.pqarchiver.com/washingtonpost_historical/results.html?st=advanced&uid=&MAC=50a23aa1f3f5c6104e90e36051420d61&QryTxt=&sortby=CHRON&datetype=6&frommonth=3&fromday=5&fromyear=1979&tomonth=3&today=5&toyear=1979&By=&Title=&at_hist=article&at_hist=editorial_article
        add_default_params( d, {
          :uid=>"",
          :MAC=>"50a23aa1f3f5c6104e90e36051420d61",
          :QryTxt=>"",
        })
      end
  
  end

end