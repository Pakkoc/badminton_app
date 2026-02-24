import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_notifier.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;
  late ProviderContainer container;

  setUp(() {
    mockPostRepository = MockPostRepository();
    container = ProviderContainer(
      overrides: [
        postRepositoryProvider
            .overrideWithValue(mockPostRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PostListNotifier', () {
    test('초기 상태는 빈 리스트이다', () {
      // Arrange & Act
      final state = container.read(postListNotifierProvider);

      // Assert
      expect(state, const PostListState());
      expect(state.posts, isEmpty);
      expect(state.isLoading, false);
    });

    test('loadPosts 성공 시 게시글 목록을 반환한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getByShopAndCategory(
          testShop.id,
          'notice',
        ),
      ).thenAnswer((_) async => [testPostNotice]);

      final notifier = container.read(
        postListNotifierProvider.notifier,
      );

      // Act
      await notifier.loadPosts(testShop.id, 'notice');

      // Assert
      final state = container.read(postListNotifierProvider);
      expect(state.posts, [testPostNotice]);
      expect(state.isLoading, false);
    });

    test('loadPosts 실패 시 에러 메시지를 설정한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getByShopAndCategory(
          testShop.id,
          'notice',
        ),
      ).thenThrow(Exception('error'));

      final notifier = container.read(
        postListNotifierProvider.notifier,
      );

      // Act
      await notifier.loadPosts(testShop.id, 'notice');

      // Assert
      final state = container.read(postListNotifierProvider);
      expect(state.error, '게시글 목록을 불러올 수 없습니다');
    });
  });
}
