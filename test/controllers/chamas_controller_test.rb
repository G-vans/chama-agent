require "test_helper"

class ChamasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get chamas_index_url
    assert_response :success
  end

  test "should get show" do
    get chamas_show_url
    assert_response :success
  end
end
