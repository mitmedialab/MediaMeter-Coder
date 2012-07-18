class Answer < ActiveRecord::Base

  belongs_to      :article
  belongs_to      :user

  CONFIDENT_THRESHOLD = 0.75

  ANSWER_TYPES = {
    "generic_one"=>"GenericOneAnswer",
    "generic_two"=>"GenericTwoAnswer"
  }

  def self.classname_for_type(answer_type)
    raise ArgumentError.new("#{answer_type} is not a valid answer type status") if !(ANSWER_TYPES.keys.include? answer_type)
    ANSWER_TYPES[answer_type]
  end

  def self.type_for_classname(class_name)
    raise ArgumentError.new("#{class_name} is not a valid answer class") if !(ANSWER_TYPES.has_value? class_name)
    ANSWER_TYPES.key class_name
  end

  def self.new_by_type(answer_type, args={})
    classname = self.classname_for_type(answer_type)
    classname.constantize.new(args)
  end

  def self.types
    ANSWER_TYPES.keys
  end

  def is_type(type)
    return Answer::classname_for_type(type)==self.class.name
  end

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

  def yes?
    answer==true
  end

  def no?
    answer==false
  end

  def self.counts_by_type_source_year(sampletags,types,sources,years,user_ids)
    # init the return storage
    yes_counts = {} 
    types.each do |type|
      yes_counts[type] = {}
      sources.each do |source| 
        yes_counts[type][source] = {}
        years.each do |year|
          yes_counts[type][source][year] = 0
        end
      end
    end
    # fill in the counts
    counts = Answer.includes(:article).
      where('YEAR(articles.pub_date) > 0').
      where('articles.sampletag'=>sampletags,'user_id'=>user_ids).
      group(:type,'articles.source','YEAR(articles.pub_date)',:answer).count
    counts.each do |groups, value|
      type = Answer::type_for_classname(groups[0])
      source = groups[1]
      year = groups[2]
      answer = groups[3]
      yes_counts[type][source][year] = value if answer==true
    end
    # return
    yes_counts
  end

  # group answers for a user by confidence
  def self.confidence_frequency(user_id, answer_type)
    type_class = Answer::classname_for_type(answer_type)
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
        from answers where user_id=? and type=?) s
      group by confidence_group
      order by confidence_group desc
      ",user_id,type_class]))
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

  # Import answers from a big CSV
  def self.import_from_csv(user, question_type, filepath)
    # prep to import
    answer_count = 0
    col_headers = Array.new
    question = Question.for_answer_type(question_type)
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
      "answer_type"=>nil,
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
          # verify answer info, just to be safe
          answer_type = row[ col_indices["answer_type"] ]
          if answer_type!=question_type
            results_string = "Row #{answer_count} has the wrong type!  Expecting #{question_type} but found #{answer_type}"  
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
    results_string = "Imported #{answer_count} #{question_type} answers for #{user.username}" if parse_worked
    return parse_worked, results_string
  end

end
