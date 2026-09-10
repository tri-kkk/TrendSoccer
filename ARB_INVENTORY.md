# ARB Inventory (corrected)

**Migration complete (reference only).** The app ARB migration finished in commits `ff5be04` through `9646c48` (nine steps). This file is kept as reference for the orphan cleanup that follows screen assembly — not a live work list. Orphan census (post-migration): 338 keys with no `lib/` call site; 318 of those belong to screens not built yet, so dead vs unwired cannot be distinguished until assembly finishes.

**Do not act on these stale entries:** `lib/design_system/widgets/ts_status_badge.dart` (widget deleted, never rendered); `reportPremiumOnlyTitle` (removed from ARB during migration — use `reportsComboLockedTitle`).

Investigation only (original snapshot below).

## Inclusion rule

A string is listed in Q1 only when it is **rendered to the user as UI copy** — widget parameters, toast/dialog text, or return values of UI getters/switch arms (`_label`, `_title`, `_messageForAuthFailure`, tab labels).

**Excluded:** literals used for parsing, matching, comparison, formatting, routing, API/config keys, markdown split markers (`feed_preview_detail_logic.dart`), sentence-boundary heuristics (`analysis_text_formatter.dart`), `RegExp` sources, and `l10n.*` lines.

**ARB matching:** exact trimmed en value, case-insensitive. Multiple exact matches → `DECISION: …`.

- Literal occurrences in scan scope: **2345**
- Accepted unique UI literals (Q1 rows): **170**
- Rejected as non-UI (occurrences not in Q1): **2097**

## League filter chips (separate)

`SoccerAnalysisLeagueChip`: `label` (ko) + `labelEn` (en). `displayLabel(languageCode)` → `labelEn` if `en`, else `label`. Already bilingual; not Q1.

| id | label (ko) | labelEn | codes |
|---|---|---|---|
| `all` | 전체 | All | — |
| `champions_league` | UCL | UCL | 'UCL', 'CL' |
| `europa_league` | UEL | UEL | 'UEL', 'EL' |
| `premier_league` | 프리미어리그 | Premier League | 'PL' |
| `laliga` | 라리가 | La Liga | 'PD' |
| `bundesliga` | 분데스리가 | Bundesliga | 'BL1' |
| `serie_a` | 세리에A | Serie A | 'SA' |
| `ligue_1` | 리그1 | Ligue 1 | 'FL1' |
| `eredivisie` | 에레디비지 | Eredivisie | 'DED' |
| `mls` | MLS | MLS | 'MLS' |
| `k_league` | K리그 | K League | 'KL', 'KL1', 'KL2' |
| `j1_league` | J리그 | J League | 'J1' |

**Consumed by:** `feed_league_chips.dart`, `reports_league_chips.dart`, `feed_preview_logic.dart`, `reports_*_logic.dart`, `soccer_provider.dart`

## Q1. Full inventory

| file | line | literal | role | proposed scope | classification | existing ARB key |
|---|---|---|---|---|---|---|
| lib/features_v2/auth/login_screen.dart | 162 | `Better Data,\nSmarter Analysis Reports,\nFor Your Choice.` | other | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 201 | `Continue as guest` | label | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 177 | `Continue with Google` | label | auth | C | loginGoogle |
| lib/features_v2/auth/login_screen.dart | 189 | `Continue with Naver` | label | auth | C | loginNaver |
| lib/features_v2/auth/login_screen.dart | 93 | `Network error. Check your connection and try again.` | other | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 102 | `No sign-in token was returned. (token_null)` | other | auth | C | — |
| lib/features_v2/auth/login_screen.dart:71; lib/features_v2/auth/login_screen.dart:106 | 2 | `Sign-in failed. Please try again.` | toast | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 91 | `Sign-in timed out. Please try again.` | other | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 96 | `Sign-in was rejected by the server. (api_error)` | other | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 105 | `Signed in, but the profile could not load. (profile_load_failed)` | other | auth | C | — |
| lib/features_v2/auth/login_screen.dart | 99 | `The sign-in provider reported an error. (sdk_error)` | other | auth | C | — |
| lib/features_v2/auth/signup_complete_screen.dart | 164 | `Moving to home in ${_seconds}s` | other | auth | C | — |
| lib/features_v2/auth/signup_complete_screen.dart | 156 | `Start now` | label | auth | C | — |
| lib/features_v2/auth/signup_complete_screen.dart | 106 | `Welcome to TrendSoccer` | other | auth | C | — |
| lib/features_v2/auth/signup_complete_screen.dart | 112 | `Your 48-hour free trial has started` | other | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 212 | `Agree to all` | label | auth | C | signupAgreeAll |
| lib/features_v2/auth/signup_terms_screen.dart | 203 | `Agree to terms\nto get started` | other | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 249 | `Continue` | label | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 45 | `Leave` | button | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 42 | `Leave sign-up?` | title | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 46 | `Stay` | button | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 184 | `Terms` | title | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 71 | `Unable to complete sign-up. Please try again.` | toast | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 44 | `Your account will not be activated until you agree to the terms.` | other | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 240 | `[Optional] Marketing messages` | label | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 231 | `[Required] Privacy policy` | label | auth | C | — |
| lib/features_v2/auth/signup_terms_screen.dart | 222 | `[Required] Terms of service` | label | auth | C | — |
| lib/design_system/widgets/ts_accuracy_card.dart:251; lib/design_system/widgets/ts_app_bar.dart:55; lib/design_system/widgets/ts_app_bar.dart:75; lib/design_system/widgets/ts_gauge_bar.dart:53; lib/design_system/widgets/ts_gauge_bar.dart:66; lib/design_system/widgets/ts_gauge_bar.dart:79; lib/design_system/widgets/ts_match_row.dart:112; lib/design_system/widgets/ts_stack_bar.dart:57; lib/design_system/widgets/ts_stack_bar.dart:69; lib/design_system/widgets/ts_stack_bar.dart:80; lib/design_system/widgets/ts_starting_pitchers_section.dart:255; lib/features_v2/matches/widgets/baseball_report_lock_policy.dart:26; lib/features_v2/matches/widgets/soccer_report_lock_policy.dart:35; lib/features_v2/reports/combo_detail_screen.dart:74; lib/features_v2/reports/combo_detail_screen.dart:115; lib/features_v2/reports/reports_analysis_body.dart:85; lib/features_v2/reports/reports_analysis_body.dart:197 | 17 | `` | other | common | C | — |
| lib/design_system/widgets/ts_accuracy_card.dart | 232 | `·` | other | common | C | — |
| lib/design_system/widgets/ts_bottom_navigation.dart | 82 | `Feed` | other | common | C | — |
| lib/design_system/widgets/ts_bottom_navigation.dart | 79 | `Home` | other | common | C | DECISION: labelHome, pickDirectionHome |
| lib/design_system/widgets/ts_bottom_navigation.dart | 80 | `Matches` | other | common | C | DECISION: cardComboCount, comboComboCount |
| lib/design_system/widgets/ts_bottom_navigation.dart | 83 | `Menu` | other | common | C | tabMenu |
| lib/design_system/widgets/ts_bottom_navigation.dart | 81 | `Reports` | other | common | C | cardPickCount |
| lib/design_system/widgets/ts_combo_footer.dart:32; lib/design_system/widgets/ts_combo_match_row.dart:38 | 2 | `In progress` | other | common | C | comboStatusInProgress |
| lib/design_system/widgets/ts_combo_footer.dart:33; lib/design_system/widgets/ts_combo_match_row.dart:39 | 2 | `Match` | other | common | C | DECISION: comboMatchHit, comboStatusHit |
| lib/design_system/widgets/ts_combo_footer.dart:35; lib/design_system/widgets/ts_combo_match_row.dart:40 | 2 | `Mismatch` | other | common | C | DECISION: comboMatchFail, comboStatusMiss |
| lib/design_system/widgets/ts_combo_footer.dart | 34 | `Partial` | other | common | C | comboStatusPartial |
| lib/design_system/widgets/ts_combo_match_row.dart | 132 | `A` | other | common | B | labelAwayShort |
| lib/design_system/widgets/ts_combo_match_row.dart | 125 | `H` | other | common | B | labelHomeShort |
| lib/design_system/widgets/ts_plan_ticket.dart | 29 | `FREE` | other | common | C | subscribePlanFree |
| lib/design_system/widgets/ts_plan_ticket.dart | 43 | `Manage` | other | common | C | — |
| lib/design_system/widgets/ts_plan_ticket.dart | 31 | `PREMIUM` | other | common | C | DECISION: reportTabPremium, subscribePlanPremium, tabPremium |
| lib/design_system/widgets/ts_plan_ticket.dart | 30 | `TRIAL` | other | common | C | — |
| lib/design_system/widgets/ts_plan_ticket.dart | 41 | `Upgrade` | other | common | C | — |
| lib/design_system/widgets/ts_result_dot.dart | 17 | `D` | other | common | B | labelDrawShort |
| lib/design_system/widgets/ts_result_dot.dart | 18 | `L` | other | common | B | soccerStatLosses |
| lib/design_system/widgets/ts_result_dot.dart | 16 | `W` | other | common | B | DECISION: labelWinShort, soccerStatWins |
| lib/design_system/widgets/ts_stack_bar.dart | 108 | `Draws` | other | common | C | — |
| lib/design_system/widgets/ts_stack_bar.dart:98; lib/design_system/widgets/ts_stack_bar.dart:117 | 2 | `Wins` | other | common | C | — |
| lib/design_system/widgets/ts_status_badge.dart **STALE — file deleted** | 21 | `CAN` | other | common | C | — |
| lib/design_system/widgets/ts_status_badge.dart **STALE — file deleted** | 18 | `HT` | other | common | C | — |
| lib/main.dart:106; lib/main.dart:186 | 2 | `TrendSoccer` | other | common | C | appName |
| lib/core/models/match_header_data.dart | 168 | `NS` | other | home | C | — |
| lib/features_v2/feed/feed_news_logic.dart:50; lib/features_v2/home/home_screen.dart:977 | 2 | `News` | label | home | C | — |
| lib/features_v2/home/home_screen.dart | 887 | `Aggressive` | label | home | C | — |
| lib/features_v2/home/home_screen.dart | 186 | `Baseball Analysis` | title | home | C | DECISION: analysisTabBaseball, trendBaseballAnalysis |
| lib/features_v2/home/home_screen.dart | 433 | `Based on $total picks` | label | home | C | — |
| lib/features_v2/home/home_screen.dart | 408 | `Baseline 33% — random guess across three results` | other | home | C | — |
| lib/features_v2/home/home_screen.dart | 407 | `Baseline 50% — random guess between two teams` | other | home | C | — |
| lib/features_v2/home/home_screen.dart | 187 | `MLB · KBO · NPB` | title | home | C | — |
| lib/features_v2/home/home_screen.dart | 901 | `Multi-Match Analysis` | title | home | C | DECISION: cardTodayCombo, reportsComboDetailTitle, todayCombination |
| lib/features_v2/home/home_screen.dart | 486 | `No settled picks in this period` | title | home | C | — |
| lib/features_v2/home/home_screen.dart:422; lib/features_v2/home/home_screen.dart:468 | 2 | `Prediction accuracy` | label | home | C | — |
| lib/features_v2/home/home_screen.dart | 439 | `Recent` | label | home | C | — |
| lib/features_v2/home/home_screen.dart | 173 | `Reports, multi-match analysis` | other | home | C | — |
| lib/features_v2/home/home_screen.dart | 78 | `See all` | other | home | C | — |
| lib/features_v2/home/home_screen.dart | 180 | `Soccer Analysis` | title | home | C | DECISION: analysisTabSoccer, trendSoccerAnalysis |
| lib/features_v2/home/home_screen.dart | 886 | `Stable` | label | home | C | DECISION: comboSafe, comboTypeSafe, reportsComboTypeStable |
| lib/features_v2/home/home_screen.dart | 1080 | `Today's Matches` | title | home | C | — |
| lib/features_v2/home/home_screen.dart | 902 | `Today's baseball combinations` | title | home | C | — |
| lib/features_v2/home/home_screen.dart | 488 | `Try a longer window, or check back when the season resumes.` | other | home | C | — |
| lib/features_v2/home/home_screen.dart | 172 | `Unlock full analysis` | other | home | C | — |
| lib/features_v2/home/home_screen.dart | 892 | `View combinations` | label | home | C | — |
| lib/features_v2/home/home_screen.dart | 440 | `View picks` | label | home | C | — |
| lib/design_system/widgets/ts_status_badge.dart:19 **STALE — file deleted**; lib/features_v2/matches/matches_screen.dart:1113; lib/features_v2/matches/match_report_screen.dart:729 | 3 | `FT` | other | matchReport | B | fixtureStatusFinal |
| lib/design_system/widgets/ts_status_badge.dart:17 **STALE — file deleted**; lib/features_v2/matches/matches_screen.dart:1168; lib/features_v2/matches/match_report_screen.dart:735 | 3 | `LIVE` | other | matchReport | B | fixtureLive |
| lib/features_v2/matches/match_report_screen.dart | 488 | `Match Report` | title | matchReport | C | matchReportTitle |
| lib/features_v2/matches/widgets/baseball_ai_match_analysis_report_block.dart:216; lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:550 | 2 | `-` | other | matchReport | C | — |
| lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart | 334 | `AVG` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:348; lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:275; lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:342 | 3 | `ERA` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart | 341 | `OPS` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:426; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:440; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:446; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:460; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:467; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:475; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:480 | 7 | `Recent form` | title | matchReport | C | soccerRecentForm |
| lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:355; lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:282; lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:349 | 3 | `WHIP` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart | 510 | `Win rate` | label | matchReport | C | — |
| lib/features_v2/matches/widgets/baseball_report_block_placeholders.dart:13; lib/features_v2/matches/widgets/soccer_report_block_placeholders.dart:19 | 2 | `Home Team` | other | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_report_block_placeholders.dart:15; lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:574; lib/features_v2/matches/widgets/soccer_report_block_placeholders.dart:21 | 3 | `REPORT` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_report_lock_policy.dart:33; lib/features_v2/matches/widgets/soccer_report_lock_policy.dart:46 | 2 | `Log in to view` | label | matchReport | C | — |
| lib/features_v2/matches/widgets/baseball_report_lock_policy.dart:40; lib/features_v2/matches/widgets/soccer_report_lock_policy.dart:53 | 2 | `Premium content` | label | matchReport | C | premiumNonSubscriberTitle |
| lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart | 318 | `IP` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:272; lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:325; lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:356 | 3 | `K` | other | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart | 272 | `K/9` | other | matchReport | B | — |
| lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart | 212 | `VS` | label | matchReport | C | — |
| lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart | 311 | `W-L` | label | matchReport | B | — |
| lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart | 530 | `No data` | title | matchReport | C | — |
| lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart | 131 | `No market indicators reported for either team in this match.` | other | matchReport | C | — |
| lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart | 380 | `No recent form data reported for either team in this match.` | other | matchReport | C | — |
| lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart | 226 | `No strengths or weaknesses reported for either team in this match.` | other | matchReport | C | — |
| lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart | 531 | `No team statistics reported for this match.` | body | matchReport | C | — |
| lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart | 575 | `GOOD` | other | matchReport | B | — |
| lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart | 576 | `PASS` | other | matchReport | B | — |
| lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:107; lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:155 | 2 | `Prediction` | title | matchReport | C | — |
| lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:113; lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:162 | 2 | `Reasoning` | title | matchReport | C | soccerAnalysisReasoning |
| lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:119; lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:169 | 2 | `Three-method` | title | matchReport | C | — |
| lib/design_system/widgets/ts_status_badge.dart:20 **STALE — file deleted**; lib/features_v2/matches/matches_screen.dart:1090 | 2 | `PPD` | other | matches | B | statusPostponed |
| lib/features_v2/matches/matches_screen.dart | 1687 | `AI` | badge | matches | B | — |
| lib/features_v2/matches/matches_screen.dart | 1161 | `All` | label | matches | C | DECISION: feedNewsSportAll, filterAll |
| lib/features_v2/matches/matches_screen.dart | 1491 | `Browse all matches` | button | matches | C | — |
| lib/features_v2/matches/matches_screen.dart | 1094 | `CANC` | label | matches | C | — |
| lib/features_v2/matches/matches_screen.dart | 1489 | `No live matches` | title | matches | C | — |
| lib/features_v2/matches/matches_screen.dart | 1490 | `No matches are in progress right now.` | body | matches | C | — |
| lib/features_v2/matches/matches_screen.dart | 1098 | `SUSP` | label | matches | B | statusInterrupted |
| lib/features_v2/matches/matches_screen.dart | 1512 | `Try another date from the strip above.` | other | matches | C | reportsComboEmptyBody |
| lib/features_v2/matches/matches_screen.dart | 1513 | `View other dates` | button | matches | C | — |
| lib/design_system/widgets/ts_sport_toggle.dart:74; lib/features_v2/menu/notification_settings_screen.dart:151 | 2 | `Baseball` | other | menu | C | DECISION: feedNewsSportBaseball, notificationBaseball, sportBaseball |
| lib/design_system/widgets/ts_sport_toggle.dart:74; lib/features_v2/menu/notification_settings_screen.dart:132 | 2 | `Soccer` | other | menu | C | DECISION: feedNewsSportSoccer, notificationSoccer, sportSoccer |
| lib/features_v2/menu/help_screen.dart | 200 | `Email` | label | menu | C | helpCenterEmail |
| lib/features_v2/menu/help_screen.dart:159; lib/features_v2/menu/menu_screen.dart:243; lib/features_v2/menu/menu_screen.dart:314 | 3 | `Help` | title | menu | C | — |
| lib/features_v2/menu/help_screen.dart | 223 | `Message` | label | menu | C | helpCenterMessage |
| lib/features_v2/menu/help_screen.dart | 189 | `Name` | label | menu | C | helpCenterName |
| lib/features_v2/menu/help_screen.dart | 242 | `Send inquiry` | label | menu | C | helpCenterSend |
| lib/features_v2/menu/help_screen.dart | 212 | `Subject` | label | menu | C | helpCenterSubject |
| lib/features_v2/menu/help_screen.dart | 182 | `Tell us what you need help with. We usually reply within one business day.` | other | menu | C | — |
| lib/features_v2/menu/help_screen.dart | 139 | `Your inquiry has been sent.` | toast | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 173 | `Account deleted successfully.` | toast | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 148 | `All data is permanently removed. Type DELETE to confirm.` | other | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:258; lib/features_v2/menu/menu_screen.dart:329 | 2 | `App version` | label | menu | C | menuAppVersion |
| lib/features_v2/menu/menu_screen.dart:377; lib/features_v2/menu/menu_screen.dart:381 | 2 | `Basic analysis only` | other | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:82; lib/features_v2/menu/menu_screen.dart:152 | 2 | `Cancel` | button | menu | C | cancel |
| lib/features_v2/menu/menu_screen.dart | 149 | `Confirmation` | label | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:426; lib/features_v2/menu/settings_sheets.dart:95 | 2 | `Dark` | other | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 151 | `Delete` | button | menu | C | deleteAccountConfirm |
| lib/features_v2/menu/menu_screen.dart | 345 | `Delete account` | label | menu | C | DECISION: deleteAccountTitle, menuDeleteAccount |
| lib/features_v2/menu/menu_screen.dart | 146 | `Delete account?` | title | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:419; lib/features_v2/menu/settings_sheets.dart:49 | 2 | `English` | other | menu | C | languageEnglish |
| lib/features_v2/menu/menu_screen.dart:225; lib/features_v2/menu/menu_screen.dart:296; lib/features_v2/menu/settings_sheets.dart:46 | 3 | `Language` | label | menu | C | DECISION: languageSettingsTitle, menuLanguage |
| lib/features_v2/menu/menu_screen.dart:425; lib/features_v2/menu/settings_sheets.dart:90 | 2 | `Light` | other | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:220; lib/features_v2/menu/menu_screen.dart:291; lib/features_v2/menu/notification_settings_screen.dart:95 | 3 | `Notifications` | label | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:248; lib/features_v2/menu/menu_screen.dart:319; lib/features_v2/menu/privacy_screen.dart:13 | 3 | `Privacy policy` | label | menu | C | DECISION: menuPrivacyPolicy, signupPrivacyRequired |
| lib/features_v2/menu/menu_screen.dart:81; lib/features_v2/menu/menu_screen.dart:340 | 2 | `Sign out` | button | menu | C | DECISION: menuSignOut, signOutConfirm, signOutTitle |
| lib/features_v2/menu/menu_screen.dart | 79 | `Sign out?` | title | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 212 | `Sign up` | button | menu | C | DECISION: signupPageTitle, signupSubmit |
| lib/features_v2/menu/menu_screen.dart | 211 | `Sign up to unlock full analysis reports.` | title | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 95 | `Signed out successfully.` | toast | menu | C | signOutSuccess |
| lib/features_v2/menu/menu_screen.dart | 210 | `Start your 48-hour free trial` | title | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 284 | `Subscription` | label | menu | C | menuSubscribeInfoSection |
| lib/features_v2/menu/menu_screen.dart:424; lib/features_v2/menu/settings_sheets.dart:85 | 2 | `System` | other | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:253; lib/features_v2/menu/menu_screen.dart:324; lib/features_v2/menu/terms_screen.dart:13 | 3 | `Terms of service` | label | menu | C | DECISION: menuTermsOfService, signupTermsRequired |
| lib/features_v2/menu/menu_screen.dart:231; lib/features_v2/menu/menu_screen.dart:302; lib/features_v2/menu/settings_sheets.dart:82 | 3 | `Theme` | label | menu | C | DECISION: menuTheme, themeSettingsTitle |
| lib/features_v2/menu/menu_screen.dart | 379 | `Trial ends in ${_trialHoursRemaining(auth)} hours · billing unavailable during trial` | other | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 177 | `Unable to delete account. Please try again.` | toast | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 99 | `Unable to sign out. Please try again.` | toast | menu | C | — |
| lib/features_v2/menu/menu_screen.dart | 80 | `You can sign back in anytime.` | body | menu | C | — |
| lib/features_v2/menu/menu_screen.dart:420; lib/features_v2/menu/settings_sheets.dart:54 | 2 | `한국어` | other | menu | C | languageKorean |
| lib/features_v2/menu/notification_settings_screen.dart | 119 | `Announcements` | label | menu | C | — |
| lib/features_v2/menu/notification_settings_screen.dart | 114 | `App alerts` | label | menu | C | — |
| lib/features_v2/menu/notification_settings_screen.dart | 108 | `General` | title | menu | C | notificationGeneral |
| lib/features_v2/menu/notification_settings_screen.dart | 124 | `Marketing` | label | menu | C | notificationMarketing |
| lib/features_v2/feed/feed_header_shell.dart:49; lib/features_v2/home/home_screen.dart:206; lib/features_v2/matches/matches_screen.dart:1400; lib/features_v2/menu/menu_screen.dart:193; lib/features_v2/reports/reports_header_shell.dart:148 | 5 | `Log in` | label | reports | C | DECISION: lockGuestAction, loginAppBarTitle |
| lib/features_v2/reports/reports_route_map.dart:51; lib/features_v2/reports/reports_route_map.dart:53 | 2 | `Analysis` | other | reports | C | DECISION: labelPrediction, labelRecommend, tabAnalysis |
| lib/features_v2/reports/reports_route_map.dart | 53 | `Multi-Match` | other | reports | C | — |
| lib/features_v2/reports/reports_route_map.dart | 51 | `Premium` | other | reports | C | DECISION: reportTabPremium, subscribePlanPremium, tabPremium |
| lib/features_v2/system/billing_loading_screen.dart | 35 | `Do not close the app.\nThis may take a moment.` | other | system | C | — |
| lib/features_v2/system/billing_loading_screen.dart | 29 | `Processing payment` | other | system | C | — |
| lib/features_v2/system/force_update_screen.dart | 49 | `A new version is available.\nUpdate to keep using TrendSoccer.` | other | system | C | — |
| lib/features_v2/system/force_update_screen.dart | 82 | `Still under maintenance. Please try again shortly.` | toast | system | C | — |
| lib/features_v2/system/force_update_screen.dart | 45 | `Under maintenance` | other | system | C | maintenanceTitle |
| lib/features_v2/system/force_update_screen.dart | 168 | `Update now` | label | system | C | — |
| lib/features_v2/system/force_update_screen.dart | 45 | `Update required` | other | system | C | forceUpdateTitle |
| lib/features_v2/system/force_update_screen.dart | 48 | `We are working on it. Please try again shortly.` | other | system | C | — |

## Q2. Counts

### By scope

| scope | C | B | A | total |
|---|---:|---:|---:|---:|
| auth | 27 | 0 | 0 | 27 |
| home | 22 | 0 | 0 | 22 |
| matches | 7 | 3 | 0 | 10 |
| matchReport | 15 | 14 | 0 | 29 |
| reports | 4 | 0 | 0 | 4 |
| menu | 44 | 0 | 0 | 44 |
| system | 8 | 0 | 0 | 8 |
| common | 21 | 5 | 0 | 26 |
| **all** | 148 | 22 | 0 | 170 |

### By file

| file | C | B | A | total |
|---|---:|---:|---:|---:|
| `lib/core/models/match_header_data.dart` | 1 | 0 | 0 | 1 |
| `lib/design_system/widgets/ts_accuracy_card.dart` | 2 | 0 | 0 | 2 |
| `lib/design_system/widgets/ts_app_bar.dart` | 2 | 0 | 0 | 2 |
| `lib/design_system/widgets/ts_bottom_navigation.dart` | 5 | 0 | 0 | 5 |
| `lib/design_system/widgets/ts_combo_footer.dart` | 4 | 0 | 0 | 4 |
| `lib/design_system/widgets/ts_combo_match_row.dart` | 3 | 2 | 0 | 5 |
| `lib/design_system/widgets/ts_gauge_bar.dart` | 3 | 0 | 0 | 3 |
| `lib/design_system/widgets/ts_match_row.dart` | 1 | 0 | 0 | 1 |
| `lib/design_system/widgets/ts_plan_ticket.dart` | 5 | 0 | 0 | 5 |
| `lib/design_system/widgets/ts_result_dot.dart` | 0 | 3 | 0 | 3 |
| `lib/design_system/widgets/ts_sport_toggle.dart` | 2 | 0 | 0 | 2 |
| `lib/design_system/widgets/ts_stack_bar.dart` | 6 | 0 | 0 | 6 |
| `lib/design_system/widgets/ts_starting_pitchers_section.dart` | 1 | 0 | 0 | 1 |
| `lib/design_system/widgets/ts_status_badge.dart` **STALE — file deleted** | 2 | 3 | 0 | 5 |
| `lib/features_v2/auth/login_screen.dart` | 12 | 0 | 0 | 12 |
| `lib/features_v2/auth/signup_complete_screen.dart` | 4 | 0 | 0 | 4 |
| `lib/features_v2/auth/signup_terms_screen.dart` | 12 | 0 | 0 | 12 |
| `lib/features_v2/feed/feed_header_shell.dart` | 1 | 0 | 0 | 1 |
| `lib/features_v2/feed/feed_news_logic.dart` | 1 | 0 | 0 | 1 |
| `lib/features_v2/home/home_screen.dart` | 23 | 0 | 0 | 23 |
| `lib/features_v2/matches/match_report_screen.dart` | 1 | 2 | 0 | 3 |
| `lib/features_v2/matches/matches_screen.dart` | 8 | 5 | 0 | 13 |
| `lib/features_v2/matches/widgets/baseball_ai_match_analysis_report_block.dart` | 1 | 0 | 0 | 1 |
| `lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart` | 8 | 4 | 0 | 12 |
| `lib/features_v2/matches/widgets/baseball_report_block_placeholders.dart` | 0 | 2 | 0 | 2 |
| `lib/features_v2/matches/widgets/baseball_report_lock_policy.dart` | 3 | 0 | 0 | 3 |
| `lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart` | 1 | 10 | 0 | 11 |
| `lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart` | 5 | 0 | 0 | 5 |
| `lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart` | 7 | 3 | 0 | 10 |
| `lib/features_v2/matches/widgets/soccer_report_block_placeholders.dart` | 0 | 2 | 0 | 2 |
| `lib/features_v2/matches/widgets/soccer_report_lock_policy.dart` | 3 | 0 | 0 | 3 |
| `lib/features_v2/menu/help_screen.dart` | 8 | 0 | 0 | 8 |
| `lib/features_v2/menu/menu_screen.dart` | 42 | 0 | 0 | 42 |
| `lib/features_v2/menu/notification_settings_screen.dart` | 7 | 0 | 0 | 7 |
| `lib/features_v2/menu/privacy_screen.dart` | 1 | 0 | 0 | 1 |
| `lib/features_v2/menu/settings_sheets.dart` | 7 | 0 | 0 | 7 |
| `lib/features_v2/menu/terms_screen.dart` | 1 | 0 | 0 | 1 |
| `lib/features_v2/reports/combo_detail_screen.dart` | 2 | 0 | 0 | 2 |
| `lib/features_v2/reports/reports_analysis_body.dart` | 2 | 0 | 0 | 2 |
| `lib/features_v2/reports/reports_header_shell.dart` | 1 | 0 | 0 | 1 |
| `lib/features_v2/reports/reports_route_map.dart` | 4 | 0 | 0 | 4 |
| `lib/features_v2/system/billing_loading_screen.dart` | 2 | 0 | 0 | 2 |
| `lib/features_v2/system/force_update_screen.dart` | 6 | 0 | 0 | 6 |
| `lib/main.dart` | 2 | 0 | 0 | 2 |

## Q3. report / reports collision

### `report*` (singular)

| key | en | screens | scope | rename matchReport*? |
|---|---|---|---|---|
| `reportAuthorRole` | Football data analyst | feed/preview_detail_screen | feed | no (feed) |
| `reportBlockLoadError` | Could not load | matches/match_report_screen, matches/widgets/baseball_ai_match_analysis_report_block, matches/widgets/baseball_extended_report_blocks, matches/widgets/baseball_h2h_report_block, matches/widgets/baseball_pitcher_analysis_report_block, matches/widgets/baseball_starting_pitchers_report_block, matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_predict_report_blocks | matchReport | yes → `matchReportBlockLoadError` |
| `reportBlockUnavailable` | This section is unavailable right now | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_predict_report_blocks | matchReport | yes → `matchReportBlockUnavailable` |
| `reportDetailLoadError` | Could not load match preview. | feed/preview_detail_screen | feed | no (feed) |
| `reportEmptySubtitle` | New previews will appear here when published. | (unused) | feed | no (feed) |
| `reportEmptyTitle` | No match previews yet. | (unused) | feed | no (feed) |
| `reportListLoadError` | Could not load match previews. | feed/feed_preview_body | feed | no (feed) |
| `reportNotFoundSubtitle` | Please select again from the list. | feed/preview_detail_screen | feed | no (feed) |
| `reportNotFoundTitle` | Report not found. | feed/preview_detail_screen | feed | no (feed) |
| `reportPremiumOnlyMessage` | Subscribe to view AI analysis results | (unused) | matchReport | yes → `matchReportPremiumOnlyMessage` |
| `reportPremiumOnlyTitle` **STALE — removed from ARB; use `reportsComboLockedTitle`** | Premium members only | (unused) | matchReport | was → `matchReportPremiumOnlyTitle` |
| `reportTabAiAnalysis` | AI Analysis | (unused) | matchReport | yes → `matchReportTabAiAnalysis` |
| `reportTabPremium` | Premium | (unused) | matchReport | yes → `matchReportTabPremium` |
| `reportTabStandard` | Standard | (unused) | matchReport | yes → `matchReportTabStandard` |

### `reports*` (plural)

| key | en | screens | scope |
|---|---|---|---|
| `reportsAnalysisNoLeagueBody` | Try another league or view all analysis. | reports/reports_analysis_body | reports |
| `reportsAnalysisNoLeagueTitle` | Analysis isn't ready yet | reports/reports_analysis_body | reports |
| `reportsAnalysisViewAll` | View all analysis | reports/reports_analysis_body | reports |
| `reportsComboDetailTitle` | Multi-Match Analysis | reports/combo_detail_screen | reports |
| `reportsComboEmptyBody` | Try another date from the strip above. | reports/reports_combo_body | reports |
| `reportsComboEmptyTitle` | No multi-match picks for this day | reports/reports_combo_body | reports |
| `reportsComboLockedBody` | Subscribe to see the full combination. | reports/combo_detail_screen | reports |
| `reportsComboLockedTitle` | Premium members only | reports/combo_detail_screen | reports |
| `reportsComboNoLeagueBody` | Try another league or view all picks. | reports/reports_combo_body | reports |
| `reportsComboNoLeagueTitle` | No picks for this league | reports/reports_combo_body | reports |
| `reportsComboTypeHighIndex` | High index | reports/reports_combo_logic | reports |
| `reportsComboTypeStable` | Stable | reports/reports_combo_logic | reports |
| `reportsComboViewAll` | View all picks | reports/reports_combo_body | reports |
| `reportsPremiumEmptyBody` | Curation is strict — some days have none.
Check Analysis for all supported leagu | reports/reports_soccer_premium_body | reports |
| `reportsPremiumEmptyTitle` | No premium picks today | reports/reports_soccer_premium_body | reports |
| `reportsPremiumNoLeagueBody` | Curation is strict.
Check other leagues or view all picks. | reports/reports_soccer_premium_body | reports |
| `reportsPremiumNoLeagueTitle` | No premium pick for this league | reports/reports_soccer_premium_body | reports |
| `reportsPremiumViewAll` | View all picks | reports/reports_soccer_premium_body | reports |

### Rename call sites

- `reportBlockLoadError`: lib/features_v2/matches/match_report_screen.dart:662, lib/features_v2/matches/widgets/baseball_ai_match_analysis_report_block.dart:367, lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:981, lib/features_v2/matches/widgets/baseball_h2h_report_block.dart:371, lib/features_v2/matches/widgets/baseball_pitcher_analysis_report_block.dart:249, lib/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart:667, lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart:600, lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:520
- `reportBlockUnavailable`: lib/features_v2/matches/widgets/soccer_extended_report_blocks.dart:601, lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:521
- `reportPremiumOnlyMessage`: no call sites
- `reportPremiumOnlyTitle` **STALE — key removed from ARB**; wired replacement: `reportsComboLockedTitle`
- `reportTabAiAnalysis`: no call sites
- `reportTabPremium`: no call sites
- `reportTabStandard`: no call sites

## Q4. Collisions

### ARB identical/near-identical en

- **near**: `accessLockOpens24HoursBefore` ↔ `accessLockOpensOneHourBefore`
  - `accessLockOpens24HoursBefore`: "Opens 24 hours before kickoff."
  - `accessLockOpensOneHourBefore`: "Opens 1 hour before kickoff."
- **identical**: `accessUnlockViewAnalysis` ↔ `analysisCardView`
  - `accessUnlockViewAnalysis`: "View analysis"
  - `analysisCardView`: "View analysis"
- **near**: `alarmEnabledToast` ↔ `alarmDisabledToast`
  - `alarmEnabledToast`: "Match alerts enabled for {homeTeam} vs {awayTeam}"
  - `alarmDisabledToast`: "Match alerts disabled for {homeTeam} vs {awayTeam}"
- **identical**: `alarmFulltime` ↔ `soccerEventFulltime`
  - `alarmFulltime`: "Full-time"
  - `soccerEventFulltime`: "Full-time"
- **identical**: `alarmGoal` ↔ `soccerEventGoal`
  - `alarmGoal`: "Goal"
  - `soccerEventGoal`: "Goal"
- **identical**: `alarmHalftime` ↔ `soccerEventHalftime`
  - `alarmHalftime`: "Half-time"
  - `soccerEventHalftime`: "Half-time"
- **identical**: `alarmKickoff` ↔ `soccerEventKickoff`
  - `alarmKickoff`: "Kick-off"
  - `soccerEventKickoff`: "Kick-off"
- **identical**: `alarmRedCard` ↔ `soccerEventRedCard`
  - `alarmRedCard`: "Red Card"
  - `soccerEventRedCard`: "Red Card"
- **identical**: `alarmSecondHalf` ↔ `alarmSecondHalfStart`
  - `alarmSecondHalf`: "2nd Half Start"
  - `alarmSecondHalfStart`: "2nd Half Start"
- **identical**: `alarmSubstitution` ↔ `soccerEventSubstitution`
  - `alarmSubstitution`: "Substitution"
  - `soccerEventSubstitution`: "Substitution"
- **identical**: `alarmYellowCard` ↔ `soccerEventYellowCard`
  - `alarmYellowCard`: "Yellow Card"
  - `soccerEventYellowCard`: "Yellow Card"
- **identical**: `analysisCardViewAnalysis` ↔ `analyzeButton`
  - `analysisCardViewAnalysis`: "Analyze"
  - `analyzeButton`: "Analyze"
- **identical**: `analysisNoBaseballScheduled` ↔ `trendNoBaseballScheduled`
  - `analysisNoBaseballScheduled`: "No baseball games scheduled."
  - `trendNoBaseballScheduled`: "No baseball games scheduled."
- **identical**: `analysisNoMatches` ↔ `fixtureNoMatches`
  - `analysisNoMatches`: "No matches"
  - `fixtureNoMatches`: "No matches"
- **identical**: `analysisTabBaseball` ↔ `trendBaseballAnalysis`
  - `analysisTabBaseball`: "Baseball Analysis"
  - `trendBaseballAnalysis`: "Baseball Analysis"
- **identical**: `analysisTabSoccer` ↔ `trendSoccerAnalysis`
  - `analysisTabSoccer`: "Soccer Analysis"
  - `trendSoccerAnalysis`: "Soccer Analysis"
- **identical**: `analysisToday` ↔ `comboDashboardToday`
  - `analysisToday`: "Today"
  - `comboDashboardToday`: "Today"
- **identical**: `analysisToday` ↔ `today`
  - `analysisToday`: "Today"
  - `today`: "Today"
- **identical**: `baseballBaseline` ↔ `baseballOddsBaseline`
  - `baseballBaseline`: "Line"
  - `baseballOddsBaseline`: "Line"
- **identical**: `baseballEventGameEnd` ↔ `alarmGameEnd`
  - `baseballEventGameEnd`: "Game End"
  - `alarmGameEnd`: "Game End"
- **identical**: `baseballEventHomerun` ↔ `alarmHomerun`
  - `baseballEventHomerun`: "Home Run"
  - `alarmHomerun`: "Home Run"
- **identical**: `baseballEventScore` ↔ `alarmScore`
  - `baseballEventScore`: "Score"
  - `alarmScore`: "Score"
- **identical**: `baseballRecent10` ↔ `soccerRecent10`
  - `baseballRecent10`: "Last 10 games"
  - `soccerRecent10`: "Last 10 games"
- **identical**: `baseballReliability` ↔ `comboReliability`
  - `baseballReliability`: "Reliability"
  - `comboReliability`: "Reliability"
- **identical**: `baseballSectionOdds` ↔ `labelOdds`
  - `baseballSectionOdds`: "Index"
  - `labelOdds`: "Index"
- **identical**: `baseballSectionPitchers` ↔ `baseballSectionPitchersKo`
  - `baseballSectionPitchers`: "Starting Pitchers"
  - `baseballSectionPitchersKo`: "Starting pitchers"
- **identical**: `baseballWinProbability` ↔ `soccerStatWinProb`
  - `baseballWinProbability`: "Win likelihood"
  - `soccerStatWinProb`: "Win likelihood"
- **identical**: `cardComboCount` ↔ `comboComboCount`
  - `cardComboCount`: "Matches"
  - `comboComboCount`: "Matches"
- **identical**: `cardTodayCombo` ↔ `todayCombination`
  - `cardTodayCombo`: "Multi-match analysis"
  - `todayCombination`: "Multi-match analysis"
- **identical**: `cardTodayPick` ↔ `todayPremiumPick`
  - `cardTodayPick`: "Today's featured match"
  - `todayPremiumPick`: "Today's featured match"
- **identical**: `cardUpdateLabel` ↔ `forceUpdateButton`
  - `cardUpdateLabel`: "Update"
  - `forceUpdateButton`: "Update"
- **identical**: `comboDashboardToday` ↔ `today`
  - `comboDashboardToday`: "Today"
  - `today`: "Today"
- **near**: `comboFoldCount` ↔ `comboResultHitCount`
  - `comboFoldCount`: "{count} matches"
  - `comboResultHitCount`: "{count} match"
- **near**: `comboFoldCount` ↔ `soccerH2hMatchCount`
  - `comboFoldCount`: "{count} matches"
  - `soccerH2hMatchCount`: "({count} matches)"
- **identical**: `comboHighOdds` ↔ `comboTypeHigh`
  - `comboHighOdds`: "High index"
  - `comboTypeHigh`: "High index"
- **identical**: `comboMatchFail` ↔ `comboStatusMiss`
  - `comboMatchFail`: "Mismatch"
  - `comboStatusMiss`: "Mismatch"
- **identical**: `comboMatchHit` ↔ `comboStatusHit`
  - `comboMatchHit`: "Match"
  - `comboStatusHit`: "Match"
- **identical**: `comboSafe` ↔ `comboTypeSafe`
  - `comboSafe`: "Stable"
  - `comboTypeSafe`: "Stable"
- **identical**: `comboWin` ↔ `labelWin`
  - `comboWin`: "Win"
  - `labelWin`: "Win"
- **identical**: `deleteAccountTitle` ↔ `menuDeleteAccount`
  - `deleteAccountTitle`: "Delete Account"
  - `menuDeleteAccount`: "Delete Account"
- **near**: `errorNaverLoginFailed` ↔ `loginNaverFailed`
  - `errorNaverLoginFailed`: "Naver login failed. Please try again."
  - `loginNaverFailed`: "Naver sign-in failed. Please try again."
- **near**: `errorNetwork` ↔ `errorNetworkTimeout`
  - `errorNetwork`: "Please check your network connection."
  - `errorNetworkTimeout`: "Please check your network connection"
- **identical**: `errorNetwork` ↔ `networkErrorMessage`
  - `errorNetwork`: "Please check your network connection."
  - `networkErrorMessage`: "Please check your network connection."
- **near**: `errorNetworkTimeout` ↔ `networkErrorMessage`
  - `errorNetworkTimeout`: "Please check your network connection"
  - `networkErrorMessage`: "Please check your network connection."
- **identical**: `errorPayment` ↔ `subscribeFailMessage`
  - `errorPayment`: "Payment failed."
  - `subscribeFailMessage`: "Payment failed."
- **near**: `errorPayment` ↔ `subscribeFailTitle`
  - `errorPayment`: "Payment failed."
  - `subscribeFailTitle`: "Payment Failed"
- **identical**: `exitConfirm` ↔ `exitDialogConfirm`
  - `exitConfirm`: "Exit"
  - `exitDialogConfirm`: "Exit"
- **identical**: `exitDialogMessage` ↔ `exitMessage`
  - `exitDialogMessage`: "Are you sure you want to exit TrendSoccer?"
  - `exitMessage`: "Are you sure you want to exit TrendSoccer?"
- **identical**: `exitDialogTitle` ↔ `exitTitle`
  - `exitDialogTitle`: "Exit App"
  - `exitTitle`: "Exit App"
- **identical**: `feedNewsSportAll` ↔ `filterAll`
  - `feedNewsSportAll`: "All"
  - `filterAll`: "All"
- **identical**: `feedNewsSportBaseball` ↔ `notificationBaseball`
  - `feedNewsSportBaseball`: "Baseball"
  - `notificationBaseball`: "Baseball"
- **identical**: `feedNewsSportBaseball` ↔ `sportBaseball`
  - `feedNewsSportBaseball`: "Baseball"
  - `sportBaseball`: "Baseball"
- **identical**: `feedNewsSportSoccer` ↔ `notificationSoccer`
  - `feedNewsSportSoccer`: "Soccer"
  - `notificationSoccer`: "Soccer"
- **identical**: `feedNewsSportSoccer` ↔ `sportSoccer`
  - `feedNewsSportSoccer`: "Soccer"
  - `sportSoccer`: "Soccer"
- **identical**: `fixtureCancelled` ↔ `matchCancelled`
  - `fixtureCancelled`: "Cancelled"
  - `matchCancelled`: "Cancelled"
- **identical**: `fixturePostponed` ↔ `matchPostponed`
  - `fixturePostponed`: "Postponed"
  - `matchPostponed`: "Postponed"
- **identical**: `forceUpdateSkip` ↔ `skip`
  - `forceUpdateSkip`: "Skip"
  - `skip`: "Skip"
- **identical**: `goBack` ↔ `subscribeBack`
  - `goBack`: "Go back"
  - `subscribeBack`: "Go back"
- **identical**: `helpCenterTitle` ↔ `menuHelpCenter`
  - `helpCenterTitle`: "Help Center"
  - `menuHelpCenter`: "Help Center"
- **identical**: `labelAway` ↔ `pickDirectionAway`
  - `labelAway`: "Away"
  - `pickDirectionAway`: "Away"
- **identical**: `labelDraw` ↔ `pickDirectionDraw`
  - `labelDraw`: "Draw"
  - `pickDirectionDraw`: "Draw"
- **identical**: `labelDraw` ↔ `soccerDraw`
  - `labelDraw`: "Draw"
  - `soccerDraw`: "Draw"
- **identical**: `labelDraw` ↔ `soccerOddsDraw`
  - `labelDraw`: "Draw"
  - `soccerOddsDraw`: "Draw"
- **identical**: `labelHome` ↔ `pickDirectionHome`
  - `labelHome`: "Home"
  - `pickDirectionHome`: "Home"
- **identical**: `labelPrediction` ↔ `labelRecommend`
  - `labelPrediction`: "Analysis"
  - `labelRecommend`: "Analysis"
- **identical**: `labelPrediction` ↔ `tabAnalysis`
  - `labelPrediction`: "Analysis"
  - `tabAnalysis`: "Analysis"
- **identical**: `labelRecommend` ↔ `tabAnalysis`
  - `labelRecommend`: "Analysis"
  - `tabAnalysis`: "Analysis"
- **identical**: `labelWinShort` ↔ `soccerStatWins`
  - `labelWinShort`: "W"
  - `soccerStatWins`: "W"
- **identical**: `languageSettingsTitle` ↔ `menuLanguage`
  - `languageSettingsTitle`: "Language"
  - `menuLanguage`: "Language"
- **identical**: `lockGuestAction` ↔ `loginAppBarTitle`
  - `lockGuestAction`: "Log in"
  - `loginAppBarTitle`: "Log In"
- **identical**: `matchAlarmDisabledGoSettings` ↔ `notificationPermissionGoSettings`
  - `matchAlarmDisabledGoSettings`: "Go to Settings"
  - `notificationPermissionGoSettings`: "Go to Settings"
- **identical**: `menuExplore` ↔ `menuExploreSection`
  - `menuExplore`: "Explore"
  - `menuExploreSection`: "Explore"
- **identical**: `menuNotification` ↔ `notificationSettings`
  - `menuNotification`: "Notification"
  - `notificationSettings`: "Notification"
- **near**: `menuPremiumExpiryDate` ↔ `subscribePremiumExpiry`
  - `menuPremiumExpiryDate`: "Expires {date}"
  - `subscribePremiumExpiry`: "Expires: {date}"
- **identical**: `menuPrivacyPolicy` ↔ `signupPrivacyRequired`
  - `menuPrivacyPolicy`: "Privacy Policy"
  - `signupPrivacyRequired`: "Privacy Policy"
- **identical**: `menuSettings` ↔ `menuSettingsSection`
  - `menuSettings`: "Settings"
  - `menuSettingsSection`: "Settings"
- **identical**: `menuSignOut` ↔ `signOutConfirm`
  - `menuSignOut`: "Sign Out"
  - `signOutConfirm`: "Sign Out"
- **identical**: `menuSignOut` ↔ `signOutTitle`
  - `menuSignOut`: "Sign Out"
  - `signOutTitle`: "Sign Out"
- **identical**: `menuSubscribe` ↔ `menuSubscribeTitle`
  - `menuSubscribe`: "Subscribe"
  - `menuSubscribeTitle`: "Subscribe"
- **identical**: `menuSubscribeFree` ↔ `planTicketStart`
  - `menuSubscribeFree`: "Start Subscription"
  - `planTicketStart`: "Start subscription"
- **identical**: `menuSubscribeManage` ↔ `menuSubscribeManageTitle`
  - `menuSubscribeManage`: "Manage Subscription"
  - `menuSubscribeManageTitle`: "Manage Subscription"
- **identical**: `menuSubscribeManage` ↔ `planTicketManage`
  - `menuSubscribeManage`: "Manage Subscription"
  - `planTicketManage`: "Manage subscription"
- **identical**: `menuSubscribeManageTitle` ↔ `planTicketManage`
  - `menuSubscribeManageTitle`: "Manage Subscription"
  - `planTicketManage`: "Manage subscription"
- **identical**: `menuTermsOfService` ↔ `signupTermsRequired`
  - `menuTermsOfService`: "Terms of Service"
  - `signupTermsRequired`: "Terms of Service"
- **identical**: `menuTheme` ↔ `themeSettingsTitle`
  - `menuTheme`: "Theme"
  - `themeSettingsTitle`: "Theme"
- **identical**: `menuTrialRemaining` ↔ `planTicketTrialRemaining`
  - `menuTrialRemaining`: "{hours}h {minutes}m remaining"
  - `planTicketTrialRemaining`: "{hours}h {minutes}m remaining"
- **identical**: `notificationAppGeneral` ↔ `notificationAppAlerts`
  - `notificationAppGeneral`: "App Notifications"
  - `notificationAppAlerts`: "App Notifications"
- **identical**: `notificationBaseball` ↔ `sportBaseball`
  - `notificationBaseball`: "Baseball"
  - `sportBaseball`: "Baseball"
- **identical**: `notificationDisabledSnack` ↔ `notificationPermissionDisabledBanner`
  - `notificationDisabledSnack`: "Notifications are disabled. Please enable them in Settings."
  - `notificationPermissionDisabledBanner`: "Notifications are disabled. Please enable them in Settings."
- **identical**: `notificationSoccer` ↔ `sportSoccer`
  - `notificationSoccer`: "Soccer"
  - `sportSoccer`: "Soccer"
- **identical**: `pickDirectionDraw` ↔ `soccerDraw`
  - `pickDirectionDraw`: "Draw"
  - `soccerDraw`: "Draw"
- **identical**: `pickDirectionDraw` ↔ `soccerOddsDraw`
  - `pickDirectionDraw`: "Draw"
  - `soccerOddsDraw`: "Draw"
- **identical**: `planTicketExpiryDate` ↔ `planTicketExpiryPendingDate`
  - `planTicketExpiryDate`: "Expiry date : {date}"
  - `planTicketExpiryPendingDate`: "Expiry date : {date}"
- **identical**: `planTicketFree` ↔ `planTicketFreeTitle`
  - `planTicketFree`: "Free plan"
  - `planTicketFreeTitle`: "Free Plan"
- **identical**: `planTicketPremium` ↔ `planTicketPremiumTitle`
  - `planTicketPremium`: "Premium plan"
  - `planTicketPremiumTitle`: "Premium Plan"
- **identical**: `premiumBenefit24h` ↔ `signupCompletePremiumBenefit1`
  - `premiumBenefit24h`: "24-hour priority analysis access"
  - `signupCompletePremiumBenefit1`: "24-hour priority analysis access"
- **identical**: `premiumBenefitBaseballAi` ↔ `signupCompletePremiumBenefit3`
  - `premiumBenefitBaseballAi`: "Baseball AI Analysis"
  - `signupCompletePremiumBenefit3`: "Baseball AI Analysis"
- **identical**: `premiumBenefitPremiumPick` ↔ `signupCompletePremiumBenefit2`
  - `premiumBenefitPremiumPick`: "Unlimited Premium Reports"
  - `signupCompletePremiumBenefit2`: "Unlimited Premium Reports"
- **identical**: `premiumBenefitsTitle` ↔ `signupCompletePremiumBenefitsHeader`
  - `premiumBenefitsTitle`: "Premium benefits"
  - `signupCompletePremiumBenefitsHeader`: "Premium benefits"
- **identical**: `premiumExclusiveShort` ↔ `soccerPremiumOnly`
  - `premiumExclusiveShort`: "Premium only"
  - `soccerPremiumOnly`: "Premium only"
- **identical**: `premiumSubscribeNow` ↔ `subscribeNow`
  - `premiumSubscribeNow`: "Subscribe Now"
  - `subscribeNow`: "Subscribe now"
- **near**: `reportDetailLoadError` ↔ `reportListLoadError`
  - `reportDetailLoadError`: "Could not load match preview."
  - `reportListLoadError`: "Could not load match previews."
- **identical**: `reportTabPremium` ↔ `subscribePlanPremium`
  - `reportTabPremium`: "Premium"
  - `subscribePlanPremium`: "Premium"
- **identical**: `reportTabPremium` ↔ `tabPremium`
  - `reportTabPremium`: "Premium"
  - `tabPremium`: "Premium"
- **identical**: `reportsComboDetailTitle` ↔ `cardTodayCombo`
  - `reportsComboDetailTitle`: "Multi-Match Analysis"
  - `cardTodayCombo`: "Multi-match analysis"
- **identical**: `reportsComboDetailTitle` ↔ `todayCombination`
  - `reportsComboDetailTitle`: "Multi-Match Analysis"
  - `todayCombination`: "Multi-match analysis"
- **identical**: `reportsComboLockedTitle` ↔ `reportPremiumOnlyTitle` **STALE — `reportPremiumOnlyTitle` removed from ARB**
  - `reportsComboLockedTitle`: "Premium members only"
  - `reportPremiumOnlyTitle`: "Premium members only" (historical; key deleted)
- **identical**: `reportsComboTypeHighIndex` ↔ `comboHighOdds`
  - `reportsComboTypeHighIndex`: "High index"
  - `comboHighOdds`: "High index"
- **identical**: `reportsComboTypeHighIndex` ↔ `comboTypeHigh`
  - `reportsComboTypeHighIndex`: "High index"
  - `comboTypeHigh`: "High index"
- **identical**: `reportsComboTypeStable` ↔ `comboSafe`
  - `reportsComboTypeStable`: "Stable"
  - `comboSafe`: "Stable"
- **identical**: `reportsComboTypeStable` ↔ `comboTypeSafe`
  - `reportsComboTypeStable`: "Stable"
  - `comboTypeSafe`: "Stable"
- **identical**: `reportsPremiumViewAll` ↔ `reportsComboViewAll`
  - `reportsPremiumViewAll`: "View all picks"
  - `reportsComboViewAll`: "View all picks"
- **identical**: `signOutConfirm` ↔ `signOutTitle`
  - `signOutConfirm`: "Sign Out"
  - `signOutTitle`: "Sign Out"
- **identical**: `signupCompleteFreeBenefit3` ↔ `subscribeFreeBenefit3`
  - `signupCompleteFreeBenefit3`: "Live scores and fixtures"
  - `subscribeFreeBenefit3`: "Live scores and fixtures"
- **identical**: `signupPageTitle` ↔ `signupSubmit`
  - `signupPageTitle`: "Sign up"
  - `signupSubmit`: "Sign Up"
- **identical**: `soccerDraw` ↔ `soccerOddsDraw`
  - `soccerDraw`: "Draw"
  - `soccerOddsDraw`: "Draw"
- **identical**: `soccerPowerDiff` ↔ `soccerStatPowerDiff`
  - `soccerPowerDiff`: "Power diff."
  - `soccerStatPowerDiff`: "Power diff."
- **near**: `subscribeFailMessage` ↔ `subscribeFailTitle`
  - `subscribeFailMessage`: "Payment failed."
  - `subscribeFailTitle`: "Payment Failed"
- **identical**: `subscribePlanPremium` ↔ `tabPremium`
  - `subscribePlanPremium`: "Premium"
  - `tabPremium`: "Premium"
- **near**: `subscribeStartPremium` ↔ `subscribeStartPremiumArrow`
  - `subscribeStartPremium`: "Start Premium"
  - `subscribeStartPremiumArrow`: "Start Premium →"

### Q1 swap-only (single exact match): 38

- `Continue with Google` → `loginGoogle` (lib/features_v2/auth/login_screen.dart:177)
- `Continue with Naver` → `loginNaver` (lib/features_v2/auth/login_screen.dart:189)
- `Agree to all` → `signupAgreeAll` (lib/features_v2/auth/signup_terms_screen.dart:212)
- `Menu` → `tabMenu` (lib/design_system/widgets/ts_bottom_navigation.dart:83)
- `Reports` → `cardPickCount` (lib/design_system/widgets/ts_bottom_navigation.dart:81)
- `In progress` → `comboStatusInProgress` (lib/design_system/widgets/ts_combo_footer.dart:32; lib/design_system/widgets/ts_combo_match_row.dart:38)
- `Partial` → `comboStatusPartial` (lib/design_system/widgets/ts_combo_footer.dart:34)
- `A` → `labelAwayShort` (lib/design_system/widgets/ts_combo_match_row.dart:132)
- `H` → `labelHomeShort` (lib/design_system/widgets/ts_combo_match_row.dart:125)
- `FREE` → `subscribePlanFree` (lib/design_system/widgets/ts_plan_ticket.dart:29)
- `D` → `labelDrawShort` (lib/design_system/widgets/ts_result_dot.dart:17)
- `L` → `soccerStatLosses` (lib/design_system/widgets/ts_result_dot.dart:18)
- `TrendSoccer` → `appName` (lib/main.dart:106; lib/main.dart:186)
- `FT` → `fixtureStatusFinal` (lib/design_system/widgets/ts_status_badge.dart:19 **STALE — file deleted**; lib/features_v2/matches/matches_screen.dart:1113; lib/features_v2/matches/match_report_screen.dart:729)
- `LIVE` → `fixtureLive` (lib/design_system/widgets/ts_status_badge.dart:17 **STALE — file deleted**; lib/features_v2/matches/matches_screen.dart:1168; lib/features_v2/matches/match_report_screen.dart:735)
- `Match Report` → `matchReportTitle` (lib/features_v2/matches/match_report_screen.dart:488)
- `Recent form` → `soccerRecentForm` (lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:426; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:440; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:446; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:460; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:467; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:475; lib/features_v2/matches/widgets/baseball_extended_report_blocks.dart:480)
- `Premium content` → `premiumNonSubscriberTitle` (lib/features_v2/matches/widgets/baseball_report_lock_policy.dart:40; lib/features_v2/matches/widgets/soccer_report_lock_policy.dart:53)
- `Reasoning` → `soccerAnalysisReasoning` (lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:113; lib/features_v2/matches/widgets/soccer_predict_report_blocks.dart:162)
- `PPD` → `statusPostponed` (lib/design_system/widgets/ts_status_badge.dart:20 **STALE — file deleted**; lib/features_v2/matches/matches_screen.dart:1090)
- `SUSP` → `statusInterrupted` (lib/features_v2/matches/matches_screen.dart:1098)
- `Try another date from the strip above.` → `reportsComboEmptyBody` (lib/features_v2/matches/matches_screen.dart:1512)
- `Email` → `helpCenterEmail` (lib/features_v2/menu/help_screen.dart:200)
- `Message` → `helpCenterMessage` (lib/features_v2/menu/help_screen.dart:223)
- `Name` → `helpCenterName` (lib/features_v2/menu/help_screen.dart:189)
- `Send inquiry` → `helpCenterSend` (lib/features_v2/menu/help_screen.dart:242)
- `Subject` → `helpCenterSubject` (lib/features_v2/menu/help_screen.dart:212)
- `App version` → `menuAppVersion` (lib/features_v2/menu/menu_screen.dart:258; lib/features_v2/menu/menu_screen.dart:329)
- `Cancel` → `cancel` (lib/features_v2/menu/menu_screen.dart:82; lib/features_v2/menu/menu_screen.dart:152)
- `Delete` → `deleteAccountConfirm` (lib/features_v2/menu/menu_screen.dart:151)
- `English` → `languageEnglish` (lib/features_v2/menu/menu_screen.dart:419; lib/features_v2/menu/settings_sheets.dart:49)
- `Signed out successfully.` → `signOutSuccess` (lib/features_v2/menu/menu_screen.dart:95)
- `Subscription` → `menuSubscribeInfoSection` (lib/features_v2/menu/menu_screen.dart:284)
- `한국어` → `languageKorean` (lib/features_v2/menu/menu_screen.dart:420; lib/features_v2/menu/settings_sheets.dart:54)
- `General` → `notificationGeneral` (lib/features_v2/menu/notification_settings_screen.dart:108)
- `Marketing` → `notificationMarketing` (lib/features_v2/menu/notification_settings_screen.dart:124)
- `Under maintenance` → `maintenanceTitle` (lib/features_v2/system/force_update_screen.dart:45)
- `Update required` → `forceUpdateTitle` (lib/features_v2/system/force_update_screen.dart:45)

### Q1 DECISION rows (multiple exact matches): 23

- `Home` → DECISION: labelHome, pickDirectionHome (lib/design_system/widgets/ts_bottom_navigation.dart:79)
- `Matches` → DECISION: cardComboCount, comboComboCount (lib/design_system/widgets/ts_bottom_navigation.dart:80)
- `Match` → DECISION: comboMatchHit, comboStatusHit (lib/design_system/widgets/ts_combo_footer.dart:33; lib/design_system/widgets/ts_combo_match_row.dart:39)
- `Mismatch` → DECISION: comboMatchFail, comboStatusMiss (lib/design_system/widgets/ts_combo_footer.dart:35; lib/design_system/widgets/ts_combo_match_row.dart:40)
- `PREMIUM` → DECISION: reportTabPremium, subscribePlanPremium, tabPremium (lib/design_system/widgets/ts_plan_ticket.dart:31)
- `W` → DECISION: labelWinShort, soccerStatWins (lib/design_system/widgets/ts_result_dot.dart:16)
- `Baseball Analysis` → DECISION: analysisTabBaseball, trendBaseballAnalysis (lib/features_v2/home/home_screen.dart:186)
- `Multi-Match Analysis` → DECISION: cardTodayCombo, reportsComboDetailTitle, todayCombination (lib/features_v2/home/home_screen.dart:901)
- `Soccer Analysis` → DECISION: analysisTabSoccer, trendSoccerAnalysis (lib/features_v2/home/home_screen.dart:180)
- `Stable` → DECISION: comboSafe, comboTypeSafe, reportsComboTypeStable (lib/features_v2/home/home_screen.dart:886)
- `All` → DECISION: feedNewsSportAll, filterAll (lib/features_v2/matches/matches_screen.dart:1161)
- `Baseball` → DECISION: feedNewsSportBaseball, notificationBaseball, sportBaseball (lib/design_system/widgets/ts_sport_toggle.dart:74; lib/features_v2/menu/notification_settings_screen.dart:151)
- `Soccer` → DECISION: feedNewsSportSoccer, notificationSoccer, sportSoccer (lib/design_system/widgets/ts_sport_toggle.dart:74; lib/features_v2/menu/notification_settings_screen.dart:132)
- `Delete account` → DECISION: deleteAccountTitle, menuDeleteAccount (lib/features_v2/menu/menu_screen.dart:345)
- `Language` → DECISION: languageSettingsTitle, menuLanguage (lib/features_v2/menu/menu_screen.dart:225; lib/features_v2/menu/menu_screen.dart:296; lib/features_v2/menu/settings_sheets.dart:46)
- `Privacy policy` → DECISION: menuPrivacyPolicy, signupPrivacyRequired (lib/features_v2/menu/menu_screen.dart:248; lib/features_v2/menu/menu_screen.dart:319; lib/features_v2/menu/privacy_screen.dart:13)
- `Sign out` → DECISION: menuSignOut, signOutConfirm, signOutTitle (lib/features_v2/menu/menu_screen.dart:81; lib/features_v2/menu/menu_screen.dart:340)
- `Sign up` → DECISION: signupPageTitle, signupSubmit (lib/features_v2/menu/menu_screen.dart:212)
- `Terms of service` → DECISION: menuTermsOfService, signupTermsRequired (lib/features_v2/menu/menu_screen.dart:253; lib/features_v2/menu/menu_screen.dart:324; lib/features_v2/menu/terms_screen.dart:13)
- `Theme` → DECISION: menuTheme, themeSettingsTitle (lib/features_v2/menu/menu_screen.dart:231; lib/features_v2/menu/menu_screen.dart:302; lib/features_v2/menu/settings_sheets.dart:82)
- `Log in` → DECISION: lockGuestAction, loginAppBarTitle (lib/features_v2/feed/feed_header_shell.dart:49; lib/features_v2/home/home_screen.dart:206; lib/features_v2/matches/matches_screen.dart:1400; lib/features_v2/menu/menu_screen.dart:193; lib/features_v2/reports/reports_header_shell.dart:148)
- `Analysis` → DECISION: labelPrediction, labelRecommend, tabAnalysis (lib/features_v2/reports/reports_route_map.dart:51; lib/features_v2/reports/reports_route_map.dart:53)
- `Premium` → DECISION: reportTabPremium, subscribePlanPremium, tabPremium (lib/features_v2/reports/reports_route_map.dart:51)

## Q5. Sport-prefixed keys

- baseball*: **62**
- soccer*: **62**

### baseball*

| `baseballAiLoadFailed` | (unused) | — |
| `baseballAiLoading` | (unused) | — |
| `baseballAiLoadingHint` | (unused) | — |
| `baseballAiMatchAnalysis` | matches/widgets/baseball_ai_match_analysis_report_block | — |
| `baseballAiPremiumHint` | (unused) | — |
| `baseballAiSummary` | reports/combo_detail_logic | baseball* on reports |
| `baseballAiSummaryDefault` | (unused) | — |
| `baseballAiTabLoadFailed` | (unused) | — |
| `baseballAiTabLoading` | (unused) | — |
| `baseballAiTabLoadingHint` | (unused) | — |
| `baseballAiWinProbabilityHint` | (unused) | — |
| `baseballAnalysisHeldUntilStarters` | matches/widgets/baseball_ai_match_analysis_report_block, matches/widgets/baseball_extended_report_blocks, matches/widgets/baseball_pitcher_analysis_report_block | — |
| `baseballBaseline` | (unused) | — |
| `baseballBaselineDash` | (unused) | — |
| `baseballBaselineValue` | (unused) | — |
| `baseballConfidenceHigh` | (unused) | — |
| `baseballConfidenceLow` | (unused) | — |
| `baseballConfidenceMedium` | (unused) | — |
| `baseballEventFirstPitch` | (unused) | — |
| `baseballEventGameEnd` | (unused) | — |
| `baseballEventHomerun` | (unused) | — |
| `baseballEventInningChange` | (unused) | — |
| `baseballEventScore` | (unused) | — |
| `baseballH2hLastFive` | matches/widgets/baseball_h2h_report_block | — |
| `baseballH2hLoading` | (unused) | — |
| `baseballH2hNoData` | (unused) | — |
| `baseballHomeAwayRecord` | matches/widgets/baseball_extended_report_blocks, matches/widgets/baseball_report_block_placeholders | — |
| `baseballHomeAwayWinRate` | (unused) | — |
| `baseballInningBottom` | (unused) | — |
| `baseballInningTop` | (unused) | — |
| `baseballOddsBaseline` | (unused) | — |
| `baseballOverUnder` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballPitcherAnalysis` | matches/widgets/baseball_pitcher_analysis_report_block, matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballPitcherAnalysisNoData` | matches/widgets/baseball_pitcher_analysis_report_block, matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballPitcherGeneric` | matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballPitcherLeftHand` | matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballPitcherMatchup` | (unused) | — |
| `baseballPitcherRightHand` | matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballProductionBatterEdge` | (unused) | — |
| `baseballProductionDefenseEdge` | (unused) | — |
| `baseballRecent10` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballRelatedMatches` | (unused) | — |
| `baseballReliability` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballSeasonStats` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballSeasonStatsNoData` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballSectionH2h` | (unused) | — |
| `baseballSectionOdds` | (unused) | — |
| `baseballSectionPitchers` | matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballSectionPitchersKo` | matches/widgets/baseball_starting_pitchers_report_block | — |
| `baseballStatHits` | matches/widgets/baseball_extended_report_blocks, matches/widgets/baseball_report_block_placeholders | — |
| `baseballStatRunsAllowed` | matches/widgets/baseball_extended_report_blocks, matches/widgets/baseball_report_block_placeholders | — |
| `baseballStatRunsScored` | matches/widgets/baseball_extended_report_blocks, matches/widgets/baseball_report_block_placeholders | — |
| `baseballStrength` | (unused) | — |
| `baseballTeamBattingAvg` | (unused) | — |
| `baseballTeamEra` | (unused) | — |
| `baseballTeamOps` | (unused) | — |
| `baseballTeamProductivity` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballTeamProductivityComment` | matches/widgets/baseball_extended_report_blocks | — |
| `baseballTeamWhip` | (unused) | — |
| `baseballWeakness` | (unused) | — |
| `baseballWinProbability` | (unused) | — |
| `baseballWinsLosses` | (unused) | — |

### soccer*

| `soccerAiPremiumOnly` | (unused) | — |
| `soccerAiPremiumSubscribeHint` | (unused) | — |
| `soccerAnalysisReasoning` | (unused) | — |
| `soccerAnalysisResult` | (unused) | — |
| `soccerAwayPower` | (unused) | — |
| `soccerAwayWinPct` | matches/widgets/soccer_predict_report_blocks | — |
| `soccerDraw` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerEventFulltime` | (unused) | — |
| `soccerEventGoal` | (unused) | — |
| `soccerEventHalftime` | (unused) | — |
| `soccerEventKickoff` | (unused) | — |
| `soccerEventRedCard` | (unused) | — |
| `soccerEventSubstitution` | (unused) | — |
| `soccerEventYellowCard` | (unused) | — |
| `soccerFinalProbability` | (unused) | — |
| `soccerH2h` | matches/widgets/baseball_h2h_report_block, matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | soccer* on baseball widget |
| `soccerH2hAllTime` | (unused) | — |
| `soccerH2hAvgGoals` | (unused) | — |
| `soccerH2hInsights` | (unused) | — |
| `soccerH2hLoading` | (unused) | — |
| `soccerH2hMatchCount` | (unused) | — |
| `soccerH2hMaxScore` | (unused) | — |
| `soccerH2hRecent` | matches/widgets/baseball_h2h_report_block, matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | soccer* on baseball widget |
| `soccerH2hStatistics` | (unused) | — |
| `soccerHomePower` | (unused) | — |
| `soccerHomeWinPct` | matches/widgets/soccer_predict_report_blocks | — |
| `soccerMarketBtts` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerMarketCs` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerMarketFts` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerMarketIndicators` | matches/widgets/soccer_extended_report_blocks | — |
| `soccerMethod3` | (unused) | — |
| `soccerMethodFirstGoal` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerMethodMinMax` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerMethodPaCompare` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerOddsAway` | (unused) | — |
| `soccerOddsDraw` | (unused) | — |
| `soccerOddsHome` | (unused) | — |
| `soccerPowerDiff` | (unused) | — |
| `soccerPowerIndex` | (unused) | — |
| `soccerPremiumOnly` | (unused) | — |
| `soccerReasonFirstGoalAway` | (unused) | — |
| `soccerReasonFirstGoalHome` | (unused) | — |
| `soccerRecent10` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerRecentForm` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerSeasonAway` | (unused) | — |
| `soccerSeasonHome` | (unused) | — |
| `soccerStatAnalyzedMatches` | (unused) | — |
| `soccerStatComebackRate` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerStatFirstGoalRate` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerStatGoalDifference` | matches/widgets/soccer_predict_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerStatGoalLine` | (unused) | — |
| `soccerStatLosses` | (unused) | — |
| `soccerStatOver15` | (unused) | — |
| `soccerStatOver25` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerStatOver35` | (unused) | — |
| `soccerStatPattern` | (unused) | — |
| `soccerStatPowerDiff` | (unused) | — |
| `soccerStatTeamInsights` | matches/widgets/soccer_extended_report_blocks | — |
| `soccerStatTeamStats` | matches/widgets/soccer_predict_report_blocks | — |
| `soccerStatWinProb` | (unused) | — |
| `soccerStatWinRate` | matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders | — |
| `soccerStatWins` | (unused) | — |

### Scope inconsistencies

- `baseballAiSummary` (baseball* on reports): reports/combo_detail_logic
- `soccerH2h` (soccer* on baseball widget): matches/widgets/baseball_h2h_report_block, matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders
- `soccerH2hRecent` (soccer* on baseball widget): matches/widgets/baseball_h2h_report_block, matches/widgets/soccer_extended_report_blocks, matches/widgets/soccer_report_block_placeholders