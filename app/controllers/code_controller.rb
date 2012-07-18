class CodeController < ApplicationController

  before_filter :require_username
 
  def generic_one
    @answer_type = "generic_one"
    @question = Question.where(:key=>@answer_type.camelize).first
    render :code
  end 
 
  def generic_two
    @answer_type = "generic_two"
    @question = Queston.for_answer_type @answer_type
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
