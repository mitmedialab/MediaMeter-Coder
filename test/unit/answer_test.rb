require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  
  test "new by type" do
    local = Answer.new_by_type "local", {:user=>users(:bob), 
                                         :article=>articles(:one), 
                                         :source=>"MediaMeter Coder"}
    answer_test(local, "LocalAnswer", users(:bob), articles(:one), "MediaMeter Coder")


    international = Answer.new_by_type "international", {:user=>users(:bob), 
                                                         :article=>articles(:one), 
                                                         :source=>"MediaMeter Coder"}
    answer_test(international, "InternationalAnswer", users(:bob), articles(:one), "MediaMeter Coder")


    foreign = Answer.new_by_type "foreign", {:user=>users(:bob), 
                                             :article=>articles(:one), 
                                             :source=>"MediaMeter Coder"}
    answer_test(foreign, "ForeignAnswer", users(:bob), articles(:one), "MediaMeter Coder")


    arts = Answer.new_by_type "arts", {:user=>users(:bob), 
                                       :article=>articles(:one), 
                                       :source=>"MediaMeter Coder"}
    answer_test(arts, "ArtsAnswer", users(:bob), articles(:one), "MediaMeter Coder")


    sports = Answer.new_by_type "sports", {:user=>users(:bob), 
                                           :article=>articles(:one), 
                                            :source=>"MediaMeter Coder"}
    answer_test(sports, "SportsAnswer", users(:bob), articles(:one), "MediaMeter Coder")


    national = Answer.new_by_type "national", {:user=>users(:bob), 
                                               :article=>articles(:one), 
                                               :source=>"MediaMeter Coder"}
    answer_test(national, "NationalAnswer", users(:bob), articles(:one), "MediaMeter Coder")

  end

  def answer_test(answer, classname, user, article, source)
    assert_equal classname, answer.class.to_s
    assert_equal user, answer.user
    assert_equal article, answer.article
    assert_equal source, answer.source
  end

end
