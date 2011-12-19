module NewsScrapers

  class WashPoScraper < NewsScrapers::HistoricalNewsScraper
  
    BASE_URL = "http://pqasb.pqarchiver.com"
    SEARCH_PATH_PRE_1986 = "/washingtonpost_historical/results.html"
    SEARCH_PATH_POST_1986 = "/washingtonpost/results.html"
  
    def initialize
      super
    end
  
    # get all the articles on a particlar day and insert them into the db
    def scrape(d)
      
      NewsScrapers.logger.info "    Scraping with #{d}"
      
      if(d.year <= 1986)
        search_path = SEARCH_PATH_PRE_1986
        params = search_params_pre_1986 d
      else
        search_path = SEARCH_PATH_POST_1986
        params = search_params_post_1986 d
      end
      
      doc = fetch_url(BASE_URL + search_path,params)
      
      #figure out number of result pages
      page_count = 0
      doc.css('#container td.default').each do |cell|
        matches = cell.content.match(/Results (.*) to (.*) of (.*)/)
        if matches
          matches = matches.to_a
          start_idx = matches[1].to_i
          end_idx = matches[2].to_i
          total_results = matches[3].to_i
          results_per_page = end_idx  - start_idx + 1
          page_count = (total_results.to_f / results_per_page.to_f).ceil
        end
      end
      NewsScrapers.logger.info "    #{page_count} pages"
      
      #for each page of results
      (0..page_count-1).each do |current_page|
        NewsScrapers.logger.info "    Page #{current_page}"
        params[:start] = 10 * current_page
        doc = fetch_url(BASE_URL + search_path, params)  # will refetch from cache the first time - no biggie
        #  for each article link
        parse_out_article_urls(doc).each do |article_path|
          article_url = BASE_URL + article_path
          NewsScrapers.logger.info "      Article #{article_url}"
          if Article.scraped_already? article_url
            # skip it if we've already fetched this link
            NewsScrapers.logger.info "        scraped already - skipping"
          else
            # load an article page and parse it to fill in an Article object, save it
            article_doc = fetch_url(article_url)
            article = Article.from_wash_po_doc(article_doc,article_url,d)
            article.save
            NewsScrapers.logger.info "        saved"
          end
          exit
        end
      end
      
    end
  
    private
  
      # take a parsed results page and get all the urls for articles
      def parse_out_article_urls(doc)
        doc.css('font.result_title > a').collect do |a|
          a.attribute('href').value
        end
      end
  
      # get the params for a more recent search
      def search_params_post_1986(d)
        # http://pqasb.pqarchiver.com/washingtonpost/results.html?st=advanced&uid=&MAC=50a23aa1f3f5c6104e90e36051420d61&QryTxt=*&sortby=RELEVANCE&datetype=6&frommonth=03&fromday=06&fromyear=1989&tomonth=12&today=03&toyear=2011&By=&Title=&Sect=ALL
        {
        :st=>"advanced",
        :uid=>"",
        :MAC=>"50a23aa1f3f5c6104e90e36051420d61",
        :QryTxt=>"*",
        :sortby=>"RELEVANCE",
        :datetype=>"6",
        :frommonth=>d.month,
        :fromday=>d.mday,
        :fromyear=>d.year,
        :tomonth=>d.month,
        :today=>d.mday,
        :toyear=>d.year,
        :By=>"",
        :Title=>"",
        :Sect=>"ALL",
        }
      end
    
      # get the params for an archival search
      def search_params_pre_1986(d)
        # http://pqasb.pqarchiver.com/washingtonpost_historical/results.html?st=advanced&uid=&MAC=50a23aa1f3f5c6104e90e36051420d61&QryTxt=&sortby=CHRON&datetype=6&frommonth=3&fromday=5&fromyear=1979&tomonth=3&today=5&toyear=1979&By=&Title=&at_hist=article&at_hist=editorial_article
        {
        :st=>"advanced",
        :uid=>"",
        :MAC=>"50a23aa1f3f5c6104e90e36051420d61",
        :QryTxt=>"",
        :sortby=>"CHRON",
        :datetype=>"6",
        :frommonth=>d.month,
        :fromday=>d.mday,
        :fromyear=>d.year,
        :tomonth=>d.month,
        :today=>d.mday,
        :toyear=>d.year,
        :By=>"",
        :Title=>"",
        :at_hist=>["article","editorial_article"]
        }
      end
  
  end

end