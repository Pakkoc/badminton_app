# 샵 상세 — 상태 설계

> 화면 ID: `customer-shop-detail`
> 최종 수정일: 2026-02-27

---

## 상태 데이터 (State)

freezed 클래스: `ShopDetailState`

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `shop` | `Shop?` | `null` | 샵 상세 정보 (이름, 주소, 연락처, 소개글, 좌표) |
| `isMember` | `bool` | `false` | 현재 사용자가 이 샵의 회원인지 여부 |
| `isRegistering` | `bool` | `false` | 회원 등록 진행 중 여부 |
| `noticePosts` | `List<Post>` | `[]` | 공지사항 목록 |
| `eventPosts` | `List<Post>` | `[]` | 이벤트 목록 |
| `inventoryItems` | `List<InventoryItem>` | `[]` | 재고 목록 |
| `receivedCount` | `int` | `0` | 접수 건수 |
| `inProgressCount` | `int` | `0` | 작업중 건수 |
| `isLoading` | `bool` | `false` | 데이터 로딩 중 여부 |
| `error` | `String?` | `null` | 에러 메시지 |

---

## Provider 구조

단일 `NotifierProvider`로 화면 전체 상태를 관리한다.

| Provider | 타입 | 역할 |
|----------|------|------|
| `shopDetailNotifierProvider` | `NotifierProvider<ShopDetailNotifier, ShopDetailState>` | 샵 상세 화면 전체 상태 관리 |

### 의존 Provider

| Provider | 출처 | 용도 |
|----------|------|------|
| `currentUserProvider` | M3 인증 모듈 | 현재 사용자 ID로 회원 여부 확인 |
| `shopRepositoryProvider` | M5 리포지토리 | 샵 상세 조회 |
| `memberRepositoryProvider` | M5 리포지토리 | 회원 여부 조회 및 회원 등록 |
| `postRepositoryProvider` | M5 리포지토리 | 공지사항/이벤트 목록 조회 |
| `orderRepositoryProvider` | M5 리포지토리 | 접수/작업중 건수 집계 |
| `inventoryRepositoryProvider` | M5 리포지토리 | 재고 목록 조회 |

---

## 상태 변화 조건표

| 트리거 | 상태 변화 | UI 변화 |
|--------|-----------|---------|
| 화면 진입 | `isLoading`: `true` | CircularProgressIndicator 표시 |
| 데이터 로드 성공 | `shop`, `isMember`, `noticePosts`, `eventPosts`, `inventoryItems`, `receivedCount`, `inProgressCount` 설정, `isLoading`: `false` | 샵 정보 + 작업 현황 + 탭 콘텐츠 표시 |
| 샵을 찾을 수 없음 | `error`: '샵을 찾을 수 없습니다', `isLoading`: `false` | ErrorView 표시 |
| 데이터 로드 실패 | `error`: 에러 메시지, `isLoading`: `false` | ErrorView 표시 |
| 회원 등록 시작 | `isRegistering`: `true` | 등록 버튼 로딩 상태 |
| 회원 등록 성공 | `isMember`: `true`, `isRegistering`: `false` | 등록 완료 상태 반영 |
| 회원 등록 실패 | `error`: '회원 등록에 실패했습니다', `isRegistering`: `false` | 에러 메시지 표시 |

---

## 노출 인터페이스

### 읽기 (State)

| 이름 | 타입 | 설명 |
|------|------|------|
| `shop` | `Shop?` | 샵 상세 정보 |
| `isMember` | `bool` | 회원 여부 |
| `isRegistering` | `bool` | 회원 등록 진행 중 |
| `noticePosts` | `List<Post>` | 공지사항 목록 |
| `eventPosts` | `List<Post>` | 이벤트 목록 |
| `inventoryItems` | `List<InventoryItem>` | 재고 목록 |
| `receivedCount` | `int` | 접수 건수 |
| `inProgressCount` | `int` | 작업중 건수 |
| `isLoading` | `bool` | 로딩 중 여부 |
| `error` | `String?` | 에러 메시지 |

### 쓰기 (Actions)

| 이름 | 파라미터 | 설명 |
|------|----------|------|
| `loadShop(shopId)` | `String shopId` | 샵 상세 + 회원 여부 + 게시글 + 재고 + 작업 건수 일괄 로드 |
| `registerMember(shopId)` | `String shopId` | 현재 사용자를 해당 샵에 회원 등록 |
