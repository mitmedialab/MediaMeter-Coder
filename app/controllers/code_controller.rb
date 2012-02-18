class CodeController < ApplicationController
  layout nil
  layout "application", :except=>[:answer]
  before_filter :require_username
 
  def international
  end

  def foreign
  end
  
  def national
  end
  
  def sports
  end
 
  def answer 
    return if params[:answer_type].nil?
    if(params[:answer].nil? or params[:id].nil?)
      @article = @user.get_next_unanswered_article(params[:answer_type])
      return
    end
    return if !(["yes", "no"].include? params[:answer])

    answer = nil
    answer = 1 if params[:answer] == "yes"
    answer = 0 if params[:answer] == "no"

    article = Article.find_by_id(params[:id]) 
    @answer = Answer.new_by_type(params[:answer_type], {:user=>@user, :article=>article, :source=>"MediaMeter Coder", :answer=>answer})
    @answer.save
    @article = @user.get_next_unanswered_article(params[:answer_type])
  end
end
