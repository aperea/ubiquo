require File.dirname(__FILE__) + '/../../test_helper'

class Ubiquo::HomeControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

end
