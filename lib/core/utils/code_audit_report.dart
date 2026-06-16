// TrendSoccer — Comprehensive Code Audit Report
// Generated: 2026-05-20
// ANALYSIS ONLY — no executable code; documentation for engineering review.
// ignore_for_file: type=lint

library;

/*
================================================================================
TRENDSOCCER CODE AUDIT REPORT
================================================================================
Scope: lib/ (Flutter app)
Method: ripgrep + PowerShell scans + dart analyze
Note: color_tokens.dart does not exist; primitives live in tokens/ts_colors.dart.
      TsSemanticColors lives in ts_semantic_colors.dart (not app_theme.dart).

================================================================================
1. HARDCODED COLORS — Color(0x...) outside token files
================================================================================
Excludes: ts_colors.dart, ts_semantic_colors.dart, app_theme.dart, *_test.dart, *.g.dart

TOTAL OCCURRENCES: 37 (across 15 files)

TOP FILES (all files with violations; fewer than 20 total):
  Count  File
  -----  ----
  8      lib/shared/widgets/cards/today_combo_card.dart
  4      lib/shared/widgets/combo/combo_dashboard.dart
  4      lib/shared/widgets/combo/combo_card.dart
  4      lib/shared/widgets/combo/combo_status_badge.dart
  2      lib/features/trend/trend_page.dart
  2      lib/features/analysis/widgets/baseball/premium/baseball_premium_tab.dart
  2      lib/features/analysis/widgets/baseball/premium/over_under_section.dart
  2      lib/shared/widgets/menu/plan_option.dart
  2      lib/shared/widgets/baseball/position_chip.dart
  2      lib/shared/widgets/combo/combo_type_badge.dart
  1      lib/shared/widgets/auth/trial_banner.dart
  1      lib/features/analysis/widgets/baseball/standard/baseball_h2h_section.dart
  1      lib/features/analysis/widgets/baseball/standard/baseball_odds_section.dart
  1      lib/shared/widgets/cards/premium_pick_card.dart
  1      lib/shared/widgets/premium/stats_card.dart

PATTERNS OBSERVED:
  - Semi-transparent brand tints: Color(0x3300DF81), Color(0x1A00DF81), etc.
  - System color alphas: 0x33F59E0B (warning), 0x3310B981 (success), 0x33EF4444 (error)
  - Legacy green #00DF81 still used in several combo/baseball widgets (pre-Mint migration)
  - trend_page.dart: overlay scrim colors Color(0xBF212726) / Color(0xD9FDFCFB)

RECOMMENDATION:
  Extract alpha-tint helpers or semantic tokens (e.g. interactiveSurface variants)
  and replace raw hex with TsColors.brandPrimary* / TsColors.system* + withValues().

================================================================================
2. HARDCODED TEXT STYLES — inline TextStyle() outside TsType
================================================================================
Excludes: ts_type.dart, tokens/, *_test.dart, *.g.dart

TOTAL OCCURRENCES: 16 (across 4 files)

TOP FILES:
  Count  File
  -----  ----
  8      lib/shared/widgets/fixture/alarm_sheet.dart
  6      lib/core/theme/app_theme.dart (theme wiring — acceptable)
  1      lib/features/fixture/fixture_page.dart
  1      lib/shared/widgets/report/match_header.dart (static _vsTextStyle const)

APP CODE ONLY (excluding app_theme.dart): 10 occurrences in 3 files.

RECOMMENDATION:
  alarm_sheet.dart: replace 8 inline TextStyle(color: ...) with TsType.*.copyWith().
  fixture_page.dart line ~981: use TsType.bodyLRegular.copyWith(...).
  match_header.dart: consider TsType token for VS label.

================================================================================
3. HARDCODED SPACING — EdgeInsets.* without TsSpacing
================================================================================
TOTAL OCCURRENCES: 179 lines containing EdgeInsets.* without TsSpacing reference
(Not all are violations — many use standard 16/24 layout values.)

SAMPLE (first 30):
  lib/main_screen.dart:54               EdgeInsets.all(24)
  lib/main_screen.dart:154              EdgeInsets.symmetric(horizontal: 16, vertical: 12)
  lib/features/analysis/analysis_page.dart:403   symmetric(horizontal: 16, vertical: 12)
  lib/features/analysis/analysis_page.dart:423   fromLTRB(16, 16, 16, 0)
  lib/features/analysis/analysis_page.dart:439   fromLTRB(16, 16, 16, 0)
  lib/features/analysis/analysis_page.dart:451   all(16)
  lib/features/analysis/analysis_page.dart:462   only(bottom: 16)
  lib/features/analysis/baseball_match_report_page.dart:105   only(...)
  lib/features/analysis/soccer_match_report_page.dart:136     only(...)
  lib/features/analysis/soccer_match_report_page.dart:200     symmetric(vertical: 48)
  lib/features/analysis/widgets/baseball_matches_section.dart (multiple 32/48 vertical)
  lib/features/analysis/widgets/soccer_matches_section.dart (multiple 32/48 vertical)
  lib/features/analysis/widgets/baseball/premium/baseball_ai_tab.dart (48/64 vertical)
  lib/features/analysis/widgets/baseball/premium/baseball_premium_tab.dart (16/24 padding)
  lib/features/analysis/widgets/baseball/premium/over_under_section.dart:51
  lib/features/analysis/widgets/baseball/premium/team_production_section.dart:59

COMMON MAGIC NUMBERS: 8, 12, 16, 24, 32, 48, 64

RECOMMENDATION:
  Map recurring values to TsSpacing (xs/sm/md/lg/xl) incrementally; prioritize
  shared widgets and page-level padding first.

================================================================================
4. UNUSED FILES — no package-path import found in lib/
================================================================================
Method: scan each lib/ .dart file recursively (excl. l10n/, *.g.dart, main.dart) for
        package:trendsoccer/<path> or path string references.

CAVEAT: Files re-exported via barrel files (e.g. premium_sections.dart) may
        appear unused if only the barrel is imported. Manual verification needed.

LIKELY UNUSED (no direct import path found):
  lib/core/models/payment_models.dart
  lib/core/utils/soccer_i18n_field_report.dart
  lib/features/fixture/fixture_date_navigation.dart
  lib/features/fixture/fixture_dummy_data.dart
  lib/features/report/report_page.dart
  lib/shared/widgets/widgets.dart (barrel export file — never imported)

LIKELY FALSE POSITIVES (used via barrel export, not direct path):
  lib/features/analysis/widgets/baseball/premium/ (all) → premium_sections.dart
  lib/features/analysis/widgets/soccer/standard/_section.dart → standard tab imports
  lib/shared/widgets/menu/plan_option.dart → exported by widgets.dart (but widgets.dart itself unused)
  lib/shared/widgets/auth/ (all) → may be dead or routed via unused barrel

RECOMMENDATION:
  Delete confirmed dead files; wire report_page.dart into router or remove;
  either adopt widgets.dart barrel app-wide or delete it and use direct imports.

================================================================================
5. UNUSED IMPORTS — dart analyze
================================================================================
RESULT: 0 unused_import warnings

  dart analyze → "No issues found!"

================================================================================
6. REMAINING DEBUG LOGS — debugPrint
================================================================================
TOTAL COUNT: 405 occurrences (excluding *_test.dart)

TEMPORARY MARKERS: 0 lines tagged "// TEMPORARY"

SAMPLE (first 40 — all appear permanent diagnostic logging):
  lib/main.dart:25                          [FCM] background
  lib/main.dart:30                          [MAIN] app starting
  lib/main.dart:35                          [MAIN] Firebase initialized
  lib/main.dart:40-47                       [MAIN] FCM init
  lib/main.dart:66                          [AUTH] Naver SDK initialized
  lib/main_screen.dart:236                  [NAV] Tab changed
  lib/core/models/fixture_models_v2.dart    [FIXTURE] parse logs
  lib/core/models/soccer_models.dart        [SOCCER] fromJson keys
  lib/core/providers/auth_provider.dart     [AUTH] login/loadProfile/delete (many)
  ... continues across fixture_service, fcm_service, iap_service, baseball parsers

TOP FILES BY debugPrint DENSITY:
  lib/core/providers/auth_provider.dart     ~80+
  lib/core/services/iap_service.dart        ~50+
  lib/core/services/fcm_service.dart        ~30+
  lib/core/services/fixture_service.dart    ~20+
  lib/features/fixture/fixture_page.dart    ~20+
  lib/features/analysis/models/baseball_standard_parser.dart
  lib/features/analysis/models/baseball_premium_parser.dart

CATEGORIZATION:
  Permanent (production diagnostics): ~405 — no gating behind kDebugMode observed widely
  Temporary: 0 explicitly marked

RECOMMENDATION:
  Wrap verbose logs in kDebugMode; keep critical error logs; strip parser key-dump
  logs before release builds.

================================================================================
7. SURFACE TOKEN USAGE — post Base↔Raised swap verification
================================================================================
Current semantics (after swap):
  surfaceBase   → card/widget background  (dark #141415, light #F5F5F5)
  surfaceRaised → page background         (dark #0A0A0B, light #FFFFFF)

REFERENCE COUNTS (excl. ts_semantic_colors, app_theme, tokens/):
  surfaceBase:   60 references across ~35 files
  surfaceRaised: 58 references across ~40 files

--- CORRECT PAGE BG (surfaceRaised on Scaffold/page) ---
  lib/features/analysis/analysis_page.dart        Scaffold backgroundColor
  lib/features/fixture/fixture_page.dart          Scaffold backgroundColor
  lib/core/theme/app_theme.dart                   AppBar/NavBar/BottomNav (raised chrome)

--- LIKELY INCORRECT PAGE BG (surfaceBase on Scaffold — should be surfaceRaised) ---
  lib/main_screen.dart                            Scaffold backgroundColor
  lib/features/menu/menu_page.dart
  lib/features/trend/trend_page.dart
  lib/features/premium/premium_page.dart
  lib/features/auth/login_page.dart
  lib/features/auth/signup_terms_page.dart
  lib/features/auth/signup_complete_page.dart
  lib/features/splash/splash_page.dart
  lib/features/maintenance/maintenance_page.dart
  lib/features/update/force_update_page.dart
  lib/features/menu/about_page.dart
  lib/features/menu/privacy_policy_page.dart
  lib/features/menu/terms_of_service_page.dart
  lib/features/menu/notification_settings_page.dart
  lib/features/menu/subscribe_page.dart
  lib/features/menu/subscribe_fail_page.dart
  lib/features/menu/subscribe_success_page.dart
  lib/features/analysis/baseball_match_report_page.dart
  lib/features/analysis/soccer_match_report_page.dart
  lib/features/report/soccer_report_list_page.dart
  lib/features/report/soccer_report_detail_page.dart
  lib/features/report/report_page.dart
  lib/core/theme/app_theme.dart                   scaffoldBackgroundColor (both themes)

--- CORRECT WIDGET/CHROME (surfaceBase on cards, chips, app bars) ---
  lib/features/analysis/analysis_page.dart        SliverAppBar backgroundColor
  lib/features/fixture/fixture_page.dart          SliverAppBar + DateTabBar
  lib/shared/widgets/filter/ts_filter_chip.dart   active text on primary
  lib/shared/widgets/buttons/ts_button.dart       on-primary text color
  lib/shared/widgets/fixture/date_nav_chip.dart   active label colors
  lib/shared/widgets/toggle/sports_toggle.dart    selected segment fill

--- LIKELY INCORRECT CARD BG (surfaceRaised on cards — should be surfaceBase) ---
  ~35 widget files use surfaceRaised for Container/Card backgrounds:
  lib/shared/widgets/cards/premium_pick_card.dart
  lib/shared/widgets/cards/today_combo_card.dart
  lib/shared/widgets/cards/today_pick_card.dart
  lib/shared/widgets/combo/combo_card.dart
  lib/shared/widgets/combo/combo_dashboard.dart
  lib/shared/widgets/fixture/fixture_matches_card.dart
  lib/shared/widgets/menu/profile_card.dart
  lib/shared/widgets/menu/menu_list_item.dart
  lib/shared/widgets/menu/guest_banner.dart
  lib/shared/widgets/menu/plan_ticket.dart
  lib/shared/widgets/navigation/ts_bottom_navigation.dart
  lib/shared/widgets/navigation/date_tab_bar.dart (default background)
  lib/features/analysis/widgets/ (most section cards)
  ... (see per-file breakdown in audit tooling output)

--- MIXED / CONTEXT-DEPENDENT ---
  lib/features/trend/trend_page.dart            page=Base, overlay=Raised
  lib/features/premium/premium_page.dart        page=Base, inner cards=Raised
  lib/shared/widgets/appbar/ts_app_bar.dart     uses surfaceBase (widget chrome)

RECOMMENDATION:
  Systematic migration pass:
    Scaffold/page backgrounds  → surfaceRaised
    Card/list item/container   → surfaceBase
  Priority: app_theme scaffoldBackgroundColor + main_screen shell (affects all tabs).

================================================================================
8. TODO / FIXME / HACK / XXX COMMENTS
================================================================================
TOTAL: 5 occurrences (4 unique locations)

  lib/features/analysis/analysis_dummy_data.dart:35
    // TODO: Switch to labelEn when locale is 'en'

  lib/core/services/soccer_service.dart:113
    // TODO: Replace with /api/v1/mobile/soccer/matches when available

  lib/core/services/soccer_service.dart:355
    // TODO: Replace with /api/v1/mobile/soccer/premium-picks when available

  lib/core/services/soccer_service.dart:376
    // TODO: Replace with /api/v1/mobile/soccer/premium-picks/stats when available

  lib/features/analysis/widgets/soccer/standard/soccer_standard_tab.dart:275
    // TODO: Parse markdown into structured sections

No FIXME, HACK, or XXX markers found.

================================================================================
9. FILE SIZE SUMMARY — large files (lines)
================================================================================
  1073  lib/features/fixture/fixture_page.dart
  1066  lib/features/analysis/widgets/baseball/standard/starting_pitchers_section.dart
   894  lib/core/providers/auth_provider.dart
   736  lib/features/trend/trend_page.dart
   704  lib/features/menu/menu_page.dart

CONCERN: fixture_page.dart and starting_pitchers_section.dart exceed 1000 lines.
         auth_provider.dart nearing 900 lines (auth + profile + social login).

RECOMMENDATION:
  Extract fixture polling/alarm logic and baseball pitcher UI into sub-widgets/files.

================================================================================
10. DART ANALYZE
================================================================================
  $ dart analyze
  Analyzing TrendSoccer...
  No issues found!

================================================================================
SUMMARY — TOP PRIORITIES
================================================================================
  P1  Surface token migration after Base↔Raised swap (scaffold + cards inverted
      in many files; app_theme scaffold still uses surfaceBase)
  P2  Remove/gate 405 debugPrint statements for release builds
  P3  Replace 37 hardcoded Color(0x...) in combo/baseball/trend widgets
  P4  Delete or wire unused files (payment_models, report_page, widgets.dart barrel)
  P5  Split 1000+ line files (fixture_page, starting_pitchers_section)
  P6  Inline TextStyle cleanup (alarm_sheet.dart — 8 instances)
  P7  EdgeInsets → TsSpacing gradual adoption (179 touch points)

================================================================================
END OF REPORT
================================================================================
*/
