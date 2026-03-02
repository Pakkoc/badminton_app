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
