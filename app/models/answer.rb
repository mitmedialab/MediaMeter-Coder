class Answer < ActiveRecord::Base

  belongs_to      :article
  belongs_to      :user

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

  def self.new_by_type(answer_type)
    classname = self.classname_for_type(answer_type)
    classname.constantize.new
  end

end
