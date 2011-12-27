
module NewsScrapers

  # Descend from this and override a few methods to handle results from proquest archives
  class ProQuestScraper < NewsScrapers::HistoricalNewsScraper
    
    BASE_URL = "http://pqasb.pqarchiver.com"

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
        search_params[:start] = 10 * current_page
        doc = fetch_url(search_url, search_params)  # will refetch from cache the first time - no biggie
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
            article = Article.from_pro_quest_doc(article_doc)
            article.src_url = article_url
            article.pub_date = d
            populate_article_before_save(article) # delegate to child for source, etc.            
            article.save
            article_count = article_count + 1
            NewsScrapers.logger.info "        saved"
          end
        end
      end      
    
      article_count
    end
    
    private
  
      # take a parsed results page and get all the urls for articles
      def parse_out_article_urls(doc)
        doc.css('font.result_title > a').collect do |a|
          a.attribute('href').value
        end
      end

      def populate_article_before_save(article)
        raise NotImplementedError.new("Hey! You must implement populte_article_before_save in your subclass")
      end

      # override this and return the full url
      def get_search_url_and_params(d)
        raise NotImplementedError.new("Hey! You must implement get_search_url in your subclass")
      end
    
      # pass in the first page of results, and get back the number of pages of results 
      def parse_out_page_count(doc)
        page_count = nil
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
        page_count
      end
   
   end
       
end