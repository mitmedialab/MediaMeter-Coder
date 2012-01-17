module NewsScrapers

  class BaseProQuestExtractor
    
    def name
      self.class.name
    end
    
    def get_base_url
    end
    
    def get_results_page_url_param
    end

    def extract_page_count(doc)
    end
    
    def extract_articles_from_results_list(doc)
    end
    
    def extract_article_info!(article, doc)
    end
    
    def extract_scanned_file_url(article, doc)
    end
    
    def get_default_params(d)
    end
    
    # Use this to bypass the cache on the first request for results, so the cookie gets
    # initialized correctly!
    def needs_cookies?
      false
    end
    
  end

  class MitProQuestExtractor < NewsScrapers::BaseProQuestExtractor
    
    BASE_URL = "http://proquest.umi.com.libproxy.mit.edu"
    SEACH_PATH = "/pqdweb" 
    
    def initialize
      super
    end

    def get_base_url
      BASE_URL  
    end

    def needs_cookies?
      # we need to bypass the cache on the first lookup to get the cookie
      true
    end
    
    def get_default_params(d)
      {
        :author=>'',
        :AT=>'article',
        :beforeDate=>'',
        :clientId=>'5482',
        :date=>'ON',
        :fromDate=>'',
        :FT=>'1',
        :h_pmid=>'',
        :h_pubtitle=>'',
        :JSEnabled=>'1',
        :moreOptState=>'OPEN',
        :onDate=>NewsScrapers.prefix_with_zero(d.month).to_s+"/"+NewsScrapers.prefix_with_zero(d.day).to_s+"/"+d.year.to_s,
        :querySyntax=>'PQ',
        :RQT=>'305',
        :searchInterface=>'1',
        :sortby=>'CHRON',
        :toDate=>'',
        :TS=>'1326312163',
      }
    end

    def get_results_page_url_param
      :firstIndex
    end
    
    def extract_page_count(doc)
      page_count = nil
      if(doc.css('#pageNavLine div.left').length > 0)
        text = doc.css('#pageNavLine div.left').first.content
        matches = text.match(/(.*)-(.*) of (.*)/)
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

    def extract_articles_from_results_list(doc)
      doc.css('#results .resultsItemBody').collect do |elem|
        article = Article.new
        article.headline = elem.css('.resultsHLL a').first.content
        matches = elem.css('.resultsHLL').first.content.strip.match(/p\. (.*) \((.*) page\)/) 
        if matches
          matches = matches.to_a
          article.page = matches[1]
          article.total_pages = matches[2].to_i
        end
        abstract_links = elem.css(".resultsFormats ul li a[title='Abstract']") 
        if abstract_links.length > 0
          article.src_url = get_base_url + abstract_links.first.attribute('href').value
        else 
          article.src_url = get_base_url + elem.css('.resultsHLL a').first.attribute('href').value
        end
        scan_links = elem.css(".resultsFormats ul li a[title='Article image - PDF (Scanned Image)']") 
        if scan_links.length > 0
          article.scan_src_url = get_base_url + scan_links.first.attribute('href').value
        end
        article
      end
    end
    
    def extract_article_info!(article, doc)
      article.abstract = doc.css('.docSection > div.textMedium p').first.content
      doc.css('#tableIndexTerms tr').each do |row|
        token = row.css('td strong').first.content
        if token=="Author(s):"
          article.byline = row.css('td')[1].content
        end
        if token=="Section:"
          article.section = row.css('td')[1].content
        end
        if token=="Text Word Count"
          article.section = row.css('td')[1].content.to_i
        end
      end
    end

    def extract_scanned_file_url(article, doc)
      article.scan_file_url = get_base_url + doc.css("frame")[1].attribute('src').value
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

    def get_results_page_url_param
      :start
    end
    
    def get_default_params d
      {
        :datetype=>"6",
        :frommonth=>NewsScrapers.prefix_with_zero(d.month),
        :fromday=>NewsScrapers.prefix_with_zero(d.day),
        :fromyear=>d.year,
        :tomonth=>NewsScrapers.prefix_with_zero(d.month),
        :today=>NewsScrapers.prefix_with_zero(d.day),
        :toyear=>d.year,
        :st=>"advanced",
        :By=>"",
        :Title=>"",
        :sortby=>"CHRON",
        :Sect=>'ALL',
      }
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
    def extract_articles_from_results_list(doc)
      doc.css('font.result_title > a').collect do |elem|
        article = Article.new
        article.src_url = get_base_url + elem.attribute('href').value
        article.headline = elem.content.strip
        article
      end
    end
    
    def extract_article_info!(article, doc)
      doc.css('div#container table tr td table')[1].css('tr').each do |row|
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
        if( row.css('td').length==2)
          if (row.css('td'))[0].content == "Author:"
            article.byline = (row>('td'))[1].content
          end
          if (row.css('td'))[0].content == "Start Page:"
            article.page = (row>('td'))[1].content
          end
          if (row.css('td'))[0].content == "Pages:"
            article.total_pages = (row>('td'))[1].content.to_i
          end
          if (row.css('td'))[0].content == "Text Word Count:"
            article.word_count = (row>('td'))[1].content.to_i
          end
          if (row.css('td'))[0].content == "Section:"
            article.section = (row>('td'))[1].content
          end
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

    def blacklist_scrape_index(d, params, tag)
      search_url, search_params = get_search_url_and_params(d, params)

      NewsScrapers.logger.info "    ==Blacklist Scraping with #{d}"

      extractor = get_extractor(d)

      doc = fetch_url( search_url, search_params, extractor.needs_cookies?)

      page_count = extractor.extract_page_count(doc)
      if page_count == nil
        NewsScrapers.logger.error("Didn't find page count with #{extractor.name}")
        page_count = 0
        #exit
      end
      NewsScrapers.logger.info "    #{page_count} pages of results to blacklist"

   #for each page of results
      article_count = 0
      (0..page_count-1).each do |current_page|
        sleep(1)
        NewsScrapers.logger.info "    Page #{current_page} of #{page_count}"
        search_params[extractor.get_results_page_url_param] = 10 * current_page
        doc = fetch_url(search_url, search_params)  # will refetch from cache the first time - no biggie
        #  for each article link
        extractor.extract_articles_from_results_list(doc).each do |article|
          NewsScrapers.logger.info "      Article #{article.src_url}"
          if Article.scraped_already? article.src_url
            database_article = Article.scraped_already? article.src_url
            pp article if database_article.nil?
            database_article.add_blacklist_tag(tag)
#            database_article.set_queue_status(:blacklisted)
            database_article.save
            NewsScrapers.logger.info "        scraped already - blacklisting"
          else
            populate_article_before_save(article) # delegate to child for source
            article.set_queue_status(:blacklisted)
            article.pub_date = d
            article.add_blacklist_tag(tag)
            article.save
            article_count += 1
            NewsScrapers.logger.info "        created and blacklisted article with #{extractor.name}"
          end
        end
      end
      article_count
    end

    def scrape_index(d)
      NewsScrapers.logger.info "    Scraping with #{d}"

      search_url, search_params = get_search_url_and_params(d)

      extractor = get_extractor(d)

      doc = fetch_url( search_url, search_params, extractor.needs_cookies?)

      #figure out number of result pages
      page_count = extractor.extract_page_count(doc)
      if page_count == nil
        NewsScrapers.logger.error("Didn't find page count with #{extractor.name}")
        exit
      end
      NewsScrapers.logger.info "    #{page_count} pages of results"

      #for each page of results
      article_count = 0      
      (0..page_count-1).each do |current_page|
        NewsScrapers.logger.info "    Page #{current_page} of #{page_count}"
        search_params[extractor.get_results_page_url_param] = 10 * current_page
        doc = fetch_url(search_url, search_params)  # will refetch from cache the first time - no biggie
        #  for each article link
        extractor.extract_articles_from_results_list(doc).each do |article|
          NewsScrapers.logger.info "      Article #{article.src_url}"
          if Article.scraped_already? article.src_url
            # skip it if we've already fetched this link
            NewsScrapers.logger.info "        scraped already - skipping"
          else
            sleep(1)
            populate_article_before_save(article) # delegate to child for source
            article.set_queue_status(:queued)
            article.pub_date = d
            article.save
            article_count += 1
            NewsScrapers.logger.info "        created article with #{extractor.name}"
          end
        end
      end
      article_count
    end
     

    def scrape_article(article)
      article.set_queue_status(:in_progress)
      article.save
      # load an article page and parse it to fill in an Article object, save it
      extractor = get_extractor(article.pub_date)
      if article.src_url != article.scan_src_url
        # if there is no abstract url, just a scan url, then skip this
        article_doc = fetch_url(article.src_url)
        extractor.extract_article_info!(article, article_doc)
      end
      if article.has_scan_src_url?
        article_scan_doc = fetch_url(article.scan_src_url)
        extractor.extract_scanned_file_url(article,article_scan_doc)
        if article.has_scan_file_url?
          scan_dir = article.path_to_scan_dir
          extension = article.scan_file_url.split('.').pop()
          article.scan_local_filename = article.id.to_s + "." + extension
          @requester.get(article.scan_file_url).save( File.join(scan_dir, article.scan_local_filename) )
        end
      end
      article.set_queue_status(:complete)
      article.save 
      NewsScrapers.logger.info "        scraped with #{extractor.name}"
      article
    end
  
    # get all the articles on a particlar day and insert them into the db
    def scrape(d)
      scrape_index(d)
      while(Article.where({:queue_status=>:queued, :source=>get_source_name}).count > 0)
        Article.where({:queue_status=>:queued, :source=>get_source_name}).find(:all, :limit=>10) do |article|
          scrape_article(article) 
        end
      end
    end

    def blacklist_scrape(d)
      raise NotImplementedError.new("Hey! You must implement blacklist_scrape in your subclass")
    end

    private

    def get_extractor(d)
      extractor = nil
      if d.year > 1980
        extractor = PublicProQuestExtractor.new
      else
        extractor = MitProQuestExtractor.new
      end
      extractor
    end
    
    def populate_article_before_save(article)
      article.source = get_source_name
    end

    def get_source_name
      raise NotImplementedError.new("Hey! You must implement get_source_type in your subclass")
    end

    # override this and return the full url
    def get_search_url_and_params(d)
      raise NotImplementedError.new("Hey! You must implement get_search_url in your subclass")
    end

   
    def add_default_params(d, existing_params)
      get_extractor(d).get_default_params(d).merge(existing_params)
    end
    
  end  
end
