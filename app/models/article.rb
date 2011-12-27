require 'digest/md5'


# helper to encrypt the content of one colunm into another before saving
class EncryptionWrapper

  def initialize(src,dest)
    @src_col = src
    @dest_col = dest
  end

  def before_save(record)
    record.send("#{@dest_col}=",encrypt(record.send("#{@src_col}")))
  end
  
  private

    def encrypt(value)
      Digest::MD5.hexdigest(value)
    end

end

class Article < ActiveRecord::Base

  before_save   EncryptionWrapper.new('src_url','src_url_md5')

  # create a new one from a pre-parsed proquest results page
  def self.from_pro_quest_doc(doc)
    article = Article.new
    doc.css('div#container > table tr td > table tr').each do |row|
      if (row>('td.docTitle')).length > 0
        if (row>('td.docTitle')).children[0].name!="img"
          article.headline = (row>('td.docTitle')).children[0].content  
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
    article
  end

  # auto populate some generated columns before save
  def self.scraped_already? src_url
    src_url_md5 = Digest::MD5.hexdigest(src_url)
    where("src_url_md5 = ?",src_url_md5).first
  end
  
  def self.count_without_abstracts
    count(:all,:conditions=>['abstract is null'])
  end

end
