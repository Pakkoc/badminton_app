# 고객 홈 — 상태 설계

> 화면 ID: `customer-home`
> 최종 수정일: 2026-02-28

---

## 상태 데이터 (State)

freezed 클래스: `CustomerHomeState`

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `activeOrders` | `List<GutOrder>` | `[]` | 현재 활성 작업 목록 (received + in_progress + completed) |
| `shopNames` | `Map<String, String>` | `{}` | 주문에 연결된 샵 이름 맵 (shopId → name) |
| `isLoading` | `bool` | `false` | 데이터 로딩 중 여부 |
| `error` | `String?` | `null` | 에러 메시지 |

---

## Provider 구조

단일 `NotifierProvider`로 화면 전체 상태를 관리한다.

| Provider | 타입 | 역할 |
|----------|------|------|
| `customerHomeNotifierProvider` | `NotifierProvider<CustomerHomeNotifier, CustomerHomeState>` | 화면의 메인 상태 관리. 초기 로드 및 데이터 집계 |
| `unreadNotificationCountProvider` | `StateNotifierProvider<UnreadNotificationCountNotifier, int>` | 읽지 않은 알림 수. AppBar 알림 아이콘 뱃지에 표시 |

### 의존 Provider

| Provider | 출처 | 용도 |
|----------|------|------|
| `currentUserProvider` | M3 인증 모듈 | 현재 사용자 ID로 회원 조회 |
| `memberRepositoryProvider` | M5 리포지토리 | 사용자의 회원 정보 → shopId 목록 확보 |
| `orderRepositoryProvider` | M5 리포지토리 | 샵별 주문 조회 |
| `shopRepositoryProvider` | M5 리포지토리 | 샵 이름 조회 |
| `unreadNotificationCountProvider` | 공통 Provider | 읽지 않은 알림 수 (Supabase Realtime 구독) |

---

## 상태 변화 조건표

| 트리거 | 상태 변화 | UI 변화 |
|--------|-----------|---------|
| 화면 최초 진입 | `isLoading`: `true` | CircularProgressIndicator 표시 |
| 데이터 로드 성공 (0건) | `activeOrders`: `[]`, `isLoading`: `false` | 빈 상태 UI ("진행 중인 작업이 없습니다") |
| 데이터 로드 성공 (1건 이상) | `activeOrders`: `[...]`, `shopNames`: `{...}`, `isLoading`: `false` | 요약 카드 + 작업 카드 목록 표시 |
| 데이터 로드 실패 | `error`: 에러 메시지, `isLoading`: `false` | ErrorView 표시 |

---

## 파생 데이터

화면에서 `activeOrders`를 기반으로 직접 계산:

| 이름 | 계산 방식 | 설명 |
|------|-----------|------|
| 접수 건수 | `activeOrders.where(status == received).length` | 요약 카드에 표시 |
| 작업중 건수 | `activeOrders.where(status == inProgress).length` | 요약 카드에 표시 |

---

## 노출 인터페이스

### 읽기 (State)

| 이름 | 타입 | 설명 |
|------|------|------|
| `activeOrders` | `List<GutOrder>` | 활성 작업 목록 |
| `shopNames` | `Map<String, String>` | 샵 ID → 이름 매핑 |
| `isLoading` | `bool` | 로딩 중 여부 |
| `error` | `String?` | 에러 메시지 |

### 쓰기 (Actions)

| 이름 | 파라미터 | 설명 |
|------|----------|------|
| `loadOrders()` | 없음 | 사용자의 활성 주문 전체 로드. 회원 조회 → 샵별 주문 조회 → 샵 이름 매핑 |
