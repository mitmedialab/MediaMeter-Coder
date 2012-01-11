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
         params = search_params_pre_1986 d
          url = MitProQuestExtractor::BASE_URL + MitProQuestExtractor::SEACH_PATH
        else
          search_path = SEARCH_PATH_POST_1986
          params = search_params_post_1986 d
          url = PublicProQuestExtractor::BASE_URL + search_path
        end
        return url, params        
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
        # http://proquest.umi.com.libproxy.mit.edu/pqdweb?SQ=&DBId=9866&date=ON&onDate=03%2F05%2F1979&beforeDate=&fromDate=&toDate=&FT=1&AT=article&author=&sortby=CHRON&RQT=305&querySyntax=PQ&searchInterface=1&moreOptState=OPEN&TS=1326313179&h_pubtitle=&h_pmid=&clientId=5482&JSEnabled=1
        add_default_params( d, {
          :DBId=>'9866',
        })
      end
  
  end

end