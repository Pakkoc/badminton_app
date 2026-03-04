# 작업 상세 — 상태 설계

> 화면 ID: `customer-order-detail`
> 최종 수정일: 2026-03-04

---

## 상태 데이터 (State)

freezed 클래스: `OrderDetailState`

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `order` | `GutOrder?` | `null` | 작업 상세 정보 |
| `shop` | `Shop?` | `null` | 작업이 속한 샵 정보 (이름, 주소, 연락처) |
| `isLoading` | `bool` | `false` | 데이터 로딩 중 여부 |
| `error` | `String?` | `null` | 에러 메시지 |

---

## Provider 구조

`NotifierProvider.family`로 orderId를 파라미터로 받아 상태를 관리한다.

| Provider | 타입 | 역할 |
|----------|------|------|
| `orderDetailNotifierProvider` | `NotifierProviderFamily<OrderDetailNotifier, OrderDetailState, String>` | 특정 주문의 상세 정보 + 샵 정보 로드 |

### 의존 Provider

| Provider | 출처 | 용도 |
|----------|------|------|
| `orderRepositoryProvider` | M5 리포지토리 | 주문 상세 조회 |
| `shopRepositoryProvider` | M5 리포지토리 | 샵 정보 조회 (주문의 shopId로) |

---

## 상태 변화 조건표

| 트리거 | 상태 변화 | UI 변화 |
|--------|-----------|---------|
| 화면 최초 진입 | `isLoading`: `true` | CircularProgressIndicator 표시 |
| 데이터 로드 성공 | `order`: 주문 데이터, `shop`: 샵 데이터, `isLoading`: `false` | 상태 뱃지 + 타임라인 + 샵 정보 표시 |
| 주문을 찾을 수 없음 | `error`: '주문을 찾을 수 없습니다', `isLoading`: `false` | ErrorView 표시 |
| 데이터 로드 실패 | `error`: 에러 메시지, `isLoading`: `false` | ErrorView 표시 |

---

## 파생 데이터

화면에서 `order` 상태를 기반으로 타임라인을 직접 구성:

| 이름 | 계산 방식 | 설명 |
|------|-----------|------|
| 타임라인 단계 | `order.status`와 타임스탬프(`createdAt`, `inProgressAt`, `completedAt`)로 각 단계 활성 여부 계산 | 3단계: 접수됨 → 작업중 → 완료 |

---

## 노출 인터페이스

### 읽기 (State)

| 이름 | 타입 | 설명 |
|------|------|------|
| `order` | `GutOrder?` | 작업 상세 데이터 |
| `shop` | `Shop?` | 샵 정보 |
| `isLoading` | `bool` | 로딩 중 여부 |
| `error` | `String?` | 에러 메시지 |

### 쓰기 (Actions)

| 이름 | 파라미터 | 설명 |
|------|----------|------|
| `loadOrder(orderId)` | `String orderId` | 주문 상세 + 샵 정보 로드 |
