module NewsScrapers

  class BaseProQuestExtractor
    
  end

  class MitProQuestExtractor < NewsScrapers::BaseProQuestExtractor
    
    def initialize
      super
    end
    
  end
 
  class PublicProQuestExtractor < NewsScrapers::BaseProQuestExtractor
    BASE_URL = "http://pqasb.pqarchiver.com"
    
    def initialize
      super
    end
    
    def get_base_url
      BASE_URL  
    end

    # pass in the first page of results, and get back the number of pages of results 
    def extract_page_count(doc)
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
    
    # take a parsed results page and get all the urls for articles
    def extract_article_links(doc)
      doc.css('font.result_title > a').collect do |a|
        metadata = {}
        metadata[:url] = get_base_url + a.attribute('href').value
        metadata[:headline] = a.content.strip
        metadata
       end
    end
    
    def extract_article_info!(article, doc)
      doc.css('div#container table tr td table tr').each do |row|
        if(article.headline.nil?)
          if (row>('td.docTitle')).length > 0
            if (row>('td.docTitle')).children[0].name!="img"
              article.headline = (row>('td.docTitle')).children[0].content 
            end
          end
        end

        if (row>('td p')).length > 0
          article.abstract = (row>('td p')).children[0].content
        end
        if (row>('td'))[0].content == "Author:"
          article.byline = (row>('td'))[1].content
        end
        if (row>('td'))[0].content == "Start Page:"
          article.page = (row>('td'))[1].content
        end
        if (row>('td'))[0].content == "Pages:"
          article.total_pages = (row>('td'))[1].content.to_i
        end
        if (row>('td'))[0].content == "Text Word Count:"
          article.word_count = (row>('td'))[1].content.to_i
        end
        if (row>('td'))[0].content == "Section:"
          article.section = (row>('td'))[1].content
        end
      end
      # hack for Chicago Tribune
      if (doc.css('div.docTitle').length > 0) && (article.abstract == nil) 
        if (doc.css('div.docTitle').first.parent.children.length >= 12)
           article.abstract = doc.css('div.docTitle').first.parent.children[11].content.strip
        end
      end
    end
    
  end

  # Descend from this and override a few methods to handle results from proquest archives
  class ProQuestScraper < NewsScrapers::HistoricalNewsScraper
    
    def initialize
      super
    end

    def scrape_index(d)
      NewsScrapers.logger.info "    Scraping with #{d}"

      search_url, search_params = get_search_url_and_params(d)

      doc = fetch_url( search_url, search_params)

      extractor = get_extractor(d)

      #figure out number of result pages
      page_count = extractor.extract_page_count(doc)
      NewsScrapers.logger.info "    #{page_count} pages of results"

      #for each page of results
      article_count = 0      
      (0..page_count-1).each do |current_page|
        NewsScrapers.logger.info "    Page #{current_page}"
        search_params[:start] = 10 * current_page
        doc = fetch_url(search_url, search_params)  # will refetch from cache the first time - no biggie
        #  for each article link
        extractor.extract_article_links(doc).each do |article_info|
          NewsScrapers.logger.info "      Article #{article_info[:url]}"
          if Article.scraped_already? article_info[:url]
            # skip it if we've already fetched this link
            NewsScrapers.logger.info "        scraped already - skipping"
          else
            article = Article.new(:src_url  => article_info[:url],
                                  :headline => article_info[:headline])
            populate_article_before_save(article) # delegate to child for source
            article.set_queue_status(:queued)
            article.pub_date = d
            article.save
            article_count += 1
            NewsScrapers.logger.info "        created"
          end
        end
      end
      article_count
    end
     
    def get_extractor(d)
      extractor = nil
      #if d.year > 1984
        extractor = PublicProQuestExtractor.new
      #else
      #  extractor = MitProQuestExtractor.new
      #end
      extractor
    end
     
    def scrape_article(article)
      article.set_queue_status(:in_progress)
      article.save
      # load an article page and parse it to fill in an Article object, save it
      article_doc = fetch_url(article.src_url)
      #modify
      extractor = get_extractor(article.pub_date)
      extractor.extract_article_info!(article, article_doc)
      article.set_queue_status(:complete)
      article.save 
      NewsScrapers.logger.info "        scraped"
      article
      exit
    end
  
    # get all the articles on a particlar day and insert them into the db
    def scrape(d)
      scrape_index(d)
      while(Article.where("queue_status='queued'").count > 0)
        Article.where("queue_status='queued'").find(:all, :limit=>10) do |article|
          scrape_article(article) 
        end
      end
    end

    private
    
    def populate_article_before_save(article)
      raise NotImplementedError.new("Hey! You must implement populte_article_before_save in your subclass")
    end

    # override this and return the full url
    def get_search_url_and_params(d)
      raise NotImplementedError.new("Hey! You must implement get_search_url in your subclass")
    end
   
    def add_default_params(d, existing_params)
      {
        :datetype=>"6",
        :frommonth=>prefix_with_zero(d.month),
        :fromday=>prefix_with_zero(d.day),
        :fromyear=>d.year,
        :tomonth=>prefix_with_zero(d.month),
        :today=>prefix_with_zero(d.day),
        :toyear=>d.year,
        :st=>"advanced",
        :By=>"",
        :Title=>"",
        :sortby=>"CHRON",
        :at_hist=>["article","editorial_article"],
      }.merge(existing_params)
    end
  end  
end
