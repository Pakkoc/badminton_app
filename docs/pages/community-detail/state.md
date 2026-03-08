# 게시글 상세 — 상태 설계

> 화면 ID: `community-detail`
> 최종 수정일: 2026-03-07

---

## 상태 데이터 (State)

이 화면은 로컬 StatefulWidget 상태 + FutureProvider 조합으로 관리한다.

### 로컬 상태

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `_commentController` | `TextEditingController` | - | 댓글 입력 컨트롤러 |
| `_replyToId` | `String?` | `null` | 대댓글 대상 댓글 ID |
| `_replyToName` | `String?` | `null` | 대댓글 대상 닉네임 (입력 바 답글 칩 표시용) |
| `_mentionName` | `String?` | `null` | 대댓글 전송 시 content 앞에 삽입할 @멘션 대상 이름 |
| `_expanded` | `Map<String, bool>` | `{}` | 댓글 ID별 대댓글 펼치기 상태 (_CommentSection 내부) |

### 파라미터

| 이름 | 타입 | 설명 |
|------|------|------|
| `postId` | `String` | 라우트에서 전달받는 게시글 ID |

---

## Provider 구조

| Provider | 타입 | 역할 |
|----------|------|------|
| `communityPostDetailProvider` | `FutureProvider.autoDispose.family<CommunityPost?, String>` | 게시글 상세 조회 |
| `communityCommentsProvider` | `FutureProvider.autoDispose.family<List<CommunityComment>, String>` | 게시글 댓글 목록 |
| `communityPostLikeStatusProvider` | `FutureProvider.autoDispose.family<bool, ({String userId, String postId})>` | 현재 사용자의 좋아요 여부 |

### 의존 Provider

| Provider | 소스 |
|----------|------|
| `communityPostRepositoryProvider` | 게시글 CRUD |
| `communityCommentRepositoryProvider` | 댓글 CRUD |
| `communityLikeRepositoryProvider` | 좋아요 토글 |
| `communityReportRepositoryProvider` | 신고 |
| `supabaseProvider` | 현재 사용자 ID |

---

## 데이터 흐름

```
postId (라우트 파라미터)
  ├─ communityPostDetailProvider(postId) → 게시글 본문
  ├─ communityCommentsProvider(postId) → 댓글 목록
  └─ communityPostLikeStatusProvider({userId, postId}) → 좋아요 상태
```

---

## 갱신 트리거

| 이벤트 | 갱신 대상 |
|--------|----------|
| 좋아요 토글 | `communityPostDetailProvider`, `communityPostLikeStatusProvider` |
| 댓글 작성 | `communityCommentsProvider`, `communityPostDetailProvider` |
| 댓글 삭제 | `communityCommentsProvider`, `communityPostDetailProvider` |
| 게시글 삭제 | pop (목록으로 돌아감) |
| 답글 탭 | `_replyToId`, `_replyToName`, `_mentionName` 로컬 상태 갱신 |
| 답글 취소 (✕) | `_replyToId`, `_replyToName`, `_mentionName` → null 초기화 |
| 답글 펼치기/숨기기 탭 | `_expanded[commentId]` 토글 (로컬 상태) |
