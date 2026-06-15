# TrendSoccer Development Status

**Version:** v8  
**Last updated:** 2026-05-20  
**Status:** 릴리즈 준비 단계 — QA 대기 항목 제외 전체 기능 구현 완료  
**Overall progress:** ~97%

---

## Summary

TrendSoccer is a Flutter-based sports analysis app (soccer + baseball) with premium subscriptions, live fixtures, match alarms, AI analysis, and trend/premium content. Core app features are implemented; remaining work is primarily QA validation (live match scenarios) and release build preparation.

---

## Recently Completed (v7 → v8)

### Analytics & Notifications
- **Firebase Analytics** — `sign_up` (post terms agreement) and `purchase` (post IAP verify) events
- **Notification icon customization** — `ic_notification.xml` vector drawable; AndroidManifest + FCM service updated
- **FCM device locale registration** — `locale` sent on `registerDevice()`; re-register on language change
- **Batch alarm API integration** — `GET /api/v1/mobile/notifications/matches` (50-ID chunks) replaces per-match calls
- **secondHalf soccer alarm event** — toggle in alarm sheet; default `true`; soccer-only
- **Alarm loading optimization** — selected-date scope + batch API (no parallel per-match flood)

### Fixture & Live
- **Soccer live state preservation** — `_lastKnownSoccerLiveStates` cache; empty poll no longer clears overlay; FT permanent merge via `soccerPolledFixturesProvider`
- **Soccer live retry** — 3s retry when `/api/live-matches` returns empty
- **Soccer halftime HT display** — shows `HT` when status is halftime
- **Cancelled/postponed match handling** — `POST`/`CANC` via `normalizeMatchStatus()`; baseball `includeAllStatuses` (no `status=scheduled` filter on Fixture tab)
- **Baseball status filter removal** — Fixture tab fetches all statuses; Analysis tab unchanged

### Trend & Analysis UI
- **Trend tab reorder** — section order updated per design
- **Blur empty state card** — off-season soccer empty state with `BackdropFilter`; baseball uses spinner during load
- **League filter chip + section title i18n** — `leagueNameEn` from API for English locale
- **WC custom icon** — `26fwc.svg` for World Cup league
- **Blog prediction blur** — Free tier content gating
- **Standard/Premium toggle translation** — KO: 스탠다드 / 프리미엄
- **Combo AI text line breaks** — display formatting fix
- **MLB pitcher-stats fallback** — chip direct extraction when stats unavailable
- **Predict language parameter** — API language param wired for predictions

### i18n & Locale
- **Hardcoded Korean cleanup** — 44 UI-facing strings migrated to ARB + `error_resolver`
- **Date formatter locale branching** — locale-aware date display across key screens
- **Legal pages locale URL fetch** — privacy/terms/help fetched by active locale

### Menu & Subscription
- **PlanTicket subscription dates** — start / expiry / cancellation-pending display; `yyyy.MM.dd` format; hide dates when null
- **Trial countdown CTA** — remaining time on trial plan ticket
- **Premium "구독 관리하기"** — opens Google Play subscription management

---

## Feature Areas — Current State

| Area | Status | Notes |
|------|--------|-------|
| Auth (Google / Naver / email) | ✅ Complete | JWT, consent, error codes i18n |
| Soccer fixtures | ✅ Complete | Live overlay, HT, POST/CANC, alarm bells |
| Baseball fixtures | ✅ Complete | 7-day range, all statuses, live poll merge |
| Match alarms | ✅ Complete | Batch GET, secondHalf, per-event toggles |
| Trend tab | ✅ Complete | Analysis cards, blur empty (soccer), spinner (baseball) |
| Analysis / AI | ✅ Complete | Soccer + baseball flows, access gates |
| Premium / IAP | ✅ Complete | Subscribe, restore, analytics purchase event |
| Menu / PlanTicket | ✅ Complete | Premium/Trial/Free states, Play Store manage |
| FCM / push prefs | ✅ Complete | Device register, locale, topics |
| i18n (KO / EN) | ✅ Complete | Major UI strings ARB-backed |
| Firebase Analytics | ✅ Complete | sign_up, purchase |
| Legal pages | ✅ Complete | Locale-aware URL fetch |

---

## Backend Status

| Item | Status |
|------|--------|
| 5min fast cron | ✅ Deployed |
| `push_event_log` | ✅ Deployed |
| KBO/NPB live | ⚠️ Score only (final) |
| Baseball 17–19 date fix | ✅ Deployed |
| Batch alarm API | ✅ Deployed |
| `secondHalf` push event | ✅ Deployed |

---

## Remaining Work

### QA Pending
- Live match end-to-end testing (soccer + baseball)
- Alarm delivery verification (kickoff, goal, HT, secondHalf, FT)
- Empty `/api/live-matches` recovery under real network conditions
- Postponed/cancelled baseball match display across date chips
- IAP / subscription state edge cases (cancel pending, trial expiry, restore)

### Release Preparation
- Release build configuration (signing, versioning, store listing)
- Final regression pass on KO / EN locales
- Remove any remaining temporary diagnostic logs (fixture baseball API, etc.) before store submit
- Store screenshots and metadata

---

## Tech Stack (unchanged)

- **Flutter** — UI
- **Riverpod** — state management
- **go_router** — navigation
- **Supabase** — auth backend
- **Dio** — HTTP (web API + notifications)
- **FCM** — push notifications
- **Firebase Analytics** — sign_up, purchase
- **Figma** — design system (TsSemanticColors, TsType, components)

---

## Document History

| Version | Date | Summary |
|---------|------|---------|
| v7 | — | Pre-release feature complete baseline |
| v8 | 2026-05-20 | Analytics, alarms, live cache, i18n cleanup, PlanTicket dates, release-ready (~97%) |
