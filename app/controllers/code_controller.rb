class CodeController < ApplicationController
  def international
  end

  def foreign
  end
  
  def national
  end
  
  def sports
  end
 
  def answer 
    return if session[:username].nil?
    @user = User.find_by_username(session[:username])
    return if @user.nil? or params[:answer_type].nil?
    return if !(["yes", "no"].include? params[:answer])
    
    article = Article.find_by_id(params[:id]) 
    @answer = Answer.new_by_type(params[:answer_type])
    @answer.user = @user
    @answer.article = article
    @answer.answer = 1 if params[:answer] == "yes"
    @answer.answer = 0 if params[:answer] == "no"
    @answer.save

    #TODO finish while conscious
   
    
  end
end
