class CodeController < ApplicationController
  layout "browse", :except=>[:answer]
  before_filter :require_username
 
  def arts
    @answer_type = "arts"
    render :code
  end 
 
  def international
    @answer_type = "international"
    render :code
  end

  def foreign
    @answer_type = "foreign"
    render :code
  end
  
  def national
    @answer_type = "national"
    render :code
  end
  
  def sports
    @answer_type = "sports"
    render :code
  end

  def local
    @answer_type = "local"
    render :code
  end
 
  def answer 
    @article = nil
    @answer_type = nil

    @answer_type = params[:answer_type]
    if(params[:answer].nil? or params[:id].nil?)
      @article = @user.get_next_unanswered_article(params[:answer_type])
    else
      answer = nil
      answer = 1 if params[:answer] == "yes"
      answer = 0 if params[:answer] == "no"
      article = Article.find_by_id(params[:id]) 
      @answer = Answer.new_by_type(@answer_type, {:user=>@user, :article=>article, :source=>"MediaMeter Coder", :answer=>answer})
      @answer.save
      @article = @user.get_next_unanswered_article(params[:answer_type])
    end

    render :partial => "answer"
  end
  
end
