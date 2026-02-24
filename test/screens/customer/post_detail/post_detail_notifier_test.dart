import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_notifier.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_state.dart';
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

  group('PostDetailNotifier', () {
    test('초기 상태는 post가 null이다', () {
      // Arrange & Act
      final state =
          container.read(postDetailNotifierProvider);

      // Assert
      expect(state, const PostDetailState());
      expect(state.post, isNull);
      expect(state.isLoading, false);
    });

    test('loadPost 성공 시 게시글을 반환한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getById(testPostNotice.id),
      ).thenAnswer((_) async => testPostNotice);

      final notifier = container.read(
        postDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.loadPost(testPostNotice.id);

      // Assert
      final state =
          container.read(postDetailNotifierProvider);
      expect(state.post, testPostNotice);
      expect(state.isLoading, false);
    });

    test('loadPost 게시글이 없으면 에러를 설정한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getById('nonexistent'),
      ).thenAnswer((_) async => null);

      final notifier = container.read(
        postDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.loadPost('nonexistent');

      // Assert
      final state =
          container.read(postDetailNotifierProvider);
      expect(state.error, '게시글을 찾을 수 없습니다');
    });

    test('loadPost 실패 시 에러 메시지를 설정한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getById('error-id'),
      ).thenThrow(Exception('error'));

      final notifier = container.read(
        postDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.loadPost('error-id');

      // Assert
      final state =
          container.read(postDetailNotifierProvider);
      expect(state.error, '게시글을 불러올 수 없습니다');
    });
  });
}
