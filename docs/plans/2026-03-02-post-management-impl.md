# 게시글 관리 기능 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 사장님의 "게시글 작성" 기능을 "게시글 관리"(목록 조회, 작성, 수정, 삭제)로 확장한다.

**Architecture:** PostRepository에 update/delete/getByShop 메서드를 추가하고, 새 PostManageScreen(목록)을 만들며, 기존 PostCreateScreen에 수정 모드를 추가한다. 라우트와 설정 메뉴를 변경한다.

**Tech Stack:** Flutter, Riverpod 2.6.x, freezed, go_router, Supabase, mocktail

---

## Task 1: PostRepository에 update 메서드 추가

**Files:**
- Modify: `lib/repositories/post_repository.dart`
- Modify: `test/repositories/post_repository_test.dart`

**Step 1: 실패하는 테스트 작성**

`test/repositories/post_repository_test.dart`에 update 테스트 추가:

```dart
test('update 메서드가 정의되어 있다', () {
  expect(repository.update, isA<Function>());
});
```

**Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/repositories/post_repository_test.dart -v`
Expected: FAIL — `update` is not defined

**Step 3: 최소 구현**

`lib/repositories/post_repository.dart`에 추가:

```dart
/// 게시글을 수정한다.
Future<Post> update(String postId, Post post) async {
  try {
    final data = await client
        .from('posts')
        .update(post.toJson())
        .eq('id', postId)
        .select()
        .single();
    return Post.fromJson(data);
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
}
```

**Step 4: 테스트 통과 확인**

Run: `flutter test test/repositories/post_repository_test.dart -v`
Expected: PASS

**Step 5: 커밋**

```
feat: PostRepository에 update 메서드 추가
```

---

## Task 2: PostRepository에 delete 메서드 추가

**Files:**
- Modify: `lib/repositories/post_repository.dart`
- Modify: `test/repositories/post_repository_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
test('delete 메서드가 정의되어 있다', () {
  expect(repository.delete, isA<Function>());
});
```

**Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/repositories/post_repository_test.dart -v`
Expected: FAIL

**Step 3: 최소 구현**

```dart
/// 게시글을 삭제한다.
Future<void> delete(String postId) async {
  try {
    await client.from('posts').delete().eq('id', postId);
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
}
```

**Step 4: 테스트 통과 확인**

Run: `flutter test test/repositories/post_repository_test.dart -v`
Expected: PASS

**Step 5: 커밋**

```
feat: PostRepository에 delete 메서드 추가
```

---

## Task 3: PostRepository에 getByShop 메서드 추가

**Files:**
- Modify: `lib/repositories/post_repository.dart`
- Modify: `test/repositories/post_repository_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
test('getByShop 메서드가 정의되어 있다', () {
  expect(repository.getByShop, isA<Function>());
});
```

**Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/repositories/post_repository_test.dart -v`
Expected: FAIL

**Step 3: 최소 구현**

```dart
/// 매장의 전체 게시글을 조회한다 (카테고리 필터 선택).
Future<List<Post>> getByShop(
  String shopId, {
  PostCategory? category,
}) async {
  try {
    var query = client
        .from('posts')
        .select()
        .eq('shop_id', shopId);
    if (category != null) {
      query = query.eq('category', category.toJson());
    }
    final data = await query.order('created_at', ascending: false);
    return data.map(Post.fromJson).toList();
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
}
```

**Step 4: 테스트 통과 확인**

Run: `flutter test test/repositories/post_repository_test.dart -v`
Expected: PASS

**Step 5: 커밋**

```
feat: PostRepository에 getByShop 메서드 추가
```

---

## Task 4: PostManageState freezed 모델 생성

**Files:**
- Create: `lib/screens/owner/post_manage/post_manage_state.dart`

**Step 1: freezed 상태 모델 작성**

```dart
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_manage_state.freezed.dart';

@freezed
class PostManageState with _$PostManageState {
  const factory PostManageState({
    @Default([]) List<Post> posts,
    PostCategory? selectedCategory,
    @Default(false) bool isLoading,
    @Default(false) bool isDeleting,
    String? errorMessage,
  }) = _PostManageState;
}
```

**Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `post_manage_state.freezed.dart` 생성 확인

**Step 3: 커밋**

```
feat: PostManageState freezed 모델 생성
```

---

## Task 5: PostManageNotifier 구현 + 테스트

**Files:**
- Create: `lib/screens/owner/post_manage/post_manage_notifier.dart`
- Create: `test/screens/owner/post_manage/post_manage_notifier_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_notifier.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  group('PostManageNotifier', () {
    late MockPostRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockPostRepository();
      container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('초기 상태는 빈 목록이다', () {
      final state = container.read(postManageNotifierProvider);
      expect(state, const PostManageState());
    });

    test('loadPosts 호출 시 게시글 목록을 로드한다', () async {
      when(() => mockRepo.getByShop(testShop.id))
          .thenAnswer((_) async => [testPostNotice, testPostEvent]);

      final notifier =
          container.read(postManageNotifierProvider.notifier);
      await notifier.loadPosts(testShop.id);

      final state = container.read(postManageNotifierProvider);
      expect(state.posts.length, 2);
      expect(state.isLoading, false);
    });

    test('카테고리 필터를 변경할 수 있다', () async {
      when(() => mockRepo.getByShop(
            testShop.id,
            category: PostCategory.notice,
          )).thenAnswer((_) async => [testPostNotice]);

      final notifier =
          container.read(postManageNotifierProvider.notifier);
      await notifier.filterByCategory(
        testShop.id,
        PostCategory.notice,
      );

      final state = container.read(postManageNotifierProvider);
      expect(state.selectedCategory, PostCategory.notice);
      expect(state.posts.length, 1);
    });

    test('deletePost 호출 시 게시글을 삭제하고 목록을 갱신한다', () async {
      when(() => mockRepo.delete(testPostNotice.id))
          .thenAnswer((_) async {});
      when(() => mockRepo.getByShop(testShop.id))
          .thenAnswer((_) async => [testPostEvent]);

      final notifier =
          container.read(postManageNotifierProvider.notifier);
      final result = await notifier.deletePost(
        testShop.id,
        testPostNotice.id,
      );

      expect(result, true);
      final state = container.read(postManageNotifierProvider);
      expect(state.posts.length, 1);
      expect(state.isDeleting, false);
    });
  });
}
```

**Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/screens/owner/post_manage/post_manage_notifier_test.dart -v`
Expected: FAIL — provider/notifier 미정의

**Step 3: 최소 구현**

`lib/screens/owner/post_manage/post_manage_notifier.dart`:

```dart
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postManageNotifierProvider =
    NotifierProvider<PostManageNotifier, PostManageState>(
  PostManageNotifier.new,
);

class PostManageNotifier extends Notifier<PostManageState> {
  @override
  PostManageState build() => const PostManageState();

  Future<void> loadPosts(String shopId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(postRepositoryProvider);
      final posts = await repo.getByShop(
        shopId,
        category: state.selectedCategory,
      );
      state = state.copyWith(posts: posts, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.userMessage,
      );
    }
  }

  Future<void> filterByCategory(
    String shopId,
    PostCategory? category,
  ) async {
    state = state.copyWith(selectedCategory: category);
    await loadPosts(shopId);
  }

  Future<bool> deletePost(String shopId, String postId) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.delete(postId);
      await loadPosts(shopId);
      state = state.copyWith(isDeleting: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: e.userMessage,
      );
      return false;
    }
  }
}
```

**Step 4: 테스트 통과 확인**

Run: `flutter test test/screens/owner/post_manage/post_manage_notifier_test.dart -v`
Expected: PASS

**Step 5: 커밋**

```
feat: PostManageNotifier 구현 및 테스트
```

---

## Task 6: PostCreateState에 수정 모드 필드 추가

**Files:**
- Modify: `lib/screens/owner/post_create/post_create_state.dart`

**Step 1: state에 editingPostId, isLoadingPost 필드 추가**

```dart
@freezed
class PostCreateState with _$PostCreateState {
  const factory PostCreateState({
    @Default(PostCategory.notice) PostCategory category,
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<String> images,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    String? editingPostId,
    @Default(false) bool isLoadingPost,
  }) = _PostCreateState;
}
```

**Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: freezed 재생성

**Step 3: 커밋**

```
feat: PostCreateState에 수정 모드 필드 추가
```

---

## Task 7: PostCreateNotifier에 수정 모드 기능 추가 + 테스트

**Files:**
- Modify: `lib/screens/owner/post_create/post_create_notifier.dart`
- Create: `test/screens/owner/post_create/post_create_notifier_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  group('PostCreateNotifier', () {
    late MockPostRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockPostRepository();
      container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('초기 상태는 작성 모드이다', () {
      final state = container.read(postCreateNotifierProvider);
      expect(state.editingPostId, isNull);
      expect(state.isLoadingPost, false);
    });

    test('loadPost 호출 시 기존 게시글 데이터를 로드한다', () async {
      when(() => mockRepo.getById(testPostNotice.id))
          .thenAnswer((_) async => testPostNotice);

      final notifier =
          container.read(postCreateNotifierProvider.notifier);
      await notifier.loadPost(testPostNotice.id);

      final state = container.read(postCreateNotifierProvider);
      expect(state.editingPostId, testPostNotice.id);
      expect(state.title, testPostNotice.title);
      expect(state.content, testPostNotice.content);
      expect(state.category, testPostNotice.category);
      expect(state.isLoadingPost, false);
    });

    test('submit은 수정 모드일 때 update를 호출한다', () async {
      when(() => mockRepo.getById(testPostNotice.id))
          .thenAnswer((_) async => testPostNotice);
      when(() => mockRepo.update(testPostNotice.id, any()))
          .thenAnswer((_) async => testPostNotice);

      final notifier =
          container.read(postCreateNotifierProvider.notifier);
      await notifier.loadPost(testPostNotice.id);
      final result = await notifier.submit(testPostNotice.shopId);

      expect(result, true);
      verify(() => mockRepo.update(testPostNotice.id, any()))
          .called(1);
    });
  });
}
```

**Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/screens/owner/post_create/post_create_notifier_test.dart -v`
Expected: FAIL — `loadPost` 미정의

**Step 3: PostCreateNotifier에 loadPost 메서드 추가 및 submit 수정**

`lib/screens/owner/post_create/post_create_notifier.dart`에서 수정:

```dart
/// 기존 게시글을 수정 모드로 로드한다.
Future<void> loadPost(String postId) async {
  state = state.copyWith(isLoadingPost: true, errorMessage: null);
  try {
    final repo = ref.read(postRepositoryProvider);
    final post = await repo.getById(postId);
    if (post == null) {
      state = state.copyWith(
        isLoadingPost: false,
        errorMessage: '게시글을 찾을 수 없습니다',
      );
      return;
    }
    state = state.copyWith(
      editingPostId: post.id,
      category: post.category,
      title: post.title,
      content: post.content,
      images: post.images,
      eventStartDate: post.eventStartDate,
      eventEndDate: post.eventEndDate,
      isLoadingPost: false,
    );
  } on AppException catch (e) {
    state = state.copyWith(
      isLoadingPost: false,
      errorMessage: e.userMessage,
    );
  }
}
```

`submit` 메서드에서 수정 모드 분기 추가 — `state.editingPostId != null`이면 `update` 호출:

```dart
// submit 메서드 내부, try 블록에서:
if (state.editingPostId != null) {
  await postRepository.update(state.editingPostId!, post);
} else {
  await postRepository.create(post);
}
```

**Step 4: 테스트 통과 확인**

Run: `flutter test test/screens/owner/post_create/post_create_notifier_test.dart -v`
Expected: PASS

**Step 5: 기존 테스트도 모두 통과하는지 확인**

Run: `flutter test -v`
Expected: 전체 PASS

**Step 6: 커밋**

```
feat: PostCreateNotifier에 수정 모드(loadPost, update) 추가
```

---

## Task 8: PostManageScreen UI 구현

**Files:**
- Create: `lib/screens/owner/post_manage/post_manage_screen.dart`

**Step 1: UI 위젯 구현**

> 참조: 고객 PostListScreen의 카드 스타일을 따르되, 편집/삭제 아이콘을 추가한다.
> Pencil 디자인 색상: 공지사항 뱃지 `#DCFCE7`/`#166534`, 이벤트 뱃지 `#FEF3C7`/`#92400E`, 카드 cornerRadius 12, 보더 1px `#E2E8F0`

```dart
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_notifier.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostManageScreen extends ConsumerStatefulWidget {
  const PostManageScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<PostManageScreen> createState() =>
      _PostManageScreenState();
}

class _PostManageScreenState extends ConsumerState<PostManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postManageNotifierProvider.notifier)
          .loadPosts(widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postManageNotifierProvider);
    final notifier = ref.read(postManageNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('게시글 관리')),
      body: Column(
        children: [
          // 카테고리 탭
          _CategoryTabs(
            selected: state.selectedCategory,
            onChanged: (cat) =>
                notifier.filterByCategory(widget.shopId, cat),
          ),
          // 목록
          Expanded(
            child: state.isLoading
                ? const LoadingIndicator()
                : state.posts.isEmpty
                    ? const EmptyState(
                        icon: Icons.article_outlined,
                        message: '등록된 게시글이 없습니다',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.posts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return _PostCard(
                            post: post,
                            onEdit: () => context.push(
                              '/owner/settings/post-manage'
                              '/edit/${post.id}'
                              '?shopId=${widget.shopId}',
                            ),
                            onDelete: () =>
                                _confirmDelete(post.id),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/owner/settings/post-manage/create'
          '?shopId=${widget.shopId}',
        ),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmDelete(String postId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '게시글 삭제',
      message: '정말 삭제하시겠습니까?',
    );
    if (confirmed && mounted) {
      final notifier = ref.read(postManageNotifierProvider.notifier);
      final success =
          await notifier.deletePost(widget.shopId, postId);
      if (success && mounted) {
        AppToast.success(context, '게시글이 삭제되었습니다');
      }
    }
  }
}
```

private 위젯 `_CategoryTabs`, `_PostCard`도 같은 파일에 작성 (고객 PostListScreen의 카드 스타일 참조).

**Step 2: 커밋**

```
feat: PostManageScreen UI 구현
```

---

## Task 9: PostCreateScreen에 수정 모드 UI 반영

**Files:**
- Modify: `lib/screens/owner/post_create/post_create_screen.dart`

**Step 1: PostCreateScreen 수정**

변경 사항:
1. 생성자에 `String? postId` 파라미터 추가
2. `postId != null`이면 `initState`에서 `loadPost(postId)` 호출
3. AppBar 제목: `postId != null ? '게시글 수정' : '게시글 작성'`
4. 하단 버튼 텍스트: `postId != null ? '수정하기' : '등록하기'`
5. 성공 토스트: `postId != null ? '게시글이 수정되었습니다' : '게시글이 등록되었습니다'`
6. `isLoadingPost` true일 때 LoadingIndicator 표시
7. 수정 모드일 때 TextField에 initialValue 설정을 위해 ConsumerStatefulWidget으로 변경하고 TextEditingController 사용

**주의:** 기존 `PostCreateScreen`은 `ConsumerWidget`이므로 `ConsumerStatefulWidget`으로 변경하여 controller 초기화와 loadPost 호출이 가능하게 한다.

**Step 2: 커밋**

```
feat: PostCreateScreen에 수정 모드 UI 반영
```

---

## Task 10: 라우터 변경

**Files:**
- Modify: `lib/app/router.dart`

**Step 1: 라우트 수정**

`/owner/settings` 하위의 기존 `post-create` 라우트를 제거하고 새 라우트 추가:

```dart
// 기존 삭제:
// GoRoute(path: 'post-create', ...)

// 새로 추가:
GoRoute(
  path: 'post-manage',
  builder: (context, state) {
    final shopId =
        state.uri.queryParameters['shopId'] ?? '';
    return PostManageScreen(shopId: shopId);
  },
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) {
        final shopId =
            state.uri.queryParameters['shopId'] ?? '';
        return PostCreateScreen(shopId: shopId);
      },
    ),
    GoRoute(
      path: 'edit/:postId',
      builder: (context, state) {
        final shopId =
            state.uri.queryParameters['shopId'] ?? '';
        final postId =
            state.pathParameters['postId']!;
        return PostCreateScreen(
          shopId: shopId,
          postId: postId,
        );
      },
    ),
  ],
),
```

import 추가:
```dart
import 'package:badminton_app/screens/owner/post_manage/post_manage_screen.dart';
```

**Step 2: 커밋**

```
refactor: 라우터를 게시글 관리 구조로 변경
```

---

## Task 11: ShopSettingsScreen 메뉴 항목 변경

**Files:**
- Modify: `lib/screens/owner/shop_settings/shop_settings_screen.dart`

**Step 1: 메뉴 항목 수정**

`shop_settings_screen.dart:140-148`에서:

변경 전:
```dart
_MenuItemTile(
  icon: Icons.edit_note,
  label: '게시글 작성',
  showDivider: true,
  onTap: () => context.push(
    '/owner/settings/post-create'
    '?shopId=${state.shop!.id}',
  ),
),
```

변경 후:
```dart
_MenuItemTile(
  icon: Icons.article,
  label: '게시글 관리',
  showDivider: true,
  onTap: () => context.push(
    '/owner/settings/post-manage'
    '?shopId=${state.shop!.id}',
  ),
),
```

**Step 2: 커밋**

```
refactor: 설정 메뉴 "게시글 작성"을 "게시글 관리"로 변경
```

---

## Task 12: PostCreateScreen 작성 완료 후 목록 갱신

**Files:**
- Modify: `lib/screens/owner/post_create/post_create_screen.dart`

**Step 1: pop 후 목록 갱신**

PostCreateScreen에서 작성/수정 성공 후 `context.pop(true)`로 결과를 반환하고, PostManageScreen에서 `push` 대신 `push<bool>`로 결과를 받아 목록을 갱신한다.

PostManageScreen의 FAB 및 편집 버튼에서:
```dart
final result = await context.push<bool>(
  '/owner/settings/post-manage/create?shopId=${widget.shopId}',
);
if (result == true && mounted) {
  ref.read(postManageNotifierProvider.notifier)
      .loadPosts(widget.shopId);
}
```

**Step 2: 커밋**

```
feat: 게시글 작성/수정 완료 후 목록 자동 갱신
```

---

## Task 13: 전체 테스트 실행 및 정리

**Step 1: 전체 테스트 실행**

Run: `flutter test -v`
Expected: 전체 PASS

**Step 2: 분석(lint) 실행**

Run: `dart analyze`
Expected: No issues found

**Step 3: 최종 커밋 (필요한 경우)**

```
chore: 게시글 관리 기능 전체 테스트 통과 확인
```

---

## Task 14: Pencil 디자인 변경

**Files:**
- Modify: `design/app_desing.pen`

**Step 1: shop-settings 화면에서 메뉴 항목 변경**

- "게시글 작성" → "게시글 관리"로 텍스트 변경
- 아이콘 `edit_note` → `article`로 변경

**Step 2: PostManage 화면 디자인 추가**

기존 고객 PostListScreen 디자인을 참조하여 사장님용 게시글 관리 목록 화면 추가:
- AppBar: "← 게시글 관리"
- 카테고리 탭: 전체 / 공지사항 / 이벤트
- 게시글 카드: 기존 카드에 편집/삭제 아이콘 추가
- FAB: "+" 버튼

**Step 3: 커밋**

```
chore: Pencil 디자인에 게시글 관리 화면 추가
```

---

## Task 15: 문서 업데이트

**Files:**
- Modify: `docs/screen-registry.yaml`
- Modify: `docs/ui-specs/post-create.md`
- Create: `docs/ui-specs/post-manage.md`

**Step 1: screen-registry.yaml 업데이트**

- `owner-post-create`의 설명을 "게시글 작성/수정"으로 변경
- `owner-post-manage` 항목 추가

**Step 2: post-create.md 수정 모드 내용 추가**

- 수정 모드 진입 시 기존 데이터 로드
- AppBar/버튼 텍스트 분기

**Step 3: post-manage.md 신규 작성**

- 화면 구성, 카테고리 탭, 게시글 카드, FAB, 삭제 플로우

**Step 4: 커밋**

```
docs: 게시글 관리 관련 문서 업데이트
```
