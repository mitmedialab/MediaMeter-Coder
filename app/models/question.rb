class Question < ActiveRecord::Base

  has_many :answers
  
  alias_attribute :name, :title

  def export_safe_text
    title.downcase.gsub(/ /,"_")
  end

  def answer_list
    list = {}
    (1..5).each do |answer_num|
      list[answer_text(answer_num)] = answer_num if has_answer answer_num
    end
    list
  end
  
  def has_answer answer_num
    !(answer_text answer_num).empty? 
  end
  
  def answer_text answer_num
    text = ""
    case answer_num
    when 1
      text = answer_one
    when 2 
      text = answer_two
    when 3 
      text = answer_three
    when 4 
      text = answer_four
    when 5 
      text = answer_five
    end
    text
  end

end
