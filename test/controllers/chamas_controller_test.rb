require "test_helper"

class ChamasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get chamas_url
    assert_response :success
  end

  test "should get show" do
    get chama_url(chamas(:one))
    assert_response :success
  end
end
