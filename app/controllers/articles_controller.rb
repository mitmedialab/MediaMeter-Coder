class ArticlesController < ApplicationController

  def summary
    @types = Gold.types
    @sources = Article.all_sources
    @years = Article.all_years
    # chart of stories per day / source / year
    @avg_stories_per_day_by_source_and_year = Article.average_stories_per_day_by_source_and_year
    # answer confidence
    @all_answer_types = Answer.types
    @user_type_confidence = {}     
    crowd_users = User.having_answers_with_confidence
    crowd_users.each do |user|
      @user_type_confidence[user] = {}
      @all_answer_types.each do |type|
        confidence_freq = Answer.confidence_frequency(user.id, type)
        @user_type_confidence[user][type] = confidence_freq 
      end
    end
    # gold status
    @gold_reason_pcts = Gold.reasoned_percent_by_type
  end

  def export_by_sampletags

    @users = User.all
    @all_sampletags = Article.sampletag_counts
    @all_answer_types = Gold.types 
    
    respond_to do |format|
      format.html
      format.csv {
        # collect the passed params from the user 
        @sampletags = (params[:sampletag].keep_if {|k,v| v.to_i==1}).keys
        @answer_type = params[:answer]['type']
        # pull out the articles we care about
        @articles = Article.where(:sampletag=>@sampletags).includes(:golds,:answers)
        timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
        # do some csv config
        @question_text = Article.question_text(@answer_type).downcase.gsub(/ /,"_")
        @filename = @answer_type + "_" + "articles" + "_" + timestamp + ".csv"
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
