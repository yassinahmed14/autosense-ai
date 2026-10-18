# Milestones and lean costs

Planning ranges assume one developer, existing computer/phones and a small pilot.
They are estimates, not quotes or delivery promises. Amounts are USD, excluding
taxes, professional labor, vehicle access and store commissions. Reviewed 2026-10-12.

| Stage | Estimate | Exit criteria |
|---|---:|---|
| Run starter and learn code | 1–2 days | Local API, manual flow, mock flow and checks pass |
| Review diagnostic content | 3–5 days | Technician reviews code definitions, uncertainty and safety copy; source/licensing recorded |
| Supabase Auth and history | 3–5 days | Login, token verification, owner-only persistence, deletion and two-user RLS tests pass |
| Validate one physical BLE/Wi-Fi profile | 1–2 weeks | Experimental transport exists; document exact profile, collect real traces and complete phone/vehicle matrix |
| Small private pilot | 1 week | 5–10 users, consent, feedback, failure review; no unsupported compatibility claims |
| Release preparation | 3–7 days | HTTPS, rate limits, privacy policy, signing and platform review requirements completed |

Start with manual input to test whether users understand the results and find the
next steps useful. Add a real BLE adapter only after that workflow is validated.

| Item | Local / tiny pilot | Notes |
|---|---:|---|
| Flutter + local Python API | $0/month | Existing computer and development tools assumed |
| Supabase | $0 initially; Pro from $25/month | Free tier subject to quotas; Pro first project included, extra projects cost more |
| API hosting allowance | $5–15/month | Budget estimate for a small service, not a verified provider quote |
| Domain allowance | $10–20/year | Optional budget estimate; actual TLD/registrar price varies |
| AI inference | $0 | No AI model is called in this starter |
| One documented BLE adapter | $40–100 one time | Procurement allowance only; choose after reviewing its profile, no compatibility promise |
| Apple distribution membership | $99/year | Or local currency where available; check eligibility and current terms |
| Google Play registration | $25 one time | Account verification and testing requirements also apply |

Local development can cost $0 with existing equipment. A hosted pilot allowance is
$5–15/month on Supabase Free or $30–40/month on Pro, before extras. Adapter and both
store fees add an estimated $164–224 in first-year setup, excluding hardware already
owned, domain, taxes and hosting. Budget technician review separately. Mac/Xcode
access is required for iOS builds; no Mac purchase/rental is included here.

Official prices: [Supabase](https://supabase.com/pricing),
[Apple Developer Program](https://developer.apple.com/programs/enroll/),
[Google Play registration](https://support.google.com/googleplay/android-developer/answer/6112435).
Recheck before purchase. Hardware, host, domain and schedule ranges above are planning
assumptions, not externally verified prices.
