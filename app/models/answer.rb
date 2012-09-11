class Answer < ActiveRecord::Base

  belongs_to      :article
  belongs_to      :user
  belongs_to      :question

  CONFIDENT_THRESHOLD = 0.75

  def has_confidence?
    return !confidence.nil?
  end
  
  def not_confident?
    return true if has_confidence? && (confidence < CONFIDENT_THRESHOLD)
    return false
  end

  def unanswered?
    answer==nil
  end
  
  def answered?
    answer!=nil
  end

  # group answers for a user by confidence
  def self.confidence_frequency(user_id, question_id)
    # inspired by http://stackoverflow.com/questions/232387/in-sql-how-can-you-group-by-in-ranges
    results = self.connection.execute(sanitize_sql(["
      select s.confidence_group as confidence_range, count(*) as frequency from (
        select case
          when confidence between 0 and 0.1 then '0 to 0.1'
          when confidence between 0.1 and 0.2 then '0 to 0.1'
          when confidence between 0.2 and 0.3 then '0.2 to 0.3'
          when confidence between 0.3 and 0.4 then '0.3 to 0.4'
          when confidence between 0.4 and 0.5 then '0.4 to 0.5'
          when confidence between 0.5 and 0.6 then '0.5 to 0.6'
          when confidence between 0.6 and 0.7 then '0.6 to 0.7'
          when confidence between 0.7 and 0.8 then '0.7 to 0.8'
          when confidence between 0.8 and 0.9 then '0.8 to 0.9'
          when confidence between 0.9 and 1.0 then '0.9 to 1.0'
        end as confidence_group, confidence
        from answers where user_id=? and question_id=?) s
      group by confidence_group
      order by confidence_group desc
      ",user_id,question_id]))
    cleaned_results = Hash.new
    ranges = [ '0 to 0.1', '0.1 to 0.2','0.2 to 0.3', '0.3 to 0.4', '0.4 to 0.5', 
               '0.5 to 0.6', '0.6 to 0.7', '0.7 to 0.8', '0.8 to 0.9', '0.9 to 1.0' ]
    ranges.each do |key|
      cleaned_results[key] = 0
    end
    total_answers = (results.map {|i|i[1].to_i}).inject(:+)
    results.each do |row|
      cleaned_results[row[0]] = row[1].to_i*100 / total_answers
    end
    cleaned_results
  end

  # Import answers from a big CrowdFlower CSV
  def self.import_from_csv(user, question_id, filepath)
    # prep to import
    answer_count = 0
    col_headers = Array.new
    question = Question.find(question_id)
    question_text = question.export_safe_text
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
      "question_id"=>nil,
      answer_col=>nil,
      confidence_col=>nil,
    }
    # import
    parse_worked = true
    results_string = nil
    CSV.foreach(File.open(filepath)) do |row|
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
            results_string = ("Didn't find some required coloumns! Couldn't find these columns: <ul><li>"+(col_indices.keys - col_headers).join("</li><li>")+"</li></ul>").html_safe
            parse_worked = false
          end
        else
          # everything checks out, go ahead and create and save the answer
          answer = Answer.new({
            :user_id => user.id,
            :question_id => question_id,
            :article_id => row[ col_indices["id"] ].to_i,
            :confidence => row[ col_indices[confidence_col] ].to_f,
            :answer => row[ col_indices[answer_col] ],
            :judgements => row[ col_indices["_trusted_judgments"], ].to_i
          })
          answer.save
        end # answer count
      end # parse worked
      answer_count = answer_count + 1
    end # csv for each    
    results_string = "Imported #{answer_count} #{question.title} answers for #{user.username}" if parse_worked
    return parse_worked, results_string
  end

  def self.total_by_user_id 
    user_answer_counts = Hash.new
    User.all.each do |user|
      user_answer_counts[user.id] = Answer.where(:user_id=>user.id).count
    end
    user_answer_counts
  end
  
end
