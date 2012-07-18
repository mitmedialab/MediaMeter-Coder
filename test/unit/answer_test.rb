require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  
  test "new by type" do
    generic_one = Answer.new_by_type "generic_one", {:user=>users(:bob), 
                                         :article=>articles(:one), 
                                         :source=>"MediaMeter Coder"}
    answer_test(generic_one, "GenericOneAnswer", users(:bob), articles(:one), "MediaMeter Coder")


    generic_two = Answer.new_by_type "generic_two", {:user=>users(:bob), 
                                                         :article=>articles(:one), 
                                                         :source=>"MediaMeter Coder"}
    answer_test(generic_two, "GenericTwoAnswer", users(:bob), articles(:one), "MediaMeter Coder")

  end

  def answer_test(answer, classname, user, article, source)
    assert_equal classname, answer.class.to_s
    assert_equal user, answer.user
    assert_equal article, answer.article
    assert_equal source, answer.source
  end

end
