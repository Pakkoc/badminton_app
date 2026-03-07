# 커뮤니티 목록 — 상태 설계

> 화면 ID: `community-list`
> 최종 수정일: 2026-03-07

---

## 상태 데이터 (State)

이 화면은 로컬 StatefulWidget 상태 + FutureProvider 조합으로 관리한다.

### 로컬 상태

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `_isSearching` | `bool` | `false` | 검색 모드 활성화 여부 |
| `_searchController` | `TextEditingController` | - | 검색어 입력 컨트롤러 |

---

## Provider 구조

| Provider | 타입 | 역할 |
|----------|------|------|
| `communityPostListProvider` | `FutureProvider.autoDispose<List<CommunityPost>>` | 전체 게시글 목록 조회 |
| `communitySearchProvider` | `FutureProvider.autoDispose.family<List<CommunityPost>, String>` | 검색어 기반 게시글 검색 |

### 의존 Provider

| Provider | 소스 |
|----------|------|
| `communityPostRepositoryProvider` | `repositories/community_post_repository.dart` |

---

## 데이터 흐름

```
communityPostRepositoryProvider
  └─ communityPostListProvider (getAll)
  └─ communitySearchProvider (search by query)
       └─ UI 렌더링 (AsyncValue.when)
```

---

## 갱신 트리거

| 이벤트 | 갱신 대상 |
|--------|----------|
| Pull-to-refresh | `ref.invalidate(communityPostListProvider)` |
| 검색어 submit | `communitySearchProvider(query)` watch |
| 검색 모드 해제 | `_searchController.clear()` → `communityPostListProvider` watch |
