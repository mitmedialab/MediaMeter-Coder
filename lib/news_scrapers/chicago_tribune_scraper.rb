module NewsScrapers

  class ChicagoTribuneScraper < NewsScrapers::ProQuestScraper
  
    SEARCH_PATH = "/chicagotribune/results.html"
  
    def initialize
      super
    end
  
    private

      def populate_article_before_save(article)
        article.source = "Chicago Tribune"
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
        # http://pqasb.pqarchiver.com/latimes/results.html?st=advanced&QryTxt=*&type=current&sortby=CHRON&datetype=6&frommonth=03&fromday=06&fromyear=1989&tomonth=03&today=06&toyear=1989&By=&Title=&at_curr=ALL&Sect=ALL
        add_default_params( d, {
          :QryTxt=>"*",
          :type=>"current",
          :at_curr=>"ALL",
          :Sect=>"ALL"
        })
      end
    
      # get the params for an archival search
      def search_params_pre_1984(d)
        # http://pqasb.pqarchiver.com/chicagotribune/results.html?st=advanced&QryTxt=&type=historic&sortby=CHRON&datetype=6&frommonth=03&fromday=03&fromyear=1979&tomonth=03&today=03&toyear=1979&By=&Title=&at_hist=article&at_hist=editorial_article&at_hist=front_page
        add_default_params( d, {
          :QryTxt=>"",
          :type=>"historic",
        })
      end
  
  end

end