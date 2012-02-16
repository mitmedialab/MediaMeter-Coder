class User < ActiveRecord::Base
  has_many :answers
 
  def get_next_unanswered_article
    next_unanswered_article = nil
    Article.find() do |article|
      if !answers.detect{|answer| answer.article == article}
        next_unanswered_article = article
        break
      end
    end
    next_unanswered_article
  end
end
