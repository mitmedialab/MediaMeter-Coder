class Gold < ActiveRecord::Base

  self.per_page = 100

  belongs_to      :article

  GOLD_TYPES = {
    "arts"=>"ArtsGold",
    "foreign"=>"ForeignGold", 
    "international"=>"InternationalGold", 
    "local"=>"LocalGold", 
    "national"=>"NationalGold", 
    "sports"=>"SportsGold"
  }

  def self.classname_for_type(gold_type)
    raise ArgumentError.new("#{gold_type} is not a valid gold type status") if !(GOLD_TYPES.keys.include? gold_type)
    GOLD_TYPES[gold_type]
  end

  def self.new_by_type(gold_type, args={})
    classname = self.classname_for_type(gold_type)
    classname.constantize.new(args)
  end

  def self.types
    GOLD_TYPES.keys
  end

  def is_type(type)
    return Gold::classname_for_type(type)==self.class.name
  end
  
  def unanswered?
    return answer==nil
  end
  
  def answered?
    return answer!=nil
  end

end

