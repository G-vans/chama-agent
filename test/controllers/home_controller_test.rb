require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root explains chamas and links to the live demo" do
    get root_url

    assert_response :success
    assert_select "h1", /mum's chama/i
    assert_select "a[href='#{chamas_path}']", /Enter the live demo/i
    assert_includes response.body, "~12M"
  end
end
