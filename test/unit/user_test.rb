require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:bob)
  end

  test "get next unanswered article" do
    article = @user.get_next_unanswered_article ("international")
    assert_equal articles(:one), article
  end
end
