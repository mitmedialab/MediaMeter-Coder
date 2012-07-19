class User < ActiveRecord::Base
  has_many :answers
 
  alias_attribute :name, :username
 
  def get_next_unanswered_article(question_id)
    next_unanswered_article = nil
    query_string = ""
    query_string << <<-SQL
SELECT articles.*, 
       selected_answers.user_id 
  FROM articles 
  LEFT OUTER JOIN (
    SELECT * from answers 
     WHERE answers.user_id = #{id}
       AND answers.question_id = "#{question_id}")
    AS selected_answers 
    ON articles.id = selected_answers.article_id 
  WHERE selected_answers.user_id IS NULL 
  LIMIT 1;
SQL
    result = Article.find_by_sql(query_string)
    next_unanswered_article = result[0] if result.size > 0
#    Article.find() do |article|
#      if !answers.detect{|answer| answer.article == article}
#        next_unanswered_article = article
#        break
#      end
#    end
    next_unanswered_article
  end

  def find_answers_by_question_id(question_id)
    answers.find_all_by_question_id(question_id)
  end

  # return a list of user_ids that have any answers with confidence
  # (ie. any users from CrowdFlower)
  def self.having_answers_with_confidence
    User.where(:id=>Answer.where("confidence is not null").group(:user_id).select(:user_id))
  end
  
end
