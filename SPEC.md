# Chama Agent — Project Spec

**Built for OpenAI Build Week 2026**
**Track:** Work and Productivity
**Author:** Jevans Otieno

---

## One-line pitch

A treasurer's copilot for Kenyan rotating savings groups (chamas) — uses M-PESA to automate contribution collection and GPT-5.6 to produce intelligent group health reports.

---

## The problem

Roughly 12 million Kenyan adults participate in a chama — a rotating savings and investment group. The treasurer manages the entire operation on Excel spreadsheets, WhatsApp messages, and memory. Contributions get missed. Balances get disputed. Groups collapse from bookkeeping errors that were preventable.

No tool exists that fits how chamas actually work — mobile-first, WhatsApp-native, M-PESA as the payment rail.

Beyond Kenya, rotating savings groups exist across cultures: **susu** in Ghana, **tanda** in Mexico, **kye** in Korea, **hui** in China, **ROSCA** in academic terms. Roughly **700 million people globally** use this pattern. The chama problem is universal — this agent extends beyond Kenya.

---

## Target users

- **Primary:** chama treasurers in Kenya (25-55, WhatsApp-native, mobile-first)
- **Secondary:** chairpersons and members who want visibility into the group's health
- **Long-term:** any rotating savings/investment group globally

---

## Core MVP (Build Week scope)

1. **Chama + Member management** — CRUD with a Hotwire dashboard
2. **M-PESA STK Push contribution collection** — via Daraja sandbox
3. **AI-generated Chama Health Reports** — GPT-5.6 reads real chama data and produces a natural-language summary + suggested actions + meeting agenda items
4. **PDF member statements** — downloadable via Prawn
5. **Callback loop** — Daraja webhook → contribution recorded → real-time UI update via Turbo Streams

### Out of scope for the hackathon
- Real M-PESA production (sandbox only)
- Live WhatsApp Business API (parse exported chat if time permits)
- Voice-first UX
- Multi-currency / multi-country
- Mobile app

---

## Tech stack

| Layer | Tool | Why |
|---|---|---|
| Backend | Ruby on Rails 8.1 | Familiar stack, ships fast |
| Database | SQLite (dev), PostgreSQL-ready | Simple deploy for demo |
| Background jobs | Sidekiq | For callback processing + async reports |
| HTTP client | Faraday | Daraja + OpenAI calls |
| LLM | GPT-5.6 via `ruby-openai` | The agentic reasoning layer |
| Build tool | Codex CLI + ChatGPT Codex | Paired programming during the sprint |
| Frontend | Hotwire (Turbo + Stimulus) + Tailwind | Fast, server-rendered, mobile-friendly |
| PDF | Prawn + Prawn-Table | Member statements |
| Payments | Safaricom Daraja API | M-PESA STK Push (sandbox) |
| Env | dotenv-rails | Local config |
| Tunneling | ngrok | Expose local server for Daraja callbacks |

---

## Data model

```
Chama
├── name (string)
├── contribution_amount (decimal)
├── frequency (string) — "monthly", "weekly"
└── has_many: members, agent_reports

Member
├── name (string)
├── phone (string) — format "2547XXXXXXXX"
├── chama_id (fk)
├── joined_at (date)
└── has_many: contributions

Contribution
├── member_id (fk)
├── amount (decimal)
├── mpesa_receipt (string) — from Daraja callback
├── paid_at (datetime)
├── status (string) — "pending", "completed", "failed"

AgentReport
├── chama_id (fk)
├── content (jsonb/text) — GPT-5.6 output
└── generated_at (datetime)
```

---

## Core user flow (this is the demo video)

**0:00-0:20 — Hook.** Screenshot of a real chama's WhatsApp group (redacted names) showing contribution reminders, disputes, missed payments.

**0:20-1:00 — The dashboard.** Treasurer opens Chama Agent. Sees: 5 members, contributions this cycle, who's paid, who's in arrears.

**1:00-1:40 — The agentic moment.** Treasurer clicks **"Generate Health Report."** GPT-5.6 analyzes the chama's data and produces:
- A health score (0-100)
- Narrative summary the treasurer could read at the meeting
- Members in arrears with amounts
- Suggested actions
- Proposed meeting agenda items

Show this appearing on screen.

**1:40-2:15 — Payment flow.** Treasurer clicks **"Request Contribution"** on Jane's row. STK Push fires (sandbox). Callback returns. Jane's contribution appears in the ledger. UI updates via Turbo Stream.

**2:15-2:45 — PDF statement.** Treasurer downloads Jane's monthly statement PDF. Show the clean output.

**2:45-3:00 — Global framing.** *"Rotating savings groups exist as susu in Ghana, tanda in Mexico, kye in Korea. 700 million people worldwide use this pattern. Chama Agent extends to all of them."*

---

## Judging criteria alignment

| Criterion | How Chama Agent delivers |
|---|---|
| **Technological Implementation** | Codex used for building M-PESA integration + PDF layer + service classes. GPT-5.6 does the intelligent reasoning in `AgentReportService`. Both used meaningfully, not superficially. |
| **Design** | Complete product experience — treasurer flow from dashboard → agent report → contribution collection → PDF statement. Not a technical demo, a working product slice. |
| **Potential Impact** | 12M Kenyans + 700M globally in rotating savings groups. Real audience, real bookkeeping pain, existing informal financial market ~$3-4B/year in Kenya alone. |
| **Quality of the Idea** | Kenya-rooted, globally universal. Non-obvious framing — treats chamas as legitimate financial infrastructure, not informal fringe activity. |

---

## Build plan (5 days)

### Day 1 — Friday July 17 ✅
- Rails app scaffolded, models generated, seeds working
- Daraja sandbox account created
- Gemfile updated with all dependencies
- `.env` skeleton
- OpenAI credits redeemed
- DarajaClient service class working (OAuth + STK Push tested in console)

### Day 2 — Saturday evening (post-Sabbath)
- `AgentReportService` — GPT-5.6 integration
- Prompt engineering to produce clean JSON reports
- Test with seed data, iterate prompt until output is convincing
- First agent-generated report saved to DB

### Day 3 — Sunday (full day)
- **Morning:** Hotwire dashboard for Chama + Members + Contributions
- **Midday:** PDF statement generation via Prawn
- **Afternoon:** ngrok setup + Daraja callback controller + Turbo Stream real-time updates
- **Evening:** Demo data polish, seed 2-3 realistic chamas, tune the agent output

### Day 4 — Monday (deadline day)
- **Morning:** Bug fixes, edge cases, final agent prompt tuning
- **Midday:** Record 3-minute demo video (script → screen recording → voice-over)
- **Afternoon:** Write README, clean up repo, verify submission requirements
- **Evening:** Submit on Devpost by 5pm PT (3am Tuesday EAT)

---

## Codex usage log

Track key moments where Codex accelerated development. This directly maps to a judging criterion.

- [ ] Scaffolded DarajaClient service class
- [ ] Generated STK Push request body structure
- [ ] Built Prawn PDF layout code
- [ ] Wrote Turbo Stream broadcast handlers
- [ ] Refactored callback controller
- [ ] Add more as they happen…

---

## Prompt design principles for AgentReportService

The agent's output must be:
- **Warm and practical** — like a trusted friend, not a bank statement
- **Culturally aware** — uses KES, addresses the group by name, respects chama norms
- **Actionable** — every insight ties to a suggested action
- **Structured** — always valid JSON so the app can render it reliably

Key prompt elements:
1. System role: "assistant for the treasurer of a Kenyan chama"
2. Response format: strict JSON schema
3. Instruction to celebrate if no one is in arrears
4. Temperature: 0.4 (some warmth in language, still structured)

---

## Stretch goals (only if time permits)

- **WhatsApp chat parsing** — upload exported `.txt`, agent extracts meeting decisions and disputes
- **Loan eligibility** — agent reasons over contribution history to suggest whether a member qualifies for a chama loan
- **SMS reminders** — via Africa's Talking free tier, agent-generated messages sent to members in arrears
- **Meeting minutes generator** — record a chairperson's voice note, agent transcribes + structures it
- **Multi-language** — Swahili output for members who prefer it

---

## Global expansion notes

Same core value proposition works for:
- **Ghana** (susu) — mobile money via MTN MoMo
- **Nigeria** (esusu / ajo) — mobile money via Paystack
- **Mexico** (tanda) — mobile wallet via Mercado Pago
- **Philippines** (paluwagan) — GCash
- **India** (chit funds) — UPI

Payment rail swaps, but the agent layer and data model remain the same.

---

## Success metrics for the demo

- Judges can watch the 3-minute video and immediately understand what Chama Agent does
- The AI report output feels intelligent, not templated
- The M-PESA flow visibly works (STK Push → callback → recorded contribution)
- The global framing lands (rotating savings is universal)
- Codex usage is clearly demonstrated in the video voice-over

---

## Repository structure

```
chama-agent/
├── app/
│   ├── models/
│   │   ├── chama.rb
│   │   ├── member.rb
│   │   ├── contribution.rb
│   │   └── agent_report.rb
│   ├── services/
│   │   ├── daraja_client.rb
│   │   ├── stk_push_service.rb
│   │   └── agent_report_service.rb
│   ├── controllers/
│   │   ├── chamas_controller.rb
│   │   ├── members_controller.rb
│   │   ├── contributions_controller.rb
│   │   ├── agent_reports_controller.rb
│   │   └── api/mpesa_controller.rb
│   ├── jobs/
│   │   ├── mpesa_callback_job.rb
│   │   └── generate_report_job.rb
│   └── views/
│       ├── chamas/
│       ├── members/
│       ├── agent_reports/
│       └── layouts/
├── db/
│   ├── migrate/
│   ├── schema.rb
│   └── seeds.rb
├── config/
├── SPEC.md            (this file)
├── README.md          (submission-facing)
├── .env.example
└── .env               (gitignored)
```
