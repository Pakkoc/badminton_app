import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockPostRepository extends Mock implements PostRepository {}

class FakePost extends Fake implements Post {}

void main() {
  late MockPostRepository mockPostRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakePost());
  });

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

  group('PostCreateNotifier', () {
    test('초기 상태는 공지사항 카테고리이다', () {
      // Arrange & Act
      final state =
          container.read(postCreateNotifierProvider);

      // Assert
      expect(state, const PostCreateState());
      expect(state.category, PostCategory.notice);
      expect(state.title, '');
      expect(state.content, '');
      expect(state.images, isEmpty);
    });

    test('updateTitle은 제목을 변경한다', () {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );

      // Act
      notifier.updateTitle('테스트 제목');

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.title, '테스트 제목');
    });

    test('updateContent는 내용을 변경한다', () {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );

      // Act
      notifier.updateContent('테스트 내용');

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.content, '테스트 내용');
    });

    test('selectCategory는 카테고리를 변경한다', () {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );

      // Act
      notifier.selectCategory(PostCategory.event);

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.category, PostCategory.event);
    });

    test(
      'selectCategory를 notice로 변경하면 이벤트 날짜가 초기화된다',
      () {
        // Arrange
        final notifier = container.read(
          postCreateNotifierProvider.notifier,
        );
        notifier.selectCategory(PostCategory.event);
        notifier.setEventDates(
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2026, 3, 31),
        );

        // Act
        notifier.selectCategory(PostCategory.notice);

        // Assert
        final state =
            container.read(postCreateNotifierProvider);
        expect(state.eventStartDate, isNull);
        expect(state.eventEndDate, isNull);
      },
    );

    test('addImage는 이미지를 추가한다', () {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );

      // Act
      notifier.addImage('https://example.com/img.jpg');

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.images.length, 1);
    });

    test('addImage는 5장 초과 시 에러를 설정한다', () {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      for (var i = 0; i < 5; i++) {
        notifier.addImage('https://example.com/$i.jpg');
      }

      // Act
      notifier.addImage('https://example.com/6.jpg');

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.images.length, 5);
      expect(
        state.errorMessage,
        '이미지는 최대 5장까지 등록할 수 있습니다',
      );
    });

    test('removeImage는 이미지를 제거한다', () {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      notifier.addImage('https://example.com/img.jpg');

      // Act
      notifier.removeImage(0);

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.images, isEmpty);
    });

    test('submit 제목이 비어있으면 에러를 반환한다', () async {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      notifier.updateContent('내용');

      // Act
      final result = await notifier.submit(testShop.id);

      // Assert
      expect(result, false);
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.errorMessage, '제목을 입력해주세요');
    });

    test('submit 내용이 비어있으면 에러를 반환한다', () async {
      // Arrange
      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      notifier.updateTitle('제목');

      // Act
      final result = await notifier.submit(testShop.id);

      // Assert
      expect(result, false);
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.errorMessage, '내용을 입력해주세요');
    });

    test(
      'submit 이벤트인데 날짜 없으면 에러를 반환한다',
      () async {
        // Arrange
        final notifier = container.read(
          postCreateNotifierProvider.notifier,
        );
        notifier.updateTitle('제목');
        notifier.updateContent('내용');
        notifier.selectCategory(PostCategory.event);

        // Act
        final result = await notifier.submit(testShop.id);

        // Assert
        expect(result, false);
        final state =
            container.read(postCreateNotifierProvider);
        expect(
          state.errorMessage,
          '이벤트 기간을 설정해주세요',
        );
      },
    );

    test('submit 성공 시 true를 반환한다', () async {
      // Arrange
      when(
        () => mockPostRepository.create(any()),
      ).thenAnswer((_) async => testPostNotice);

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      notifier.updateTitle('제목');
      notifier.updateContent('내용');

      // Act
      final result = await notifier.submit(testShop.id);

      // Assert
      expect(result, true);
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.isSubmitting, false);
    });

    test('submit 실패 시 에러 메시지를 설정한다', () async {
      // Arrange
      when(
        () => mockPostRepository.create(any()),
      ).thenThrow(Exception('error'));

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      notifier.updateTitle('제목');
      notifier.updateContent('내용');

      // Act
      final result = await notifier.submit(testShop.id);

      // Assert
      expect(result, false);
      final state =
          container.read(postCreateNotifierProvider);
      expect(
        state.errorMessage,
        '게시글 등록에 실패했습니다',
      );
    });
  });
}
