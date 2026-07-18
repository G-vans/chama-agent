require "test_helper"

class AgentReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get agent_reports_create_url
    assert_response :success
  end
end
