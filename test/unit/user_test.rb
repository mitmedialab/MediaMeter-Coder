require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:bob)
  end

  test "get next unanswered article" do
    article = @user.get_next_unanswered_article ("international")
    assert_equal articles(:one), article
  end

  test "get answer count for answer type" do
    assert_equal 1, users(:bob).find_answers_by_type("international").size
    assert_equal 1, users(:bob).find_answers_by_type("arts").size
    assert_equal 0, users(:bob).find_answers_by_type("local").size
  end
end
