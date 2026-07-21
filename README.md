# Chama Agent

Chama Agent is a GPT-5.6 operations copilot for Kenyan savings groups. It turns contribution records and exported group conversations into concrete decisions, collection actions, meeting agendas, reminders, and accountable member statements.

Built for **OpenAI Build Week 2026 — Work & Productivity**.

## Why it exists

Chama officials often coordinate money and decisions across spreadsheets, M-PESA messages, meetings, and busy WhatsApp groups. Missed contributions and buried decisions create avoidable disputes.

Chama Agent gives an official one operational view:

- GPT-5.6 health reports grounded in the chama's contribution records
- GPT-5.6 analysis of exported WhatsApp or community-channel conversations
- M-PESA Daraja STK Push contribution requests
- Daraja callback processing with live Turbo Stream dashboard updates
- PDF member statements
- Deterministic sample data for a repeatable demonstration

The same operating model can extend to funeral committees, wedding contributions, welfare groups, alumni groups, and other member-led communities. Payment and chat channels may change; the need to turn conversation into accountable action remains.

## Demo flow

1. Open Demo Chama and review member arrears.
2. Generate a GPT-5.6 health report.
3. Paste [`db/sample_whatsapp_chat.txt`](db/sample_whatsapp_chat.txt) into **Group Chat Intelligence** and analyze it.
4. Request Jane's KES 5,000 contribution through M-PESA.
5. Watch the callback create a Contribution and replace Jane's row over Turbo Streams.
6. Download Jane's PDF statement.

## Technology

- Ruby 3.4.3 and Rails 8.1
- SQLite for the hackathon demo
- Hotwire: Turbo Streams and Action Cable
- Tailwind CSS
- GPT-5.6 through `ruby-openai`
- Safaricom Daraja sandbox through Faraday
- Prawn for PDF statements

## Setup

Prerequisites:

- Ruby 3.4+
- Bundler
- An OpenAI API key with GPT-5.6 access
- Daraja sandbox credentials
- ngrok for receiving Daraja callbacks locally

Install and prepare the app:

```sh
git clone git@github.com:G-vans/chama-agent.git
cd chama-agent
bundle install
cp .env.example .env
bin/rails db:prepare
bin/rails db:seed
```

Add your credentials to `.env`, then start Rails:

```sh
bin/rails server -p 3001
```

The seeded app contains one Demo Chama with five members. Jane starts exactly KES 5,000 behind, making her the payment-flow demo target. Running `bin/rails db:seed` again resets this chama's reports, chat analyses, members, and contributions to the same starting point.

## Daraja callback setup

Start a tunnel in another terminal:

```sh
ngrok http 3001
```

Set the generated HTTPS URL in `.env`:

```env
DARAJA_CALLBACK_URL=https://your-subdomain.ngrok-free.app/api/mpesa/callback
```

Restart Rails after changing the callback URL. The development configuration permits only the exact callback host configured in this variable.

Safaricom's sandbox can return timeout code `1037` even when the full STK Push and callback loop is correctly connected. For a reliable recorded demonstration, the optional and visibly disclosed fallback can be enabled:

```env
DARAJA_DEMO_MODE=true
```

When enabled, a failed sandbox callback is correlated to the requested member and completed with a `DEMO-*` receipt through the same Contribution and Turbo broadcast path. It is disabled by default and the dashboard displays a **Sandbox demo mode** notice while active.

## Testing

```sh
bin/rails test
bin/rails zeitwerk:check
```

The test suite covers successful and failed Daraja callbacks, the disclosed sandbox fallback, STK Push request arguments, dashboard rendering, and GPT-5.6 model enforcement.

## How GPT-5.6 is used

`AgentReportService` sends real contribution history, expected totals, arrears, and last-payment information to GPT-5.6. It returns a structured health score, narrative, arrears list, suggested actions, and meeting agenda.

`ChatAnalysisService` sends an imported conversation plus known member names to GPT-5.6. It returns a structured operations brief containing topics, actual decisions, owned action items, contribution commitments, unresolved issues, recommended reminders, and a meeting agenda. The prompt explicitly instructs the model not to invent decisions, owners, dates, or amounts.

Both features use JSON output that Rails persists and renders, so GPT-5.6 is part of the working application rather than a decorative chatbot.

## How Codex accelerated the build

Codex was used as the primary implementation collaborator throughout Build Week. It helped:

- Design and implement the Daraja OAuth, STK Push, and webhook flow
- Diagnose Rails host authorization and Safaricom sandbox callback failures
- Build Turbo Stream request states and live Action Cable member updates
- Find and repair callback-to-member correlation behavior
- Upgrade the shipped health-report path from the iteration model to GPT-5.6
- Diagnose GPT-5.6's unsupported custom temperature using the live API error
- Build and validate the GPT-5.6 group-chat intelligence workflow
- Make seed data deterministic and add focused integration tests
- Structure the repository and demo around the judging criteria

The repository history intentionally keeps these capabilities in small sequential commits so judges can inspect how the product evolved.

## Important scope note

The current project analyzes conversations pasted from an exported WhatsApp or other group-channel transcript. It does not claim live WhatsApp Business API connectivity. A production version would connect the same agent services to the channels each community already uses, subject to member consent and platform permissions.
