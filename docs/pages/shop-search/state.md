# 주변 샵 검색 — 상태 설계

> 화면 ID: `customer-shop-search`
> 최종 수정일: 2026-02-27

---

## 상태 데이터 (State)

freezed 클래스: `ShopSearchState`

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `shops` | `List<Shop>` | `[]` | 조회된 샵 목록 |
| `viewMode` | `ShopSearchViewMode` | `map` | 현재 뷰 모드 (map / list) |
| `selectedShop` | `Shop?` | `null` | 지도 뷰에서 선택된 샵 (하단 시트 표시용) |
| `orderCounts` | `Map<String, ShopOrderCounts>` | `{}` | 샵별 접수/작업중 건수 (shopId → counts) |
| `hasLocationPermission` | `bool` | `false` | 위치 권한 획득 여부 |
| `isLoading` | `bool` | `false` | 데이터 로딩 중 여부 |
| `error` | `String?` | `null` | 에러 메시지 |

### ShopSearchViewMode (enum)

| 값 | 설명 |
|----|------|
| `map` | 지도 뷰 (네이버 맵 + 마커) |
| `list` | 리스트 뷰 (카드 목록) |

### ShopOrderCounts (freezed)

| 필드 | 타입 | 설명 |
|------|------|------|
| `receivedCount` | `int` | 접수 건수 |
| `inProgressCount` | `int` | 작업중 건수 |

---

## Provider 구조

단일 `NotifierProvider`로 화면 전체 상태를 관리한다.

| Provider | 타입 | 역할 |
|----------|------|------|
| `shopSearchNotifierProvider` | `NotifierProvider<ShopSearchNotifier, ShopSearchState>` | 샵 검색 화면 전체 상태 관리 |

### 의존 Provider

| Provider | 출처 | 용도 |
|----------|------|------|
| `shopRepositoryProvider` | M5 리포지토리 | 전체 샵 목록 조회 |
| `orderRepositoryProvider` | M5 리포지토리 | 샵별 주문 건수 집계 |

---

## 상태 변화 조건표

| 트리거 | 상태 변화 | UI 변화 |
|--------|-----------|---------|
| 화면 진입 | `isLoading`: `true` | CircularProgressIndicator 표시 |
| 위치 권한 획득 | `hasLocationPermission`: `true` | 지도에 현재 위치 표시 |
| 샵 목록 로드 성공 | `shops`: `[...]`, `orderCounts`: `{...}`, `isLoading`: `false` | 지도 마커 또는 리스트 카드 표시 |
| 샵 목록 로드 실패 | `error`: 에러 메시지, `isLoading`: `false` | ErrorView 표시 |
| 뷰 모드 토글 | `viewMode`: `map` ↔ `list` | 지도 뷰 ↔ 리스트 뷰 전환 |
| 마커 탭 | `selectedShop`: 해당 샵 | 하단 시트 표시 |
| 지도 빈 영역 탭 | `selectedShop`: `null` | 하단 시트 닫힘 |
| 샵 카드 탭 | (네비게이션) | 샵 상세 화면으로 이동 |

---

## 노출 인터페이스

### 읽기 (State)

| 이름 | 타입 | 설명 |
|------|------|------|
| `shops` | `List<Shop>` | 조회된 샵 목록 |
| `viewMode` | `ShopSearchViewMode` | 현재 뷰 모드 |
| `selectedShop` | `Shop?` | 선택된 샵 |
| `orderCounts` | `Map<String, ShopOrderCounts>` | 샵별 주문 건수 |
| `hasLocationPermission` | `bool` | 위치 권한 여부 |
| `isLoading` | `bool` | 로딩 중 여부 |
| `error` | `String?` | 에러 메시지 |

### 쓰기 (Actions)

| 이름 | 파라미터 | 설명 |
|------|----------|------|
| `loadShops()` | 없음 | 전체 샵 목록 + 샵별 주문 건수 로드 |
| `toggleViewMode()` | 없음 | 지도 ↔ 리스트 뷰 전환 |
| `selectShop(shop)` | `Shop shop` | 마커 탭 시 샵 선택 |
| `clearSelection()` | 없음 | 샵 선택 해제 |
| `setLocationPermission(granted)` | `bool granted` | 위치 권한 상태 설정 |
