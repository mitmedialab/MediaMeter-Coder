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
  
end
