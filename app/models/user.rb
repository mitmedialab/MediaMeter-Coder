class User < ActiveRecord::Base
  has_many :answers
 
  alias_attribute :name, :username
 
  def get_next_unanswered_article(question_id, answer_limit=nil)
    next_unanswered_article = nil
    # find all the unanswered articles for a user
    query_string = ""
    query_string << <<-SQL
SELECT articles.*, 
       selected_answers.user_id 
  FROM articles 
  LEFT OUTER JOIN (
    SELECT * from answers 
     WHERE answers.user_id = #{id}
       AND answers.question_id = #{question_id})
    AS selected_answers 
    ON articles.id = selected_answers.article_id 
  WHERE selected_answers.user_id IS NULL 
SQL
    unanswered_articles = Article.find_by_sql(query_string)
    # now make sure we don't get too many answers for each article
    if answer_limit != nil
      logger.info "check limit"
      unanswered_articles.select! do |article|
        (Answer.where(:article_id=>article.id,:question_id=>question_id).count < answer_limit)
      end
    end
    logger.info "count = "+unanswered_articles.count.to_s
    next_unanswered_article = unanswered_articles[0] if unanswered_articles.size > 0
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
