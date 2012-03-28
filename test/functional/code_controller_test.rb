require 'test_helper'

class CodeControllerTest < ActionController::TestCase
  setup do
    @article = articles(:two)
    @user = users(:bob)
  end

  test "answer" do

    assert_no_difference('Answer.count') do
      post :answer,
        {:answer_type=>"international"},
        {:username=>@user.username}
        assert_equal articles(:one), assigns[:article]
#        assert_select 'a[href=?]', "/article_scans/12345.pdf", :text=>"Read PDF for detail"
    end

    assert_difference('Answer.count') do
      assert_difference('InternationalAnswer.count') do
        post :answer, 
             {:id=> @article.id, :answer_type=>"international", :answer=>"yes"},
             {:username=>@user.username}
        assert assigns[:answer]
        assert_equal @article.id, assigns[:answer].article.id
        assert_equal "MediaMeter Coder", assigns[:answer].source
        assert_equal articles(:one), assigns[:article]
      end
    end

    assert_difference('Answer.count') do
      assert_difference('InternationalAnswer.count') do
        post :answer,
             {:id=> @article.id, :answer_type=>"international", :answer=>"no"},
             {:username=>@user.username}
      end
    end

    assert_no_difference('Answer.count') do
      e = assert_raise(ArgumentError){
        post :answer,
             {:id=> @article.id, :answer_type=>"wiggle", :answer=>"yes"},
             {:username=>@user.username}
      }
      assert_match(/not a valid answer type status/, e.message)
      post :answer,
           {:id=> @article.id, :answer_type=>"international", :answer=>"wiggle"},
           {:username=>@user.username}
    end
  end

end
