class CodeController < ApplicationController

  before_filter :require_username
 
  def by_question
    @question = Question.find(params[:question_id])
    render :code
  end 
  
  def answer 
    max_answers_per_article = MediaMeterCodingEngine::Application.config.max_answers_per_article
    @article = nil

    @question = Question.find(params[:question_id])
    if(params[:answer].nil? or params[:id].nil?)
      @article = @user.get_next_unanswered_article(@question.id,max_answers_per_article)
    else
      answer = params[:answer]

      article = Article.find_by_id(params[:id]) 
      @answer = Answer.new({
         :question_id=>@question.id,
         :user=>@user, 
         :article=>article, 
         :source=>"MediaMeter Coder", 
         :answer=>answer
      })
      @answer.save
      @article = @user.get_next_unanswered_article(@question.id,max_answers_per_article)
    end

    render :partial => "answer"
  end
  
end
