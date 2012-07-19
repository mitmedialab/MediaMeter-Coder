class ArticlesController < ApplicationController

  def random
    random_article = Article.order("RAND()").first
    redirect_to article_path(random_article.id)
  end

  def summary
    @answer_count = Answer.count
    @answer_count_users = Answer.group(:user_id).count.keys.length
    @article_count = Article.count
    @users = User.all
    @user_answer_counts = []
    @users.each do |user|
      @user_answer_counts[user.id] = Answer.where(:user_id=>user.id).count
    end
  end

  def by_sampletag
    @sampletag = params[:sampletag]
    @articles = Article.where(:sampletag=>@sampletag).page(params[:page]).order(:pub_date,:source,:headline)
    @prefix = @sampletag
    render 'index'
  end

  def by_source
    @source = params[:source]
    @articles = Article.where(:source=>@source).page(params[:page]).order(:pub_date,:source,:headline)
    @prefix = @source
    render 'index'
  end

  def export_by_sampletags

    @users = User.all
    @all_sampletags = Article.sampletag_counts
    
    respond_to do |format|
      format.html
      format.csv {
        # collect the passed params from the user 
        @sampletags = (params[:sampletag].keep_if {|k,v| v.to_i==1}).keys
        @question = Question.find(params[:question][:id])
        # pull out the articles we care about
        @articles = Article.where(:sampletag=>@sampletags).includes(:answers,:golds)
        timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
        # do some csv config
        @question_text = @question.export_safe_text
        @filename = @question_text + "_" + "articles" + "_" + timestamp + ".csv"
        @output_encoding = 'UTF-8'
      }
    end
        
  end

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.page(params[:page]).order(:pub_date,:source,:headline)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.includes(:golds,:answers).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.json
  #def new
  #  @article = Article.new

  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.json { render json: @article }
  #  end
  #end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.json
  #def create
  #  @article = Article.new(params[:article])

  #  respond_to do |format|
  #    if @article.save
  #      format.html { redirect_to @article, notice: 'Article was successfully created.' }
  #      format.json { render json: @article, status: :created, location: @article }
  #    else
  #      format.html { render action: "new" }
  #      format.json { render json: @article.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :ok }
    end
  end

end
