# TrendSoccer 외부 데이터 의존성 문서

> 코드베이스 조사 기준. Flutter 앱(`lib/`)에서 실제로 호출·파싱·표시하는 범위만 기록함.  
> 추정하지 않음 — 코드에 없으면 **코드에서 확인 불가**로 표기.

---

## 1. API-Football / API-Baseball

### 1.0 요약

| 항목 | 내용 |
|------|------|
| Flutter 직접 REST 호출 | **없음** — `api-football.com`, `api-baseball.com` 등 API-Sports REST 엔드포인트를 앱이 직접 호출하는 코드 없음 |
| 데이터 경로 | 자체 백엔드 `WEB_API_BASE_URL`(`AppConfig.webApiBaseUrl`, `.env`)가 축구·야구 데이터를 프록시·가공 |
| API-Sports 직접 사용 | 팀 로고 **정적 CDN** URL만 생성: `https://media.api-sports.io/football/teams/{teamId}.png` (`SoccerService._footballTeamLogoUrl`, premium pick history 로고) |
| API-Baseball 직접 사용 | **없음** (야구 팀 로고는 API 응답 필드 `homeLogo` 등 사용) |
| 유일한 타사 스포츠 API 직접 호출 | **MLB Stats API** — `BaseballService.fetchMlbSeasonStats` → `statsapi.mlb.com` (아래 1.2) |
| 요금제 / rate limit | 코드·주석에 API-Football/API-Baseball 플랜·한도 **코드에서 확인 불가**. API 오류 코드 `RATE_LIMITED` 처리만 존재 (`error_resolver.dart`) |

---

### 1.1 미디어 CDN (API-Sports)

| 항목 | 내용 |
|------|------|
| URL 패턴 | `GET https://media.api-sports.io/football/teams/{teamId}.png` (HTTP GET, 이미지 바이너리) |
| 래퍼 | `SoccerService._footballTeamLogoUrl` / `_registerHistoryPickTeamLogo` |
| 소비 화면 | Premium pick 최근 결과 카드 (`premiumPickStatsProvider` → `RecentWinData` 로고) |
| 캐싱 | 없음 (URL 문자열만 생성; `CachedNetworkImage` 등은 소비 측 위젯에 따름) |

---

### 1.2 MLB Stats API (직접 호출)

| 항목 | 내용 |
|------|------|
| Method / Path | `GET https://statsapi.mlb.com/api/v1/people/{pitcherId}?hydrate=stats(group=[pitching],type=[season],season={season})` |
| 래퍼 | `BaseballService.fetchMlbSeasonStats` |
| Query | `pitcherId` 동적, `season` 동적 (현재·이전 시즌) |
| 소비 화면 | 야구 경기 리포트 Premium 탭 — 선발 투수 시즌 스탯 (`baseball_match_report_provider`) |
| 타임아웃 | connect/receive 각 5초 |
| 캐싱 | 없음 |
| 읽는 필드 | `people[0].stats[0].splits[0].stat` Map 전체를 `Map<String, dynamic>`으로 반환 후 UI 파서가 사용 |
| 무시하는 필드 | `people` 내 선수 메타(이름, 팀, 포지션 등), `stats`/`splits`의 비-season 항목, `stat` Map 내 사용하지 않는 키는 파서·UI 미표시분 전부 |

---

### 1.3 백엔드 프록시 엔드포인트 (축구 — API-Football 유래 데이터)

Base URL: `WEB_API_BASE_URL` · 클라이언트: `webDioProvider` · 인증: `TokenService` JWT Bearer(있을 때만)

#### `GET /api/odds-from-db`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService._fetchOddsFromDb` / `getMatches`; `FixtureService.getSoccerFixtures` |
| 소비 화면 | Trend(날짜별), Analysis(7일 병합), Fixture(축구 일정) |
| Query 파라미터 | `date` — 동적(선택); `league=ALL`, `daysBack=3`, `daysAhead=4` — Fixture 전용 고정; 빈 params — Analysis fallback |
| 호출 빈도 | Provider/페이지 로드 시; Analysis 빈 결과 시 30분 스킵(`_soccerEmptyCheckInterval`); Fixture pull-to-refresh |
| 캐싱 | `SoccerService` 인메모리 5분 TTL (`_responseCache`) — **FixtureService는 캐시 미사용** |
| 읽는 필드 (매치 카드) | `matchId`/`id`, `homeTeam`/`home_team`, `awayTeam`/`away_team`, 팀 KO명·로고·`teamId`, `league`/`leagueCode`/`leagueName`/`leagueLogo`, `commence_time`/timestamp, `status`, `home_odds`/`draw_odds`/`away_odds`, `finalScoreHome`/`finalScoreAway`, `grade`, `prediction`/`confidence`/`recommendation` (premium pick 카드용) |
| 읽는 필드 (Fixture) | 위 + `apiMatchId`, `homeGoals`/`awayGoals`, `sport` |
| **무시하는 필드** | 응답 루트의 `total`, `page`, `meta` 등 페이지네이션; 매치 객체 내 파서 alias에 없는 모든 키; `LeagueInfo.country`; 중첩 `score`/`scores`/`result` 객체( flat 스코어 키 우선); Analysis 리그 화이트리스트(`analysisLeagueCodes`) 밖 리그 전체 |

#### `POST /api/predict-v2`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getMatchPrediction` |
| 소비 화면 | 축구 경기 리포트 Standard 탭 (`soccerPredictionProvider` → `parseSoccerStandardAnalysis`) |
| Body | `homeTeam`, `awayTeam`, `homeTeamId`, `awayTeamId`, `leagueId`( `leagueIdMap` 고정 매핑, 기본 39), `leagueCode`, `season` 고정 `'2025'`, `homeOdds`/`drawOdds`/`awayOdds`, `matchId`(선택), `commenceTime`(선택) |
| 타임아웃 | send/receive 20초 |
| 호출 빈도 | 리포트 Standard 탭 진입 시 1회(Provider family) |
| 읽는 필드 | `prediction.recommendation.pick`/`grade`/`reasons[]`; `finalProb.home`/`draw`/`away`; `patternStats` 승무패율·총 경기수; `homePower`/`awayPower`; `method1`~`method3`; `debug`+`homePA`/`awayPA` → 팀 스탯; 중첩 `match`/`odds` (헤더 fallback 없을 때) |
| **무시하는 필드** | `recommendation.reasoning`/`reason`/`summary` 문자열(배열 `reasons`만 사용); `prediction.pattern` 단독 필드; `prediction` 하위 파서 미참조 Map 전체; 요청에 넣은 `season` 외 응답 메타; 루트 `success`/`error` 래퍼(있어도 `_adaptToMap`만) |

#### `GET /api/h2h-enhanced`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getMatchH2H` → `soccerH2HProvider` |
| 소비 화면 | **없음 — Provider 정의만 있고 UI에서 watch/invalidate 하지 않음** |
| Query | `team1`, `team2`, `last` 기본 10 |
| **무시** | 엔드포인트 자체가 UI 미연결 → 응답 전체 미사용 |

#### `GET /api/h2h-analysis`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getMatchH2HAnalysis` → `soccerH2HAnalysisProvider` |
| 소비 화면 | 축구 경기 리포트 Premium 탭 (`SoccerPremiumParsed.fromResponse`) |
| Query | `homeTeam`, `awayTeam`, `lang` 동적 |
| 읽는 필드 | `overall.*`, `recent5.*`, `firstGoalAnalysis`/`firstGoal`, `scorePatterns.mostCommon`/`over25Rate`/`bttsRate`, `recentMatches[]`, `insights[]` |
| **무시하는 필드** | `H2HMatch.venue` (파싱 후 UI 미표시); `scorePatterns.avgHomeGoals`/`avgAwayGoals`; `recentMatches` 외 H2H 상세 이벤트; 응답 내 파서 미참조 키 전부 |

#### `GET /api/team-stats`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getTeamStats` → `homeTeamStatsProvider` / `awayTeamStatsProvider` |
| 소비 화면 | 축구 Premium 탭 팀 폼 (`TeamStatsParsed.fromResponse`) |
| Query | `team`, `league`, `teamId`, `lang` |
| 읽는 필드 | `recentForm.last10`/`last5`, `homeStats`/`awayStats`, `markets.*`, `recentMatches[]`, `strengths`/`weaknesses` |
| **무시하는 필드** | `data` 외 루트 메타; `recentMatches` 5경기 초과분; markets 키 중 UI 미매핑 항목 |

#### `POST /api/analysis`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.postMatchAnalysis` |
| 소비 화면 | **없음 — 서비스 메서드만 존재, 호출처 없음** |

#### `GET /api/premium-picks`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getPremiumPicks` → `premiumPicksProvider` |
| 소비 화면 | Premium 탭 (`PremiumPage`) |
| Query | `date` 동적 |
| 호출 빈도 | 날짜 칩 변경·pull-to-refresh |
| 읽는 필드 | `SoccerAnalysisCard` 동일 (매치+odds+prediction+grade) |
| **무시하는 필드** | pick 메타데이터(작성자, 신뢰도 상세, 근거 텍스트 전문 등) — 카드 모델에 없는 키 전부 |

#### `GET /api/premium-picks/stats`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getPremiumPickStats` → `premiumPickStatsProvider` (history 실패 시 fallback) |
| Query | `days` 기본 30 |
| 소비 화면 | Trend Premium pick 통계 카드 |
| 읽는 필드 | `stats.winRate`, `streak`, `streakType`, `total`, `recentResults[]` |
| **무시하는 필드** | history에 없는 세부 breakdown; `accuracy`/`hitRate` alias 외 통계 키 |

#### `GET /api/premium-picks/history`

| 항목 | 내용 |
|------|------|
| 래퍼 | `SoccerService.getPremiumPickHistory` + `calculateRecentStats` |
| 소비 화면 | Trend (`premiumPickStatsProvider` 우선 소스) |
| 읽는 필드 | picks: `result`/`outcome`, `commence_time`, `match`/`homeTeam`/`awayTeam`, `predicted`, `score`, `home_team_id`/`away_team_id` |
| **무시하는 필드** | `calculateRecentStats`가 WIN/LOSE 외 상태; pick별 상세 분석 텍스트; API가 주는 odds·grade·league 등 history 항목 내 미참조 키 |

---

### 1.4 백엔드 프록시 엔드포인트 (야구 — API-Baseball 유래 데이터)

#### `GET /api/baseball/matches`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getMatches` / `getMatchDetail`; `FixtureService.getBaseballFixtures`; `BaseballService.getUpcomingMatches`(미사용) |
| 소비 화면 | Analysis, Fixture(야구), 야구 리포트 헤더 |
| Query (목록) | `date` 동적, `status` 고정 `'scheduled'`(Analysis), `limit` 고정 `'50'`, `language` 동적 |
| Query (상세) | `id`, `skipML=true`, `language` |
| Query (Fixture) | `date`, `limit=50`; `includeAllStatuses` 시 status/skipML 생략; 과거일 `status=finished&skipML=true` |
| 호출 빈도 | 날짜별 lazy load(Fixture); Analysis 7일 병합; 상세 1회 |
| 읽는 필드 | `BaseballAnalysisCard`/`FixtureMatch` 필드: id, league, teams, KO명, logos, pitchers, scores, status, timestamp, `odds`, `aiPick`, `hasPitcherData`, `dbId` |
| **무시하는 필드** | `dbId`(파싱만, UI 미표시); 상세 `match` 외 루트 ML 예측 블록(`skipML=true` 요청); innings/scoreboard 상세; broadcast·venue·weather; `ouLines` 다중 라인 중 UI가 단일 `overUnderLine`만 쓰는 경우 나머지 |

#### `POST /api/baseball/predict`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getBaseballPredict` |
| 소비 화면 | 야구 Premium 탭 |
| Body | `matchId`, `homeTeam`, `awayTeam`, `quick`, `language` |
| 읽는 필드 | `predict`/`prediction`/`aiPrediction` 중첩 — grade, confidence, over/under prob 등 (`baseball_premium_parser`) |
| **무시하는 필드** | quick=true/false에 따른 상세 분석 본문; 파서 미매핑 예측 하위 키 |

#### `GET /api/baseball/h2h`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getH2H` |
| 소비 화면 | 야구 Standard 탭 H2H 섹션 |
| Query | `homeTeamId`, `awayTeamId` |
| **무시하는 필드** | 파서가 사용하지 않는 H2H 통계·경기 메타 전부 (코드: `baseball_standard_parser._parseH2HMatches`가 읽는 키 외) |

#### `POST /api/baseball/pitcher-analysis`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getPitcherAnalysis` |
| 소비 화면 | 야구 Premium 탭 AI 투수 분석 |
| Body | `matchId`, teams, pitchers, `homeStats`/`awayStats`, `league`, `language` |
| **무시하는 필드** | 응답 내 마크다운/HTML 전문 중 UI 섹션으로 매핑되지 않은 블록 |

#### `GET /api/baseball/team-stats`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getBaseballTeamStats` |
| 소비 화면 | 야구 Premium 탭 팀 시즌 성적 |
| Query | `teamId` |
| **무시하는 필드** | 시즌 splits·플레이오프·홈/원정 분리 등 파서 미사용 키 |

#### `GET /api/baseball/pitcher-stats`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getMlbPitcherStats` |
| 소비 화면 | MLB 선발 투수 카드 |
| Query | `matchId`, `homePitcherId`, `awayPitcherId`, `language` |
| **무시하는 필드** | MLB 외 리그에서 빈 응답; stat 세부 항목 중 UI 라벨 없는 항목 |

#### `GET /api/baseball/kbo-pitcher-stats`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getKboPitcherStats` |
| 소비 화면 | KBO/NPB 선발 투수 카드 |
| Query | `league`, `season` 고정 `'2026'`, pitcher/team names, `language` |
| **무시하는 필드** | 시즌·경기별 raw stat 중 merge 로직이 쓰지 않는 키 |

#### `GET /api/baseball/combo-picks`

| 항목 | 내용 |
|------|------|
| 래퍼 | `BaseballService.getBaseballComboPicks` (`days`); `BaseballComboService.getComboPicks` (`date`) |
| 소비 화면 | Premium 탭 30일 통계(`baseballComboPicksProvider`); Analysis Today Combo(`baseballComboStatsProvider`) |
| Query | `days=30` 또는 `date`+`language` |
| 읽는 필드 | combo: `total_odds`, `avg_confidence`, `status`, picks[], `league`, AI summary/sections (`combo_parser`) |
| **무시하는 필드** | combo 항목 내 개별 pick confidence 분포; settlement 메타; API 루트 집계 중 UI 미표시 필드 |

#### `GET /api/live-matches`

| 항목 | 내용 |
|------|------|
| 래퍼 | `FixtureService.getLiveMatches` |
| 소비 화면 | Fixture 축구 LIVE 폴링 |
| 호출 빈도 | 30초 `Timer.periodic`; 빈 응답 시 3초 후 1회 재시도 |
| 읽는 필드 | `matches[].id`/`fixtureId`, `status`, `statusLong`, `elapsed`, `elapsedExtra`, `homeScore`, `awayScore`, `leagueCode` |
| **무시하는 필드** | `halftimeHomeScore`/`halftimeAwayScore` (파싱·캐시만, **UI 미표시**); `statusLong` (캐시만); 이벤트 타임라인·통계·선수 정보 |

---

### 1.5 서비스 레이어에만 있고 UI 미호출

| 메서드 | 엔드포인트 |
|--------|-----------|
| `SoccerService.getMatchH2H` | `GET /api/h2h-enhanced` |
| `SoccerService.postMatchAnalysis` | `POST /api/analysis` |
| `AuthService.fetchSubscriptionByEmail` | `GET /api/subscription` |
| `BaseballService.getUpcomingMatches` | `GET /api/baseball/matches` ×7일 내부 호출이나 **Provider/화면 연결 없음** |

---

## 2. 자체 백엔드

### 2.0 Base URL

| 용도 | 소스 | 값 |
|------|------|-----|
| Mobile API (`ApiService`) | `.env` `API_BASE_URL` | `AppConfig.apiBaseUrl` |
| Web/Sports API | `.env` `WEB_API_BASE_URL` | `AppConfig.webApiBaseUrl` |
| 일부 Mobile 엔드포인트 | **하드코딩** | `https://www.trendsoccer.com` (FCM, IAP verify, `/me`, 알림, 광고) |

---

### 2.1 인증·계정 (`API_BASE_URL` + 하드코딩 혼용)

| Method | Path | Body / Query | 응답(읽는 필드) | 소비 | Auth |
|--------|------|--------------|----------------|------|------|
| POST | `/api/v1/mobile/auth/google` | `{ accessToken, deviceInfo:{platform, appVersion} }` | `session.accessToken`, `user.*` | Login | 없음 |
| POST | `/api/v1/mobile/auth/naver` | 동일 | 동일 | Login | 없음 |
| POST | `/api/auth/agree-terms` | `{ email, termsAgreed, privacyAgreed, marketingAgreed }` | `success`, `isTrial`, `message` | Signup terms | `api_client` JWT |
| GET | `/api/v1/mobile/me` | — | `data.user` 또는 `user`: tier, subscription, trial, email, name, … | Menu, Subscribe, 전역 auth | Bearer JWT |
| POST | `/api/v1/mobile/me/withdraw` | — | — | 계정 탈퇴 | Bearer |
| GET | `/api/subscription` | `email` | `status`, `expires_at` | **호출처 없음** | Bearer |
| GET | `/api/auth/csrf` | — | — | 로그아웃 플로우 | 쿠키 |
| POST | `/api/auth/signout` | — | — | 로그아웃 | — |
| POST | `/api/user/delete` | — | — | 계정 삭제 (`auth_provider`) | Bearer |

`ApiService` 응답 래퍼: `{ success, data, error }` — `success != true` 시 예외.

---

### 2.2 FCM·알림 (하드코딩 `https://www.trendsoccer.com`)

| Method | Path | Body / Query | 소비 | Auth |
|--------|------|--------------|------|------|
| POST | `/api/v1/mobile/devices` | `{ token, platform:'android', appVersion, locale }` | FCM init/token refresh | JWT 선택 |
| POST | `/api/v1/mobile/notifications/migrate` | `{ token }` | 로그인 후 | Bearer |
| DELETE | `/api/v1/mobile/devices` | `{ token }` | 로그아웃 | Bearer |
| GET | `/api/v1/mobile/notifications/match/{matchId}` | `sport` | Fixture 알람 시트 | Bearer 또는 `X-Device-Token` |
| GET | `/api/v1/mobile/notifications/matches` | `sport`, `ids`(콤마 구분) | Fixture 배치 알람 | 동일 |
| PUT | `/api/v1/mobile/notifications/match/{matchId}` | `{ sport, enabled, events{} }` | 알람 저장 | Bearer |

읽는 필드: `success`, `data.enabled`, `data.events.{kickoff,goal,…}`

---

### 2.3 결제

| Method | Path | Body | 소비 | Auth |
|--------|------|------|------|------|
| POST | `/api/v1/mobile/purchase/verify` | `{ productId, purchaseToken, platform:'android' }` | IAP 검증 | Bearer |

읽는 필드: 래퍼 `data.plan` (Analytics용); HTTP 402 `PAYMENT_PENDING`, 409 `TOKEN_ALREADY_USED`

---

### 2.4 블로그·리포트 (`WEB_API_BASE_URL`)

| Method | Path | Query | 응답(읽는 필드) | 소비 |
|--------|------|-------|----------------|------|
| GET | `/api/blog/posts` | `published=true`, `lang`, `category=preview`, `limit=20`, `offset=0` | `slug`, `title`/`title_kr`, `excerpt`/`excerpt_kr`/`excerpt_en`, `published_at`, `thumbnail_url`/`cover_image` | Match Preview 목록 |
| GET | `/api/blog/post/{slug}` | `lang` | `slug`, `title`, `content`, `published_at`, `thumbnail_url`, `tags[]` | Match Preview 상세 |
| GET | `/{locale}/privacy` | — (plain HTML) | HTML → markdown (`legal_content_parser`) | Privacy |
| GET | `/{locale}/terms` | — | 동일 | Terms |
| POST | `/api/contact` | `{ name, email, subject, message }` | `success` | Help Center |

**무시하는 필드 (블로그):** `language`(파싱만), `cover_image`(thumbnail fallback으로만), 목록 `offset` 이후 페이지(고정 `limit=20`만), 본문 외 CMS 메타(author, SEO, revision 등)

---

### 2.5 광고 (하드코딩 base)

| Method | Path | Query / Body | 읽는 필드 | 소비 |
|--------|------|--------------|-----------|------|
| GET | `/api/ads` | `slot`, `active=true` | `ads[].id`, `image_url`, `link_url` | Trend 배너 |
| POST | `/api/ads/track` | `id`, `type`(impression/click) | — | Trend |

슬롯: `mobile_app_main_top`, `mobile_app_main_bottom`, `mobile_app_main_banner`

**무시하는 필드:** 광고 title, weight, schedule, targeting 등 `id`/`image_url`/`link_url` 외 전부

---

## 3. Supabase

| 항목 | 내용 |
|------|------|
| 초기화 | `Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY)` — `.env` |
| 테이블 / View / RPC | **코드에서 참조 없음** — `.from()`, `.rpc()` 호출 없음 |
| 사용 범위 | `Supabase.instance.client.auth.currentSession` (JWT 읽기), `auth.signOut()` |
| 읽는 컬럼 | Auth session: `accessToken` (및 만료 메타) |
| 쓰는 컬럼 | **없음** (DB write 없음) |
| RLS 가정 | **코드에서 확인 불가** (DB 미사용) |
| Realtime | **없음** |

실제 로그인·프로필·구독 상태는 자체 Mobile API + JWT(`TokenService` / `auth_jwt` prefs)가 담당.

---

## 4. Firebase

### 4.1 Remote Config

| Key | Type | Default (앱 코드) | 읽는 위치 |
|-----|------|-------------------|-----------|
| `min_supported_version` | String | **코드에서 setDefaults 없음** → 미설정 시 빈 문자열 | `AppConfigService` → Splash 강제 업데이트 |
| `latest_version` | String | 동일 | `AppConfigService` (읽기만, 강제 업데이트 로직은 `min_supported_version`만 사용) |
| `force_update` | Bool | 동일 → `false` | `AppConfigService` (**Splash에서 미사용**) |
| `update_message` | String | 동일 | `ForceUpdatePage` (optional) |
| `maintenance_mode` | Bool | 동일 | Splash → `/maintenance` |
| `maintenance_message` | String | 동일 | `MaintenancePage` |
| `announcement_ko` | String (JSON) | 동일 | `AnnouncementService` |
| `announcement_en` | String (JSON) | 동일 | 동일 |

JSON 필드 (`announcement_*`): `enabled`, `id`, `title`, `message`, `buttonText`, `url`/`actionUrl`

공통 설정: `fetchTimeout` 5초, `minimumFetchInterval` 1시간

---

### 4.2 FCM

| 항목 | 내용 |
|------|------|
| 구독 토픽 (base) | `app_general`, `match_events`, `marketing` |
| Locale suffix | `app_general_ko` / `_en` 등 (`topicWithLocale`) |
| Legacy unsubscribe | locale 없는 base 토픽 3개 |
| Payload 처리 | `data.type`: `match_event` → `sport` soccer/baseball → `/fixture?sport=&filter=live`; `topic` → 무시 |
| Notification 표시 | `notification.title`/`body`; `data.teamLogo` URL → large icon 다운로드 |
| 기타 data 키 | **명시적 처리 없음** (deep link 외 무시) |

---

### 4.3 Analytics

| 이벤트 | 파라미터 | 호출 위치 |
|--------|----------|-----------|
| `sign_up` | `sign_up_method` (Google/Naver) | `AnalyticsService.logSignUp` — agree-terms 성공 후 |
| `purchase` | `currency: KRW`, `value` 4900/9900, `items[]` (itemName premium, itemCategory monthly/quarterly) | IAP verify 성공 후 |
| Screen views | route `name` | `FirebaseAnalyticsObserver` (GoRouter) — 파라미터 **코드에서 확인 불가** |

커스텀 `logEvent` 호출 **없음**.

---

## 5. Google Play IAP / AdMob

### 5.1 IAP

| 항목 | 값 |
|------|-----|
| Product ID | `premium` |
| Base plan ID | `monthly-plan`, `quarterly-plan` |
| Query | `InAppPurchase.queryProductDetails({'premium'})` |
| 검증 | `POST https://www.trendsoccer.com/api/v1/mobile/purchase/verify` |

### 5.2 AdMob

| Placement | Ad unit ID (`_useTestAds=false`) |
|-----------|-----------------------------------|
| Trend 하단 배너 | `ca-app-pub-7853814871438044/5988937231` |
| Analysis 배너 | `ca-app-pub-7853814871438044/9736610556` |
| Fixture 배너 | `ca-app-pub-7853814871438044/9648980645` |
| 테스트 모드 | `ca-app-pub-3940256099942544/6300978111` (`_useTestAds=true` 시 전부) |

표시 조건: `!auth.hasFullAccess` (`PremiumAdWrapper`)

---

## 6. 데이터 갭 분석

앱이 이미 수신·파싱 가능하나 UI에 표시되지 않거나, 엔드포인트가 연결되지 않은 항목.

| Source | Field / Endpoint | 내용 | 제안 화면 |
|--------|----------------|------|-----------|
| `GET /api/h2h-enhanced` | (전체) | 향상된 H2H 통계 — Provider만 존재 | 축구 Standard/Premium H2H |
| `POST /api/analysis` | (전체) | AI 경기 분석 본문 | 축구 리포트 Standard |
| `GET /api/subscription` | `status`, `expires_at` | 이메일 기준 구독 조회 | Subscribe 결제 폴링 |
| `BaseballService.getUpcomingMatches` | 7일 병합 목록 | Analysis용 경기 프리페치 | Analysis 야구 탭 |
| `/api/v1/mobile/me` | `avatarUrl` | 프로필 이미지 | Menu `ProfileCard` |
| `/api/v1/mobile/me` | `createdAt` | 가입일 | Menu About/프로필 |
| `/api/v1/mobile/me` → `subscription` | `nextBillingDate`, `cancelledAt` | 다음 결제·해지 예정 | Subscribe / Menu PlanTicket |
| `LiveMatchData` | `halftimeHomeScore`, `halftimeAwayScore` | 하프타임 스코어 | Fixture 라이브 행 |
| `LiveMatchData` | `statusLong` | 상태 장문(예: "Second Half") | Fixture 상태 텍스트 |
| `FixtureMatch` | `leagueNameEn` | 리그 영문명 | Fixture EN locale |
| `BlogPostDetail` | `language` | 게시물 언어 | Preview 목록 배지 |
| `BlogPostListItem` | `language` | 동일 | 목록 |
| `GET /api/blog/posts` | `offset>0` 페이지 | 20건 이후 글 | Preview 목록 infinite scroll |
| `GET /api/ads` | title, 기타 메타 | 광고 제목·스케줄 | Trend 배너 accessibility |
| `predict-v2` | `recommendation.reasoning` (string) | 단일 요약 문장 | Standard reasoning (현재 `reasons[]`만) |
| `h2h-analysis` | `H2HMatch.venue` | 경기장 | Premium 최근 H2H |
| `h2h-analysis` | `scorePatterns.avgHomeGoals`, `avgAwayGoals` | 평균 득점 | Premium score patterns |
| `team-stats` | `strengths[]`, `weaknesses[]` | 팀 강약점 문장 | Premium 팀 탭 |
| `team-stats` | `recentMatches` 6~10번째 | 추가 폼 | Premium 폼 확장 |
| `premium-picks/history` | pick별 `score`, 미정산 상태 | 상세 결과 | Premium 히스토리 탭 |
| `premium-picks/stats` | API 원본 (history 없을 때) | 서버 집계 전체 | Trend stats 카드 보강 |
| `odds-from-db` | `LeagueInfo.country` | 리그 국가 | Analysis 리그 칩 툴팁 |
| `baseball/matches` | `dbId` | 레거시 DB id | 디버그/지원용 |
| `baseball/matches` | `ouLines[]` 다중 라인 | OU 여러 라인 | 야구 odds 섹션 |
| `baseball/predict` | `quick=false` 상세 블록 | 전체 AI 분석 | Premium 탭 |
| `MLB stat` Map | 미표시 stat 키 (WHIP, K/9 등) | 시즌 상세 | 선발 투수 카드 |
| `Remote Config` | `latest_version`, `force_update` | 최신 버전·강제 플래그 | Splash soft update |
| `FCM data` | `match_event` 외 payload | 커스텀 딥링크 | 해당 화면 라우팅 |
| `FirebaseAnalyticsObserver` | screen parameters | 화면별 상세 | 내부 분석 (UI 아님) |

---

## 7. 알려진 제약

### 7.1 코드·주석 (데이터 레이어)

| 위치 | 내용 |
|------|------|
| `soccer_service.dart` | TODO: `/api/odds-from-db` → `/api/v1/mobile/soccer/matches` 교체 예정 |
| `soccer_service.dart` | TODO: premium-picks → `/api/v1/mobile/soccer/premium-picks` |
| `soccer_service.dart` | TODO: premium-picks/stats → `/api/v1/mobile/soccer/premium-picks/stats` |
| `error_resolver.dart` | API 오류 `RATE_LIMITED` → `errorRateLimited` UI 문자열 |
| `soccer_provider.dart` | Analysis 빈 결과 30분간 재요청 스킵 |
| `fixture_page.dart` | 축구 live poll 30초; finished cache TTL 5분 |
| `SoccerService._responseCache` | 5분 TTL — Fixture/다른 호출자와 공유 안 됨 |

### 7.2 `TrendSoccer_Development_Status.md` 기록 (백엔드·데이터 품질)

| 이슈 | 상세 |
|------|------|
| 야구 연장전 | 9회 이후 이닝·종료 스코어 불일치 사례 |
| NPB 실시간 지연 | 경쟁앱 대비 2이닝+ 지연 (API-Baseball 갱신 주기) |
| 야구 PPD | 연기 상태 전환 지연 |
| 축구 PK 실축 | missed penalty 골 알림 오발 |
| 축구 VAR 골 취소 | 취소 알림·스코어 미반영 |
| VAR 후 스코어 | 취소 골 포함 스코어로 후속 알림 |

### 7.3 기타

| 항목 | 내용 |
|------|------|
| API-Football/Baseball 플랜 한도 | **코드에서 확인 불가** |
| Supabase DB 스키마 | 앱 미사용 — **코드에서 확인 불가** |
| Remote Config in-app default | `setDefaults` 없음 — 오프라인·미설정 시 빈 문자열/`false` |
| `force_update` RC 키 | fetch되나 Splash 분기 미사용 |
| Blog pagination | `limit=20`, `offset=0` 고정 — 추가 로드 UI 없음 |
| Wide markdown tables | Match Preview — 가로 스크롤 미구현 (오버플로우 가능) |

---

*문서 생성: 코드 정적 분석 (`lib/core/services/*`, `lib/core/providers/*`, `lib/features/*`, `lib/core/models/*`)*
