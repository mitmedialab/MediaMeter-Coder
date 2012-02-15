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

    answer = nil
    answer = 1 if params[:answer] == "yes"
    answer = 0 if params[:answer] == "no"

    article = Article.find_by_id(params[:id]) 
    @answer = Answer.new_by_type(params[:answer_type], {:user=>@user, :article=>article, :source=>"MediaMeter Coder", :answer=>answer})
    @answer.save

    #TODO finish while conscious
   
    
  end
end
