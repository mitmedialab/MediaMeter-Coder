class Gold < ActiveRecord::Base

  self.per_page = 100

  belongs_to      :article

  GOLD_TYPES = {
    "generic_one"=>"GenericOneGold",
    "generic_two"=>"GenericTwoGold"
  }

  def self.classname_for_type(gold_type)
    raise ArgumentError.new("#{gold_type} is not a valid gold type") if !(GOLD_TYPES.has_key? gold_type)
    GOLD_TYPES[gold_type]
  end

  def self.type_for_classname(class_name)
    raise ArgumentError.new("#{class_name} is not a valid gold class") if !(GOLD_TYPES.has_value? class_name)
    GOLD_TYPES.key class_name
  end

  def self.new_by_type(gold_type, args={})
    classname = self.classname_for_type(gold_type)
    classname.constantize.new(args)
  end

  def self.types
    GOLD_TYPES.keys.sort
  end

  def is_type(type)
    Gold::classname_for_type(type)==self.class.name
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
  
  def has_reason?
    (reason!=nil) && (reason.length > 0)
  end

  # return a hash of type=>total, reasoned, pct of golds with reasons
  def self.reasoned_percent_by_type
    with_reasons = Gold.group(:type).where('reason is not null').count
    logger.info with_reasons
    all = Gold.group(:type).count
    pcts = {}
    all.each do |type_classname,count|
      type_short_name = type_for_classname(type_classname)
      pct = 0.0 
      pct = with_reasons[type_classname].to_f / count.to_f if with_reasons.has_key? type_classname
      pcts[type_short_name] = { 
        :total => all[type_classname],
        :reasoned => with_reasons[type_classname], 
        :pct => pct
        }   
    end
    pcts
  end
  
  def self.counts_by_type_source_year(sampletags,types,sources,years)
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
    counts = Gold.includes(:article).where('YEAR(articles.pub_date) > 0').where('articles.sampletag'=>sampletags).
      group(:type,'articles.source','YEAR(articles.pub_date)',:answer).count
    counts.each do |groups, value|
      type = Gold::type_for_classname(groups[0])
      source = groups[1]
      year = groups[2]
      answer = groups[3]
      yes_counts[type][source][year] = value if answer==true
    end
    # return
    yes_counts
  end

end

