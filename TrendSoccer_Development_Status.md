# TrendSoccer v2 개발 현황 (Development Status)

> 최종 업데이트: 2026-06-23
> 버전: v10
> 상태: 릴리즈 준비 완료 — 백엔드 QA 6건 대기 중
> 진행도: ~99%

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 서비스명 | TrendSoccer |
| 플랫폼 | Flutter (Android v1) |
| 개발 방식 | 바이브 코딩 (Claude + Cursor Agent + Figma MCP) |
| 디자인 | 다크/라이트 모드, Android Compact 412x917 |
| 폰트 | Poppins + Pretendard (fontFamilyFallback) |
| Design System | v2.2 (3-Tier: Primitives + Theme + Language) |
| 코드 규모 | ~225 Dart 파일, ~43,500줄 |

---

## 완료 작업 요약

### UI / 레이아웃
- 전체 페이지 리라이트 (Auth, Trend, Analysis, Fixture, Premium, Menu)
- SliverAppBar (floating logo + pinned date tabs)
- 스포츠 토글/필터칩/LIVE 필터칩, 리그 아이콘 활성 테마 스왑
- 트렌드 탭 섹션 순서 Figma 매칭
- PlanTicket 구독 날짜 표시, Trial 카운트다운 CTA
- 리포트 카드 16:9 썸네일 + shimmer 스켈레톤 로딩

### 디자인 시스템
- Brand Primary: Mint (#1ECE8E), neutral 배경, Surface 위계 반전
- 하드코딩 Color → 토큰 (37개), spacing → TsSpacing (400개)
- SnackBar → TsToast 통일, 인라인 TextStyle → TsType
- dart analyze 0 issues, empty_catches 19개 코멘트 완료

### 백엔드 연동
- 축구/야구 전체 API, 블로그, 광고, 문의하기
- API 데이터 locale 분기 (ko/en)

### 인증 / 결제
- Google/Naver OAuth, Google Play IAP, Firebase Analytics, Trial 48h

### FCM 알림
- 토픽 locale, 배치 조회, secondHalf 이벤트
- 비로그인 알림 (X-Device-Token), 알림 설정 페이지
- 글로벌 이벤트 → 벨 ON 시 PUT 반영, resync 로직

### i18n
- 200+ ARB 키, 에러 리졸버, 날짜 포맷, FCM locale 등록

### 광고
- AdMob 배너 3개 탭 (프로덕션 ID, _useTestAds=false)
- 직광고 배너 (API: mobile_app_main_banner, 380x120)
- 프리미엄/Trial 사용자 광고 숨김, app-ads.txt 배포

### Fixture
- 야구 lazy load, 축구 라이브 캐시 보존, FT 영구 반영
- 추가시간 (elapsedExtra: 90+3'), 서스펜드/연기 (POST/INTR/PP → PPD)
- 야구 리그 순서 (MLB→NPB→KBO→CPBL)
- 라이브 스코어 변경 시 매치 행 blink 효과

### UX
- Pull-to-refresh 4개 탭
- 뒤로가기 종료 다이얼로그 (per-tab PopScope)
- 오프라인 오버레이 (connectivity_plus, 3초 debounce)
- 앱 버전 동적 (PackageInfo)
- 분석 카드 InkWell ripple, FT 스코어 승리팀 bold

### 신규 기능
- Firebase Remote Config 공지사항 (ko/en 분기, id별 dismiss)
- In-App Review (5회 실행 + 30일 간격)

### 성능 최적화
- lazy load, API 캐시, 폰트 트림 (-6.5MB)
- debugPrint 전체 제거 (411개), 미사용 파일 삭제 (5개)

---

## 백엔드 전달 대기 (6건)

| # | 이슈 | 상세 |
|---|------|------|
| 1 | 야구 연장전 이닝/스코어 | 9회에서 이닝 추적 멈춤, 종료 스코어 불일치 (라쿠텐-세이부 12회 8-7 → 알림 6-6) |
| 2 | 축구 PK 실축 골 알림 | missed penalty 시 골 알림 차단 필요 (Messi PK 실축 → "PK 골!" 발송) |
| 3 | NPB 실시간 데이터 지연 | 경쟁앱 대비 2이닝+ 차이, API-Baseball 갱신 주기 확인 |
| 4 | 야구 PPD 전환 지연 | API status 변경 반영 타이밍 확인 |
| 5 | 축구 VAR 골 취소 알림 미처리 | 골 취소 시 알림 미발송 + 스코어 미수정 |
| 6 | VAR 취소 후 스코어 불일치 | 취소된 골 포함된 스코어로 후속 알림 발송 (3-0인데 3-1로) |

---

## 실데이터 QA 대기 (3건)

| # | 항목 | 조건 |
|---|------|------|
| 1 | 알림 resync 검증 | 다음 라이브 경기 |
| 2 | 라이브 스코어 점멸 효과 | 다음 라이브 경기 |
| 3 | 축구 리그 섹션 순서 | 정규 리그 재개 후 |

---

## 실데이터 QA 완료

| 항목 | 상태 |
|------|------|
| 하프타임 알림 | ✅ |
| secondHalf 알림 | ✅ |
| 교체 알림 OFF | ✅ |
| PPD 표시 | ✅ |
| FCM locale | ✅ |
| 축구 FT 전환 | ✅ |

---

## 릴리즈 전 남은 작업

| # | 항목 | 비고 |
|---|------|------|
| 1 | pubspec version → 1.0.0+1 | 릴리즈 시 |
| 2 | Release AAB 빌드 | 다음 주 |
| 3 | Play Store 등록정보 | 다음 주 |

---

## 환경 정보

| 항목 | 값 |
|------|-----|
| Supabase | https://riqvjiiwjyynvhuynisv.supabase.co |
| API | https://www.trendsoccer.com |
| Figma | b7nJDvmcQAZmwn6UM7xfti |
| AdMob App ID | ca-app-pub-7853814871438044~8929624483 |
| AdMob trend | ca-app-pub-7853814871438044/5988937231 |
| AdMob analysis | ca-app-pub-7853814871438044/9736610556 |
| AdMob fixture | ca-app-pub-7853814871438044/9648980645 |
| Keystore | D:\TrendSoccer\android\upload-keystore.jks |

---

## 코드 품질

| 항목 | 상태 |
|------|------|
| dart analyze | 0 issues |
| debugPrint | 0개 |
| 하드코딩 Color/Spacing | 0개 |
| Remote Config | minimumFetchInterval: 1시간 |
| AdMob | _useTestAds = false |

---

## 참고 문서

- 기획서: TrendSoccer_앱기획서_v2_2.md
- Design System: TrendSoccer_Design_System_v2_2.md
- Design Session: TrendSoccer_Design_Session_v2_2.md
- Figma: https://www.figma.com/design/b7nJDvmcQAZmwn6UM7xfti/TrendSoccer
- Git: https://github.com/tri-kkk/TrendSoccer.git

---

*TrendSoccer v2 — ~99% 완성 / 앱 코드 릴리즈 준비 완료, 백엔드 QA 6건 대기*
