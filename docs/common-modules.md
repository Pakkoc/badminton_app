# 공통 모듈 설계

> 이 문서가 완성되기 전에 화면별 구현을 시작하지 않는다.

## 디렉토리 구조

```
lib/
├── main.dart                          # 앱 진입점
├── app/
│   ├── app.dart                       # MaterialApp 위젯
│   ├── router.dart                    # [M2] 라우터
│   └── theme.dart                     # Material 3 테마
├── core/
│   ├── config/
│   │   └── env.dart                   # [M1] 환경 변수
│   ├── error/
│   │   ├── app_exception.dart         # [M6] 에러 클래스
│   │   └── error_handler.dart         # [M6] 에러 핸들러
│   ├── utils/
│   │   ├── validators.dart            # [M10] 유효성 검증
│   │   └── formatters.dart            # [M11] 포맷 유틸리티
│   └── constants/
│       └── app_constants.dart         # 앱 상수
├── models/
│   ├── user.dart                      # [M4] User 모델
│   ├── shop.dart                      # [M4] Shop 모델
│   ├── member.dart                    # [M4] Member 모델
│   ├── order.dart                     # [M4] Order 모델
│   ├── post.dart                      # [M4] Post 모델
│   ├── inventory_item.dart            # [M4] InventoryItem 모델
│   ├── notification_item.dart         # [M4] NotificationItem 모델
│   └── enums.dart                     # [M4] 공통 Enum
├── repositories/
│   ├── auth_repository.dart           # [M3] 인증 리포지토리
│   ├── user_repository.dart           # [M5] User CRUD
│   ├── shop_repository.dart           # [M5] Shop CRUD
│   ├── member_repository.dart         # [M5] Member CRUD
│   ├── order_repository.dart          # [M5] Order CRUD
│   ├── post_repository.dart           # [M5] Post CRUD
│   ├── inventory_repository.dart      # [M5] Inventory CRUD
│   ├── notification_repository.dart   # [M5] Notification CRUD
│   └── storage_repository.dart        # [M7] 이미지 업로드
├── providers/
│   ├── auth_provider.dart             # [M3] 인증 상태
│   ├── supabase_provider.dart         # [M1] Supabase 클라이언트
│   └── fcm_provider.dart              # [M8] FCM 상태
├── services/
│   └── fcm_service.dart               # [M8] FCM 서비스
├── widgets/
│   ├── loading_indicator.dart         # [M9] 로딩 인디케이터
│   ├── skeleton_shimmer.dart          # [M9] 스켈레톤 shimmer
│   ├── empty_state.dart               # [M9] 빈 상태
│   ├── error_view.dart                # [M9] 에러 화면
│   ├── status_badge.dart              # [M9] 상태 뱃지
│   ├── confirm_dialog.dart            # [M9] 확인 다이얼로그
│   ├── toast.dart                     # [M9] 토스트/스낵바
│   ├── phone_input_field.dart         # [M9] 전화번호 입력 필드
│   └── map_preview.dart              # [M9] 지도 미리보기
└── screens/
    ├── auth/                          # 인증 화면들
    ├── customer/                      # 고객 화면들
    └── owner/                         # 사장님 화면들
```

---

## M1. 앱 초기화 / 환경 설정

**역할**: Supabase, Firebase 초기화 및 환경 변수 관리

**파일 위치**: `lib/main.dart`, `lib/core/config/env.dart`, `lib/providers/supabase_provider.dart`

**의존성**: `supabase_flutter`, `firebase_core`, `firebase_messaging`, `flutter_riverpod`

**공개 인터페이스**:

| 항목 | 설명 |
|------|------|
| `main()` | Supabase.initialize + Firebase.initializeApp + runApp |
| `Env.supabaseUrl` | Supabase Project URL |
| `Env.supabaseAnonKey` | Supabase Anon Key |
| `supabaseProvider` | Riverpod Provider로 SupabaseClient 제공 |

**사용하는 유스케이스**: 전체 (모든 유스케이스가 Supabase 클라이언트에 의존)

---

## M2. 라우터 (go_router)

**역할**: 화면 라우팅, 인증 가드, 역할별 리다이렉트, 딥링크 처리

**파일 위치**: `lib/app/router.dart`

**의존성**: `go_router`, `flutter_riverpod`

**공개 인터페이스**:

| 항목 | 설명 |
|------|------|
| `routerProvider` | GoRouter를 제공하는 Riverpod Provider |
| 인증 가드 | 미인증 → `/login`, 프로필 미설정 → `/profile-setup` |
| 역할 리다이렉트 | customer → `/customer/home`, shop_owner → `/owner/dashboard` |
| 딥링크 | `gutarim://shop/{shopId}` → QR 회원 등록 처리 |

**라우트 구조**:

```
/splash
/login
/profile-setup
/shop-register
/customer
  /home
  /order/:orderId
  /order-history
  /shop-search
  /shop/:shopId
  /shop/:shopId/posts/:category
  /shop/:shopId/post/:postId
  /notifications
  /mypage
  /profile-edit
/owner
  /dashboard
  /order-create
  /order-manage
  /shop-qr
  /post-create
  /inventory
  /settings
```

**사용하는 유스케이스**: 전체

---

## M3. 인증 모듈

**역할**: 소셜 로그인, 세션 관리, 인증 상태 관리, 신규/기존 사용자 판별

**파일 위치**: `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`

**의존성**: `supabase_flutter`, `flutter_riverpod`

**공개 인터페이스**:

| 항목 | 설명 |
|------|------|
| `AuthRepository.signInWithOAuth(provider)` | 소셜 로그인 (카카오/네이버/Google/Apple) |
| `AuthRepository.signOut()` | 로그아웃 |
| `AuthRepository.currentUser` | 현재 Supabase Auth User |
| `authStateProvider` | 인증 상태 스트림 (StreamProvider) |
| `currentUserProvider` | 현재 users 테이블 레코드 (AsyncNotifierProvider) |
| `isNewUserProvider` | 신규 사용자 여부 (users 테이블에 레코드 없음) |
| `userRoleProvider` | 현재 사용자 역할 (customer / shop_owner / null) |

**사용하는 유스케이스**: UC-1(로그인), UC-2(샵등록 시 owner 확인), UC-3~10(인증 가드)

---

## M4. 데이터 모델

**역할**: DB 테이블에 대응하는 불변 데이터 클래스 및 Enum 정의

**파일 위치**: `lib/models/`

**의존성**: `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`

**모델 목록**:

| 모델 | 파일 | 대응 테이블 | 사용 유스케이스 |
|------|------|-----------|--------------|
| `User` | user.dart | users | UC-1, 3, 4, 5, 9 |
| `Shop` | shop.dart | shops | UC-2, 4, 5, 6, 9 |
| `Member` | member.dart | members | UC-3, 4, 5 |
| `Order` | order.dart | orders | UC-4, 5, 6, 10 |
| `Post` | post.dart | posts | UC-7 |
| `InventoryItem` | inventory_item.dart | inventory | UC-8 |
| `NotificationItem` | notification_item.dart | notifications | UC-5, 10 |

**공통 Enum** (`lib/models/enums.dart`):

| Enum | 값 | 사용 유스케이스 |
|------|----|--------------|
| `UserRole` | customer, shopOwner | UC-1, 2, 라우터 |
| `OrderStatus` | received, inProgress, completed | UC-4, 5, 6 |
| `PostCategory` | notice, event | UC-7 |
| `NotificationType` | statusChange, completion, notice, receipt | UC-5, 10 |

**freezed 클래스 규칙**:
- `fromJson` / `toJson` 팩토리 필수
- Supabase 컬럼명(snake_case)과 Dart 필드명(camelCase) 간 `@JsonKey(name:)` 사용
- nullable 필드는 `?` 타입으로 선언

---

## M5. 리포지토리 계층

**역할**: Supabase DB 접근을 추상화. 각 테이블별 CRUD 및 비즈니스 쿼리를 제공

**파일 위치**: `lib/repositories/`

**의존성**: `supabase_flutter`, `flutter_riverpod`

**공통 패턴**:

| 리포지토리 | 주요 메서드 | 사용 유스케이스 |
|-----------|-----------|--------------|
| `UserRepository` | `getById`, `create`, `update`, `matchMembersByPhone` | UC-1, 3, 9 |
| `ShopRepository` | `getById`, `create`, `update`, `getByOwner`, `searchByBounds` | UC-2, 6, 9 |
| `MemberRepository` | `getByShopAndUser`, `getByShopAndPhone`, `search`, `create`, `update` | UC-3, 4 |
| `OrderRepository` | `create`, `updateStatus`, `delete`, `getByShop`, `getByMemberUser`, `countActiveByShop`, `streamByShop`, `streamById` | UC-4, 5, 6, 10 |
| `PostRepository` | `create`, `getByShopAndCategory`, `getById` | UC-7 |
| `InventoryRepository` | `create`, `update`, `delete`, `getByShop` | UC-8 |
| `NotificationRepository` | `getByUser`, `markAsRead`, `markAllAsRead`, `getUnreadCount` | UC-10 |

**리포지토리 규칙**:
- 모든 리포지토리는 `SupabaseClient`를 생성자 주입받음
- Riverpod Provider로 제공 (테스트 시 Mock 교체 용이)
- 에러 발생 시 `AppException`으로 래핑하여 throw
- Realtime 구독은 `Stream<List<T>>`로 반환

---

## M6. 에러 처리

**역할**: 공통 에러 클래스, 에러 핸들러, 사용자 메시지 매핑

**파일 위치**: `lib/core/error/app_exception.dart`, `lib/core/error/error_handler.dart`

**의존성**: 없음 (순수 Dart)

**공개 인터페이스**:

| 항목 | 설명 |
|------|------|
| `AppException` | 앱 공통 에러 클래스 (code, message, originalError) |
| `AppException.network()` | 네트워크 에러 팩토리 |
| `AppException.server()` | 서버 에러 팩토리 |
| `AppException.validation()` | 유효성 검증 에러 팩토리 |
| `AppException.notFound()` | 데이터 없음 에러 팩토리 |
| `AppException.unauthorized()` | 인증 에러 팩토리 |
| `ErrorHandler.handle(error)` | 에러를 AppException으로 변환 (Supabase PostgrestException, SocketException 등) |
| `AppException.userMessage` | 사용자에게 표시할 한국어 메시지 |

**에러 메시지 매핑**:

| 에러 코드 | 사용자 메시지 |
|----------|-------------|
| `network` | "네트워크 연결을 확인해주세요" |
| `server` | "서버 오류가 발생했습니다. 다시 시도해주세요" |
| `unauthorized` | "로그인이 필요합니다" |
| `not_found` | "데이터를 찾을 수 없습니다" |
| `duplicate` | "이미 등록된 데이터입니다" |
| `validation` | (필드별 동적 메시지) |

**사용하는 유스케이스**: 전체 (모든 유스케이스에서 에러 처리 필요)

---

## M7. 이미지 업로드 (Storage)

**역할**: Supabase Storage에 이미지 업로드, URL 반환

**파일 위치**: `lib/repositories/storage_repository.dart`

**의존성**: `supabase_flutter`, `image_picker`

**공개 인터페이스**:

| 항목 | 설명 |
|------|------|
| `StorageRepository.uploadImage(bucket, file, path)` | 이미지 업로드 → public URL 반환 |
| `StorageRepository.deleteImage(bucket, path)` | 이미지 삭제 |
| 버킷: `profile-images` | 프로필 이미지 (UC-9) |
| 버킷: `post-images` | 게시글 이미지 (UC-7) |
| 버킷: `inventory-images` | 재고 상품 이미지 (UC-8) |

**파일 경로 규칙**: `{userId}/{uuid}.jpg` (충돌 방지)

**사용하는 유스케이스**: UC-7(게시글), UC-8(재고), UC-9(프로필)

---

## M8. FCM 푸시 알림

**역할**: FCM 토큰 관리, 포그라운드/백그라운드 알림 수신 처리

**파일 위치**: `lib/services/fcm_service.dart`, `lib/providers/fcm_provider.dart`

**의존성**: `firebase_messaging`, `firebase_core`, `supabase_flutter`, `flutter_local_notifications`

**공개 인터페이스**:

| 항목 | 설명 |
|------|------|
| `FcmService.initialize()` | FCM 초기화 + 권한 요청 + 로컬 알림 채널 생성. `main()`에서 호출 |
| `FcmService.getToken()` | 현재 FCM 토큰 반환 |
| `FcmService.saveTokenToDb(userId, client)` | 토큰을 users.fcm_token에 저장. 스플래시(`splash_providers.dart`)에서 호출 |
| `FcmService.onTokenRefresh` | 토큰 갱신 시 DB 업데이트 |
| `FcmService.onMessage` | 포그라운드 알림 수신 스트림 |
| `FcmService.onMessageOpenedApp` | 알림 탭 → 딥링크 처리 |

**포그라운드 알림**: 앱이 열린 상태에서 FCM 메시지를 수신하면 `flutter_local_notifications`를 사용하여 시스템 알림바에 알림을 표시한다.

**사용하는 유스케이스**: UC-4(접수 알림), UC-5(상태 변경 알림), UC-10(알림 조회)

---

## M9. 공통 위젯

**역할**: 2개 이상 화면에서 재사용되는 UI 컴포넌트

**파일 위치**: `lib/widgets/`

**의존성**: `flutter`

### 위젯 목록

| 위젯 | 파일 | 설명 | 사용 유스케이스 |
|------|------|------|--------------|
| `LoadingIndicator` | loading_indicator.dart | 버튼 로딩, 전체 로딩 | 전체 |
| `SkeletonShimmer` | skeleton_shimmer.dart | 스켈레톤 로딩 효과 | UC-4, 5, 6, 7, 8, 10 |
| `EmptyState` | empty_state.dart | 아이콘 + 메시지 + 선택적 CTA | UC-6, 7, 8, 10 |
| `ErrorView` | error_view.dart | 에러 아이콘 + 메시지 + 재시도 버튼 | 전체 |
| `StatusBadge` | status_badge.dart | 작업 상태 뱃지 (색상 + 텍스트) | UC-4, 5, 6 |
| `ConfirmDialog` | confirm_dialog.dart | 확인/취소 다이얼로그 | UC-5, 8, 9 |
| `AppToast` | toast.dart | 성공/에러 토스트 메시지 | UC-1, 2, 3, 4, 7, 8, 9 |
| `PhoneInputField` | phone_input_field.dart | 전화번호 입력 (자동 하이픈) | UC-1, 2, 3, 9 |
| `MapPreview` | map_preview.dart | 네이버 지도 미리보기 (좌표→마커, 미입력 시 안내) | UC-2, 9 |

### EmptyState 위젯 인터페이스

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `icon` | IconData | 중앙 아이콘 |
| `message` | String | 안내 메시지 |
| `actionLabel` | String? | CTA 버튼 텍스트 (선택) |
| `onAction` | VoidCallback? | CTA 버튼 콜백 (선택) |

### StatusBadge 위젯 인터페이스

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `status` | OrderStatus | 작업 상태 |
| `size` | StatusBadgeSize | small (목록용) / large (상세용) |

**상태별 스타일**:

| 상태 | 배경색 | 텍스트 | 한국어 |
|------|--------|--------|--------|
| received | `#FEF3C7` | `#F59E0B` | 접수됨 |
| inProgress | `#DBEAFE` | `#3B82F6` | 작업중 |
| completed | `#DCFCE7` | `#22C55E` | 완료 |

---

## M10. 유효성 검증

**역할**: 입력값 검증 함수 (폼 validator로 사용)

**파일 위치**: `lib/core/utils/validators.dart`

**의존성**: 없음 (순수 Dart)

**공개 인터페이스**:

| 함수 | 반환 | 규칙 | 사용 유스케이스 |
|------|------|------|--------------|
| `Validators.name(value)` | String? (에러 메시지 또는 null) | 2~20자 | UC-1, 2, 3, 9 |
| `Validators.phone(value)` | String? | 010-XXXX-XXXX 형식 | UC-1, 2, 3, 9 |
| `Validators.shopName(value)` | String? | 1~50자 | UC-2, 9 |
| `Validators.description(value)` | String? | 0~200자 (빈 문자열 허용) | UC-2, 9 |
| `Validators.postTitle(value)` | String? | 1~100자 | UC-7 |
| `Validators.postContent(value)` | String? | 1~2000자 | UC-7 |
| `Validators.memo(value)` | String? | 0~500자 | UC-4 |
| `Validators.productName(value)` | String? | 1~50자 | UC-8 |
| `Validators.quantity(value)` | String? | 0~9999 정수 | UC-8 |

---

## M11. 포맷 유틸리티

**역할**: 날짜, 전화번호, 상대 시간 등의 표시 형식 변환

**파일 위치**: `lib/core/utils/formatters.dart`

**의존성**: 없음 (순수 Dart)

**공개 인터페이스**:

| 함수 | 입력 | 출력 | 사용 유스케이스 |
|------|------|------|--------------|
| `Formatters.relativeTime(dateTime)` | DateTime | "방금 전", "5분 전", "2시간 전", "3일 전" | UC-10 |
| `Formatters.dateTime(dateTime)` | DateTime | "MM/DD HH:mm" | UC-4, 5 (타임라인) |
| `Formatters.date(dateTime)` | DateTime | "YYYY.MM.DD" | UC-7 (이벤트 기간) |
| `Formatters.phone(phone)` | String | "010-1234-5678" (하이픈 삽입) | UC-1, 2, 3, 4, 9 |
| `Formatters.phoneRaw(phone)` | String | "01012345678" (하이픈 제거) | UC-1, 3 (DB 저장용) |

---

## M12. 테스트 환경

**역할**: TDD를 위한 테스트 인프라 설정

**파일 위치**: `test/`

**의존성**: `flutter_test`, `mocktail`

### 디렉토리 구조

```
test/
├── helpers/
│   ├── mocks.dart                # 공통 Mock 클래스
│   ├── fixtures.dart             # 테스트 픽스처 (샘플 데이터)
│   └── test_app.dart             # 테스트용 앱 래퍼 (ProviderScope 등)
├── models/                       # 모델 직렬화 테스트
├── repositories/                 # 리포지토리 단위 테스트
├── providers/                    # Provider 상태 테스트
├── widgets/                      # 공통 위젯 테스트
├── screens/                      # 화면별 위젯 테스트
│   ├── auth/
│   ├── customer/
│   └── owner/
└── integration/                  # 통합 테스트
```

### Mock 클래스

| Mock | 대상 | 사용 범위 |
|------|------|----------|
| `MockSupabaseClient` | SupabaseClient | 전체 리포지토리 테스트 |
| `MockAuthRepository` | AuthRepository | 인증 의존 화면 테스트 |
| `MockGoRouter` | GoRouter | 네비게이션 테스트 |
| `MockStorageRepository` | StorageRepository | 이미지 업로드 테스트 |
| `MockFcmService` | FcmService | 푸시 알림 테스트 |

### 테스트 픽스처 (fixtures.dart)

| 픽스처 | 설명 |
|--------|------|
| `testUser` | 테스트용 User 객체 (customer) |
| `testOwner` | 테스트용 User 객체 (shop_owner) |
| `testShop` | 테스트용 Shop 객체 |
| `testMember` | 테스트용 Member 객체 |
| `testOrder` | 테스트용 Order 객체 (각 status별) |
| `testPost` | 테스트용 Post 객체 (notice, event) |
| `testInventoryItem` | 테스트용 InventoryItem 객체 |
| `testNotification` | 테스트용 NotificationItem 객체 |

### 테스트 비율 (테스트 피라미드)

| 레벨 | 비율 | 대상 |
|------|------|------|
| Unit Test | 70% | 모델, 리포지토리, 유효성 검증, 포맷터, 에러 핸들러 |
| Widget Test | 20% | 공통 위젯, 화면별 UI |
| Integration Test | 10% | 주요 사용자 흐름 (로그인→홈, 작업접수→상태변경) |

---

## 자가 검증

### 검증 1: 완전성

| 질문 | 답변 |
|------|------|
| 모든 유스케이스에서 공통으로 쓰이는 코드가 빠짐없이 포함되었는가? | **예** — 인증(M3), 에러처리(M6), 라우팅(M2)이 전체 UC를 커버 |
| 2개 이상 화면에서 동일한 로직이 필요한 부분이 누락되지 않았는가? | **예** — 교차분석 결과 phone 검증(5개 UC), 이미지업로드(3개 UC), 상태뱃지(3개 UC) 등 모두 공통 모듈로 분리됨 |

### 검증 2: 독립성

| 질문 | 답변 |
|------|------|
| 이 공통 모듈만 먼저 구현하면, 이후 모든 화면을 병렬로 개발할 수 있는가? | **예** — 모델(M4), 리포지토리(M5), 위젯(M9), 에러(M6), 검증(M10), 포맷(M11)이 모두 화면 독립적으로 설계됨 |
| 화면 A 개발자가 화면 B 개발자의 코드를 기다려야 하는 상황이 없는가? | **예** — 모든 화면은 공통 모듈(리포지토리, 위젯, 모델)에만 의존하고 다른 화면에 의존하지 않음 |

### 검증 3: 최소성

| 질문 | 답변 |
|------|------|
| 과잉 설계된 모듈이 없는가? | **예** — Geocoding은 화면 수준(UC-2, UC-6)에서 직접 사용. 지도 미리보기(`MapPreview`)는 샵 등록/설정 2개 화면에서 공유하므로 M9로 분리. QR 스캔도 UC-3, UC-4 화면에서 직접 처리 |
| 문서에 언급되지 않은 추측성 모듈이 포함되지 않았는가? | **예** — 분석/로깅, 다국어, 캐시 레이어 등 기획/유스케이스에 없는 모듈은 제외함 |

---

## 구현 순서

공통 모듈은 의존성 순서에 따라 다음 순서로 구현한다:

```
1. M4  데이터 모델 + Enum        ← 의존성 없음 (freezed)
2. M1  앱 초기화 / 환경 설정      ← Supabase, Firebase 초기화
3. M6  에러 처리                 ← 의존성 없음 (순수 Dart)
4. M10 유효성 검증               ← 의존성 없음 (순수 Dart)
5. M11 포맷 유틸리티             ← 의존성 없음 (순수 Dart)
6. M5  리포지토리 계층           ← M1(Supabase), M4(모델), M6(에러)
7. M7  이미지 업로드             ← M1(Supabase), M6(에러)
8. M3  인증 모듈                ← M1(Supabase), M5(UserRepo)
9. M8  FCM 푸시 알림            ← M1(Firebase), M5(UserRepo)
10. M9  공통 위젯               ← M4(Enum/모델)
11. M2  라우터                  ← M3(인증 상태)
12. M12 테스트 환경             ← 전체 모듈 Mock 설정
```

이 순서대로 구현하면 각 모듈이 의존하는 하위 모듈이 이미 준비된 상태에서 개발을 진행할 수 있다.
