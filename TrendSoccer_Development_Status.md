# TrendSoccer v2 개발 현황 (Development Status)

> 최종 업데이트: 2026-06-18
> 버전: v9
> 상태: 릴리즈 준비 완료 — Play Store 업로드 대기
> Git: https://github.com/tri-kkk/TrendSoccer.git
> Figma: https://www.figma.com/design/b7nJDvmcQAZmwn6UM7xfti/TrendSoccer
> 로컬 경로: D:\TrendSoccer

---

## 📱 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 서비스명 | TrendSoccer |
| 플랫폼 | Flutter (Android v1) |
| 개발 방식 | 바이브 코딩 (Claude + Cursor Agent + Figma MCP) |
| 디자인 | 다크/라이트 모드, Android Compact 412×917 |
| 폰트 | Poppins (영문/숫자) + Pretendard (한글, fontFamilyFallback) |
| Design System | v2.2 (3-Tier Variable: Primitives + Theme + Language) |
| 기획서 | v2.2 |
| 코드 규모 | 225 Dart 파일, ~43,500줄 |

---

## ✅ 전체 완료 작업

### UI / 레이아웃
- 전체 페이지 리라이트 (Auth, Trend, Analysis, Fixture, Premium, Menu)
- Analysis + Fixture: SliverAppBar (floating logo + pinned date tabs)
- 날짜 탭 언더바 (Analysis fillWidth, Fixture scrollable 80px)
- 스포츠 토글 textPrimary 컬러
- 필터칩 active textPrimary
- LIVE 필터칩 (배타적 선택, error 컬러)
- 로그인 리디자인 (경기장 BG + 바텀시트)
- 메뉴 AppBar 제거 + SafeArea
- 트렌드 탭 섹션 순서 Figma 매칭
- 트렌드 블러카드 (시즌 오프)
- 블로그 예측 블러 (Free)
- PlanTicket 구독 날짜 표시
- Trial 카운트다운 CTA
- 알림 토스트 (벨 ON/OFF)

### 디자인 시스템
- Brand Primary: Green → Mint (#1ECE8E)
- Canvas/OnCanvas: 그린 틴트 제거 → 순수 neutral
- Neutral: 웜 → 쿨 neutral
- Surface 위계 반전 (Base=카드, Raised=페이지)
- Interactive Surface/SurfaceStrong/Divider 토큰 추가
- 하드코딩 Color(0x) → 토큰 교체 (37개 → 0개)
- 하드코딩 spacing → TsSpacing 교체 (400개 → 0개)
- 리그 아이콘 활성 칩 테마 스왑

### 백엔드 API 연동
- 축구 API (분석, Fixture, 라이브, 프리미엄 픽, 매치 리포트)
- 야구 API (분석, Fixture, 매치 리포트, 콤보 픽)
- 블로그, 문의하기, 광고 API
- API 데이터 locale 분기 (ko/en)

### 인증 / 결제
- Google/Naver OAuth
- Google Play IAP (월간/분기 premium)
- Firebase Analytics (sign_up + purchase)
- Trial 48h 자동 부여

### FCM 알림
- 토픽 locale 접미사 (ko/en)
- 딥링크 → Fixture LIVE
- 배치 알림 조회 API
- secondHalf 이벤트
- 커스텀 알림 아이콘 + largeIcon
- 비로그인 알림 (X-Device-Token)
- 알림 설정 페이지 (일반 2 + 축구 8 + 야구 5 이벤트)
- 글로벌 이벤트 → 벨 ON 시 PUT 반영
- 알림 resync (Fixture 진입 시 서버 동기화)

### i18n
- 200+ ARB 키 (ko/en)
- 에러 코드 리졸버
- 날짜 포맷 locale 분기
- FCM 디바이스 locale 등록

### 광고
- Google AdMob 배너 (Trend/Analysis/Fixture)
- 직광고 배너 (Trend 축구-야구 사이, API: mobile_app_main_banner)
- 프리미엄/Trial 사용자 광고 숨김
- app-ads.txt 배포 완료

### Fixture
- 야구 30초 폴링 + lazy load (선택 날짜 + 인접 프리로드)
- 축구 라이브 retry + 상태 캐시 보존 + FT 영구 반영
- 하프타임 HT 표시
- 추가시간 표시 (elapsedExtra: 90+3')
- 서스펜드/연기 경기 표시 (POST/INTR)
- 취소/연기 핸들링 (CANC/ABD)
- 야구 리그 순서 (MLB→NPB→KBO→CPBL)
- WC 커스텀 아이콘

### 성능 최적화
- 야구 Fixture lazy load (7일 동시 → 선택 날짜만)
- 축구 시즌 오프 API 스킵 (30분 캐시)
- 축구 API 응답 캐시 (5분 TTL)
- 500ms blink 타이머 → AnimationController
- 폰트 트림 400-800 (−6.5MB)
- 미사용 패키지 제거 (webview_flutter, cupertino_icons)
- fixture_page 위젯 분리 (4개 서브위젯)
- debugPrint 전체 제거 (411개)
- 미사용 파일 삭제 (5개 + 빈 폴더 2개)

---

## 📊 진행도
전체 프로젝트 진행도: ████████████████████ ~98%

---

## 🟡 QA 대기 (실데이터 필요)

| # | 항목 | 조건 |
|---|------|------|
| 1 | 알림 resync 검증 | 다음 라이브 경기 |
| 2 | secondHalf 알림 수신 | 다음 WC 경기 |
| 3 | 축구 FT 30분 보존 | 다음 WC 경기 |
| 4 | POST/INTR 표시 | 다음 서스펜드 발생 시 |
| 5 | 축구 분석 영문 | 정규 리그 재개 후 |

---

## 🟢 릴리즈 전 조치

| # | 항목 | 상태 |
|---|------|------|
| 1 | pubspec version → 1.0.0+1 | 릴리즈 시 변경 |
| 2 | upload-keystore.jks 존재 확인 | 로컬 확인 필요 |
| 3 | Release AAB 빌드 | 다음 주 진행 |
| 4 | Play Store 등록정보 | 다음 주 진행 |

---

## 🔑 환경 정보
SUPABASE_URL=https://riqvjiiwjyynvhuynisv.supabase.co

API_BASE_URL=https://www.trendsoccer.com

Figma file key: b7nJDvmcQAZmwn6UM7xfti

AdMob App ID: ca-app-pub-7853814871438044~8929624483

AdMob Ad Units:

trend_bottom: ca-app-pub-7853814871438044/5988937231

analysis_bottom: ca-app-pub-7853814871438044/9736610556

fixture_bottom: ca-app-pub-7853814871438044/9648980645

Keystore: D:\TrendSoccer\android\upload-keystore.jks

---

## 🔧 빌드

```powershell
# 개발
flutter run

# 릴리즈 APK
flutter clean && flutter pub get && flutter build apk --release

# 릴리즈 AAB (Play Store)
flutter clean && flutter pub get && flutter build appbundle --release
```

---

## 📝 참고 문서

- **기획서:** TrendSoccer_앱기획서_v2_2.md
- **Design System:** TrendSoccer_Design_System_v2_2.md
- **Design Session:** TrendSoccer_Design_Session_v2_2.md
- **Figma:** https://www.figma.com/design/b7nJDvmcQAZmwn6UM7xfti/TrendSoccer
- **Git:** https://github.com/tri-kkk/TrendSoccer.git

---

*TrendSoccer v2 — ~98% 완성 / 릴리즈 준비 완료 → Play Store 업로드 대기*
