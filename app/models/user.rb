class User < ActiveRecord::Base
  has_many :answers
 
  def get_next_unanswered_article(answer_type)
    next_unanswered_article = nil
    query_string = ""
    query_string << <<-SQL
SELECT articles.*, 
       selected_answers.user_id 
  FROM articles 
  LEFT OUTER JOIN (
    SELECT * from answers 
     WHERE answers.user_id = #{id}
       AND type = "#{Answer.classname_for_type(answer_type)}")
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
end
