class Answer < ActiveRecord::Base

  belongs_to      :article
  belongs_to      :user

  CONFIDENT_THRESHOLD = 0.75

  ANSWER_TYPES = {
    "arts"=>"ArtsAnswer",
    "foreign"=>"ForeignAnswer", 
    "international"=>"InternationalAnswer", 
    "local"=>"LocalAnswer", 
    "national"=>"NationalAnswer", 
    "sports"=>"SportsAnswer"
  }

  def self.classname_for_type(answer_type)
    raise ArgumentError.new("#{answer_type} is not a valid answer type status") if !(ANSWER_TYPES.keys.include? answer_type)
    ANSWER_TYPES[answer_type]
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

end
