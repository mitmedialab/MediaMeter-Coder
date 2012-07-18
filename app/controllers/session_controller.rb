class SessionController < ApplicationController
  def new
  end

  def create
    redirect_to :action=>:new and return if !params.has_key? :username
    @user = User.find_by_username(params[:username])
    @user = User.create(:username=>params[:username]) if @user.nil?
    @user.save!
    session[:username] = @user.username
    redirect_to :controller=>:code, :action=>:generic_one and return
  end
end
