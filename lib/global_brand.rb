require 'logger'
require 'csv'
require 'nokogiri'
 
module GlobalBrand
  
  # import from an evernote export dir of articles
  def self.import_from_evernote(evernote_dir)
    Rails.logger.info "Importing from  #{evernote_dir}" 
    article_count = 0
    Dir.glob(evernote_dir+"/*.html").each do |filepath|
      filename = filepath.split("/").last
      next if filename=="index.html"
      country = filename.split("_").first
      doc = Nokogiri::HTML( File.open(filepath, "r").read )
      # parse out info
      headline = (doc.css('h1').collect { |node| node.content }).join
      headline = (doc.css('h2').collect { |node| node.content }).join if headline.length==0
      headline = doc.css('p').first.content if headline.length==0
      abstract = (doc.css('p').collect { |node| node.content }).join("\n")
      Rails.logger.info "  " + filename + " : " + headline + ": " + abstract.length.to_s + "\n"
      # save and tally
      a = Article.new({
        :source=>"Reuters",
        :byline=>filename.split(".").first,
        :headline=>headline,
        :abstract=>abstract,
        :sampletag=>country
      })
      a.save
      article_count = article_count+1
    end
    Rails.logger.info "Imported #{article_count} articles"
  end
  
  # script to recover from a catastrophic bug that set the article_id of all answers to NULL!
  # :-(
  def self.update_from_log(log_file)
    
    st_find_post = 1
    st_find_insert = 2
    
    Rails.logger.info "------------------------------------------------------------"
    Rails.logger.info "Updating answer.article_id from log file (#{log_file})"

    f = File.open('tmp/file_article_ids.sql','w')

    answer_count = 0
    error_count = 0
    article_id = nil
    state = st_find_post
    File.open(log_file, "r").each_line do |line|
      case state
      when st_find_post
        if (line =~ /^Started GET \"\/code\/answer\?id\=/ )
          url_params = CGI::parse(line.split('?')[1])
          article_id = url_params['id'].first
          state = st_find_insert
        end
      when 
        if (line =~ /INSERT INTO `answers`/)
          insert_parts = line.split(',')
          date = insert_parts[11].strip!
          date['\''] = ''
          date['\''] = ''
          answers = Answer.where(:created_at=>date)
          if answers.length == 1
            answer = answers.first
            if article_id != nil
              sql = "UPDATE `answers` SET article_id='#{article_id}' WHERE id=#{answer.id};"
              f.write(sql+"\n") 
              #answer.update_attribute(:article_id,article_id)
            else
              str = "  ERROR: didn't find and article_id"
              print str+"\n"
              Rails.logger.info str
              error_count = error_count + 1                
            end
          else
            str = "  ERROR: can't find answer matching date of #{date} (#{answers.length} found)"
            print str+"\n"
            Rails.logger.info str
            error_count = error_count + 1 
          end
          state = st_find_post
          article_id = nil
        end
      end
    end

    f.close
    Rails.logger.info "Found and updated #{answer_count} record (#{error_count} errors)"
    Rails.logger.info "------------------------------------------------------------"
        
  end
  
end
