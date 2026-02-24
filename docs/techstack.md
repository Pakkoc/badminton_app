# 기술 스택 (Tech Stack)

## 개요

거트알림은 Flutter 기반 iOS/Android 크로스 플랫폼 모바일 앱이다. 백엔드는 Supabase(BaaS)로 구성하며, 별도 서버 없이 Supabase의 DB, Auth, Realtime, Edge Function, Storage를 활용한다.

---

## 기술 스택 요약

| 계층 | 기술 | 버전 | 선택 이유 |
|------|------|------|----------|
| 프론트엔드 | Flutter | 3.27.x (stable) | iOS/Android 단일 코드베이스, Material 3 지원 |
| 프로그래밍 언어 | Dart | 3.6.x | Flutter 기본 언어 |
| BaaS / DB | Supabase (PostgreSQL) | 최신 stable | Auth, Realtime, Edge Function, Storage 통합 제공 |
| 인증 | Supabase Auth | - | 소셜 로그인 4종(카카오, 네이버, Google, Apple) 지원 |
| 상태 관리 | Riverpod | 2.6.x | 컴파일 타임 안전성, Supabase와 궁합 좋음, 커뮤니티 주류 |
| 네비게이션 | go_router | 14.x | Flutter 공식팀 유지보수, 딥링크/가드 지원 |
| 실시간 통신 | Supabase Realtime | - | DB 변경 시 클라이언트에 즉시 전달 (작업 상태 실시간 반영) |
| 푸시 알림 | Firebase Cloud Messaging (FCM) | - | 앱 미실행 시에도 푸시 알림 전송 |
| 알림 트리거 | Supabase Edge Function (Deno) | - | DB 트리거 → FCM 호출, 서버리스로 유지보수 최소화 |
| 지도 | Naver Map API + Flutter 플러그인 | - | 국내 지도 정확도, 주변 샵 검색, 길찾기 연동 |
| 파일 저장소 | Supabase Storage | - | 이미지 업로드 (재고, 게시글, 프로필) |
| 로컬 저장소 | Supabase 캐시 (supabase_flutter) | - | 토큰/세션 관리는 Supabase 클라이언트가 자동 처리 |
| 테스트 | flutter_test + mocktail | - | 단위/위젯 테스트. TDD 기반 개발 |
| 통합 테스트 | integration_test | - | E2E 테스트 |
| CI/CD | GitHub Actions | - | 자동 빌드, 테스트, 배포 파이프라인 |
| 배포 | App Store + Google Play | - | iOS + Android 배포 (웹 제외) |

---

## 상세 설명

### 프론트엔드: Flutter

- **기술**: Flutter 3.27.x (stable)
- **역할**: iOS/Android 크로스 플랫폼 앱 UI 전체
- **선택 이유**: 단일 코드베이스로 두 플랫폼 동시 지원, Material 3 디자인 시스템 네이티브 지원, Supabase 공식 Flutter SDK 제공
- **대안 고려**: React Native — Supabase 연동은 동일하나 Material 3 지원이 Flutter보다 약함

### BaaS / 데이터베이스: Supabase

- **기술**: Supabase (PostgreSQL 15+)
- **역할**: 데이터베이스, 인증, 실시간 통신, 서버리스 함수, 파일 저장소
- **선택 이유**: PostgreSQL 기반으로 RLS(Row Level Security)를 통한 세밀한 권한 제어 가능, Edge Function으로 별도 백엔드 서버 불필요, Realtime으로 실시간 상태 반영
- **대안 고려**: Firebase — NoSQL 기반이라 관계형 데이터(샵-회원-작업) 모델링에 불리, RLS 같은 세밀한 권한 제어 어려움

### 인증: Supabase Auth + 소셜 로그인 4종

- **기술**: Supabase Auth
- **역할**: 회원가입, 로그인, 세션 관리
- **소셜 로그인 공급자**:
  - **카카오** — 국내 최대 사용자 기반
  - **네이버** — 국내 주요 소셜 로그인
  - **Google** — Android 사용자 기본 계정
  - **Apple** — App Store 정책 필수 (제3자 소셜 로그인 제공 시 Apple Sign In 필수)
- **선택 이유**: Supabase Auth가 OAuth 2.0 기반 소셜 로그인을 통합 관리, 커스텀 OIDC로 카카오/네이버 연동 가능

### 상태 관리: Riverpod

- **기술**: Riverpod 2.6.x (flutter_riverpod + riverpod_annotation)
- **역할**: 앱 전역 상태 관리 (인증 상태, 작업 목록, 폼 상태 등)
- **선택 이유**: 컴파일 타임 안전성, Provider 대비 테스트 용이, Supabase 스트림과 자연스러운 연동, code generation으로 보일러플레이트 최소화
- **대안 고려**: Bloc — 엔터프라이즈급이지만 이 규모에서는 과잉 설계, 보일러플레이트가 많음

### 네비게이션: go_router

- **기술**: go_router 14.x
- **역할**: 화면 라우팅, 딥링크, 인증 가드
- **선택 이유**: Flutter 공식팀(flutter.dev) 유지보수, 선언적 라우팅, 인증 상태에 따른 리다이렉트(가드) 기본 지원, QR 코드 딥링크 처리 용이
- **대안 고려**: auto_route — 코드 생성 기반으로 타입 안전하지만 추가 빌드 스텝 필요

### 실시간 통신: Supabase Realtime

- **기술**: Supabase Realtime (supabase_flutter 내장)
- **역할**: 사장님이 작업 상태 변경 시 고객 앱에 즉시 반영
- **동작 방식**: Flutter 앱이 특정 테이블의 변경을 구독(subscribe) → DB 변경 발생 시 WebSocket으로 즉시 전달
- **선택 이유**: Supabase 내장 기능이라 별도 설정 불필요, PostgreSQL 변경 감지 기반으로 신뢰성 높음

### 푸시 알림: FCM + Supabase Edge Function

- **기술**: Firebase Cloud Messaging (FCM) + Supabase Edge Function (Deno/TypeScript)
- **역할**: 앱이 꺼져 있을 때도 작업 상태 변경 알림 전송
- **동작 방식**:
  ```
  사장님 상태 변경 → DB UPDATE → Database Trigger → Edge Function 호출 → FCM API 호출 → 고객 디바이스에 푸시 전송
  ```
- **선택 이유**: FCM은 iOS/Android 모두 지원하는 무료 푸시 서비스, Edge Function은 서버리스라 유지보수 최소화

### 지도: Naver Map API

- **기술**: Naver Map API + flutter_naver_map 플러그인
- **역할**: 주변 샵 검색 (지도 마커), 샵 위치 표시, 길찾기 연동, 주소→좌표 변환(Geocoding)
- **선택 이유**: 국내 지도 정확도 최고 (건물명, 도로명 등), 국내 사용자에게 익숙한 UX
- **대안 고려**: Google Maps — 해외 지도 정확도는 높지만 국내 상세 정보(건물명 등)에서 네이버에 열세

### 파일 저장소: Supabase Storage

- **기술**: Supabase Storage
- **역할**: 이미지 업로드 및 관리 (재고 상품 이미지, 게시글 이미지, 프로필 이미지)
- **선택 이유**: Supabase 통합 환경, RLS 기반 접근 제어, CDN 제공

### 테스트

- **단위/위젯 테스트**: flutter_test + mocktail
- **통합 테스트**: integration_test 패키지
- **테스트 비율**: Unit 70% / Widget 20% / Integration 10% (테스트 피라미드)
- **방법론**: TDD (Red → Green → Refactor)

### CI/CD: GitHub Actions

- **기술**: GitHub Actions
- **역할**: PR 시 자동 테스트, main 머지 시 빌드, 스토어 배포 자동화
- **선택 이유**: GitHub 기반 개발 환경과 자연스러운 통합, 무료 사용 가능

---

## 외부 서비스 연동

| 서비스 | 용도 | API 키 필요 |
|--------|------|------------|
| Supabase | DB, Auth, Realtime, Storage, Edge Function | ✅ (Project URL + Anon Key) |
| Firebase | FCM 푸시 알림 | ✅ (google-services.json / GoogleService-Info.plist) |
| Naver Map | 지도 표시, Geocoding, 길찾기 | ✅ (Client ID + Secret) |
| Kakao | 소셜 로그인 | ✅ (REST API Key) |
| Naver Login | 소셜 로그인 | ✅ (Client ID + Secret) |
| Google | 소셜 로그인 | ✅ (OAuth 2.0 Client ID) |
| Apple | 소셜 로그인 | ✅ (Service ID + Key) |

---

## 개발 환경

| 도구 | 버전/설정 |
|------|----------|
| Flutter SDK | 3.27.x (stable) |
| Dart SDK | 3.6.x |
| IDE | VS Code + Flutter/Dart 확장 또는 Android Studio |
| Supabase CLI | 최신 stable (로컬 개발 환경) |
| Node.js | 18+ (Supabase Edge Function 로컬 테스트) |
| Git | 2.x |

---

## 주요 Flutter 패키지

| 패키지 | 용도 |
|--------|------|
| supabase_flutter | Supabase 클라이언트 (DB, Auth, Realtime, Storage 통합) |
| flutter_riverpod + riverpod_annotation | 상태 관리 |
| riverpod_generator | Riverpod 코드 생성 |
| go_router | 네비게이션/라우팅 |
| flutter_naver_map | 네이버 지도 표시 |
| firebase_messaging | FCM 푸시 알림 |
| firebase_core | Firebase 초기화 |
| kakao_flutter_sdk | 카카오 로그인 |
| flutter_naver_login | 네이버 로그인 |
| sign_in_with_apple | Apple 로그인 |
| google_sign_in | Google 로그인 |
| image_picker | 이미지 선택 (카메라/갤러리) |
| cached_network_image | 이미지 캐싱 |
| qr_flutter | QR 코드 생성 |
| mobile_scanner | QR 코드 스캔 |
| json_annotation + json_serializable | JSON 직렬화 |
| build_runner | 코드 생성 실행 |
| freezed + freezed_annotation | 불변 데이터 클래스 생성 |
| flutter_test | 단위/위젯 테스트 |
| mocktail | Mock 객체 생성 |
| integration_test | 통합 테스트 |

---

## 아키텍처 개요

```
┌─────────────────────────────────────────┐
│              Flutter App                │
│  ┌───────────┐  ┌──────────┐  ┌──────┐ │
│  │ UI Layer  │  │ Riverpod │  │Router│ │
│  │ (Widgets) │←→│ (State)  │  │(GoR) │ │
│  └───────────┘  └────┬─────┘  └──────┘ │
│                      │                  │
│              ┌───────┴────────┐         │
│              │ Repository Layer│         │
│              └───────┬────────┘         │
└──────────────────────┼──────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │         Supabase            │
        │  ┌────┐ ┌────┐ ┌────────┐  │
        │  │ DB │ │Auth│ │Realtime│  │
        │  └──┬─┘ └────┘ └────────┘  │
        │     │                       │
        │  ┌──┴──────────┐ ┌───────┐ │
        │  │Edge Function│ │Storage│ │
        │  └──────┬──────┘ └───────┘ │
        └─────────┼───────────────────┘
                  │
            ┌─────┴─────┐
            │    FCM     │
            │(Push 알림) │
            └───────────┘
```

- **UI Layer**: Flutter 위젯, Material 3 디자인 시스템
- **State Layer**: Riverpod으로 상태 관리, Supabase Realtime 구독
- **Repository Layer**: Supabase 클라이언트를 통한 데이터 접근 추상화
- **Supabase**: DB, Auth, Realtime, Storage, Edge Function 통합 백엔드
- **FCM**: Edge Function에서 호출하여 푸시 알림 전송
