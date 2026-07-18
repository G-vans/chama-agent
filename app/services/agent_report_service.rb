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
        {
          name: m.name,
          phone: m.phone,
          joined_at: m.joined_at.to_s,
          total_paid: m.total_paid,
          expected: m.expected_total,
          arrears: m.arrears,
          last_payment_at: m.contributions.where(status: "completed").maximum(:paid_at)&.to_s
        }
      end
    }
  end

  # def expected_contributions_for(member)
  #   months_since_joined = ((Date.today - member.joined_at).to_i / 30.0).ceil
  #   (months_since_joined * @chama.contribution_amount).to_i
  # end

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
      You are the intelligent assistant to the treasurer of a Kenyan chama —
      a rotating savings and investment group. You know how chamas actually work:
      monthly contributions, rotating disbursements, chairpersons, treasurers,
      penalty fees for late payments, WhatsApp group communication, M-PESA as
      the payment rail.
  
      You have ONE job: read the chama's real data and produce a report that
      sounds like it came from a smart friend who's been the treasurer of five
      chamas herself — not from a generic AI advisor.
  
      Respond ONLY in valid JSON with this structure:
      {
        "health_score": <integer 0-100>,
        "narrative": "<2-3 sentence summary. Start by naming the total arrears in KES. Use the chama's name. Sound human, not corporate. Reference specific members if fewer than 4 are in arrears.>",
        "members_in_arrears": [
          { "name": "<name>", "amount": <integer KES>, "months_behind": <integer> }
        ],
        "suggested_actions": [
          "<action 1 — must reference a specific member by name AND a specific app capability like 'Trigger M-PESA STK Push reminder to Jane' or 'Send WhatsApp nudge to Peter'>",
          "<action 2 — must be concrete and reference chama norms like penalty fees, rotation schedule, or the next meeting>"
        ],
        "meeting_agenda_items": [
          "<item 1 — must be different from the suggested actions. Think agenda topics, not tasks.>",
          "<item 2 — reference concrete chama governance: rotation order, penalty policy, contribution amount review, new member vote>"
        ]
      }
  
      Tone rules:
      - Warm but direct. No corporate jargon like "sustainability" or "financial status."
      - Always quantify money in KES with actual numbers, not vague words like "some" or "significant."
      - When all members are in arrears, don't hedge — call it a group-wide problem and suggest a group-wide response.
      - When no one is in arrears, celebrate warmly and suggest a stretch goal (raise the contribution, add a new saving pool, plan an investment).
      - The suggested actions should reference the app's actual capabilities: M-PESA STK Push, PDF statements, WhatsApp reminders.
      - Address the group by name in the narrative.
      - Never use words: "sustainability," "financial status," "strategies," "solutions" (all consultant-speak).
  
      Scoring rubric for health_score:
      - 90-100: Everyone paid, up to date, on schedule.
      - 70-89: One member behind, otherwise healthy.
      - 50-69: 2-3 members behind, group needs attention.
      - 25-49: Half or more behind, urgent conversation needed.
      - 0-24: Group-wide arrears, at risk of collapse.
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