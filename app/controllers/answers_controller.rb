class AnswersController < ApplicationController

  # import answers from an CSV file the user uploads
  def import
    @users = User.all
    if request.post?
      upload = params[:my_file] 
      # TODO: verify params exist
      user = User.find(params[:username])
      question_id = params[:question][:id]
      filepath = upload.tempfile
      # do the import and provide feedback
      parse_worked, results_string = Answer.import_from_csv(user, question_id, filepath)
      results_string = results_string + " (from #{upload.original_filename})"
      if parse_worked
        flash.now[:notice] = results_string
      else 
        flash.now[:error] = results_string
      end
    end # is post
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
    
    @sampletags = (params[:sampletag].keep_if {|k,v| v.to_i==1}).keys
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
    
    @articles = Article.where(:sampletag=>@sampletags)
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
    
    @article = Article.find(params[:id])
    @question = Question.find(params[:question_id])
    uids = params[:uids]
    #@article.golds = Gold.where(:article_id=>article_id,:question_id=>question_id)
    #@article.answers = Answer.where(:article_id=>article_id,:question_id=>question_id,:user_id=>uids)
    @agreement_info = @article.agreement_info_for_question(@question.id) 
    @answers = @article.answers_to_question(@question.id)
    @gold = @article.gold_for_question(@question.id)
    @username_map = Hash.new
    User.all.each { |user| @username_map[user.id] = user.username }
    
    render :partial => "answer_icons", :locals => { 
              :question=>@question,
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
