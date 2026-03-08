# 댓글 시스템 개편 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 커뮤니티 댓글을 유튜브 스타일로 개편 — 아바타, 2단 제한+@멘션, 접기/펼치기, 작성자 배지, 댓글 알림

**Architecture:** DB trigger로 댓글 알림 자동 생성, UI는 StatefulWidget 로컬 상태로 접기/펼치기 관리, 리포지토리에서 2단 검증

**Tech Stack:** Flutter/Riverpod, Supabase (migration + DB trigger), freezed, mocktail

---

## Task 1: NotificationType 확장 + NotificationItem에 postId 추가

**Files:**
- Modify: `lib/models/enums.dart:136-167`
- Modify: `lib/models/notification_item.dart`
- Test: `test/models/enums_test.dart` (있으면 수정, 없으면 생성)

**Step 1: Write the failing test**

```dart
// test/models/notification_type_test.dart
import 'package:badminton_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationType', () {
    test('commentOnPost를 직렬화한다', () {
      expect(NotificationType.commentOnPost.toJson(), 'comment_on_post');
    });

    test('replyOnComment를 직렬화한다', () {
      expect(NotificationType.replyOnComment.toJson(), 'reply_on_comment');
    });

    test('comment_on_post를 역직렬화한다', () {
      expect(
        NotificationType.fromJson('comment_on_post'),
        NotificationType.commentOnPost,
      );
    });

    test('reply_on_comment를 역직렬화한다', () {
      expect(
        NotificationType.fromJson('reply_on_comment'),
        NotificationType.replyOnComment,
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/notification_type_test.dart`
Expected: FAIL — `commentOnPost` 멤버 없음

**Step 3: Write minimal implementation**

`lib/models/enums.dart` — `NotificationType` enum에 추가:

```dart
enum NotificationType {
  statusChange,
  completion,
  notice,
  receipt,
  shopApproval,
  shopRejection,
  communityReport,
  commentOnPost,
  replyOnComment;

  String toJson() => switch (this) {
        statusChange => 'status_change',
        completion => 'completion',
        notice => 'notice',
        receipt => 'receipt',
        shopApproval => 'shop_approval',
        shopRejection => 'shop_rejection',
        communityReport => 'community_report',
        commentOnPost => 'comment_on_post',
        replyOnComment => 'reply_on_comment',
      };

  static NotificationType fromJson(String value) => switch (value) {
        'status_change' => statusChange,
        'completion' => completion,
        'notice' => notice,
        'receipt' => receipt,
        'shop_approval' => shopApproval,
        'shop_rejection' => shopRejection,
        'community_report' => communityReport,
        'comment_on_post' => commentOnPost,
        'reply_on_comment' => replyOnComment,
        _ => throw ArgumentError(
              'Unknown NotificationType: $value',
            ),
      };
}
```

`lib/models/notification_item.dart` — `postId` 필드 추가:

```dart
@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(
      fromJson: NotificationType.fromJson,
      toJson: _notificationTypeToJson,
    )
    required NotificationType type,
    required String title,
    required String body,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'post_id') String? postId,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
```

**Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `flutter test test/models/notification_type_test.dart`
Expected: PASS

**Step 6: Commit**

```
git add lib/models/enums.dart lib/models/notification_item.dart lib/models/notification_item.freezed.dart lib/models/notification_item.g.dart test/models/notification_type_test.dart
git commit -m "feat: NotificationType에 댓글 알림 타입 추가, NotificationItem에 postId 필드 추가"
```

---

## Task 2: Supabase Migration — notifications.post_id + 댓글 알림 trigger

**Files:**
- Supabase migration (MCP tool 사용)

**Step 1: Apply migration — notifications에 post_id 컬럼 추가**

Supabase MCP `apply_migration`으로 실행:

```sql
-- notifications 테이블에 post_id 컬럼 추가
ALTER TABLE notifications
  ADD COLUMN post_id UUID REFERENCES community_posts(id) ON DELETE SET NULL;

-- notifications type CHECK 제약 업데이트
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    'status_change', 'completion', 'notice', 'receipt',
    'shop_approval', 'shop_rejection', 'community_report',
    'comment_on_post', 'reply_on_comment'
  ));

-- post_id 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_notifications_post_id ON notifications(post_id);
```

**Step 2: Apply migration — 댓글 알림 자동 생성 trigger**

```sql
-- 댓글 생성 시 알림을 자동으로 생성하는 함수
CREATE OR REPLACE FUNCTION notify_on_comment()
RETURNS TRIGGER AS $$
DECLARE
  v_post RECORD;
  v_parent_comment RECORD;
  v_commenter_name TEXT;
  v_target_user_id UUID;
  v_notification_type TEXT;
  v_title TEXT;
  v_body TEXT;
BEGIN
  -- 댓글 작성자 이름 조회
  SELECT name INTO v_commenter_name FROM users WHERE id = NEW.author_id;

  -- 게시글 정보 조회
  SELECT id, author_id, title INTO v_post
    FROM community_posts WHERE id = NEW.post_id;

  IF NEW.parent_id IS NULL THEN
    -- 1단 댓글: 게시글 작성자에게 알림
    v_target_user_id := v_post.author_id;
    v_notification_type := 'comment_on_post';
    v_title := '새 댓글';
    v_body := COALESCE(v_commenter_name, '알 수 없음')
      || '님이 회원님의 게시글에 댓글을 남겼습니다';
  ELSE
    -- 대댓글: 부모 댓글 작성자에게 알림
    SELECT author_id INTO v_parent_comment
      FROM community_comments WHERE id = NEW.parent_id;
    v_target_user_id := v_parent_comment.author_id;
    v_notification_type := 'reply_on_comment';
    v_title := '새 답글';
    v_body := COALESCE(v_commenter_name, '알 수 없음')
      || '님이 회원님의 댓글에 답글을 남겼습니다';
  END IF;

  -- 본인에게는 알림 안 보냄
  IF v_target_user_id IS NOT NULL AND v_target_user_id != NEW.author_id THEN
    INSERT INTO notifications (user_id, type, title, body, post_id)
    VALUES (v_target_user_id, v_notification_type, v_title, v_body, NEW.post_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- trigger 생성
DROP TRIGGER IF EXISTS trg_notify_on_comment ON community_comments;
CREATE TRIGGER trg_notify_on_comment
  AFTER INSERT ON community_comments
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_comment();
```

**Step 3: Verify with SQL query**

Supabase MCP `execute_sql`로 확인:

```sql
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'notifications' AND column_name = 'post_id';
```

Expected: `post_id | uuid`

**Step 4: Commit docs**

`docs/database.md` — notifications 테이블에 `post_id` 컬럼 추가 문서화.

```
git add docs/database.md
git commit -m "feat: notifications에 post_id 컬럼 및 댓글 알림 trigger 추가"
```

---

## Task 3: Repository — 대댓글 2단 검증 로직

**Files:**
- Modify: `lib/repositories/community_comment_repository.dart`
- Test: `test/repositories/community_comment_repository_test.dart`

**Step 1: Write the failing test**

```dart
// test/repositories/community_comment_repository_test.dart에 추가
test('대댓글의 대댓글 시도 시 parent_id를 루트 댓글로 보정한다', () async {
  // Arrange — 대댓글(parentId가 있는 댓글)에 답글 시나리오
  // resolveParentId 메서드가 2단 제한을 강제하는지 검증
  final rootId = 'root-comment-id';
  final replyId = 'reply-comment-id';

  // parentId가 이미 있는 댓글에 답글 → 루트로 보정
  final resolved = repository.resolveParentId(
    targetCommentId: replyId,
    targetCommentParentId: rootId,
  );
  expect(resolved, rootId);
});

test('1단 댓글에 답글 시 parent_id를 그대로 유지한다', () {
  final rootId = 'root-comment-id';

  final resolved = repository.resolveParentId(
    targetCommentId: rootId,
    targetCommentParentId: null, // 1단 댓글
  );
  expect(resolved, rootId);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/community_comment_repository_test.dart`
Expected: FAIL — `resolveParentId` 메서드 없음

**Step 3: Write minimal implementation**

`lib/repositories/community_comment_repository.dart`에 메서드 추가:

```dart
/// 대댓글 2단 제한을 강제한다.
///
/// 대댓글(parentId가 있는 댓글)에 답글하면 루트 댓글의 ID를 반환한다.
/// 1단 댓글에 답글하면 해당 댓글 ID를 그대로 반환한다.
String resolveParentId({
  required String targetCommentId,
  required String? targetCommentParentId,
}) {
  // 대상이 이미 대댓글이면 → 루트 댓글로 보정
  return targetCommentParentId ?? targetCommentId;
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/community_comment_repository_test.dart`
Expected: PASS

**Step 5: Commit**

```
git add lib/repositories/community_comment_repository.dart test/repositories/community_comment_repository_test.dart
git commit -m "feat: 대댓글 2단 제한 resolveParentId 메서드 추가"
```

---

## Task 4: 댓글 UI 전면 리빌드 — 아바타, 작성자 배지, @멘션

**Files:**
- Modify: `lib/screens/community/community_detail/community_detail_screen.dart`
- Test: `test/screens/community/community_detail_screen_test.dart`

**Step 1: Write the failing tests**

```dart
// test/screens/community/community_detail_screen_test.dart에 추가

testWidgets('댓글에 프로필 아바타가 표시된다', (tester) async {
  final post = CommunityPost(
    id: 'p1', authorId: 'u1', title: '제목', content: '내용',
    createdAt: DateTime(2026, 3, 1), updatedAt: DateTime(2026, 3, 1),
  );
  final comments = [
    CommunityComment(
      id: 'c1', postId: 'p1', authorId: 'u2',
      content: '댓글입니다', createdAt: DateTime(2026, 3, 1),
      authorName: '김철수',
    ),
  ];

  await tester.pumpWidget(_wrap([
    communityPostDetailProvider('p1').overrideWith((_) async => post),
    communityCommentsProvider('p1').overrideWith((_) async => comments),
    communityPostLikeStatusProvider((userId: '', postId: 'p1'))
        .overrideWith((_) async => false),
  ], const CommunityDetailScreen(postId: 'p1')));
  await tester.pumpAndSettle();

  // 댓글 섹션의 CircleAvatar (게시글 작성자 + 댓글 = 2개 이상)
  expect(find.byType(CircleAvatar), findsAtLeastNWidgets(2));
});

testWidgets('게시글 작성자 댓글에 작성자 배지가 표시된다', (tester) async {
  final post = CommunityPost(
    id: 'p1', authorId: 'u1', title: '제목', content: '내용',
    createdAt: DateTime(2026, 3, 1), updatedAt: DateTime(2026, 3, 1),
  );
  final comments = [
    CommunityComment(
      id: 'c1', postId: 'p1', authorId: 'u1', // 게시글 작성자
      content: '작성자 댓글', createdAt: DateTime(2026, 3, 1),
      authorName: '홍길동',
    ),
  ];

  await tester.pumpWidget(_wrap([
    communityPostDetailProvider('p1').overrideWith((_) async => post),
    communityCommentsProvider('p1').overrideWith((_) async => comments),
    communityPostLikeStatusProvider((userId: '', postId: 'p1'))
        .overrideWith((_) async => false),
  ], const CommunityDetailScreen(postId: 'p1')));
  await tester.pumpAndSettle();

  expect(find.text('작성자'), findsOneWidget);
});

testWidgets('대댓글이 있으면 답글 더보기 버튼이 표시된다', (tester) async {
  final post = CommunityPost(
    id: 'p1', authorId: 'u1', title: '제목', content: '내용',
    createdAt: DateTime(2026, 3, 1), updatedAt: DateTime(2026, 3, 1),
  );
  final comments = [
    CommunityComment(
      id: 'c1', postId: 'p1', authorId: 'u2',
      content: '1단 댓글', createdAt: DateTime(2026, 3, 1),
      authorName: '김철수',
    ),
    CommunityComment(
      id: 'c2', postId: 'p1', authorId: 'u3', parentId: 'c1',
      content: '대댓글', createdAt: DateTime(2026, 3, 1),
      authorName: '이영희',
    ),
  ];

  await tester.pumpWidget(_wrap([
    communityPostDetailProvider('p1').overrideWith((_) async => post),
    communityCommentsProvider('p1').overrideWith((_) async => comments),
    communityPostLikeStatusProvider((userId: '', postId: 'p1'))
        .overrideWith((_) async => false),
  ], const CommunityDetailScreen(postId: 'p1')));
  await tester.pumpAndSettle();

  expect(find.textContaining('답글 1개 더보기'), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/screens/community/community_detail_screen_test.dart`
Expected: FAIL — 아바타/배지/접기 미구현

**Step 3: Write implementation — 전체 UI 리빌드**

`lib/screens/community/community_detail/community_detail_screen.dart`의 `_CommentSection`과 `_CommentTile`을 전면 교체.

핵심 변경:

1. **`_CommentSection`** → `StatefulWidget`으로 변경 (접기/펼치기 상태 관리)
   - `Map<String, bool> _expandedComments` — 댓글별 접기/펼치기 상태
   - 1단 댓글 렌더링 → 대댓글 있으면 "답글 N개 더보기" 버튼 표시
   - 펼침 시 대댓글 목록 표시

2. **`_CommentTile`** — 아바타 + 작성자 배지 + @멘션 추가
   - `isPostAuthor` 파라미터 추가 (작성자 배지 표시용)
   - `isReply` 파라미터 추가 (아바타 크기 40/32 분기)
   - 내용에서 `@닉네임` 파트를 파란색으로 렌더링

3. **`_submitComment`** — 대댓글에 답글 시 @멘션 자동 삽입
   - `_replyToParentId` 추가 (2단 보정용)
   - `_mentionName` 추가 (대댓글→대댓글 시 @멘션 삽입할 이름)

**구현 코드 (전체 _CommentSection + _CommentTile):**

```dart
class _CommentSection extends StatefulWidget {
  const _CommentSection({
    required this.comments,
    required this.currentUserId,
    required this.postAuthorId,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final List<CommunityComment> comments;
  final String currentUserId;
  final String postAuthorId;
  final void Function(String parentId, String replyToName, String? mentionName) onReply;
  final void Function(String id) onDelete;
  final void Function(String id) onReport;
  final void Function(String id) onToggleLike;

  @override
  State<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<_CommentSection> {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final topLevel = widget.comments
        .where((c) => c.parentId == null)
        .toList();

    return Column(
      children: topLevel.map((comment) {
        final replies = widget.comments
            .where((c) => c.parentId == comment.id)
            .toList();
        final isExpanded = _expanded[comment.id] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CommentTile(
              comment: comment,
              isAuthor: comment.authorId == widget.currentUserId,
              isPostAuthor: comment.authorId == widget.postAuthorId,
              isReply: false,
              onReply: () => widget.onReply(
                comment.id,
                comment.authorName ?? '알 수 없음',
                null,
              ),
              onDelete: () => widget.onDelete(comment.id),
              onReport: () => widget.onReport(comment.id),
              onToggleLike: () => widget.onToggleLike(comment.id),
            ),
            if (replies.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _expanded[comment.id] = !isExpanded;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpanded
                              ? '답글 숨기기'
                              : '답글 ${replies.length}개 더보기',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isExpanded)
                ...replies.map(
                  (reply) => Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: _CommentTile(
                      comment: reply,
                      isAuthor: reply.authorId == widget.currentUserId,
                      isPostAuthor: reply.authorId == widget.postAuthorId,
                      isReply: true,
                      onReply: () => widget.onReply(
                        comment.id, // 루트 댓글이 parent
                        reply.authorName ?? '알 수 없음',
                        reply.authorName, // @멘션 대상
                      ),
                      onDelete: () => widget.onDelete(reply.id),
                      onReport: () => widget.onReport(reply.id),
                      onToggleLike: () => widget.onToggleLike(reply.id),
                    ),
                  ),
                ),
            ],
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
    required this.isPostAuthor,
    required this.isReply,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final CommunityComment comment;
  final bool isAuthor;
  final bool isPostAuthor;
  final bool isReply;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = isReply ? 16.0 : 20.0;
    final name = comment.authorName ?? '알 수 없음';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: comment.authorProfileImageUrl != null
                ? NetworkImage(comment.authorProfileImageUrl!)
                : null,
            child: comment.authorProfileImageUrl == null
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(fontSize: avatarRadius * 0.8),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 + 작성자 배지 + 시간 + 더보기
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (isPostAuthor) ...[
                      Text(
                        ' · 작성자',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.primary),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Text(
                      ' · ${Formatters.relativeTime(comment.createdAt)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textTertiary),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
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
                // 내용 (@멘션 파란색)
                _buildContent(context),
                const SizedBox(height: 4),
                // 좋아요 + 답글
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleLike,
                      child: Row(
                        children: [
                          const Icon(Icons.thumb_up_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        '답글',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final content = comment.content;
    // @멘션 파싱: 내용이 @로 시작하면 첫 공백까지를 멘션으로 처리
    if (content.startsWith('@')) {
      final spaceIdx = content.indexOf(' ');
      if (spaceIdx > 0) {
        final mention = content.substring(0, spaceIdx);
        final rest = content.substring(spaceIdx);
        return Text.rich(
          TextSpan(children: [
            TextSpan(
              text: mention,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextSpan(
              text: rest,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]),
        );
      }
    }
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
```

**Step 4: Update `_submitComment` and state in `_CommunityDetailScreenState`**

변경해야 할 부분:
- `_replyToName` → `_mentionName` 추가 (대댓글→대댓글 시 @멘션 삽입할 이름)
- `_submitComment`에서 `_mentionName`이 있으면 내용 앞에 `@멘션이름 ` 삽입
- `_CommentSection`에 `postAuthorId` 전달
- `onReply` 콜백 시그니처 변경

```dart
// _CommunityDetailScreenState에 추가
String? _mentionName;

// _submitComment 수정
Future<void> _submitComment() async {
  var content = _commentController.text.trim();
  if (content.isEmpty) return;

  // 대댓글에 답글 시 @멘션 자동 삽입
  if (_mentionName != null) {
    content = '@$_mentionName $content';
  }

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
    _mentionName = null;
  });
  ref.invalidate(communityCommentsProvider(widget.postId));
  ref.invalidate(communityPostDetailProvider(widget.postId));
}

// _CommentSection 호출부 수정
_CommentSection(
  comments: comments,
  currentUserId: _currentUserId,
  postAuthorId: post.authorId,
  onReply: (parentId, replyToName, mentionName) {
    setState(() {
      _replyToId = parentId;
      _replyToName = replyToName;
      _mentionName = mentionName;
    });
  },
  onDelete: _deleteComment,
  onReport: _reportComment,
  onToggleLike: (commentId) async {
    final likeRepo = ref.read(communityLikeRepositoryProvider);
    await likeRepo.toggleCommentLike(_currentUserId, commentId);
    ref.invalidate(communityCommentsProvider(widget.postId));
  },
),
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/screens/community/community_detail_screen_test.dart`
Expected: PASS

**Step 6: Commit**

```
git add lib/screens/community/community_detail/community_detail_screen.dart test/screens/community/community_detail_screen_test.dart
git commit -m "feat: 댓글 UI 유튜브 스타일로 전면 리빌드 (아바타, 작성자 배지, 접기/펼치기, @멘션)"
```

---

## Task 5: NotificationRepository — postId 지원

**Files:**
- Modify: `lib/repositories/notification_repository.dart`

**Step 1: Modify `create` method to accept optional postId**

```dart
Future<void> create({
  required String userId,
  required NotificationType type,
  required String title,
  required String body,
  String? postId,
}) async {
  try {
    await client.from('notifications').insert({
      'user_id': userId,
      'type': type.toJson(),
      'title': title,
      'body': body,
      if (postId != null) 'post_id': postId,
    });
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
}
```

**Step 2: Commit**

```
git add lib/repositories/notification_repository.dart
git commit -m "feat: NotificationRepository.create에 postId 파라미터 추가"
```

---

## Task 6: 알림 화면에서 댓글 알림 클릭 시 게시글로 이동

**Files:**
- Modify: `lib/screens/customer/notifications/notifications_screen.dart` (알림 탭 눌러서 이동하는 부분)

**Step 1: Read notifications screen**

현재 알림 화면에서 `orderId` 기반으로 이동하는 로직 확인.

**Step 2: Add postId navigation**

알림 타입이 `commentOnPost` 또는 `replyOnComment`이면 → `context.push('/community/${notification.postId}')`로 이동.

```dart
// 알림 아이템 onTap에 추가
if (notification.postId != null &&
    (notification.type == NotificationType.commentOnPost ||
     notification.type == NotificationType.replyOnComment)) {
  context.push('/community/${notification.postId}');
}
```

**Step 3: Commit**

```
git add lib/screens/customer/notifications/notifications_screen.dart
git commit -m "feat: 댓글 알림 클릭 시 해당 게시글로 이동"
```

---

## Task 7: SOT 문서 업데이트

**Files:**
- Modify: `docs/database.md` — notifications 테이블에 post_id, type CHECK 업데이트
- Modify: `docs/ui-specs/community-detail.md` — 댓글 섹션 전면 재작성
- Modify: `docs/pages/community-detail/state.md` — 접기/펼치기/멘션 상태 추가

**Step 1: Update database.md**

notifications 테이블 스키마에 `post_id` 컬럼, type CHECK에 `comment_on_post`, `reply_on_comment` 추가.

**Step 2: Update community-detail.md**

댓글 섹션(3.5)을 유튜브 스타일로 전면 재작성:
- 아바타 40px/32px
- 작성자 배지
- 접기/펼치기
- @멘션 파란색

**Step 3: Update state.md**

로컬 상태에 추가:
- `_mentionName` — 대댓글 답글 시 @멘션 대상 이름
- `_expanded` — `Map<String, bool>` 댓글별 접기/펼치기

**Step 4: Commit**

```
git add docs/database.md docs/ui-specs/community-detail.md docs/pages/community-detail/state.md
git commit -m "docs: 댓글 시스템 개편에 따른 SOT 문서 업데이트"
```

---

## Task 8: 전체 테스트 실행 + 최종 검증

**Step 1: Run all tests**

Run: `flutter test`
Expected: 전체 PASS

**Step 2: Build check**

Run: `flutter build apk --debug` (빠른 빌드 확인)
Expected: BUILD SUCCESSFUL

**Step 3: Final commit if any fixes needed**

```
git commit -m "fix: 댓글 시스템 개편 최종 수정"
```
