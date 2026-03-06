# 커뮤니티 기능 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 자유게시판 커뮤니티 기능 추가 (게시글 CRUD, 댓글/대댓글, 좋아요, 신고, 관리자 제재)

**Architecture:** 기존 `posts`와 분리된 `community_posts/comments/likes/reports` 테이블. freezed 모델 + Repository + Riverpod Notifier 패턴. 고객 하단 탭에 커뮤니티 추가.

**Tech Stack:** Flutter 3.38.x, Riverpod 2.6.x, freezed, go_router, Supabase, mocktail

**설계 문서:** `docs/plans/2026-03-06-community-design.md`

---

## Task 1: DB 마이그레이션 — 4개 테이블 + 트리거

**Files:**
- Create: Supabase migration (MCP 도구 사용)

**Step 1: community_posts 테이블 생성**

```sql
CREATE TABLE community_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  images JSONB NOT NULL DEFAULT '[]'::jsonb,
  like_count INTEGER NOT NULL DEFAULT 0 CHECK (like_count >= 0),
  comment_count INTEGER NOT NULL DEFAULT 0 CHECK (comment_count >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_community_posts_author ON community_posts(author_id);
CREATE INDEX idx_community_posts_created ON community_posts(created_at DESC);
```

**Step 2: community_comments 테이블 생성**

```sql
CREATE TABLE community_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
  post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES community_comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  like_count INTEGER NOT NULL DEFAULT 0 CHECK (like_count >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_community_comments_post ON community_comments(post_id);
CREATE INDEX idx_community_comments_parent ON community_comments(parent_id);
```

**Step 3: community_likes 테이블 생성**

```sql
CREATE TABLE community_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES community_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_like_target CHECK (
    (post_id IS NOT NULL AND comment_id IS NULL) OR
    (post_id IS NULL AND comment_id IS NOT NULL)
  )
);

CREATE UNIQUE INDEX idx_community_likes_post ON community_likes(user_id, post_id) WHERE post_id IS NOT NULL;
CREATE UNIQUE INDEX idx_community_likes_comment ON community_likes(user_id, comment_id) WHERE comment_id IS NOT NULL;
```

**Step 4: community_reports 테이블 생성**

```sql
CREATE TABLE community_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES community_comments(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'resolved', 'dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_report_target CHECK (
    (post_id IS NOT NULL AND comment_id IS NULL) OR
    (post_id IS NULL AND comment_id IS NOT NULL)
  )
);

CREATE INDEX idx_community_reports_status ON community_reports(status);
```

**Step 5: 비정규화 카운트 트리거**

```sql
-- 댓글 수 트리거
CREATE OR REPLACE FUNCTION update_community_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_posts SET comment_count = GREATEST(comment_count - 1, 0) WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_community_comment_count
AFTER INSERT OR DELETE ON community_comments
FOR EACH ROW EXECUTE FUNCTION update_community_post_comment_count();

-- 게시글 좋아요 수 트리거
CREATE OR REPLACE FUNCTION update_community_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.post_id IS NOT NULL THEN
    UPDATE community_posts SET like_count = like_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' AND OLD.post_id IS NOT NULL THEN
    UPDATE community_posts SET like_count = GREATEST(like_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_community_post_like_count
AFTER INSERT OR DELETE ON community_likes
FOR EACH ROW EXECUTE FUNCTION update_community_post_like_count();

-- 댓글 좋아요 수 트리거
CREATE OR REPLACE FUNCTION update_community_comment_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.comment_id IS NOT NULL THEN
    UPDATE community_comments SET like_count = like_count + 1 WHERE id = NEW.comment_id;
  ELSIF TG_OP = 'DELETE' AND OLD.comment_id IS NOT NULL THEN
    UPDATE community_comments SET like_count = GREATEST(like_count - 1, 0) WHERE id = OLD.comment_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_community_comment_like_count
AFTER INSERT OR DELETE ON community_likes
FOR EACH ROW EXECUTE FUNCTION update_community_comment_like_count();

-- updated_at 자동 갱신
CREATE OR REPLACE FUNCTION update_community_post_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_community_post_updated_at
BEFORE UPDATE ON community_posts
FOR EACH ROW EXECUTE FUNCTION update_community_post_updated_at();
```

**Step 6: notifications type CHECK 확장**

```sql
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
  CHECK (type IN ('status_change', 'completion', 'notice', 'receipt', 'shop_approval', 'shop_rejection', 'community_report'));
```

**Step 7: RLS 정책**

```sql
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_reports ENABLE ROW LEVEL SECURITY;

-- community_posts: 누구나 읽기, 본인만 쓰기/수정/삭제
CREATE POLICY "community_posts_select" ON community_posts FOR SELECT USING (true);
CREATE POLICY "community_posts_insert" ON community_posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "community_posts_update" ON community_posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "community_posts_delete" ON community_posts FOR DELETE USING (
  auth.uid() = author_id OR
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- community_comments: 누구나 읽기, 본인만 쓰기/삭제
CREATE POLICY "community_comments_select" ON community_comments FOR SELECT USING (true);
CREATE POLICY "community_comments_insert" ON community_comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "community_comments_delete" ON community_comments FOR DELETE USING (
  auth.uid() = author_id OR
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- community_likes: 누구나 읽기, 본인만 쓰기/삭제
CREATE POLICY "community_likes_select" ON community_likes FOR SELECT USING (true);
CREATE POLICY "community_likes_insert" ON community_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "community_likes_delete" ON community_likes FOR DELETE USING (auth.uid() = user_id);

-- community_reports: 본인 신고만 쓰기, 관리자만 전체 조회
CREATE POLICY "community_reports_insert" ON community_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "community_reports_select" ON community_reports FOR SELECT USING (
  auth.uid() = reporter_id OR
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "community_reports_update" ON community_reports FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```

**Step 8: Storage 버킷 생성**

```sql
INSERT INTO storage.buckets (id, name, public) VALUES ('community-images', 'community-images', true);

CREATE POLICY "community_images_select" ON storage.objects FOR SELECT USING (bucket_id = 'community-images');
CREATE POLICY "community_images_insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'community-images' AND auth.role() = 'authenticated');
CREATE POLICY "community_images_delete" ON storage.objects FOR DELETE USING (bucket_id = 'community-images' AND auth.uid()::text = (storage.foldername(name))[1]);
```

**Step 9: 마이그레이션 적용**

Run: Supabase MCP `apply_migration` 도구 사용

**Step 10: 커밋**

```bash
git add -A && git commit -m "feat: 커뮤니티 DB 마이그레이션 (4 테이블 + 트리거 + RLS)"
```

---

## Task 2: Enum 추가 — NotificationType, ReportStatus

**Files:**
- Modify: `lib/models/enums.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/models/enums_test.dart 에 추가
group('NotificationType', () {
  test('communityReport를 JSON 변환할 수 있다', () {
    expect(NotificationType.communityReport.toJson(), 'community_report');
  });

  test('community_report를 fromJson할 수 있다', () {
    expect(NotificationType.fromJson('community_report'), NotificationType.communityReport);
  });
});

group('ReportStatus', () {
  test('toJson이 올바른 값을 반환한다', () {
    expect(ReportStatus.pending.toJson(), 'pending');
    expect(ReportStatus.resolved.toJson(), 'resolved');
    expect(ReportStatus.dismissed.toJson(), 'dismissed');
  });

  test('fromJson이 올바른 값을 반환한다', () {
    expect(ReportStatus.fromJson('pending'), ReportStatus.pending);
    expect(ReportStatus.fromJson('resolved'), ReportStatus.resolved);
    expect(ReportStatus.fromJson('dismissed'), ReportStatus.dismissed);
  });

  test('label이 올바른 한국어를 반환한다', () {
    expect(ReportStatus.pending.label, '대기');
    expect(ReportStatus.resolved.label, '처리됨');
    expect(ReportStatus.dismissed.label, '기각');
  });
});
```

**Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/models/enums_test.dart`
Expected: FAIL

**Step 3: enums.dart 수정**

`lib/models/enums.dart`에 추가:

```dart
// NotificationType enum에 communityReport 추가
enum NotificationType {
  statusChange,
  completion,
  notice,
  receipt,
  shopApproval,
  shopRejection,
  communityReport;  // 추가

  String toJson() => switch (this) {
        statusChange => 'status_change',
        completion => 'completion',
        notice => 'notice',
        receipt => 'receipt',
        shopApproval => 'shop_approval',
        shopRejection => 'shop_rejection',
        communityReport => 'community_report',  // 추가
      };

  static NotificationType fromJson(String value) => switch (value) {
        'status_change' => statusChange,
        'completion' => completion,
        'notice' => notice,
        'receipt' => receipt,
        'shop_approval' => shopApproval,
        'shop_rejection' => shopRejection,
        'community_report' => communityReport,  // 추가
        _ => throw ArgumentError('Unknown NotificationType: $value'),
      };
}

// 새 enum 추가
enum ReportStatus {
  pending,
  resolved,
  dismissed;

  String toJson() => switch (this) {
        pending => 'pending',
        resolved => 'resolved',
        dismissed => 'dismissed',
      };

  static ReportStatus fromJson(String value) => switch (value) {
        'pending' => pending,
        'resolved' => resolved,
        'dismissed' => dismissed,
        _ => pending,
      };

  String get label => switch (this) {
        pending => '대기',
        resolved => '처리됨',
        dismissed => '기각',
      };
}
```

**Step 4: 테스트 통과 확인**

Run: `flutter test test/models/enums_test.dart`
Expected: PASS

**Step 5: 커밋**

```bash
git add lib/models/enums.dart test/models/enums_test.dart
git commit -m "feat: NotificationType에 communityReport, ReportStatus enum 추가"
```

---

## Task 3: Freezed 모델 — CommunityPost

**Files:**
- Create: `lib/models/community_post.dart`
- Test: `test/models/community_post_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/models/community_post_test.dart
import 'package:badminton_app/models/community_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityPost', () {
    test('인스턴스를 생성할 수 있다', () {
      final post = CommunityPost(
        id: 'test-id',
        authorId: 'author-id',
        title: '테스트 제목',
        content: '테스트 내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      expect(post.id, 'test-id');
      expect(post.title, '테스트 제목');
      expect(post.images, isEmpty);
      expect(post.likeCount, 0);
      expect(post.commentCount, 0);
    });

    test('JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'test-id',
        'author_id': 'author-id',
        'title': '제목',
        'content': '내용',
        'images': ['img1.jpg'],
        'like_count': 5,
        'comment_count': 3,
        'created_at': '2026-03-01T00:00:00.000Z',
        'updated_at': '2026-03-01T00:00:00.000Z',
      };
      final post = CommunityPost.fromJson(json);
      expect(post.authorId, 'author-id');
      expect(post.likeCount, 5);
      expect(post.images, ['img1.jpg']);
    });

    test('authorName은 nullable이다', () {
      final post = CommunityPost(
        id: 'id',
        authorId: 'aid',
        title: 't',
        content: 'c',
        authorName: '홍길동',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      expect(post.authorName, '홍길동');
    });
  });
}
```

**Step 2: 테스트 실행 → 실패**

Run: `flutter test test/models/community_post_test.dart`

**Step 3: 모델 구현**

```dart
// lib/models/community_post.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

@freezed
class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required String title,
    required String content,
    @Default([]) List<String> images,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // JOIN으로 가져오는 작성자 이름 (DB 컬럼 아님)
    @JsonKey(name: 'author_name', includeToJson: false) String? authorName,
    @JsonKey(name: 'author_profile_image_url', includeToJson: false) String? authorProfileImageUrl,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(_flattenAuthor(json));
}

/// Supabase JOIN 결과에서 author 정보를 flat하게 변환한다.
/// { "author": { "name": "홍길동", "profile_image_url": "..." } }
/// → { "author_name": "홍길동", "author_profile_image_url": "..." }
Map<String, dynamic> _flattenAuthor(Map<String, dynamic> json) {
  final copy = Map<String, dynamic>.from(json);
  if (copy['author'] is Map<String, dynamic>) {
    final author = copy['author'] as Map<String, dynamic>;
    copy['author_name'] = author['name'];
    copy['author_profile_image_url'] = author['profile_image_url'];
    copy.remove('author');
  }
  return copy;
}
```

**Step 4: 코드 생성 + 테스트**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/models/community_post_test.dart`
Expected: PASS

**Step 5: 커밋**

```bash
git add lib/models/community_post.dart lib/models/community_post.freezed.dart lib/models/community_post.g.dart test/models/community_post_test.dart
git commit -m "feat: CommunityPost freezed 모델 추가"
```

---

## Task 4: Freezed 모델 — CommunityComment

**Files:**
- Create: `lib/models/community_comment.dart`
- Test: `test/models/community_comment_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/models/community_comment_test.dart
import 'package:badminton_app/models/community_comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityComment', () {
    test('1단 댓글을 생성할 수 있다', () {
      final comment = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'a1',
        content: '댓글 내용',
        createdAt: DateTime(2026, 3, 1),
      );
      expect(comment.parentId, isNull);
      expect(comment.likeCount, 0);
    });

    test('대댓글을 생성할 수 있다', () {
      final reply = CommunityComment(
        id: 'c2',
        postId: 'p1',
        authorId: 'a2',
        parentId: 'c1',
        content: '대댓글',
        createdAt: DateTime(2026, 3, 1),
      );
      expect(reply.parentId, 'c1');
    });

    test('JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'c1',
        'post_id': 'p1',
        'author_id': 'a1',
        'parent_id': null,
        'content': '댓글',
        'like_count': 2,
        'created_at': '2026-03-01T00:00:00.000Z',
      };
      final comment = CommunityComment.fromJson(json);
      expect(comment.postId, 'p1');
      expect(comment.likeCount, 2);
    });
  });
}
```

**Step 2: 모델 구현**

```dart
// lib/models/community_comment.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment.freezed.dart';
part 'community_comment.g.dart';

@freezed
class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'parent_id') String? parentId,
    required String content,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'author_name', includeToJson: false) String? authorName,
    @JsonKey(name: 'author_profile_image_url', includeToJson: false) String? authorProfileImageUrl,
  }) = _CommunityComment;

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentFromJson(_flattenCommentAuthor(json));
}

Map<String, dynamic> _flattenCommentAuthor(Map<String, dynamic> json) {
  final copy = Map<String, dynamic>.from(json);
  if (copy['author'] is Map<String, dynamic>) {
    final author = copy['author'] as Map<String, dynamic>;
    copy['author_name'] = author['name'];
    copy['author_profile_image_url'] = author['profile_image_url'];
    copy.remove('author');
  }
  return copy;
}
```

**Step 3: 코드 생성 + 테스트**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/models/community_comment_test.dart`

**Step 4: 커밋**

```bash
git add lib/models/community_comment.dart lib/models/community_comment.freezed.dart lib/models/community_comment.g.dart test/models/community_comment_test.dart
git commit -m "feat: CommunityComment freezed 모델 추가"
```

---

## Task 5: Freezed 모델 — CommunityReport

**Files:**
- Create: `lib/models/community_report.dart`
- Test: `test/models/community_report_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/models/community_report_test.dart
import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityReport', () {
    test('게시글 신고를 생성할 수 있다', () {
      final report = CommunityReport(
        id: 'r1',
        reporterId: 'u1',
        postId: 'p1',
        reason: '부적절한 내용',
        status: ReportStatus.pending,
        createdAt: DateTime(2026, 3, 1),
      );
      expect(report.postId, 'p1');
      expect(report.commentId, isNull);
    });

    test('JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'r1',
        'reporter_id': 'u1',
        'post_id': 'p1',
        'comment_id': null,
        'reason': '스팸',
        'status': 'pending',
        'created_at': '2026-03-01T00:00:00.000Z',
      };
      final report = CommunityReport.fromJson(json);
      expect(report.status, ReportStatus.pending);
    });
  });
}
```

**Step 2: 모델 구현**

```dart
// lib/models/community_report.dart
import 'package:badminton_app/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_report.freezed.dart';
part 'community_report.g.dart';

@freezed
class CommunityReport with _$CommunityReport {
  const factory CommunityReport({
    required String id,
    @JsonKey(name: 'reporter_id') required String reporterId,
    @JsonKey(name: 'post_id') String? postId,
    @JsonKey(name: 'comment_id') String? commentId,
    required String reason,
    @JsonKey(fromJson: ReportStatus.fromJson, toJson: _reportStatusToJson)
    required ReportStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CommunityReport;

  factory CommunityReport.fromJson(Map<String, dynamic> json) =>
      _$CommunityReportFromJson(json);
}

String _reportStatusToJson(ReportStatus status) => status.toJson();
```

**Step 3: 코드 생성 + 테스트**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/models/community_report_test.dart`

**Step 4: 커밋**

```bash
git add lib/models/community_report.dart lib/models/community_report.freezed.dart lib/models/community_report.g.dart test/models/community_report_test.dart
git commit -m "feat: CommunityReport freezed 모델 추가"
```

---

## Task 6: 테스트 Fixture 추가

**Files:**
- Modify: `test/helpers/fixtures.dart`

**Step 1: 커뮤니티 테스트 데이터 추가**

```dart
// test/helpers/fixtures.dart 하단에 추가
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/models/community_report.dart';

final testCommunityPost = CommunityPost(
  id: 'cc0e8400-e29b-41d4-a716-446655440010',
  authorId: '550e8400-e29b-41d4-a716-446655440000',
  title: '배드민턴 라켓 추천해주세요',
  content: '초보자용 라켓 추천 부탁드립니다.',
  images: ['https://example.com/community1.jpg'],
  likeCount: 3,
  commentCount: 2,
  authorName: '홍길동',
  createdAt: DateTime(2026, 3, 1, 10),
  updatedAt: DateTime(2026, 3, 1, 10),
);

final testCommunityComment = CommunityComment(
  id: 'dd0e8400-e29b-41d4-a716-446655440011',
  postId: 'cc0e8400-e29b-41d4-a716-446655440010',
  authorId: '550e8400-e29b-41d4-a716-446655440099',
  content: '아스트록스 88D 추천합니다!',
  likeCount: 1,
  authorName: '김사장',
  createdAt: DateTime(2026, 3, 1, 11),
);

final testCommunityReply = CommunityComment(
  id: 'dd0e8400-e29b-41d4-a716-446655440012',
  postId: 'cc0e8400-e29b-41d4-a716-446655440010',
  authorId: '550e8400-e29b-41d4-a716-446655440000',
  parentId: 'dd0e8400-e29b-41d4-a716-446655440011',
  content: '감사합니다! 참고할게요.',
  authorName: '홍길동',
  createdAt: DateTime(2026, 3, 1, 12),
);

final testCommunityReport = CommunityReport(
  id: 'ee0e8400-e29b-41d4-a716-446655440013',
  reporterId: '550e8400-e29b-41d4-a716-446655440000',
  postId: 'cc0e8400-e29b-41d4-a716-446655440010',
  reason: '부적절한 내용',
  status: ReportStatus.pending,
  createdAt: DateTime(2026, 3, 1, 13),
);
```

**Step 2: 커밋**

```bash
git add test/helpers/fixtures.dart
git commit -m "feat: 커뮤니티 테스트 fixture 추가"
```

---

## Task 7: Repository — CommunityPostRepository

**Files:**
- Create: `lib/repositories/community_post_repository.dart`
- Test: `test/repositories/community_post_repository_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/repositories/community_post_repository_test.dart
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityPostRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityPostRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityPostRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityPostRepository>());
    });

    test('client를 생성자로 주입받는다', () {
      expect(repository.client, equals(mockClient));
    });

    test('getAll 메서드가 정의되어 있다', () {
      expect(repository.getAll, isA<Function>());
    });

    test('getById 메서드가 정의되어 있다', () {
      expect(repository.getById, isA<Function>());
    });

    test('create 메서드가 정의되어 있다', () {
      expect(repository.create, isA<Function>());
    });

    test('update 메서드가 정의되어 있다', () {
      expect(repository.update, isA<Function>());
    });

    test('delete 메서드가 정의되어 있다', () {
      expect(repository.delete, isA<Function>());
    });

    test('search 메서드가 정의되어 있다', () {
      expect(repository.search, isA<Function>());
    });
  });

  group('communityPostRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostRepositoryProvider, isA<Provider<CommunityPostRepository>>());
    });
  });
}
```

**Step 2: 구현**

```dart
// lib/repositories/community_post_repository.dart
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityPostRepositoryProvider =
    Provider<CommunityPostRepository>((ref) {
  return CommunityPostRepository(ref.watch(supabaseProvider));
});

class CommunityPostRepository {
  final SupabaseClient client;

  CommunityPostRepository(this.client);

  static const _selectWithAuthor =
      '*, author:users!community_posts_author_id_fkey(name, profile_image_url)';

  Future<List<CommunityPost>> getAll({int limit = 20, int offset = 0}) async {
    try {
      final data = await client
          .from('community_posts')
          .select(_selectWithAuthor)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return data.map(CommunityPost.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<CommunityPost?> getById(String id) async {
    try {
      final data = await client
          .from('community_posts')
          .select(_selectWithAuthor)
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return CommunityPost.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<CommunityPost> create({
    required String authorId,
    required String title,
    required String content,
    List<String> images = const [],
  }) async {
    try {
      final data = await client.from('community_posts').insert({
        'author_id': authorId,
        'title': title,
        'content': content,
        'images': images,
      }).select(_selectWithAuthor).single();
      return CommunityPost.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<CommunityPost> update(
    String postId, {
    String? title,
    String? content,
    List<String>? images,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (images != null) updates['images'] = images;

      final data = await client
          .from('community_posts')
          .update(updates)
          .eq('id', postId)
          .select(_selectWithAuthor)
          .single();
      return CommunityPost.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> delete(String postId) async {
    try {
      await client.from('community_posts').delete().eq('id', postId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<CommunityPost>> search(String query) async {
    try {
      final data = await client
          .from('community_posts')
          .select(_selectWithAuthor)
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);
      return data.map(CommunityPost.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
```

**Step 3: 테스트 통과 확인**

Run: `flutter test test/repositories/community_post_repository_test.dart`

**Step 4: 커밋**

```bash
git add lib/repositories/community_post_repository.dart test/repositories/community_post_repository_test.dart
git commit -m "feat: CommunityPostRepository 추가"
```

---

## Task 8: Repository — CommunityCommentRepository

**Files:**
- Create: `lib/repositories/community_comment_repository.dart`
- Test: `test/repositories/community_comment_repository_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/repositories/community_comment_repository_test.dart
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityCommentRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityCommentRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityCommentRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityCommentRepository>());
    });

    test('getByPostId 메서드가 정의되어 있다', () {
      expect(repository.getByPostId, isA<Function>());
    });

    test('create 메서드가 정의되어 있다', () {
      expect(repository.create, isA<Function>());
    });

    test('delete 메서드가 정의되어 있다', () {
      expect(repository.delete, isA<Function>());
    });
  });

  group('communityCommentRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityCommentRepositoryProvider, isA<Provider<CommunityCommentRepository>>());
    });
  });
}
```

**Step 2: 구현**

```dart
// lib/repositories/community_comment_repository.dart
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityCommentRepositoryProvider =
    Provider<CommunityCommentRepository>((ref) {
  return CommunityCommentRepository(ref.watch(supabaseProvider));
});

class CommunityCommentRepository {
  final SupabaseClient client;

  CommunityCommentRepository(this.client);

  static const _selectWithAuthor =
      '*, author:users!community_comments_author_id_fkey(name, profile_image_url)';

  Future<List<CommunityComment>> getByPostId(String postId) async {
    try {
      final data = await client
          .from('community_comments')
          .select(_selectWithAuthor)
          .eq('post_id', postId)
          .order('created_at');
      return data.map(CommunityComment.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<CommunityComment> create({
    required String postId,
    required String authorId,
    required String content,
    String? parentId,
  }) async {
    try {
      final data = await client.from('community_comments').insert({
        'post_id': postId,
        'author_id': authorId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      }).select(_selectWithAuthor).single();
      return CommunityComment.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> delete(String commentId) async {
    try {
      await client.from('community_comments').delete().eq('id', commentId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
```

**Step 3: 테스트 + 커밋**

Run: `flutter test test/repositories/community_comment_repository_test.dart`

```bash
git add lib/repositories/community_comment_repository.dart test/repositories/community_comment_repository_test.dart
git commit -m "feat: CommunityCommentRepository 추가"
```

---

## Task 9: Repository — CommunityLikeRepository

**Files:**
- Create: `lib/repositories/community_like_repository.dart`
- Test: `test/repositories/community_like_repository_test.dart`

**Step 1: 실패하는 테스트**

```dart
// test/repositories/community_like_repository_test.dart
import 'package:badminton_app/repositories/community_like_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityLikeRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityLikeRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityLikeRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityLikeRepository>());
    });

    test('togglePostLike 메서드가 정의되어 있다', () {
      expect(repository.togglePostLike, isA<Function>());
    });

    test('toggleCommentLike 메서드가 정의되어 있다', () {
      expect(repository.toggleCommentLike, isA<Function>());
    });

    test('getPostLikeStatus 메서드가 정의되어 있다', () {
      expect(repository.getPostLikeStatus, isA<Function>());
    });

    test('getCommentLikedIds 메서드가 정의되어 있다', () {
      expect(repository.getCommentLikedIds, isA<Function>());
    });
  });
}
```

**Step 2: 구현**

```dart
// lib/repositories/community_like_repository.dart
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityLikeRepositoryProvider =
    Provider<CommunityLikeRepository>((ref) {
  return CommunityLikeRepository(ref.watch(supabaseProvider));
});

class CommunityLikeRepository {
  final SupabaseClient client;

  CommunityLikeRepository(this.client);

  /// 게시글 좋아요 토글. 이미 좋아요면 취소, 아니면 추가.
  /// 반환: true = 좋아요됨, false = 취소됨
  Future<bool> togglePostLike(String userId, String postId) async {
    try {
      final existing = await client
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) {
        await client.from('community_likes').delete().eq('id', existing['id']);
        return false;
      } else {
        await client.from('community_likes').insert({
          'user_id': userId,
          'post_id': postId,
        });
        return true;
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 댓글 좋아요 토글.
  Future<bool> toggleCommentLike(String userId, String commentId) async {
    try {
      final existing = await client
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle();

      if (existing != null) {
        await client.from('community_likes').delete().eq('id', existing['id']);
        return false;
      } else {
        await client.from('community_likes').insert({
          'user_id': userId,
          'comment_id': commentId,
        });
        return true;
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 현재 사용자가 해당 게시글에 좋아요했는지 확인.
  Future<bool> getPostLikeStatus(String userId, String postId) async {
    try {
      final data = await client
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      return data != null;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 현재 사용자가 좋아요한 댓글 ID 목록.
  Future<Set<String>> getCommentLikedIds(
    String userId,
    List<String> commentIds,
  ) async {
    try {
      if (commentIds.isEmpty) return {};
      final data = await client
          .from('community_likes')
          .select('comment_id')
          .eq('user_id', userId)
          .inFilter('comment_id', commentIds);
      return data
          .map((e) => e['comment_id'] as String)
          .toSet();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
```

**Step 3: 테스트 + 커밋**

Run: `flutter test test/repositories/community_like_repository_test.dart`

```bash
git add lib/repositories/community_like_repository.dart test/repositories/community_like_repository_test.dart
git commit -m "feat: CommunityLikeRepository 추가"
```

---

## Task 10: Repository — CommunityReportRepository

**Files:**
- Create: `lib/repositories/community_report_repository.dart`
- Test: `test/repositories/community_report_repository_test.dart`

**Step 1: 실패하는 테스트**

```dart
// test/repositories/community_report_repository_test.dart
import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityReportRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityReportRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityReportRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityReportRepository>());
    });

    test('reportPost 메서드가 정의되어 있다', () {
      expect(repository.reportPost, isA<Function>());
    });

    test('reportComment 메서드가 정의되어 있다', () {
      expect(repository.reportComment, isA<Function>());
    });

    test('getPendingReports 메서드가 정의되어 있다', () {
      expect(repository.getPendingReports, isA<Function>());
    });

    test('updateStatus 메서드가 정의되어 있다', () {
      expect(repository.updateStatus, isA<Function>());
    });
  });
}
```

**Step 2: 구현**

```dart
// lib/repositories/community_report_repository.dart
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityReportRepositoryProvider =
    Provider<CommunityReportRepository>((ref) {
  return CommunityReportRepository(ref.watch(supabaseProvider));
});

class CommunityReportRepository {
  final SupabaseClient client;

  CommunityReportRepository(this.client);

  Future<CommunityReport> reportPost({
    required String reporterId,
    required String postId,
    required String reason,
  }) async {
    try {
      final data = await client.from('community_reports').insert({
        'reporter_id': reporterId,
        'post_id': postId,
        'reason': reason,
      }).select().single();
      return CommunityReport.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<CommunityReport> reportComment({
    required String reporterId,
    required String commentId,
    required String reason,
  }) async {
    try {
      final data = await client.from('community_reports').insert({
        'reporter_id': reporterId,
        'comment_id': commentId,
        'reason': reason,
      }).select().single();
      return CommunityReport.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<CommunityReport>> getPendingReports() async {
    try {
      final data = await client
          .from('community_reports')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return data.map(CommunityReport.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> updateStatus(
    String reportId,
    ReportStatus status,
  ) async {
    try {
      await client
          .from('community_reports')
          .update({'status': status.toJson()})
          .eq('id', reportId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
```

**Step 3: 테스트 + 커밋**

Run: `flutter test test/repositories/community_report_repository_test.dart`

```bash
git add lib/repositories/community_report_repository.dart test/repositories/community_report_repository_test.dart
git commit -m "feat: CommunityReportRepository 추가"
```

---

## Task 11: Provider — 커뮤니티 Provider

**Files:**
- Create: `lib/providers/community_provider.dart`
- Test: `test/providers/community_provider_test.dart`

**Step 1: 실패하는 테스트**

```dart
// test/providers/community_provider_test.dart
import 'package:badminton_app/providers/community_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('communityPostListProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostListProvider, isNotNull);
    });
  });

  group('communityPostDetailProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostDetailProvider, isNotNull);
    });
  });

  group('communityCommentsProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityCommentsProvider, isNotNull);
    });
  });

  group('communityPostLikeStatusProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostLikeStatusProvider, isNotNull);
    });
  });
}
```

**Step 2: 구현**

```dart
// lib/providers/community_provider.dart
import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_like_repository.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커뮤니티 게시글 목록 Provider.
final communityPostListProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) async {
  final repo = ref.watch(communityPostRepositoryProvider);
  return repo.getAll();
});

/// 커뮤니티 게시글 상세 Provider.
final communityPostDetailProvider =
    FutureProvider.autoDispose.family<CommunityPost?, String>((ref, postId) async {
  final repo = ref.watch(communityPostRepositoryProvider);
  return repo.getById(postId);
});

/// 커뮤니티 댓글 목록 Provider.
final communityCommentsProvider =
    FutureProvider.autoDispose.family<List<CommunityComment>, String>((ref, postId) async {
  final repo = ref.watch(communityCommentRepositoryProvider);
  return repo.getByPostId(postId);
});

/// 게시글 좋아요 상태 Provider.
final communityPostLikeStatusProvider =
    FutureProvider.autoDispose.family<bool, ({String userId, String postId})>((ref, params) async {
  final repo = ref.watch(communityLikeRepositoryProvider);
  return repo.getPostLikeStatus(params.userId, params.postId);
});

/// 커뮤니티 검색 Provider.
final communitySearchProvider =
    FutureProvider.autoDispose.family<List<CommunityPost>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(communityPostRepositoryProvider);
  return repo.search(query);
});
```

**Step 3: 테스트 + 커밋**

Run: `flutter test test/providers/community_provider_test.dart`

```bash
git add lib/providers/community_provider.dart test/providers/community_provider_test.dart
git commit -m "feat: 커뮤니티 Provider 추가"
```

---

## Task 12: 화면 — 커뮤니티 목록 (community_list)

**Files:**
- Create: `lib/screens/community/community_list/community_list_screen.dart`
- Test: `test/screens/community/community_list_screen_test.dart`

**Step 1: 화면 구현**

```dart
// lib/screens/community/community_list/community_list_screen.dart
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommunityListScreen extends ConsumerStatefulWidget {
  const CommunityListScreen({super.key});

  @override
  ConsumerState<CommunityListScreen> createState() =>
      _CommunityListScreenState();
}

class _CommunityListScreenState extends ConsumerState<CommunityListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = _isSearching && _searchController.text.isNotEmpty
        ? ref.watch(communitySearchProvider(_searchController.text))
        : ref.watch(communityPostListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => setState(() {}),
              )
            : const Text('커뮤니티'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(communityPostListProvider),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyState(message: '게시글이 없습니다');
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityPostListProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) =>
                  _PostListTile(post: posts[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/community/create'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _PostListTile extends StatelessWidget {
  const _PostListTile({required this.post});
  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Text(
              post.authorName ?? '알 수 없음',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            Text(
              Formatters.relativeTime(post.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const Spacer(),
            if (post.commentCount > 0) ...[
              const Icon(Icons.chat_bubble_outline, size: 14),
              const SizedBox(width: 2),
              Text('${post.commentCount}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
            ],
            if (post.likeCount > 0) ...[
              const Icon(Icons.favorite_border, size: 14),
              const SizedBox(width: 2),
              Text('${post.likeCount}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
      trailing: post.images.isNotEmpty
          ? const Icon(Icons.image, size: 16, color: Colors.grey)
          : null,
      onTap: () => context.go('/community/${post.id}'),
    );
  }
}
```

**Step 2: 위젯 테스트 작성**

```dart
// test/screens/community/community_list_screen_test.dart
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/screens/community/community_list/community_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityListScreen', () {
    testWidgets('AppBar에 커뮤니티 제목이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith(
              (_) async => <CommunityPost>[],
            ),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('커뮤니티'), findsOneWidget);
    });

    testWidgets('게시글이 없으면 빈 상태를 표시한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith(
              (_) async => <CommunityPost>[],
            ),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('게시글이 없습니다'), findsOneWidget);
    });

    testWidgets('FAB이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith(
              (_) async => <CommunityPost>[],
            ),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
```

**Step 3: 테스트 + 커밋**

Run: `flutter test test/screens/community/community_list_screen_test.dart`

```bash
git add lib/screens/community/community_list/ test/screens/community/
git commit -m "feat: 커뮤니티 목록 화면 추가"
```

---

## Task 13: 화면 — 게시글 작성/수정 (community_create)

**Files:**
- Create: `lib/screens/community/community_create/community_create_screen.dart`
- Create: `lib/screens/community/community_create/community_create_notifier.dart`
- Create: `lib/screens/community/community_create/community_create_state.dart`
- Test: `test/screens/community/community_create_screen_test.dart`

**Step 1: State 모델 (freezed)**

```dart
// lib/screens/community/community_create/community_create_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_create_state.freezed.dart';

@freezed
class CommunityCreateState with _$CommunityCreateState {
  const factory CommunityCreateState({
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<String> images,
    @Default(false) bool isSubmitting,
    @Default(false) bool isUploadingImage,
    String? errorMessage,
    String? editingPostId,
    @Default(false) bool isLoadingPost,
  }) = _CommunityCreateState;
}
```

**Step 2: Notifier**

```dart
// lib/screens/community/community_create/community_create_notifier.dart
import 'dart:typed_data';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'community_create_state.dart';

final communityCreateNotifierProvider =
    NotifierProvider<CommunityCreateNotifier, CommunityCreateState>(
  CommunityCreateNotifier.new,
);

class CommunityCreateNotifier extends Notifier<CommunityCreateState> {
  @override
  CommunityCreateState build() => const CommunityCreateState();

  void updateTitle(String title) {
    state = state.copyWith(title: title, errorMessage: null);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content, errorMessage: null);
  }

  Future<void> loadPost(String postId) async {
    state = state.copyWith(isLoadingPost: true, editingPostId: postId);
    try {
      final repo = ref.read(communityPostRepositoryProvider);
      final post = await repo.getById(postId);
      if (post != null) {
        state = state.copyWith(
          title: post.title,
          content: post.content,
          images: post.images,
          isLoadingPost: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingPost: false,
        errorMessage: '게시글을 불러오지 못했습니다',
      );
    }
  }

  Future<void> addImage(Uint8List bytes, String extension) async {
    if (state.images.length >= 5) {
      state = state.copyWith(errorMessage: '이미지는 최대 5장까지 첨부할 수 있습니다');
      return;
    }
    state = state.copyWith(isUploadingImage: true);
    try {
      final userId = ref.read(supabaseProvider).auth.currentUser!.id;
      final storageRepo = ref.read(storageRepositoryProvider);
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
      final url = await storageRepo.uploadImage('community-images', bytes, path);
      state = state.copyWith(
        images: [...state.images, url],
        isUploadingImage: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: '이미지 업로드에 실패했습니다',
      );
    }
  }

  void removeImage(int index) {
    final images = [...state.images]..removeAt(index);
    state = state.copyWith(images: images);
  }

  Future<bool> submit() async {
    final titleError = Validators.postTitle(state.title);
    if (titleError != null) {
      state = state.copyWith(errorMessage: titleError);
      return false;
    }
    final contentError = Validators.postContent(state.content);
    if (contentError != null) {
      state = state.copyWith(errorMessage: contentError);
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(communityPostRepositoryProvider);
      final userId = ref.read(supabaseProvider).auth.currentUser!.id;

      if (state.editingPostId != null) {
        await repo.update(
          state.editingPostId!,
          title: state.title,
          content: state.content,
          images: state.images,
        );
      } else {
        await repo.create(
          authorId: userId,
          title: state.title,
          content: state.content,
          images: state.images,
        );
      }
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return false;
    }
  }
}
```

**Step 3: Screen 위젯**

```dart
// lib/screens/community/community_create/community_create_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'community_create_notifier.dart';

class CommunityCreateScreen extends ConsumerStatefulWidget {
  const CommunityCreateScreen({super.key, this.postId});
  final String? postId;

  @override
  ConsumerState<CommunityCreateScreen> createState() =>
      _CommunityCreateScreenState();
}

class _CommunityCreateScreenState
    extends ConsumerState<CommunityCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      Future.microtask(() async {
        final notifier =
            ref.read(communityCreateNotifierProvider.notifier);
        await notifier.loadPost(widget.postId!);
        final state = ref.read(communityCreateNotifierProvider);
        _titleController.text = state.title;
        _contentController.text = state.content;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final ext = image.path.split('.').last;
    ref.read(communityCreateNotifierProvider.notifier).addImage(bytes, ext);
  }

  Future<void> _submit() async {
    final success =
        await ref.read(communityCreateNotifierProvider.notifier).submit();
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityCreateNotifierProvider);
    final notifier = ref.read(communityCreateNotifierProvider.notifier);
    final isEditing = widget.postId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '게시글 수정' : '게시글 작성'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting ? null : _submit,
            child: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('완료'),
          ),
        ],
      ),
      body: state.isLoadingPost
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '제목을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: notifier.updateTitle,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                    onChanged: notifier.updateContent,
                  ),
                  const SizedBox(height: 16),
                  _ImageSection(
                    images: state.images,
                    isUploading: state.isUploadingImage,
                    onAdd: _pickImage,
                    onRemove: notifier.removeImage,
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.images,
    required this.isUploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> images;
  final bool isUploading;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('이미지 (${images.length}/5)'),
            const Spacer(),
            if (images.length < 5)
              IconButton(
                onPressed: isUploading ? null : onAdd,
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
              ),
          ],
        ),
        if (images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

**Step 4: 코드 생성 + 테스트 + 커밋**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/screens/community/`

```bash
git add lib/screens/community/community_create/ test/screens/community/
git commit -m "feat: 커뮤니티 게시글 작성/수정 화면 추가"
```

---

## Task 14: 화면 — 게시글 상세 (community_detail)

**Files:**
- Create: `lib/screens/community/community_detail/community_detail_screen.dart`
- Test: `test/screens/community/community_detail_screen_test.dart`

**Step 1: 화면 구현**

```dart
// lib/screens/community/community_detail/community_detail_screen.dart
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_like_repository.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:badminton_app/widgets/app_toast.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState
    extends ConsumerState<CommunityDetailScreen> {
  final _commentController = TextEditingController();
  String? _replyToId;
  String? _replyToName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _currentUserId =>
      ref.read(supabaseProvider).auth.currentUser?.id ?? '';

  Future<void> _togglePostLike() async {
    final likeRepo = ref.read(communityLikeRepositoryProvider);
    await likeRepo.togglePostLike(_currentUserId, widget.postId);
    ref.invalidate(communityPostDetailProvider(widget.postId));
    ref.invalidate(communityPostLikeStatusProvider(
      (userId: _currentUserId, postId: widget.postId),
    ));
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final commentRepo = ref.read(communityCommentRepositoryProvider);
    await commentRepo.create(
      postId: widget.postId,
      authorId: _currentUserId,
      content: content,
      parentId: _replyToId,
    );
    _commentController.clear();
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
    ref.invalidate(communityCommentsProvider(widget.postId));
    ref.invalidate(communityPostDetailProvider(widget.postId));
  }

  Future<void> _deletePost() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '게시글 삭제',
      message: '정말 삭제하시겠습니까?',
    );
    if (confirmed != true) return;

    final repo = ref.read(communityPostRepositoryProvider);
    await repo.delete(widget.postId);
    if (mounted) context.pop();
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '댓글 삭제',
      message: '정말 삭제하시겠습니까?',
    );
    if (confirmed != true) return;

    final commentRepo = ref.read(communityCommentRepositoryProvider);
    await commentRepo.delete(commentId);
    ref.invalidate(communityCommentsProvider(widget.postId));
    ref.invalidate(communityPostDetailProvider(widget.postId));
  }

  Future<void> _reportPost() async {
    final reason = await _showReportDialog();
    if (reason == null) return;

    final reportRepo = ref.read(communityReportRepositoryProvider);
    await reportRepo.reportPost(
      reporterId: _currentUserId,
      postId: widget.postId,
      reason: reason,
    );
    if (mounted) AppToast.show(context, '신고가 접수되었습니다');
  }

  Future<void> _reportComment(String commentId) async {
    final reason = await _showReportDialog();
    if (reason == null) return;

    final reportRepo = ref.read(communityReportRepositoryProvider);
    await reportRepo.reportComment(
      reporterId: _currentUserId,
      commentId: commentId,
      reason: reason,
    );
    if (mounted) AppToast.show(context, '신고가 접수되었습니다');
  }

  Future<String?> _showReportDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신고'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '신고 사유를 입력해주세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(communityPostDetailProvider(widget.postId));
    final commentsAsync = ref.watch(communityCommentsProvider(widget.postId));
    final likeStatusAsync = ref.watch(communityPostLikeStatusProvider(
      (userId: _currentUserId, postId: widget.postId),
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('게시글')),
      body: postAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('게시글을 찾을 수 없습니다'));
          }
          final isAuthor = post.authorId == _currentUserId;
          final isLiked = likeStatusAsync.valueOrNull ?? false;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 작성자 + 시간
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                post.authorProfileImageUrl != null
                                    ? NetworkImage(
                                        post.authorProfileImageUrl!)
                                    : null,
                            child: post.authorProfileImageUrl == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(post.authorName ?? '알 수 없음',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.relativeTime(post.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.go(
                                    '/community/${post.id}/edit');
                              } else if (value == 'delete') {
                                _deletePost();
                              } else if (value == 'report') {
                                _reportPost();
                              }
                            },
                            itemBuilder: (_) => [
                              if (isAuthor) ...[
                                const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('수정')),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('삭제')),
                              ],
                              if (!isAuthor)
                                const PopupMenuItem(
                                    value: 'report',
                                    child: Text('신고')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 제목
                      Text(post.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      // 내용
                      Text(post.content,
                          style: Theme.of(context).textTheme.bodyMedium),
                      // 이미지
                      if (post.images.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...post.images.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(url,
                                    fit: BoxFit.cover),
                              ),
                            )),
                      ],
                      const SizedBox(height: 16),
                      // 좋아요 버튼
                      Row(
                        children: [
                          IconButton(
                            onPressed: _togglePostLike,
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                          ),
                          Text('${post.likeCount}'),
                          const SizedBox(width: 16),
                          const Icon(Icons.chat_bubble_outline,
                              size: 20),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}'),
                        ],
                      ),
                      const Divider(),
                      // 댓글 섹션
                      commentsAsync.when(
                        loading: () => const LoadingIndicator(),
                        error: (e, _) => Text('댓글 로딩 실패: $e'),
                        data: (comments) =>
                            _CommentSection(
                              comments: comments,
                              currentUserId: _currentUserId,
                              onReply: (id, name) {
                                setState(() {
                                  _replyToId = id;
                                  _replyToName = name;
                                });
                              },
                              onDelete: _deleteComment,
                              onReport: _reportComment,
                              onToggleLike: (commentId) async {
                                final likeRepo = ref.read(
                                    communityLikeRepositoryProvider);
                                await likeRepo.toggleCommentLike(
                                    _currentUserId, commentId);
                                ref.invalidate(
                                    communityCommentsProvider(
                                        widget.postId));
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              // 댓글 입력창
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyToName != null)
                        Row(
                          children: [
                            Text('@$_replyToName 에게 답글',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() {
                                _replyToId = null;
                                _replyToName = null;
                              }),
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: '댓글을 입력하세요',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _submitComment,
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentSection extends StatelessWidget {
  const _CommentSection({
    required this.comments,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final List<CommunityComment> comments;
  final String currentUserId;
  final void Function(String id, String name) onReply;
  final void Function(String id) onDelete;
  final void Function(String id) onReport;
  final void Function(String id) onToggleLike;

  @override
  Widget build(BuildContext context) {
    // 1단 댓글만 필터
    final topLevel =
        comments.where((c) => c.parentId == null).toList();

    return Column(
      children: topLevel.map((comment) {
        final replies = comments
            .where((c) => c.parentId == comment.id)
            .toList();
        return Column(
          children: [
            _CommentTile(
              comment: comment,
              isAuthor: comment.authorId == currentUserId,
              onReply: () => onReply(
                  comment.id, comment.authorName ?? '알 수 없음'),
              onDelete: () => onDelete(comment.id),
              onReport: () => onReport(comment.id),
              onToggleLike: () => onToggleLike(comment.id),
            ),
            ...replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: _CommentTile(
                    comment: reply,
                    isAuthor: reply.authorId == currentUserId,
                    onReply: () => onReply(
                        comment.id, reply.authorName ?? '알 수 없음'),
                    onDelete: () => onDelete(reply.id),
                    onReport: () => onReport(reply.id),
                    onToggleLike: () => onToggleLike(reply.id),
                  ),
                )),
          ],
        );
      }).toList(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isAuthor,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final CommunityComment comment;
  final bool isAuthor;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.authorName ?? '알 수 없음',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.relativeTime(comment.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'report') onReport();
                },
                itemBuilder: (_) => [
                  if (isAuthor)
                    const PopupMenuItem(
                        value: 'delete', child: Text('삭제')),
                  if (!isAuthor)
                    const PopupMenuItem(
                        value: 'report', child: Text('신고')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: onToggleLike,
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 14),
                    const SizedBox(width: 2),
                    Text('${comment.likeCount}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onReply,
                child: Text('답글',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**Step 2: 테스트 + 커밋**

```bash
git add lib/screens/community/community_detail/ test/screens/community/
git commit -m "feat: 커뮤니티 게시글 상세 화면 추가"
```

---

## Task 15: 화면 — 관리자 신고 관리 (admin_community_reports)

**Files:**
- Create: `lib/screens/admin/community_reports/community_reports_screen.dart`
- Test: `test/screens/admin/community_reports_screen_test.dart`

**Step 1: 화면 구현**

```dart
// lib/screens/admin/community_reports/community_reports_screen.dart
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/widgets/app_toast.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _pendingReportsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(communityReportRepositoryProvider);
  return repo.getPendingReports();
});

class CommunityReportsScreen extends ConsumerWidget {
  const CommunityReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(_pendingReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티 신고 관리')),
      body: reportsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_pendingReportsProvider),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const EmptyState(message: '대기 중인 신고가 없습니다');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final report = reports[index];
              final isPostReport = report.postId != null;
              return ListTile(
                title: Text(
                  isPostReport ? '게시글 신고' : '댓글 신고',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('사유: ${report.reason}'),
                    Text(
                      Formatters.relativeTime(report.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 삭제(제재) 버튼
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: '콘텐츠 삭제',
                          message: '해당 콘텐츠를 삭제하고 작성자에게 알림을 보냅니다.',
                        );
                        if (confirmed != true) return;

                        // 콘텐츠 삭제
                        if (isPostReport) {
                          final postRepo =
                              ref.read(communityPostRepositoryProvider);
                          final post = await postRepo.getById(report.postId!);
                          if (post != null) {
                            await postRepo.delete(report.postId!);
                            // 알림 발송
                            final notiRepo =
                                ref.read(notificationRepositoryProvider);
                            await notiRepo.create(
                              userId: post.authorId,
                              type: NotificationType.communityReport,
                              title: '커뮤니티 게시글 삭제',
                              body: '커뮤니티 규정 위반으로 게시글이 삭제되었습니다.',
                            );
                          }
                        } else {
                          final commentRepo =
                              ref.read(communityCommentRepositoryProvider);
                          await commentRepo.delete(report.commentId!);
                        }

                        // 신고 상태 변경
                        final reportRepo =
                            ref.read(communityReportRepositoryProvider);
                        await reportRepo.updateStatus(
                            report.id, ReportStatus.resolved);
                        ref.invalidate(_pendingReportsProvider);
                        if (context.mounted) {
                          AppToast.show(context, '처리되었습니다');
                        }
                      },
                    ),
                    // 기각 버튼
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.grey),
                      onPressed: () async {
                        final reportRepo =
                            ref.read(communityReportRepositoryProvider);
                        await reportRepo.updateStatus(
                            report.id, ReportStatus.dismissed);
                        ref.invalidate(_pendingReportsProvider);
                        if (context.mounted) {
                          AppToast.show(context, '기각되었습니다');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

**Step 2: 커밋**

```bash
git add lib/screens/admin/community_reports/ test/screens/admin/
git commit -m "feat: 관리자 커뮤니티 신고 관리 화면 추가"
```

---

## Task 16: 네비게이션 — 하단 탭 + 라우터

**Files:**
- Modify: `lib/widgets/customer_bottom_nav.dart`
- Modify: `lib/app/router.dart`

**Step 1: customer_bottom_nav.dart 수정 (4탭 → 5탭)**

```dart
// 커뮤니티 탭 추가 (3번째 위치)
static const _routes = [
  '/customer/home',
  '/customer/shop-search',
  '/community',          // 추가
  '/customer/order-history',
  '/customer/mypage',
];

// items에 커뮤니티 탭 추가
BottomNavigationBarItem(
  icon: Icon(Icons.forum_outlined),
  activeIcon: Icon(Icons.forum),
  label: '커뮤니티',
),
```

**Step 2: router.dart 수정**

고객 ShellRoute 안에 커뮤니티 라우트 추가:

```dart
// 커뮤니티 라우트 (고객 ShellRoute 내)
GoRoute(
  path: '/community',
  builder: (context, state) => const CommunityListScreen(),
),
GoRoute(
  path: '/community/create',
  builder: (context, state) => const CommunityCreateScreen(),
),
GoRoute(
  path: '/community/:postId',
  builder: (context, state) => CommunityDetailScreen(
    postId: state.pathParameters['postId']!,
  ),
),
GoRoute(
  path: '/community/:postId/edit',
  builder: (context, state) => CommunityCreateScreen(
    postId: state.pathParameters['postId']!,
  ),
),

// 관리자 라우트에 추가
GoRoute(
  path: '/admin/community-reports',
  builder: (context, state) => const CommunityReportsScreen(),
),
```

**Step 3: 테스트 + 커밋**

Run: `flutter test`

```bash
git add lib/widgets/customer_bottom_nav.dart lib/app/router.dart
git commit -m "feat: 고객 하단 탭에 커뮤니티 추가 및 라우트 등록"
```

---

## Task 17: 문서 업데이트

**Files:**
- Modify: `docs/database.md` — 4개 테이블 추가
- Modify: `docs/screen-registry.yaml` — 4개 화면 등록

**Step 1: database.md에 커뮤니티 테이블 추가**

Task 1의 SQL 스키마를 database.md 테이블 정의 형식에 맞춰 추가한다.

**Step 2: screen-registry.yaml에 화면 등록**

```yaml
  # ─── 커뮤니티 (공통) ───
  community-list:
    name: "커뮤니티 목록"
    description: "자유게시판 게시글 목록 및 검색"
    role: common
    pencil_id: ""
    spec_file: docs/ui-specs/community-list.md

  community-detail:
    name: "게시글 상세"
    description: "게시글 본문, 댓글/대댓글, 좋아요"
    role: common
    pencil_id: ""
    spec_file: docs/ui-specs/community-detail.md

  community-create:
    name: "게시글 작성/수정"
    description: "커뮤니티 게시글 작성 및 수정"
    role: common
    pencil_id: ""
    spec_file: docs/ui-specs/community-create.md

  # ─── 관리자 ───
  admin-community-reports:
    name: "커뮤니티 신고 관리"
    description: "신고된 게시글/댓글 검토 및 삭제/제재 처리"
    role: admin
    pencil_id: ""
    spec_file: docs/ui-specs/admin-community-reports.md
```

**Step 3: 커밋**

```bash
git add docs/database.md docs/screen-registry.yaml
git commit -m "docs: 커뮤니티 테이블 및 화면 레지스트리 업데이트"
```

---

## Task 18: 전체 테스트 + 최종 커밋

**Step 1: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 2: 전체 테스트**

Run: `flutter test`
Expected: ALL PASS

**Step 3: 분석**

Run: `dart analyze`
Expected: No issues found

**Step 4: 최종 정리 커밋 (필요 시)**

```bash
git add -A && git commit -m "chore: 커뮤니티 기능 코드 정리 및 분석 통과"
```

---

## 작업 순서 요약

| Task | 내용 | 의존성 |
|------|------|--------|
| 1 | DB 마이그레이션 | 없음 |
| 2 | Enum 추가 | 없음 |
| 3 | CommunityPost 모델 | 없음 |
| 4 | CommunityComment 모델 | 없음 |
| 5 | CommunityReport 모델 | Task 2 |
| 6 | 테스트 Fixture | Task 3, 4, 5 |
| 7 | CommunityPostRepository | Task 3 |
| 8 | CommunityCommentRepository | Task 4 |
| 9 | CommunityLikeRepository | 없음 |
| 10 | CommunityReportRepository | Task 5 |
| 11 | Provider | Task 7, 8, 9 |
| 12 | 목록 화면 | Task 11 |
| 13 | 작성/수정 화면 | Task 7, 11 |
| 14 | 상세 화면 | Task 8, 9, 10, 11 |
| 15 | 관리자 신고 화면 | Task 10 |
| 16 | 네비게이션 + 라우터 | Task 12, 13, 14, 15 |
| 17 | 문서 업데이트 | 없음 |
| 18 | 전체 테스트 | 전체 |

**병렬 실행 가능:**
- Task 1, 2, 3, 4 동시 가능
- Task 7, 8, 9 동시 가능
- Task 12, 13, 15 동시 가능
