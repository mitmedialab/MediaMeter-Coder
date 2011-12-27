
module NewsScrapers

  # Descend from this and override a few methods to handle results from proquest archives
  class NewYorkTimesScraper < NewsScrapers::HistoricalNewsScraper
    
    BASE_URL = "http://query.nytimes.com"
    SEARCH_URL = "/search/query"

    def initialize
      super
    end
  
    # get all the articles on a particlar day and insert them into the db
    def scrape(d)
      NewsScrapers.logger.info "    Scraping with #{d}"
            
      search_url, search_params = get_search_url_and_params(d)
      
      doc = fetch_url( search_url, search_params)
      
      #figure out number of result pages
      page_count = parse_out_page_count(doc)
      NewsScrapers.logger.info "    #{page_count} pages of results"

      #for each page of results
      article_count = 0
      (0..page_count-1).each do |current_page|
        NewsScrapers.logger.info "    Page #{current_page}"
        search_params[:frow] = 10 * current_page
        doc = fetch_url(search_url, search_params)  # will refetch from cache the first time - no biggie
        #  for each article link
        parse_out_article_urls(doc).each do |article_info|
          NewsScrapers.logger.info "      Article #{article_info[:url]}"
          if Article.scraped_already? article_info[:url]
            # skip it if we've already fetched this link
            NewsScrapers.logger.info "        scraped already - skipping"
          else
            # load an article page and parse it to fill in an Article object, save it
            article_doc = fetch_url(article_info[:url])
            article = parse_out_article_info(d, article_doc)
            article.src_url = article_info[:url]
            article.pub_date = d
            article.source = "New York Times"
            article.headline = article_info[:headline] if article.headline == nil
            article.section = article_info[:section] if article.section == nil
            article.byline = article_info[:byline] if article.byline == nil
            article.word_count = article_info[:word_count] if article.word_count == nil
            pp article
            pp article_info
            exit
            #article.save
            article_count = article_count + 1
            NewsScrapers.logger.info "        saved"
          end
        end
      end      
    
      article_count
    end
    
    private
    
      def parse_out_article_info(d, doc)
        article = Article.new
        if d.year <= 1980
          article.headline = doc.css("h1.abstractHeadline").first.content
          article.abstract = doc.css("p.summaryText").first.content
          bylines = doc.css(".abstractView h6.byline")
          if bylines.length>0
            article.byline = bylines[0].content.strip
            parts = bylines[2].content.strip.split(",")
            article.section = parts[1].strip.delete("Section ")
            article.page = parts[2].strip.delete("Page ")
            article.word_count = parts[4].strip.delete("words").strip
          end
        else
          article.headline = doc.css("h1").first.content
          if doc.css("#mod-article-byline > span").length > 0
            article.byline = doc.css("#mod-article-byline > span").first.content
          end
          
          article.abstract = (doc.css("#mod-a-body-first-para p").collect {|t| t.content}).join(" ")
        end
        article
      end

      def parse_out_article_urls(doc)
        doc.css('ol.srchSearchResult li').collect do |item|
          metadata = {}
          metadata[:url] = item.css("h3 a").last.attribute('href').value
          metadata[:headline] = item.css("h3 a").last.content
          if item.css(".details .byline").length > 0
            metadata[:byline]  = item.css(".details .byline").first.content
          end
          if item.css(".details .section").length > 0
            metadata[:section]  = item.css(".details .section").first.content
          end
          if item.css(".details .words").length > 0
            metadata[:word_count]  = item.css(".details .words").first.content.delete(" words")
          end
          metadata
        end
      end
  
      def parse_out_page_count doc 
        span = doc.css('#sortBy .sortRight > .sortText').first
        matches = span.content.match(/(.*) - (.*) of (.*) Results/)
        if matches
          matches = matches.to_a
          start_idx = matches[1].to_i
          end_idx = matches[2].to_i
          total_results = matches[3].to_i
          results_per_page = end_idx  - start_idx + 1
          page_count = (total_results.to_f / results_per_page.to_f).ceil
        end
        page_count
      end
  
      def get_search_url_and_params d
        params = []
        if d.year <= 1980
          params = search_params_pre_1980 d
        else 
          params = search_params_post_1980 d
        end
        return (BASE_URL + SEARCH_URL), params
      end
  
      def search_params_pre_1980 d
        # http://query.nytimes.com/search/query?frow=0&n=10&srcht=s&daterange=period&query=&srchst=p&submit.x=33&submit.y=11&submit=sub&hdlquery=&bylquery=&mon1=03&day1=05&year1=1979&mon2=03&day2=05&year2=1979
        {
        :frow=>"0",
        :n=>"10",
        :srcht=>"s",
        :daterange=>"period",
        :query=>"",
        :srchst=>"p",
        "submit.x"=>"33",
        "submit.y"=>"11",
        :submit=>"sub",
        :hdlquery=>"",
        :bylquery=>"",
        :mon1=>prefix_with_zero(d.month),
        :day1=>prefix_with_zero(d.mday),
        :year1=>d.year,
        :mon2=>prefix_with_zero(d.month),
        :day2=>prefix_with_zero(d.mday),
        :year2=>d.year,
        }
      end
   
      def search_params_post_1980 d
        # http://query.nytimes.com/search/query?frow=0&n=10&srcht=a&query=&srchst=nyt&submit.x=34&submit.y=15&submit=sub&hdlquery=&bylquery=&daterange=period&mon1=03&day1=06&year1=1989&mon2=03&day2=06&year2=1989
        {
        :frow=>"0",
        :n=>"10",
        :srcht=>"a",
        :query=>"",
        :srchst=>"nyt",
        "submit.x"=>"34",
        "submit.y"=>"15",
        :submit=>"sub",
        :hdlquery=>"",
        :bylquery=>"",
        :daterange=>"period",
        :mon1=>prefix_with_zero(d.month),
        :day1=>prefix_with_zero(d.mday),
        :year1=>d.year,
        :mon2=>prefix_with_zero(d.month),
        :day2=>prefix_with_zero(d.mday),
        :year2=>d.year
        }
      end
   
      def prefix_with_zero number
        fixed = number
        fixed = "0" + number.to_s if number < 10
        fixed
      end
        
   end
       
end