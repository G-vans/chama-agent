class ChatAnalysisService
  MODEL = "gpt-5.6".freeze

  def initialize(chama, source_text)
    @chama = chama
    @source_text = source_text
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def call
    response = @client.chat(
      parameters: {
        model: MODEL,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ]
      }
    )

    content = JSON.parse(response.dig("choices", 0, "message", "content"))
    ChatAnalysis.create!(
      chama: @chama,
      source_text: @source_text,
      content: content.to_json,
      analyzed_at: Time.current
    )
  end

  private

  def system_prompt
    <<~PROMPT
      You are the operations assistant for a Kenyan community group. The group may
      be a savings chama, funeral committee, wedding committee, welfare group, or
      another member-led initiative. Analyze an exported group-chat excerpt and
      turn informal discussion into an accurate operational brief.

      Do not invent decisions, owners, dates, amounts, or commitments. Clearly put
      uncertain or unresolved matters under unresolved_issues. Return only JSON:
      {
        "summary": "2-3 sentence plain-language brief",
        "topics": ["topic"],
        "decisions": ["decision actually agreed in the chat"],
        "action_items": [{"owner": "name or Unassigned", "task": "task", "due": "stated date or Not specified"}],
        "contribution_commitments": [{"member": "name", "amount": 0, "when": "stated date or Not specified"}],
        "unresolved_issues": ["issue"],
        "recommended_reminders": ["specific reminder an official should send"],
        "meeting_agenda": ["agenda item"]
      }
    PROMPT
  end

  def user_prompt
    <<~PROMPT
      Group: #{@chama.name}
      Known members: #{@chama.members.order(:name).pluck(:name).join(', ')}

      Exported chat:
      #{@source_text}
    PROMPT
  end
end
