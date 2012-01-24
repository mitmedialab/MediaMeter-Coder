require 'rubygems'
require 'nytimes_articles'
require 'digest/md5'
require 'yaml'

module NewsScrapers

  # Descend from this and override a few methods to handle results from proquest archives
  class NewYorkTimesScraper < NewsScrapers::HistoricalNewsScraper
    
    BASE_URL = "http://query.nytimes.com"
    SEARCH_URL = "/search/query"

    def initialize
      super
      Nytimes::Articles::Base.api_key = ''  # ASK RAHUL FOR THIS!
    end
  
    def scrape(d)
      if d.year < 1981
        website_scrape d
      else
        api_scrape d
      end
    end

    def get_source_name
      "New York Times"
    end
  
    private
    
      def api_scrape(d)
        #http://api.nytimes.com/svc/search/v1/article?format=json&query=body%3A%22the%22+source_facet%3A%5BThe+New+York+Times%5D&begin_date=20090306&end_date=20090307&fields=lead_paragraph+%2Csection_page_facet%2C+abstract%2Cbody%2C+title%2C+byline%2C+date%2C+word_count%2C+page_facet%2C+nytd_section_facet&offset=40&rank=oldest&api-key=####
        rs = api_get_results(d)
        page_count = rs.total_pages + 0
        NewsScrapers.logger.info "    #{page_count} pages of results"
        more_valid_results = true

        (0..page_count).each do |current_page|
          if !more_valid_results
            NewsScrapers.logger.info "      Not finding anymore articles with the right date - bailing!"
            return
          end
          NewsScrapers.logger.info "    Page #{current_page}"
          rs = api_get_results(d, current_page)
          # get rid of the artiles with the wrong date (because we can't search for just one day!)
          nyt_article_array = rs.results.reject do |nyt_article|
            nyt_article.date != d
          end
          more_valid_results = false if rs.results.length > nyt_article_array.length
          # now add all the articles found
          nyt_article_array.each do |nyt_article|
            article = Article.new
            article.set_queue_status(:in_progress)
            article.source = get_source_name
            article.pub_date = d
            article.byline = nyt_article.byline
            article.headline = nyt_article.title
            article.page = nyt_article.page
            article.src_url = nyt_article.url
            article.abstract = nyt_article.body  
            article.word_count = nyt_article.word_count
            article.section = nyt_article.section_page_facet
            if article.section == nil && nyt_article.nytd_section_facet != nil
              article.section = nyt_article.nytd_section_facet.join(", ")
            end
            if article.has_url?
              NewsScrapers.logger.info "      Article #{article.src_url}"
            else
              NewsScrapers.logger.info "      Article #{article.fake_url}"
            end
            if Article.scraped_already? article.fake_url
              NewsScrapers.logger.info "        scraped already - skipping"    
            else 
              article.set_queue_status(:complete)
              article.save 
              NewsScrapers.logger.info "        saved"
            end
          end
        end
      end
      
      # handle local caching of json returned from api queries (to make development not hit the daily max)
      def api_get_results(d,offset=0)
        start_date = d
        end_date = d + 1   
        fake_url = start_date.to_s + "_to_" + end_date.to_s + "_page" + offset.to_s
        if NewsScrapers.cache.exists? fake_url
          NewsScrapers.logger.debug("      from cache #{fake_url}")
          result_set = YAML::load(NewsScrapers.cache.get fake_url)
        else
          NewsScrapers.logger.debug("      from interwebs #{fake_url}")
          end_date = d + 1 
          result_set = Nytimes::Articles::Article.search(
            :body=>'the', 
            :source=>'The New York Times', 
            :begin_date=>d.year.to_s + NewsScrapers::prefix_with_zero(d.month) + NewsScrapers.prefix_with_zero(d.day), #'19890306',
            :end_date=>end_date.year.to_s + NewsScrapers::prefix_with_zero(end_date.month) + NewsScrapers.prefix_with_zero(end_date.day), #'19890307', 
            :rank=>:oldest, 
            :fields=>[:lead_paragraph, :section_page_facet, :abstract, :body, :title, 
                      :byline, :date, :word_count, :page_facet, :nytd_section_facet], 
            :offset=>offset)
          NewsScrapers.cache.put fake_url, YAML::dump(result_set) 
          sleep 1 # throttle  a little
        end
        result_set
      end
      
      def api_get_cache_key(start_date, end_date, offset)
        NewsScrapers.cache.key_for(start_date.to_s+end_date.to_s+offset.to_s)
      end
      
      # get all the articles on a particlar day and insert them into the db
      def website_scrape(d)
        search_url, search_params = website_get_search_url_and_params(d)
        
        doc = fetch_url( search_url, search_params)
        
        #figure out number of result pages
        page_count = website_parse_out_page_count(doc)
        NewsScrapers.logger.info "    #{page_count} pages of results"
  
        #for each page of results
        article_count = 0
        (0..page_count-1).each do |current_page|
          NewsScrapers.logger.info "    Page #{current_page}"
          search_params[:frow] = 10 * current_page
          doc = fetch_url(search_url, search_params)  # will refetch from cache the first time - no biggie
          #  for each article link
          website_parse_out_article_urls(doc).each do |article_info|
            NewsScrapers.logger.info "      Article #{article_info[:url]}"
            if Article.scraped_already? article_info[:url]
              # skip it if we've already fetched this link
              NewsScrapers.logger.info "        scraped already - skipping"
            else
              # load an article page and parse it to fill in an Article object, save it
              article_doc = fetch_url(article_info[:url],{},false, false)  # fetch without mechanize to avoid "\x8B" from ASCII-8BIT to UTF-8 encoding problem
              article = website_parse_out_article_info(article_doc)
              article.src_url = article_info[:url]
              article.pub_date = d
              article.source = get_source_name
              article.headline = article_info[:headline] if article.headline == nil
              article.section = article_info[:section] if article.section == nil
              article.byline = article_info[:byline] if article.byline == nil
              article.word_count = article_info[:word_count] if article.word_count == nil
              article.set_queue_status(:complete)
              article.save
              article_count = article_count + 1
              NewsScrapers.logger.info "        saved"
              sleep 0.2 # throttle each article request
            end
          end
          sleep 1 # throttle each page request
        end      
      
        article_count
      end
      
      def website_parse_out_article_info(doc)
        article = Article.new
        article.set_queue_status(:in_progress)
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
        article
      end

      def website_parse_out_article_urls(doc)
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
  
      def website_parse_out_page_count doc 
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
  
      def website_get_search_url_and_params d
        params = []
        params = website_search_params_pre_1980 d
        return (BASE_URL + SEARCH_URL), params
      end
  
      def website_search_params_pre_1980 d
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
        :mon1=>NewsScrapers::prefix_with_zero(d.month),
        :day1=>NewsScrapers::prefix_with_zero(d.mday),
        :year1=>d.year,
        :mon2=>NewsScrapers::prefix_with_zero(d.month),
        :day2=>NewsScrapers::prefix_with_zero(d.mday),
        :year2=>d.year,
        }
      end

   end
       
end