# 관리자 샵 등록 요청 상세 — 상태 설계

> 화면 ID: `admin-shop-request-detail`
> UI 스펙: `docs/ui-specs/admin-shop-request-detail.md`
> 유스케이스: UC-샵 등록 승인 관리

---

## 상태 데이터 (State)

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `shopRequestDetailState` | `ShopRequestDetailState` | `ShopRequestDetailState()` | 샵 등록 요청 상세 전체 상태 (isLoading, shop, owner, isProcessing, error 포함) |

### ShopRequestDetailState (freezed)

| 필드 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `shop` | `Shop?` | `null` | 샵 상세 정보 (status, reject_reason, reviewed_at 포함) |
| `owner` | `User?` | `null` | 신청자(사장님) 정보 (User 모델 전체) |
| `isLoading` | `bool` | `true` | 데이터 로딩 중 여부 |
| `isProcessing` | `bool` | `false` | 승인/거절 처리 중 여부 |
| `error` | `String?` | `null` | 에러 메시지 (에러 발생 시) |

---

## 비-상태 데이터 (Non-State)

| 이름 | 출처 | 설명 |
|------|------|------|
| `authState` | `authStateProvider` (M3) | 현재 인증된 사용자. role이 admin인지 확인 |
| `shopRepository` | `shopRepositoryProvider` (M5) | shops 테이블 조회 및 UPDATE (status, reject_reason, reviewed_at) |
| `userRepository` | `userRepositoryProvider` (M5) | users 테이블 조회 (사장님 정보) |
| `notificationRepository` | `notificationRepositoryProvider` (M5) | 승인/거절 알림 생성 (shopApproval, shopRejection) |

---

## 상태 변화 조건표

| 트리거 | 상태 변화 | UI 변화 |
|--------|----------|---------|
| 화면 진입 | `AsyncLoading` → shops + users 조인 조회 → `AsyncData(ShopRequestDetailState)` | 전체 스켈레톤 shimmer → 상세 정보 표시 |
| 데이터 로드 실패 | `AsyncError` | ErrorView "요청 정보를 불러올 수 없습니다" + 재시도 버튼 |
| 승인 버튼 탭 | - | 확인 다이얼로그 "이 샵을 승인하시겠습니까?" 표시 |
| 승인 확인 | `processingAction` = `approving` → shops UPDATE (status='approved', reviewed_at=now()) | 승인 버튼 로딩, 거절 버튼 비활성 |
| 승인 성공 | `processingAction` = null, `shop.status` = 'approved' | "승인 처리되었습니다" 토스트 + 목록으로 복귀 |
| 승인 실패 | `processingAction` = null | "처리에 실패했습니다. 다시 시도해주세요" 에러 스낵바 + 버튼 재활성화 |
| 거절 버튼 탭 | - | 거절 사유 입력 다이얼로그 표시 |
| 거절 확인 (사유 입력 후) | `processingAction` = `rejecting` → shops UPDATE (status='rejected', reject_reason, reviewed_at=now()) | 거절 버튼 로딩, 승인 버튼 비활성 |
| 거절 성공 | `processingAction` = null, `shop.status` = 'rejected' | "거절 처리되었습니다" 토스트 + 목록으로 복귀 |
| 거절 실패 | `processingAction` = null | "처리에 실패했습니다. 다시 시도해주세요" 에러 스낵바 + 버튼 재활성화 |

---

## Provider 구조

```mermaid
flowchart TD
    subgraph 공통_모듈["공통 모듈"]
        SP[supabaseProvider<br/>M1]
        AUTH[authStateProvider<br/>StreamProvider, M3]
        shopRepository["shopRepositoryProvider\n(Provider, M5)"]
        userRepository["userRepositoryProvider\n(Provider, M5)"]
        notificationRepository["notificationRepositoryProvider\n(Provider, M5)"]
    end

    subgraph 요청상세_화면["샵 등록 요청 상세 화면"]
        shopRequestDetailNotifier["shopRequestDetailNotifierProvider\n(StateNotifierProvider.autoDispose)"]
    end

    AUTH -->|"currentUser (admin 확인)"| shopRequestDetailNotifier
    shopRepository -->|"getById / approve / reject"| shopRequestDetailNotifier
    userRepository -->|"getById (사장님 정보)"| shopRequestDetailNotifier
    notificationRepository -->|"create (승인/거절 알림)"| shopRequestDetailNotifier
```

### Provider 상세

| Provider | 타입 | 역할 |
|----------|------|------|
| `shopRequestDetailNotifierProvider` | `StateNotifierProvider.autoDispose<ShopRequestDetailNotifier, ShopRequestDetailState>` | 샵 등록 요청 상세 상태 관리. loadDetail(shopId)로 데이터 로드. 승인/거절 처리 + 알림 생성. 화면 이탈 시 자동 해제(autoDispose) |

---

## 노출 인터페이스

### 읽기 (State)

| Provider | 타입 | 설명 |
|----------|------|------|
| `shopRequestDetailNotifierProvider` | `StateNotifierProvider.autoDispose<ShopRequestDetailNotifier, ShopRequestDetailState>` | 샵 등록 요청 상세 전체 상태. 화면 이탈 시 자동 해제 |

### 쓰기 (Actions)

| 메서드 | 파라미터 | 반환 | 설명 |
|--------|---------|------|------|
| `loadDetail(String shopId)` | `String` | `Future<void>` | shopId로 샵 상세 + 사장님 정보 조회 |
| `approve()` | - | `Future<bool>` | 샵 승인 처리. shops.status = 'approved'. 성공 시 shopApproval 알림 생성. 반환값: 성공 여부 |
| `reject(String reason)` | `String` | `Future<bool>` | 샵 거절 처리. shops.status = 'rejected', reject_reason = reason. 성공 시 shopRejection 알림 생성. 반환값: 성공 여부 |

---

## 참조하는 공통 모듈

| 모듈 | 용도 |
|------|------|
| M1 (supabaseProvider) | Supabase 클라이언트 |
| M3 (authStateProvider) | 현재 인증 사용자 정보 (admin 역할 확인) |
| M4 (Shop, User) | 샵/사용자 데이터 모델 |
| M5 (ShopRepository, UserRepository, NotificationRepository) | shops 조회/승인/거절, users 조회, 알림 생성 |
| M6 (AppException, ErrorHandler) | 에러 처리 및 사용자 메시지 매핑 |
| M8 (NotificationType) | shopApproval, shopRejection 알림 타입 |
| M9 (ConfirmDialog, ErrorView, SkeletonShimmer, AppToast) | 승인 확인 다이얼로그, 에러 화면, 스켈레톤 로딩, 성공/에러 스낵바 |
