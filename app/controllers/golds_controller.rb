# STI fixes copied from http://stackoverflow.com/questions/5246767/sti-one-controller/5252136#5252136
class GoldsController < ApplicationController

  def export_totals
    
    @sampletag = ""
    @all_sampletags = Article.sampletag_counts
    @show_results = false
    if params.has_key? :sampletag
      # collect the passed params from the user 
      @sampletags = (params[:sampletag].keep_if {|k,v| v.to_i==1}).keys
      # load general data
      @all_sources = Article.all_sources
      @all_years = Article.all_years
      @all_answer_types = Gold.types
      @all_genders = Article.all_genders 
      # total articles
      @total_articles = Article.counts_by_source_year(@sampletags)
      # article type counts
      @yes_by_type_source_year = Gold.counts_by_type_source_year(@sampletags,@all_answer_types,@all_sources,@all_years)
      # gender counts
      @gender_by_source_year = Article.gender_counts_by_source_year(@sampletags)
    end

    respond_to do |format|
      format.html
      format.json {
        @data = Hash.new
        @all_sources.each do |source|
          cleaned_source = source.parameterize.underscore
          @data[cleaned_source] = Hash.new 
          @all_years.each do |year|
            @data[cleaned_source][year] = Hash.new
            @data[cleaned_source][year][:total_articles] = @total_articles[source][year]
            @all_answer_types.each do |type|
              @data[cleaned_source][year][type] = @yes_by_type_source_year[type][source][year]
            end
            @all_genders.each do |gender|
              cleaned_gender = Article.gender_name(gender).parameterize.underscore
              total = @gender_by_source_year[gender][source][year]
              total = 0 if total.nil?                
              @data[cleaned_source][year][cleaned_gender] = total 
            end
          end
        end
        render json: @data
      }
      format.csv {
        timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
        # do some csv config
        @filename = "article_info_by_source_year_" + timestamp + ".csv"
        @output_encoding = 'UTF-8'
      }
    end

  end
  
  def import_reasons
    @all_answer_types = Gold.types 
    if request.post?
      # TODO: verify params exist
      question_type = params[:answer][:type]
      upload = params[:my_file]
      # prep to import
      gold_count = 0
      row_count = 0
      ungolden_count = 0
      col_headers = Array.new
      question = Question.for_answer_type(question_type)
      question_text = question.export_safe_text
      value_col = question_text + "_gold"
      reason_col = question_text + "_gold_reason"
      col_indices = {
        "id"=>nil,
        "answer_type"=>nil,
        reason_col=>nil,
        value_col=>nil
      }
      # import
      parse_worked = true
      error_msg = nil
      CSV.foreach(File.open(upload.tempfile)) do |row|
        if parse_worked
          if row_count==0
            # check out col headers and validate we can find the 3 cols we need (id, _trusted_judgments, answer, confidence)
            col_headers = row
            logger.info ""
            logger.info col_headers.join(", ")
            found_all_cols = true
            col_indices.each_key do |key|
              col_indices[key] = col_headers.index(key)
              found_all_cols = false if col_indices[key]==nil  
            end
            if !found_all_cols
              flash.now[:error] = ("Didn't find some required coloumns! Couldn't find these columns: <ul><li>"+(col_indices.keys - col_headers).join("</li><li>")+"</li></ul>").html_safe
              parse_worked = false
            end
          else
            # verify answer info, just to be safe
            answer_type = row[ col_indices["answer_type"] ]
            if answer_type!=question_type
              flash.now[:error] = "Row #{row_count} has the wrong type!  Expecting #{question_type} but found #{answer_type}"  
              parse_worked = false       
            else
              article_id = row[ col_indices["id"] ]
              new_reason = row[ col_indices[reason_col] ]
              new_value = row[ col_indices[value_col] ]
              # everything checks out, go ahead and create and save the answer
              matching_golds = Gold.where(:article_id=>article_id, :type=>Gold.classname_for_type(answer_type))
              if matching_golds.count==0
                if new_reason!=nil && new_reason.length > 0
                  flash.now[:error] = "Can't find a gold matching row #{row_count} in #{upload.original_filename}.  Looked for article_id #{article_id}, type #{answer_type} ("+Gold.classname_for_type(answer_type)+")"
                  parse_worked = false
                end
              else 
                gold = matching_golds.first
                if (new_value == nil) || (new_value == "")
                  # blank value means article shouldn't be golden
                  Gold.delete(gold.id)
                  article = Article.find(article_id)
                  article.golden = false
                  article.save
                  ungolden_count = ungolden_count + 1
                else
                  gold.reason = new_reason
                  gold.answer = (new_value.downcase == 'yes')
                  gold.save
                end
                gold_count = gold_count + 1
              end
            end
          end # gold count
        end # parse worked
        row_count = row_count + 1
      end # csv for each
    end # is post
    # generate some feedback
    if parse_worked
      flash.now[:notice] = "Imported #{gold_count} #{question_type} gold reasons, un-golded #{ungolden_count} articles (from #{upload.original_filename}, #{row_count} rows)"
    end
  end

  # see a list of articles with the gold answers
  def pick_reasons
    @all_sampletags = Article.sampletag_counts
    @all_answer_types = Gold.types     
  end

  # see a list of articles with the gold answers
  def edit_reasons
    
    @sampletags = (params[:sampletag].keep_if {|k,v| v.to_i==1}).keys
    @answer_type = params[:answer]['type']

    @articles = Article.where(:sampletag=>@sampletags).includes(:golds)
    
  end

  # GET /golds
  # GET /golds.json
  def index
    @golds = gold_type.includes(:article).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @golds }
    end
  end

  # GET /golds/1
  # GET /golds/1.json
  def show
    @gold = Gold.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gold }
    end
  end

  # GET /golds/new
  # GET /golds/new.json
  def new
    @gold = gold_type.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gold }
    end
  end

  # GET /golds/1/edit
  def edit
    @gold = Gold.find(params[:id])
  end

  # POST /golds
  # POST /golds.json
  def create
    @gold = gold_type.new(params[:gold])

    respond_to do |format|
      if @gold.save
        format.html { redirect_to @gold, notice: 'Gold was successfully created.' }
        format.json { render json: @gold, status: :created, location: @gold }
      else
        format.html { render action: "new" }
        format.json { render json: @gold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /golds/1
  # PUT /golds/1.json
  def update
    @gold = Gold.find(params[:id])

    respond_to do |format|
      if @gold.update_attributes(params[ @gold.class.name.underscore ])
        format.html { redirect_to @gold, notice: 'Gold was successfully updated.' }
        format.json { render :partial => "gold_reason.html.erb", :locals => { :gold=>@gold } }
      else
        format.html { render action: "edit" }
        format.json { render json: @gold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /golds/1
  # DELETE /golds/1.json
  def destroy
    @gold = Gold.find(params[:id])
    @gold.destroy

    respond_to do |format|
      format.html { redirect_to golds_url }
      format.json { head :ok }
    end
  end

  private
    def gold_type
      params[:type].constantize if params.has_key? :type
      Gold
    end

end
