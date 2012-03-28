class AnswersController < ApplicationController

  def import
    @users = User.all
    @all_answer_types = Gold.types 
    if request.post?
      # TODO: verify params exist
      user = User.find(params[:username])
      question_type = params[:answer][:type]
      upload = params[:my_file]
      # prep to import
      answer_count = 0
      col_headers = Array.new
      question_text = Article.question_text(question_type).downcase.gsub(/ /,"_")
      answer_col = question_text 
      confidence_col = question_text+":confidence"
      col_indices = {
        "id"=>nil,
        "_trusted_judgments"=>nil,
        "newspaper"=>nil,
        "page"=>nil,
        "headline"=>nil,
        "date"=>nil,
        "content"=>nil,
        "byline"=>nil,
        "answer_type"=>nil,
        answer_col=>nil,
        confidence_col=>nil,
      }
      # import
      parse_worked = true
      error_msg = nil
      CSV.foreach(File.open(upload.tempfile)) do |row|
        if parse_worked
          if answer_count==0
            # check out col headers and validate we can find the 3 cols we need (id, _trusted_judgments, answer, confidence)
            col_headers = row
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
              flash.now[:error] = "Row #{answer_count} has the wrong type!  Expecting #{question_type} but found #{answer_type}"  
              parse_worked = false       
            else
              # everything checks out, go ahead and create and save the answer
              answer = Answer.new_by_type(answer_type)
              answer.user_id = user.id
              answer.article_id = row[ col_indices["id"] ].to_i
              answer.confidence = row[ col_indices[confidence_col] ].to_f
              answer.answer = (row[ col_indices[answer_col] ] == "Yes")
              answer.judgements = row[ col_indices["_trusted_judgments"] ].to_i
              answer.save
            end
          end # answer count
        end # parse worked
        answer_count = answer_count + 1
      end # csv for each
    end # is post
    # generate some feedback
    if parse_worked
      flash.now[:notice] = "Imported #{answer_count} #{question_type} answers for #{user.username} (from #{upload.original_filename})"
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
    
    # load all the articles
    @articles = Article.where(:sampletag=>@sampletag).includes([:answers,:golds]).
      where('answers.user_id'=>user_ids)

    # compute agreement
    @disagreement_count = 0
    @types = Answer.types
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
    @articles.each do |article|
      reload_golds = false
      @types.each do |type|
      if @generate_golds && article.missing_gold_by_type(type)
          agreement_info = @agreement_by_article[article.id][type]
          threshold = 0.70 #should be a magic constant somewhere
          if (agreement_info[:yes] > threshold) || (agreement_info[:no] > threshold)
            computed_answer = (agreement_info[:yes] > threshold)
          else 
            computed_answer = nil
          end
          new_gold = Gold.new_by_type(type)
          new_gold.article_id = article.id
          new_gold.answer = computed_answer
          new_gold.save
          reload_golds = true
        end
      end
      article.golds = Gold.where(:article_id=>article.id) if reload_golds
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
