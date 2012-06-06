require 'logger'
require 'csv'
 
module CrowdFlower

  @@logger_instance = nil
  
  # Be smart about logging while running inside or outside of Rails
  def self.logger
    return Rails.logger if defined? Rails
    if @@logger_instance == nil
      @@logger_instance = Logger.new("crowd_flower_development.log")
    end
    @@logger_instance
  end
  
  # export a file with all the article info for crowdflower
  def self.export(answer_type, file_path)
    sampletags = Article.all_sampletags
    question_text = Article.question_text(answer_type).downcase.gsub(/ /,"_")
    # pull out the articles we care about
    articles = Article.where(:sampletag=>sampletags).includes(:answers,:golds)
    row_count = 0
    #output the CSV info
    CSV.open(file_path, 'wb') do |csv|
      csv << ["id", "newspaper", "page", "headline","date","content","byline","content_link", "answer_type", "_golden", "answer_id", "answer_confidence", question_text+"_gold", question_text+"_gold_reason"]
      articles.each do |a|
        # figure out gold answer
        is_gold = a.has_gold_by_type(answer_type)
        gold_answer = nil
        gold_reason = nil
        if is_gold
          gold_answer = a.gold_by_type(answer_type).yes? ? "Yes": "No"
          gold_reason = a.gold_by_type(answer_type).reason
        end 
        answer_id = nil
        answer_confidence = nil
        if (a.answers.length > 0) and (a.answers_by_type(answer_type).length > 0) 
          answer_id = a.answers_by_type(answer_type).first.id
          answer_confidence = a.answers_by_type(answer_type).first.confidence
        end
        # output row to CSV
        csv << [  a.id, 
                  a.source, 
                  a.page, 
                  a.headline, 
                  (a.pub_date.year.to_s+"/"+a.pub_date.month.to_s+"/"+a.pub_date.day.to_s),
                  a.abstract,
                  a.byline,
                  a.url_to_scan_local_file,
                  answer_type,
                  is_gold ? "TRUE" : "",
                  answer_id,
                  answer_confidence,
                  gold_answer,
                  gold_reason
                ]
        row_count = row_count + 1
      end
    end
    CrowdFlower.logger.info("Exported #{row_count} rows to #{file_path}")
  end
  
end
