# 게시글 상세 — UI 화면 스펙

> 최종 수정일: 2026-03-08

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
|  [아바타] ─┐                     |
|            │  (스레드 선)        |
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

### 3.5 댓글 (_CommentSection)

댓글 목록은 1단 댓글을 기준으로 렌더링하며, 대댓글은 각 1단 댓글 하단에 접기/펼치기 방식으로 표시한다.

#### 3.5.1 1단 댓글 타일 (_CommentTile)

| 요소 | 스펙 |
|------|------|
| 아바타 | 40px CircleAvatar, 프로필 이미지 또는 이니셜 |
| 닉네임 | titleSmall (14sp, SemiBold, textPrimary) |
| 작성자 배지 | `· 작성자` (12sp, Medium, Primary #2563EB) — `comment.authorId == post.authorId`인 경우만 표시 |
| 시간 | bodySmall (12sp, textTertiary), 예: `· 3시간 전` |
| 내용 | bodyMedium (14sp, textPrimary) |
| 좋아요 | thumb_up_outlined 16px + count (bodySmall, textTertiary) |
| 답글 버튼 | "답글" (12sp, Medium, textSecondary), 탭 시 답글 모드 진입 |
| 더보기 | more_vert PopupMenu — 본인: 삭제 / 타인: 신고 |
| 패딩 | 좌 16px, 우 16px |
| 아바타-콘텐츠 간격 | 12px |

#### 3.5.2 대댓글 타일 (_ReplyTile)

| 요소 | 스펙 |
|------|------|
| 아바타 | 32px CircleAvatar, 프로필 이미지 또는 이니셜 |
| 들여쓰기 | 좌측 52px (40px 아바타 + 12px gap) |
| @멘션 | bodyMedium Bold, Primary (#2563EB), 내용 앞에 자동 삽입 |
| 나머지 요소 | 1단 댓글 타일과 동일 (닉네임, 작성자 배지, 시간, 내용, 좋아요, 더보기) |

#### 3.5.3 답글 펼치기/숨기기 버튼 (_ReplyToggleButton)

| 요소 | 스펙 |
|------|------|
| 위치 | 1단 댓글 아래, 들여쓰기 52px |
| 텍스트 (접힌 상태) | "답글 N개 더보기" + expand_more 아이콘 16px |
| 텍스트 (펼친 상태) | "답글 숨기기" + expand_less 아이콘 16px |
| 스타일 | labelMedium (12sp, Medium), Primary (#2563EB) |
| 표시 조건 | 해당 댓글의 대댓글 수 > 0인 경우에만 표시 |

#### 3.5.4 작성자 배지

| 속성 | 값 |
|------|-----|
| 조건 | `comment.authorId == post.authorId` |
| 텍스트 | "작성자" |
| 구분자 | " · " |
| 색상 | Primary (#2563EB) |
| 크기 | labelSmall (12sp, Medium) |

#### 3.5.5 스레드 연결선 (_ThreadLine)

1단 댓글 아바타 아래에서 마지막 대댓글까지 수직으로 이어지는 시각적 연결선이다.

| 요소 | 스펙 |
|------|------|
| 색상 | `AppTheme.border` (`#E8E0D8`) |
| 두께 | 2px (렌더링 최소 단위; 디자인 의도 1.5px) |
| X 위치 | 1단 댓글 아바타 컬럼 중앙 (아바타 너비 36px의 중심 = 18px) |
| 범위 | 아바타 하단 ~ 마지막 대댓글 하단 |
| 표시 조건 | 대댓글이 1개 이상 존재할 때 (접힘/펼침 상태 무관) |
| 구현 방법 | `IntrinsicHeight` + `Row` + `Container(width: 2, color: AppTheme.border)` |
| Pencil 노드 | `MvXQ5` (Rectangle, ThreadLine), `nZEJi` (commentAvatarCol) |

**구현 레이아웃 구조:**
```
Row (37A0r, Comment 1, horizontal, alignItems: stretch)
├── Column (nZEJi, commentAvatarCol, width: 36, alignItems: center)
│   ├── Ellipse (1MbTz, Avatar, 36×36)
│   └── Rectangle (MvXQ5, ThreadLine, width: 2, height: 56, fill: #E8E0D8)
└── Column (tzw5a, commentBody, width: fill)
    ├── commentHeader (이름 · 시간 · 좋아요)
    ├── content (댓글 내용)
    ├── replyBtn ("답글")
    └── Row (wnhHu, Reply 1, horizontal)
        ├── Column (kMK5c, replyAvatarCol, width: 28)
        │   └── Ellipse (ZBJG5, Avatar, 28×28)
        └── Column (Q9wHH, replyBody, width: fill)
            ├── replyHeader (이름 · 시간)
            └── content (대댓글 내용)
```

### 3.6 댓글 입력 바 (_CommentInputBar)

| 상태 | UI |
|------|-----|
| 기본 | `[댓글을 입력하세요...]  [전송]` |
| 답글 모드 | `[@닉네임에게 답글 중 ✕]` 칩 + `[답글을 입력하세요...]  [전송]` |

| 속성 | 값 |
|------|-----|
| 상단 선 | grey.shade300, 1px |
| 답글 칩 | 닉네임 텍스트 + close 아이콘(✕), 탭 시 답글 모드 해제 |
| TextField | hintText "댓글을 입력하세요" / 답글 모드 시 "답글을 입력하세요", OutlineInputBorder |
| 전송 버튼 | send 아이콘 버튼, 내용이 비어 있으면 비활성화 |
| 답글 전송 | 전송 시 content 앞에 `@닉네임 ` 자동 삽입 (replyToName 기반) |

### 3.7 알림 타입 (댓글 관련)

| 타입 | 트리거 | 수신자 | 메시지 |
|------|--------|--------|--------|
| `comment_on_post` | 게시글에 1단 댓글 작성 | 게시글 작성자 | "{닉네임}님이 회원님의 게시글에 댓글을 남겼습니다" |
| `reply_on_comment` | 댓글에 대댓글 작성 | 부모 댓글 작성자 | "{닉네임}님이 회원님의 댓글에 답글을 남겼습니다" |

> 알림은 DB 트리거(`trg_notify_on_comment`)가 자동 생성한다. 자기 자신에게는 발송하지 않는다.

---

## 4. 인터랙션

| 이벤트 | 동작 |
|--------|------|
| 좋아요 탭 | togglePostLike, provider 갱신 |
| 댓글 좋아요 탭 | toggleCommentLike, provider 갱신 |
| 답글 탭 | replyToId/replyToName/mentionName 설정, 입력창 포커스 |
| 답글 모드 취소 (✕) | replyToId, replyToName, mentionName 초기화 |
| 댓글 전송 | create comment (parentId 있으면 대댓글, content 앞에 @멘션 자동 삽입) |
| 답글 펼치기/숨기기 탭 | _expanded[commentId] 토글 |
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
