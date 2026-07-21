require "test_helper"

class ChatAnalysisTest < ActiveSupport::TestCase
  test "parses persisted analysis content" do
    analysis = ChatAnalysis.new(content: { summary: "A useful brief" }.to_json)

    assert_equal "A useful brief", analysis.parsed_content["summary"]
  end

  test "chat intelligence uses GPT-5.6" do
    assert_equal "gpt-5.6", ChatAnalysisService::MODEL
  end
end
