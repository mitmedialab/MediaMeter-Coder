class Gold < ActiveRecord::Base

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
    raise ArgumentError.new("#{gold_type} is not a valid answer type status") if !(GOLD_TYPES.keys.include? gold_type)
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
  
end

