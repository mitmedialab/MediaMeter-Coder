class AnswersController < ApplicationController

  # import answers from an CSV file the user uploads
  def import
    @users = User.all
    @all_answer_types = Gold.types 
    if request.post?
      upload = params[:my_file] 
      # TODO: verify params exist
      user = User.find(params[:username])
      question_type = params[:answer][:type]
      filepath = upload.tempfile
      # do the import and provide feedback
      parse_worked, results_string = Answer.import_from_csv(user, question_type, filepath)
      results_string = results_string + " (from #{upload.original_filename})"
      if parse_worked
        flash.now[:notice] = results_string
      else 
        flash.now[:error] = results_string
      end
    end # is post
  end
  
  def export_totals
    
    @users = User.all
    @user_answer_counts = Hash.new
    @all_answer_types = Gold.types 
    @users.each do |user|
      @user_answer_counts[user.id] = Answer.where(:user_id=>user.id).count
    end

    @show_results = false
    @sampletag = ""
    @all_sampletags = Article.sampletag_counts
    if params.has_key? :sampletag
      # collect the passed params from the user 
      @sampletags = (params[:sampletag].keep_if {|k,v| v.to_i==1}).keys
      # load users
      user_ids = self.parse_out_selected_users.collect { |user| user.id }
      # load general data
      @all_sources = Article.all_sources
      @all_years = Article.all_years
      @all_answer_types = Answer.types
      @all_genders = Article.all_genders 
      # total articles
      @total_articles = Article.counts_by_source_year(@sampletags)
      # article type counts
      @yes_by_type_source_year = Answer.counts_by_type_source_year(@sampletags,@all_answer_types,@all_sources,@all_years,user_ids)
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
        @filename = "article_types_by_source_year_" + timestamp + ".csv"
        @output_encoding = 'UTF-8'
      }
    end

  end
  
  # pick users and a sample tag to see the aggregated answers for
  def pick
    @users = User.all
    @user_answer_counts = Hash.new

    @users.each do |user|
      @user_answer_counts[user.id] = Answer.where(:user_id=>user.id).count
    end
    @all_sampletags = Article.sampletag_counts
  end  
  
  # show the aggregated answers, and gold, for a set of users against a sampleset of articles
  def for_users
    
    @sampletag = params[:tag][:name]
    @generate_golds = params[:generate_golds].to_i==1
    @only_not_confident = params[:not_confident].to_i==1
    
    # parse out users we care about
    @selected_users = self.parse_out_selected_users
    user_ids = @selected_users.collect { |user| user.id }
    @user_id_to_name = Hash.new
    @selected_users.each { |user| @user_id_to_name[user.id] = user.username }
    
    # parse out the questions we care about
    @selected_questions = Question.all { |q| params[:question].keys.include? q.id }
    @selected_question_ids = @selected_questions.collect { |q| q.id }
    
    # load all the articles
    
    @articles = Article.where(:sampletag=>@sampletag)
    @articles.each do |article|
      if @generate_golds
        article.golds = Gold.where(:article_id=>article.id,:question_id=>@selected_question_ids)
      end
      extra_where_clause = ""
      if @only_not_confident
        extra_where_clause  = 'answers.confidence < ' + Answer::CONFIDENT_THRESHOLD.to_s
      end 
      article.answers = Answer.where(:article_id=>article.id,:question_id=>@selected_question_ids,
        :user_id=>user_ids).where(extra_where_clause)      
    end
    
    print "articles: #{@articles.count}"
    
    # compute inter-coder agreement info
    @agreement_by_article = Hash.new
    @articles.each do |article|
      @agreement_by_article[article.id] = Hash.new
      @selected_question_ids.each do |question_id|
        @agreement_by_article[article.id][question_id] = article.agreement_info_for_question(question_id)
      end
    end
    
    # init golds as needed
    if @generate_golds
      @articles.each do |article|
        @selected_questions.each do |q|
          # figure out the gold answer to use, based on agreement in answers
          agreement_info = @agreement_by_article[article.id][q.id]
          threshold = 0.70 #should be a magic constant somewhere (this is based on our first round of CF testing)
          computed_answer = nil
          (1..5).each do |possible_answer|
            if agreement_info[possible_answer] > threshold
              computed_answer = possible_answer
            end  
          end
          # create or update the gold with the new aggregate answer
          this_gold = nil
          if article.missing_gold_for_question(q.id)
            # create a new gold
            this_gold = Gold.new( {:article_id=>article.id, :answer=>computed_answer, :question_id=>q.id})
          else 
            #it has a gold, update that gold
            this_gold = article.gold_for_question(q.id)
            this_gold.answer = computed_answer 
          end
          this_gold.save
          article.golds = Gold.where(:article_id=>article.id) # greedy to reload them all
        end
      end
    end
    
  end

  # handle ajax requests when people change things in the UI
  def for_article
    
    article_id = params[:id]
    question_id = params[:question_id]
    uids = params[:uids]
    @article = Article.includes([:answers,:golds]).where('answers.user_id'=>uids).find(article_id)

    @agreement_info = @article.agreement_info_for_question(question_id) 
    @answers = @article.answers_to_question(question_id)
    @gold = @article.gold_for_question(question_id)
    @username_map = Hash.new
    User.all.each do |user|
      @username_map[user.id] = user.username
    end
  
    render :partial => "answer_icons", :locals => { 
              :agreement_info=>@agreement_info,
              :answers=>@answers,
              :gold=>@gold,
              :username_map=>@username_map
    }
  
  end

  def parse_out_selected_users
    # parse out users we care about
    User.all.select do |user|
      params.keys.include? user.id.to_s
    end
  end

end
