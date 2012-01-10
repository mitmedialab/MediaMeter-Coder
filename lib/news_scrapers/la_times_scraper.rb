module NewsScrapers

  class LaTimesScraper < NewsScrapers::ProQuestScraper
  
    SEARCH_PATH = "/latimes/results.html"
  
    def initialize
      super
    end
  
    private

      def populate_article_before_save(article)
        article.source = "LA Times"
      end
          
      def get_search_url_and_params(d)
        if(d.year <= 1984)
          params = search_params_pre_1984 d
          url = PublicProQuestExtractor::BASE_URL + SEARCH_PATH
        else
          params = search_params_post_1984 d
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
        # http://pqasb.pqarchiver.com/latimes/results.html?st=advanced&QryTxt=&type=historic&sortby=RELEVANCE&datetype=6&frommonth=03&fromday=05&fromyear=1979&tomonth=03&today=05&toyear=1979&By=&Title=&at_curr=ALL&at_hist=article
        add_default_params( d, {
          :QryTxt=>"",
          :type=>"historic",
          :at_curr=>"ALL",
        })
      end
  
  end

end