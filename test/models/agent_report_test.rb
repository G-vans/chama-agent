require "test_helper"

class AgentReportTest < ActiveSupport::TestCase
  test "health reports use GPT-5.6" do
    assert_equal "gpt-5.6", AgentReportService::MODEL
  end
end
