class CrowdController < ApplicationController

  layout 'browse'

  def review_coding
    
    users = ["rahul2","EthanZ"]
    user_ids = users.collect do |username|
      User.find_by_username(username).id
    end
    
    @articles = Article.first_sample.
      includes(:answers).
      where('answers.user_id'=>[user_ids]).
      page(params[:page])
    
  end
  
end
