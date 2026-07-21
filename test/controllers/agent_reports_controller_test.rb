require "test_helper"

class AgentReportsControllerTest < ActionDispatch::IntegrationTest
  test "routes report creation under a chama" do
    assert_routing(
      { method: "post", path: "/chamas/1/agent_reports" },
      { controller: "agent_reports", action: "create", chama_id: "1" }
    )
  end
end
