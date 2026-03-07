# 게시글 상세 — UI 화면 스펙

> 최종 수정일: 2026-03-07

---

## 1. 화면 개요

| 항목 | 내용 |
|------|------|
| **화면 ID** | `community-detail` |
| **화면 명** | 게시글 상세 |
| **Pencil ID** | `t1yQo` |
| **목적** | 게시글 본문 조회, 좋아요, 댓글/대댓글 작성, 신고 |
| **사용자 역할** | 모든 로그인 사용자 |
| **진입 조건** | 로그인 필수, postId 파라미터 필요 |

---

## 2. 레이아웃 구조

```
+----------------------------------+
|  AppBar                          |  56px
|  [뒤로] "게시글"     [더보기 ...]  |
+----------------------------------+
|                                  |
|  작성자 영역                      |
|  [아바타] 닉네임 · 시간  [...]    |
|                                  |
|  제목 (titleLarge)               |
|  본문 (bodyMedium)               |
|  [이미지들]                       |
|                                  |
|  좋아요N  댓글N                   |
|  ─── Divider ───                 |
|                                  |
|  댓글 1                          |  ← 스크롤 영역
|    └ 대댓글 1-1 (left 40px)      |
|  댓글 2                          |
|                                  |
+----------------------------------+
|  댓글 입력창                      |
|  [@답글 대상]          [전송]     |
+----------------------------------+
```

---

## 3. 컴포넌트 상세

### 3.1 AppBar

| 속성 | 값 |
|------|-----|
| 높이 | 56px |
| 좌측 | 뒤로 아이콘 (arrow_back) |
| 타이틀 | "게시글", fontSize 18, fontWeight 500 |

### 3.2 작성자 영역

| 속성 | 값 |
|------|-----|
| 아바타 | CircleAvatar radius 16, 프로필 이미지 or person 아이콘 |
| 닉네임 | textTheme.titleSmall |
| 시간 | textTheme.bodySmall, color grey |
| 더보기 | PopupMenuButton (본인: 수정/삭제, 타인: 신고) |

### 3.3 게시글 본문

| 속성 | 값 |
|------|-----|
| 제목 | textTheme.titleLarge |
| 내용 | textTheme.bodyMedium |
| 이미지 | 순차적 표시, cornerRadius 8px |

### 3.4 좋아요/댓글 액션 행

| 속성 | 값 |
|------|-----|
| 좋아요 | favorite/favorite_border + count (탭 시 토글) |
| 댓글 수 | chat_bubble_outline 20px + count |

### 3.5 댓글 (_CommentTile)

| 속성 | 값 |
|------|-----|
| 닉네임 | textTheme.titleSmall |
| 시간 | textTheme.bodySmall, color grey |
| 내용 | bodyMedium |
| 좋아요 | favorite_border 14px + count |
| 답글 | "답글" 텍스트, color blue |
| 더보기 | PopupMenu (본인: 삭제, 타인: 신고) |
| 대댓글 들여쓰기 | left 40px |

### 3.6 댓글 입력 바

| 속성 | 값 |
|------|-----|
| 상단 선 | grey.shade300 |
| 답글 대상 | "@닉네임 에게 답글" + 취소(X) 버튼 |
| TextField | hintText "댓글을 입력하세요", OutlineInputBorder |
| 전송 | send 아이콘 버튼 |

---

## 4. 인터랙션

| 이벤트 | 동작 |
|--------|------|
| 좋아요 탭 | togglePostLike, provider 갱신 |
| 댓글 좋아요 탭 | toggleCommentLike, provider 갱신 |
| 답글 탭 | replyToId/replyToName 설정, 입력창 포커스 |
| 댓글 전송 | create comment (parentId 있으면 대댓글) |
| 수정 | `/community/{postId}/edit`로 이동 |
| 삭제 | ConfirmDialog → delete → pop |
| 신고 | AlertDialog (사유 입력) → reportPost/reportComment |

---

## 5. 에러/로딩 상태

| 상태 | 표시 |
|------|------|
| 로딩 | LoadingIndicator |
| 에러 | ErrorView (메시지 + 재시도) |
| 게시글 없음 | "게시글을 찾을 수 없습니다" |
