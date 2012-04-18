class ApplicationController < ActionController::Base

  layout 'browse'

  protect_from_forgery

  def require_username
    redirect_to :controller=>:session, :action=>:new and return if !session.has_key? :username
    @user = User.find_by_username(session[:username])
    redirect_to :controller=>:session, :action=>:new and return if @user.nil?
  end
end
