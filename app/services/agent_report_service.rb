class AgentReportService
  # Use gpt-4o-mini for iteration (cheap), swap to "gpt-5.6" for final demo runs
  MODEL = ENV.fetch("AGENT_MODEL", "gpt-4o-mini").freeze

  def initialize(chama)
    @chama = chama
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  # Generates and persists an AgentReport for the chama.
  # Returns the AgentReport record.
  def call
    context = build_context
    response = call_llm(context)
    report_content = parse_response(response)

    AgentReport.create!(
      chama: @chama,
      content: report_content.to_json,
      generated_at: Time.current
    )
  end

  private

  def build_context
    members = @chama.members.includes(:contributions)

    {
      chama: {
        name: @chama.name,
        contribution_amount: @chama.contribution_amount.to_i,
        frequency: @chama.frequency,
        member_count: members.count
      },
      members: members.map do |m|
        total_paid = m.contributions.where(status: "completed").sum(:amount).to_i
        expected = expected_contributions_for(m)
        {
          name: m.name,
          phone: m.phone,
          joined_at: m.joined_at.to_s,
          total_paid: total_paid,
          expected: expected,
          arrears: [expected - total_paid, 0].max,
          last_payment_at: m.contributions.where(status: "completed").maximum(:paid_at)&.to_s
        }
      end
    }
  end

  def expected_contributions_for(member)
    months_since_joined = ((Date.today - member.joined_at).to_i / 30.0).ceil
    (months_since_joined * @chama.contribution_amount).to_i
  end

  def call_llm(context)
    @client.chat(
      parameters: {
        model: MODEL,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt(context) }
        ],
        temperature: 0.4
      }
    )
  end

  def system_prompt
    <<~PROMPT
      You are an intelligent assistant for the treasurer of a Kenyan chama
      (rotating savings and investment group). Your job is to analyze the
      group's financial data and produce a clear, actionable report.

      Respond ONLY in valid JSON with this structure:
      {
        "health_score": <integer 0-100>,
        "narrative": "<2-3 sentence plain-English summary the treasurer could read at the meeting>",
        "members_in_arrears": [
          { "name": "<name>", "amount": <integer KES>, "months_behind": <integer> }
        ],
        "suggested_actions": [
          "<action 1>",
          "<action 2>"
        ],
        "meeting_agenda_items": [
          "<item 1>",
          "<item 2>"
        ]
      }

      Tone: warm and practical, like a trusted friend, not a bank statement.
      Use KES for money. Address the group by name.
      If no one is in arrears, celebrate it briefly.
    PROMPT
  end

  def user_prompt(context)
    <<~PROMPT
      Analyze this chama and produce your report.

      Chama data:
      #{JSON.pretty_generate(context)}
    PROMPT
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    JSON.parse(content)
  end
end