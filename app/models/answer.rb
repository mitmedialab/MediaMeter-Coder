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

end
