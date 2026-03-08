# 댓글 시스템 개편 설계

> 작성일: 2026-03-08
> 참고: 유튜브 댓글 UI/UX 방식

---

## 1. 개요

커뮤니티 게시글의 댓글 시스템을 유튜브 스타일로 전면 개편한다.

### 핵심 변경사항
- 프로필 아바타 표시 (1단 40px, 대댓글 32px)
- 2단 구조 강제 + @멘션으로 다중 대화 지원
- 대댓글 접기/펼치기 ("답글 N개 더보기")
- 게시글 작성자 배지 (`· 작성자`)
- 댓글/대댓글 알림 2종 추가

---

## 2. 댓글 구조

### 2.1 2단 제한 + @멘션

```
[아바타 40px] @닉네임 · 작성자 · 3시간 전
              댓글 내용입니다
              👍 27  답글

      ▼ 답글 2개 더보기

      [아바타 32px] @닉네임2 · 8시간 전
                    답글 내용입니다
                    👍 3  답글

      [아바타 32px] @닉네임3 · 4시간 전
                    @닉네임2 대댓글에 답하는 내용
                    👍 1  답글
```

### 2.2 대댓글 규칙
- 1단 댓글에 답글 → `parent_id` = 해당 댓글 ID
- 대댓글에 답글 → `parent_id` = 1단 부모 댓글 ID (2단 유지)
- 대댓글에 답글 시 내용 앞에 `@원댓글작성자` 자동 삽입
- @멘션은 Primary Blue(#2563EB) 색상으로 표시

### 2.3 대댓글 접기/펼치기
- 대댓글이 있는 1단 댓글: 기본 **접힘**
- "답글 N개 더보기 ▼" 버튼으로 펼침
- 펼친 후 "답글 숨기기 ▲" 버튼으로 접기
- 버튼 색상: Primary Blue(#2563EB)
- 버튼 위치: 1단 댓글 아래, 대댓글 영역 위

---

## 3. UI 컴포넌트 상세

### 3.1 1단 댓글 타일

| 요소 | 스펙 |
|------|------|
| 아바타 | 40px CircleAvatar, 프로필 이미지 또는 이니셜 |
| 닉네임 | titleSmall (14sp, SemiBold, textPrimary) |
| 작성자 배지 | `· 작성자` (12sp, Medium, Primary Blue) — 게시글 작성자만 |
| 시간 | bodySmall (12sp, textTertiary), `· 3시간 전` |
| 내용 | bodyMedium (14sp, textPrimary) |
| 좋아요 | `thumb_up_outlined` 16px + count (bodySmall, textTertiary) |
| 답글 버튼 | "답글" (12sp, Medium, textSecondary) |
| 더보기 | `more_vert` PopupMenu (본인: 삭제 / 타인: 신고) |
| 패딩 | 좌 16px (아바타 시작), 우 16px |
| 아바타-콘텐츠 간격 | 12px |

### 3.2 대댓글 타일

| 요소 | 스펙 |
|------|------|
| 아바타 | 32px CircleAvatar |
| 들여쓰기 | 좌측 52px (40px 아바타 + 12px gap) |
| @멘션 | bodyMedium Bold, Primary Blue (#2563EB) |
| 나머지 | 1단 댓글과 동일 |

### 3.3 답글 펼치기 버튼

| 요소 | 스펙 |
|------|------|
| 위치 | 1단 댓글 아래, 들여쓰기 52px |
| 텍스트 | "답글 N개 더보기 ▼" / "답글 숨기기 ▲" |
| 스타일 | labelMedium (12sp, Medium), Primary Blue |
| 아이콘 | `expand_more` / `expand_less` 16px |

### 3.4 댓글 입력 바

| 상태 | UI |
|------|-----|
| 기본 | `[댓글을 입력하세요...]  [전송]` |
| 답글 모드 | `[@닉네임에게 답글 중 ✕]` + `[답글을 입력하세요...]  [전송]` |
| 대댓글에 답글 | `[@닉네임에게 답글 중 ✕]` + 전송 시 내용 앞에 `@닉네임` 자동 삽입 |

---

## 4. 작성자 배지

게시글 작성자가 본인 글에 댓글을 작성하면 닉네임 옆에 배지 표시.

```
@홍길동 · 작성자 · 3시간 전
```

| 요소 | 스펙 |
|------|------|
| 텍스트 | "작성자" |
| 구분자 | " · " (중간점) |
| 색상 | Primary Blue (#2563EB) |
| 크기 | labelSmall (12sp, Medium) |
| 조건 | `comment.authorId == post.authorId` |

---

## 5. 알림 시스템

### 5.1 알림 타입 추가

| 타입 | 트리거 | 수신자 | 메시지 |
|------|--------|--------|--------|
| `commentOnPost` | 게시글에 댓글 작성 | 게시글 작성자 | "**닉네임**님이 회원님의 게시글에 댓글을 남겼습니다" |
| `replyOnComment` | 댓글에 대댓글 작성 | 댓글 작성자 | "**닉네임**님이 회원님의 댓글에 답글을 남겼습니다" |

### 5.2 제외 조건
- 본인이 본인 글에 댓글 → 알림 안 보냄
- 본인이 본인 댓글에 답글 → 알림 안 보냄

### 5.3 DB 변경

`notifications` 테이블에 `post_id` 컬럼 추가:

```sql
ALTER TABLE notifications ADD COLUMN post_id UUID REFERENCES community_posts(id) ON DELETE SET NULL;
```

`NotificationType` enum 확장:
```dart
enum NotificationType {
  // 기존
  statusChange, completion, notice, receipt,
  shopApproval, shopRejection, communityReport,
  // 신규
  commentOnPost,    // 내 게시글에 댓글
  replyOnComment,   // 내 댓글에 답글
}
```

### 5.4 알림 생성 위치

Supabase DB Trigger로 구현:
- `community_comments` INSERT 시 trigger 실행
- `parent_id` NULL → `commentOnPost` 알림 생성 (게시글 작성자에게)
- `parent_id` NOT NULL → `replyOnComment` 알림 생성 (부모 댓글 작성자에게)
- 본인 제외 조건 체크

---

## 6. 변경 전/후 비교

| 항목 | 변경 전 | 변경 후 |
|------|---------|---------|
| 아바타 | 미표시 | 40px/32px CircleAvatar |
| 대댓글 UI | 좌측 40px 들여쓰기만 | 52px 들여쓰기 + 작은 아바타 |
| 대대댓글 | 3단 이상 가능 (UI 미지원) | 2단 강제 + @멘션 |
| 작성자 표시 | 없음 | `· 작성자` 배지 |
| @멘션 | 없음 | 대댓글 답글 시 자동 파란색 멘션 |
| 댓글 알림 | 없음 | commentOnPost + replyOnComment |
| 대댓글 접기 | 항상 펼침 | 기본 접힘 + "답글 N개 더보기" |

---

## 7. 영향 범위

### 코드 변경
| 파일 | 변경 내용 |
|------|----------|
| `lib/models/community_comment.dart` | 변경 없음 (기존 구조 충분) |
| `lib/models/notification_item.dart` | `commentOnPost`, `replyOnComment` 타입 추가, `postId` 필드 추가 |
| `lib/repositories/community_comment_repository.dart` | 대댓글 생성 시 parent 2단 검증 로직 |
| `lib/repositories/notification_repository.dart` | `postId` 필드 지원 |
| `lib/providers/community_provider.dart` | 댓글 생성 시 @멘션 자동 삽입 로직 |
| `lib/screens/community/community_detail/community_detail_screen.dart` | 전체 댓글 UI 리빌드 |

### 문서 변경
| 파일 | 변경 내용 |
|------|----------|
| `docs/database.md` | notifications.post_id 추가 |
| `docs/ui-specs/community-detail.md` | 댓글 섹션 전면 재작성 |
| `docs/pages/community-detail/state.md` | 접기/펼치기 상태, @멘션 상태 추가 |

### DB 변경 (Migration)
| 변경 | SQL |
|------|-----|
| notifications에 post_id 추가 | `ALTER TABLE notifications ADD COLUMN post_id UUID REFERENCES community_posts(id) ON DELETE SET NULL` |
| 댓글 알림 trigger 생성 | `CREATE FUNCTION notify_on_comment() ...` + `CREATE TRIGGER ...` |
