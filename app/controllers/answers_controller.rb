class AnswersController < ApplicationController
  layout 'browse'

  def pick
    @users = User.all
    @user_answer_counts = Hash.new
    @users.each do |user|
      @user_answer_counts[user.id] = Answer.where(:user_id=>user.id).count
    end
  end  
  
  def for_users
    
    # parse out users we care about
    @selected_users = User.all.select do |user|
      params.keys.include? user.id.to_s
    end
    user_ids = @selected_users.collect do |user|
      user.id
    end
    
    # load all the articles
    @articles = Article.first_sample.
      includes([:answers,:golds]).
      where('answers.user_id'=>user_ids).
      page(params[:page])
    
    # compute agreement
    @disagreement_count = 0
    @types = Answer.types
    @agreement_by_article = Hash.new
    @articles.each do |article|
      @agreement_by_article[article.id] = {}
      @types.each do |type|
        answers_of_type = article.answers_by_type(type)
        info = {
          :yes => (answers_of_type.count {|a| (a.answer==true)}).to_f / answers_of_type.count.to_f,
          :no => (answers_of_type.count {|a| (a.answer==false)}).to_f / answers_of_type.count.to_f,
        }
        if info[:yes] > info[:no]
          info[:is_of_type] = true 
        elsif info[:no] > info[:yes]
          info[:is_of_type] = false
        else 
          info[:is_of_type] = nil
          @disagreement_count = @disagreement_count + 1
        end
        @agreement_by_article[article.id][type] = info
      end
    end
    
    # init golds as needed
    @articles.each do |article|
      @types.each do |type|
        if article.missing_gold_by_type(type)
          agreement_info = @agreement_by_article[article.id][type]
          threshold = 0.70 #should be a magic constant somewhere
          if (agreement_info[:yes] > threshold) || (agreement_info[:no] > threshold)
            computed_answer = (agreement_info[:yes] > threshold)
          else 
            computed_answer = nil
          end  
          new_gold = Gold.new_by_type(type)
          new_gold.article_id = article.id
          new_gold.answer = computed_answer
          new_gold.save
        end
      end
      article.golds = Gold.where(:article_id=>article.id)
    end
    
  end

end
