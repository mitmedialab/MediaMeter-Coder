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
    
     @sampletag = "true"
    
    # parse out users we care about
    @selected_users = User.all.select do |user|
      params.keys.include? user.id.to_s
    end
    user_ids = @selected_users.collect do |user|
      user.id
    end
    @user_id_to_name = Hash.new
    @selected_users.each do |user|
      @user_id_to_name[user.id] = user.username
    end
    
    # load all the articles
    @articles = Article.where(:sampletag=>@sampletag).includes([:answers,:golds]).
      where('answers.user_id'=>user_ids)

    # compute agreement
    @disagreement_count = 0
    @types = Answer.types
    @agreement_by_article = Hash.new
    @articles.each do |article|
      @agreement_by_article[article.id] = Hash.new
      @types.each do |type|
        @agreement_by_article[article.id][type] = agreement_info_for_type(article, type)
        if @agreement_by_article[article.id][type][:is_of_type]==nil
          @disagreement_count = @disagreement_count + 1
        end
      end
    end
    
    # init golds as needed
    @articles.each do |article|
      reload_golds = false
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
          reload_golds = true
        end
      end
      article.golds = Gold.where(:article_id=>article.id) if reload_golds
    end
    
  end

  # handle ajax requests when people change things in the UI
  def for_article
    
    article_id = params[:id]
    type = params[:type]
    uids = params[:uids]
    @article = Article.includes([:answers,:golds]).where('answers.user_id'=>uids).find(article_id)

    @agreement_info = agreement_info_for_type(@article,type) 
    @answers = @article.answers_by_type(type)
    @gold = @article.gold_by_type(type)
    @username_map = Hash.new
    User.all.each do |user|
      @username_map[user.id] = user.username
    end
  
    render :partial => "answer_icons", :locals => { 
              :agreement_info=>@agreement_info,
              :answers=>@answers,
              :gold=>@gold,
              :username_map=>@username_map
    }
  
  end

  private 
  
    def agreement_info_for_type(article, type)
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
      end
      info
    end   

end
