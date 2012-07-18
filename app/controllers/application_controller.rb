class ApplicationController < ActionController::Base

  layout 'browse'

  protect_from_forgery

  before_filter :load_global_vars
 
  def load_global_vars
    @questions = Question.all
  end
 
  def require_username
    redirect_to :controller=>:session, :action=>:new and return if !session.has_key? :username
    @user = User.find_by_username(session[:username])
    redirect_to :controller=>:session, :action=>:new and return if @user.nil?
  end
  
  
  
end
