class Question < ActiveRecord::Base

  has_many :answers
  
  alias_attribute :name, :title

  def export_safe_text
    title.downcase.gsub(/ /,"_")
  end

  def self.for_answer_type answer_type
    Question.where(:key=>answer_type.camelize).first
  end

end
