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
  
  # pick users and a sample tag to see the aggregated answers for
  def pick
    @users = User.all
    @user_answer_counts = Hash.new
    @all_answer_types = Gold.types 
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
    @selected_users = User.all.select do |user|
      params.keys.include? user.id.to_s
    end
    user_ids = @selected_users.collect do |user|
      user.id
    end
    @user_id_to_name = Hash.new
    @selected_users.each do |user|
      @user_id_to_name[user.id] = user.username
    end
    
    # parse out the questions we care about
    @selected_types = Gold.types.select do |type|
      params[:answer_type].keys.include? type
    end
    @selected_type_gold_classnames = @selected_types.collect do |type|
      Gold.classname_for_type(type)
    end 
    @selected_type_answer_classnames = @selected_types.collect do |type|
      Answer.classname_for_type(type)
    end 
    
    # load all the articles
    extra_where_clause = ""
    if @only_not_confident
      extra_where_clause  = 'answers.confidence < ' + Answer::CONFIDENT_THRESHOLD.to_s
    end 
    if @generate_golds
      @articles = Article.where(:sampletag=>@sampletag).includes([:answers,:golds]).
        where('answers.user_id'=>user_ids).where(extra_where_clause)      
    else
      @articles = Article.where(:sampletag=>@sampletag).includes([:answers,:golds]).
        where('golds.type'=>@selected_type_gold_classnames).
        where('answers.type'=>@selected_type_answer_classnames).
        where('answers.user_id'=>user_ids).where(extra_where_clause)      
    end
    
    # compute agreement
    @disagreement_count = 0
    @types = @selected_types
    @agreement_by_article = Hash.new
    @articles.each do |article|
      @agreement_by_article[article.id] = Hash.new
      @types.each do |type|
        @agreement_by_article[article.id][type] = article.agreement_info_for_type(type)
        if @agreement_by_article[article.id][type][:is_of_type]==nil
          @disagreement_count = @disagreement_count + 1
        end
      end
    end
    
    # init golds as needed
    if @generate_golds
      @articles.each do |article|
        @types.each do |type|
          # figure out the gold answer to use, based on agreement in answers
          agreement_info = @agreement_by_article[article.id][type]
          threshold = 0.70 #should be a magic constant somewhere (this is based on our first round of CF testing)
          if (agreement_info[:yes] > threshold) || (agreement_info[:no] > threshold)
            computed_answer = (agreement_info[:yes] > threshold)
          else 
            computed_answer = nil
          end
          # create or update the gold with the new aggregate answer
          this_gold = nil
          if article.missing_gold_by_type(type)
            # create a new gold
            this_gold = Gold.new_by_type(type)
            this_gold.article_id = article.id
            this_gold.answer = computed_answer
          else 
            #it has a gold, update that gold
            this_gold = article.gold_by_type(type)
            this_gold.answer = computed_answer 
          end
          this_gold.save
          article.golds = Gold.where(:article_id=>article.id)
        end
      end
    end
    
  end

  # handle ajax requests when people change things in the UI
  def for_article
    
    article_id = params[:id]
    type = params[:type]
    uids = params[:uids]
    @article = Article.includes([:answers,:golds]).where('answers.user_id'=>uids).find(article_id)

    @agreement_info = @article.agreement_info_for_type(type) 
    @answers = @article.answers_by_type(type)
    @gold = @article.gold_by_type(type)
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

end
