# 커뮤니티 기능 설계

> 작성일: 2026-03-06

## 개요

배드민턴 앱에 자유게시판 형태의 커뮤니티 기능을 추가한다.
누구나 글을 쓸 수 있고, 댓글/대댓글/좋아요/신고 기능을 포함한다.

## 요구사항 요약

- 단일 게시판 (추후 카테고리 확장 예정)
- 댓글 + 대댓글 (2단 구조)
- 좋아요 (게시글, 댓글 모두)
- 이미지 첨부 최대 5장
- 작성자 프로필 닉네임 표시
- 신고 → 관리자 검토 → 삭제/제재 + 알림
- 제목+내용 검색
- 고객 하단 탭에 커뮤니티 추가 (사장님 탭은 변경 없음)

## 접근법

기존 `posts` 테이블과 분리하여 `community_posts` 등 별도 테이블을 신설한다.
샵 게시글(공지/이벤트)과 커뮤니티 자유게시판은 목적과 권한이 다르므로 테이블 분리가 적합하다.

---

## DB 스키마

### 테이블: community_posts

| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|---------|------|
| id | UUID | PK, DEFAULT uuid_generate_v7() | 게시글 ID |
| author_id | UUID | NOT NULL, FK → users(id) ON DELETE CASCADE | 작성자 |
| title | TEXT | NOT NULL | 제목 |
| content | TEXT | NOT NULL | 내용 |
| images | JSONB | NOT NULL, DEFAULT '[]'::jsonb | 이미지 URL 배열 (최대 5장) |
| like_count | INTEGER | NOT NULL, DEFAULT 0 | 좋아요 수 (비정규화) |
| comment_count | INTEGER | NOT NULL, DEFAULT 0 | 댓글 수 (비정규화) |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | 작성일 |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | 수정일 |

### 테이블: community_comments

| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|---------|------|
| id | UUID | PK, DEFAULT uuid_generate_v7() | 댓글 ID |
| post_id | UUID | NOT NULL, FK → community_posts(id) ON DELETE CASCADE | 게시글 |
| author_id | UUID | NOT NULL, FK → users(id) ON DELETE CASCADE | 작성자 |
| parent_id | UUID | NULLABLE, FK → community_comments(id) ON DELETE CASCADE | 부모 댓글 (NULL이면 1단 댓글) |
| content | TEXT | NOT NULL | 댓글 내용 |
| like_count | INTEGER | NOT NULL, DEFAULT 0 | 좋아요 수 (비정규화) |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | 작성일 |

### 테이블: community_likes

| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|---------|------|
| id | UUID | PK, DEFAULT uuid_generate_v7() | 좋아요 ID |
| user_id | UUID | NOT NULL, FK → users(id) ON DELETE CASCADE | 사용자 |
| post_id | UUID | NULLABLE, FK → community_posts(id) ON DELETE CASCADE | 게시글 (댓글이면 NULL) |
| comment_id | UUID | NULLABLE, FK → community_comments(id) ON DELETE CASCADE | 댓글 (게시글이면 NULL) |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | 생성일 |

**제약조건:**
- UNIQUE(user_id, post_id) WHERE post_id IS NOT NULL
- UNIQUE(user_id, comment_id) WHERE comment_id IS NOT NULL

### 테이블: community_reports

| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|---------|------|
| id | UUID | PK, DEFAULT uuid_generate_v7() | 신고 ID |
| reporter_id | UUID | NOT NULL, FK → users(id) ON DELETE CASCADE | 신고자 |
| post_id | UUID | NULLABLE, FK → community_posts(id) ON DELETE CASCADE | 신고 대상 게시글 |
| comment_id | UUID | NULLABLE, FK → community_comments(id) ON DELETE CASCADE | 신고 대상 댓글 |
| reason | TEXT | NOT NULL | 신고 사유 |
| status | TEXT | NOT NULL, DEFAULT 'pending', CHECK (status IN ('pending', 'resolved', 'dismissed')) | 처리 상태 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | 신고일 |

### 비정규화 카운트 갱신

`like_count`, `comment_count`는 DB 트리거로 자동 갱신한다.

### notifications 테이블 확장

기존 `type` CHECK에 `'community_report'` 추가 — 관리자 제재 시 알림 발송용.

---

## 화면 구성

### 새로운 화면 (4개)

| 화면 ID | 이름 | 역할 | 설명 |
|---------|------|------|------|
| community-list | 커뮤니티 목록 | common | 게시글 목록 + 검색 |
| community-detail | 게시글 상세 | common | 본문 + 댓글/대댓글 + 좋아요 |
| community-create | 게시글 작성/수정 | common | 제목, 내용, 이미지 첨부 |
| admin-community-reports | 신고 관리 | admin | 신고 목록 + 삭제/제재 처리 |

### 하단 탭 변경

**고객 (4탭 → 5탭):**
홈 | 샵검색 | 커뮤니티 | 이력 | MY

**사장님:** 변경 없음 (고객 모드에서 커뮤니티 접근)

### 라우트

```
/community                    → 커뮤니티 목록
/community/create             → 게시글 작성
/community/:postId            → 게시글 상세
/community/:postId/edit       → 게시글 수정
/admin/community-reports      → 신고 관리
```

---

## 기능 흐름

### 게시글 작성
1. 커뮤니티 목록 → FAB(+) → 작성 화면
2. 제목, 내용 입력 + 이미지 최대 5장 첨부
3. 저장 → community_posts INSERT → 목록 복귀

### 게시글 상세 + 좋아요
1. 목록에서 게시글 탭 → 상세 화면
2. 본문 + 이미지 + 좋아요 버튼 (하트 토글)
3. 좋아요 시 community_likes INSERT + 트리거로 like_count 갱신
4. 본인 글이면 수정/삭제 메뉴 표시

### 댓글/대댓글
1. 상세 화면 하단 댓글 입력창
2. 댓글 작성 → community_comments INSERT (parent_id = NULL)
3. "답글" 버튼 → 입력창에 "@닉네임" + parent_id 설정
4. 댓글에도 좋아요 가능, 본인 댓글 삭제 가능

### 검색
1. 목록 상단 검색바 → 제목+내용 검색 (ilike 또는 textSearch)

### 신고
1. 게시글/댓글 더보기(⋮) → "신고" → 사유 입력 → community_reports INSERT
2. "신고가 접수되었습니다" 토스트

### 관리자 제재
1. /admin/community-reports → 신고 목록 조회
2. 내용 확인 → 삭제 또는 dismiss 처리
3. 삭제 시 → 게시글/댓글 DELETE + 작성자에게 알림 (FCM + notifications INSERT)

---

## 코드 구조

### 신규 파일

**모델 (freezed)**
- lib/models/community_post.dart
- lib/models/community_comment.dart
- lib/models/community_report.dart

**리포지토리**
- lib/repositories/community_post_repository.dart
- lib/repositories/community_comment_repository.dart
- lib/repositories/community_like_repository.dart
- lib/repositories/community_report_repository.dart

**Provider**
- lib/providers/community_provider.dart

**화면**
- lib/screens/community/community_list/
- lib/screens/community/community_detail/
- lib/screens/community/community_create/
- lib/screens/admin/community_reports/

### 수정 파일

- lib/widgets/customer_bottom_nav.dart — 5탭 변경
- lib/app/router.dart — /community/*, /admin/community-reports 라우트 추가
- lib/models/enums.dart — notification type에 community_report 추가
- docs/database.md — 4개 테이블 추가
- docs/screen-registry.yaml — 4개 화면 등록

### Storage

community-images 버킷 신규 생성
