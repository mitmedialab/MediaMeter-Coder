module NewsScrapers

  class LaTimesScraper < NewsScrapers::ProQuestScraper
  
    SEARCH_PATH = "/latimes/results.html"
  
    def initialize
      super
    end

    def blacklist_scrape(d)
      if(d.year <= 1984)
        puts "BLACKLIST SCRAPING < 1984"
        blacklist_scrape_index(d, {:OpAT=>'AND',
          :RQT=>'512',
          :SrchMode=>'2',
          :moreOptState=>'CLOSED',
          :Opauthor=>'AND',
          :autor=>'',
          :AT=>'any',
          :SQ=> '',
          :FO==>'AT',
          :OP1=>'OR',
          :FO1=>'AT',
          :SQ1=>'birth_notice',
          :OP2=>'OR',
          :SQ2=>'editorial_cartoon',
          :FO2=>'AT',
          :OP3=>'OR',
          :SQ3=>'display_ad',
          :FO3=>'AT',
          :OP4=>'OR',
          :SQ4=>'classified_ad',
          :FO4=>'AT'}, "birth_notice;editorial_cartoon;display_ad;classified_ad");

        blacklist_scrape_index(d, {:OpAT=>'AND',
          :RQT=>'512',
          :SrchMode=>'2',
          :moreOptState=>'CLOSED',
          :Opauthor=>'AND',
          :autor=>'',
          :AT=>'any',
          :SQ=> '',
          :FO==>'AT',
          :OP5=>'OR',
          :SQ5=>'letter',
          :FO5=>'AT',
          :OP6=>'OR',
          :SQ6=>'lottery_numbers',
          :FO6=>'AT',
          :OP7=>'OR',
          :SQ7=>'photo_standalone',
          :FO7=>'AT',
          :OP8=>'OR',
          :SQ8=>'stock_quote',
          :FO8=>'AT',
          :OP9=>'OR',
          :SQ9=>'tbl_of_contents',
          :FO9=>'AT'
        }, "letter;lottery_numbers;photo_standalone;stock_quote;tbl_of_contents");


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
          params.merge!(additional_params)
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
