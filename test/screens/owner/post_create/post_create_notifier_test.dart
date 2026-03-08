import 'dart:typed_data';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/fixtures.dart';

class MockPostRepository extends Mock implements PostRepository {}

class FakePost extends Fake implements Post {}

class _MockStorageRepository extends Mock
    implements StorageRepository {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUser extends Mock implements User {}

void main() {
  late MockPostRepository mockPostRepository;
  late _MockStorageRepository mockStorageRepository;
  late _MockSupabaseClient mockSupabaseClient;
  late _MockGoTrueClient mockGoTrueClient;
  late _MockUser mockUser;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakePost());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockPostRepository = MockPostRepository();
    mockStorageRepository = _MockStorageRepository();
    mockSupabaseClient = _MockSupabaseClient();
    mockGoTrueClient = _MockGoTrueClient();
    mockUser = _MockUser();

    when(() => mockUser.id).thenReturn('user-123');
    when(() => mockGoTrueClient.currentUser)
        .thenReturn(mockUser);
    when(() => mockSupabaseClient.auth)
        .thenReturn(mockGoTrueClient);

    container = ProviderContainer(
      overrides: [
        postRepositoryProvider
            .overrideWithValue(mockPostRepository),
        storageRepositoryProvider
            .overrideWithValue(mockStorageRepository),
        supabaseProvider.overrideWithValue(mockSupabaseClient),
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

    test('addImage는 이미지를 업로드하고 URL을 추가한다', () async {
      // Arrange
      when(
        () => mockStorageRepository.uploadImage(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => 'https://example.com/img.jpg',
      );

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );

      // Act
      await notifier.addImage(
        Uint8List.fromList([1, 2, 3]),
        'jpg',
      );

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.images.length, 1);
      expect(state.images.first, 'https://example.com/img.jpg');
    });

    test('addImage는 5장 초과 시 에러를 설정한다', () async {
      // Arrange
      when(
        () => mockStorageRepository.uploadImage(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (invocation) async {
          final path = invocation.positionalArguments[2] as String;
          return 'https://example.com/$path';
        },
      );

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      for (var i = 0; i < 5; i++) {
        await notifier.addImage(
          Uint8List.fromList([i]),
          'jpg',
        );
      }

      // Act
      await notifier.addImage(
        Uint8List.fromList([99]),
        'jpg',
      );

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.images.length, 5);
      expect(
        state.errorMessage,
        '이미지는 최대 5장까지 등록할 수 있습니다',
      );
    });

    test('removeImage는 이미지를 제거한다', () async {
      // Arrange
      when(
        () => mockStorageRepository.uploadImage(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => 'https://example.com/img.jpg',
      );

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      await notifier.addImage(
        Uint8List.fromList([1, 2, 3]),
        'jpg',
      );

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

    test('초기 상태는 작성 모드이다', () {
      // Arrange & Act
      final state =
          container.read(postCreateNotifierProvider);

      // Assert
      expect(state.editingPostId, isNull);
      expect(state.isLoadingPost, false);
    });

    test('loadPost 호출 시 기존 게시글 데이터를 로드한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getById(testPostNotice.id),
      ).thenAnswer((_) async => testPostNotice);

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );

      // Act
      await notifier.loadPost(testPostNotice.id);

      // Assert
      final state =
          container.read(postCreateNotifierProvider);
      expect(state.editingPostId, testPostNotice.id);
      expect(state.title, testPostNotice.title);
      expect(state.content, testPostNotice.content);
      expect(state.category, testPostNotice.category);
      expect(state.isLoadingPost, false);
    });

    test(
      'loadPost에서 게시글을 찾지 못하면 에러 메시지를 설정한다',
      () async {
        // Arrange
        when(
          () => mockPostRepository.getById('nonexistent'),
        ).thenAnswer((_) async => null);

        final notifier = container.read(
          postCreateNotifierProvider.notifier,
        );

        // Act
        await notifier.loadPost('nonexistent');

        // Assert
        final state =
            container.read(postCreateNotifierProvider);
        expect(state.editingPostId, isNull);
        expect(state.errorMessage, '게시글을 찾을 수 없습니다');
      },
    );

    test('submit은 수정 모드일 때 update를 호출한다', () async {
      // Arrange
      when(
        () => mockPostRepository.getById(testPostNotice.id),
      ).thenAnswer((_) async => testPostNotice);
      when(
        () => mockPostRepository.update(
          testPostNotice.id,
          any(),
        ),
      ).thenAnswer((_) async => testPostNotice);

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      await notifier.loadPost(testPostNotice.id);

      // Act
      final result = await notifier.submit(testPostNotice.shopId);

      // Assert
      expect(result, true);
      verify(
        () => mockPostRepository.update(
          testPostNotice.id,
          any(),
        ),
      ).called(1);
      verifyNever(() => mockPostRepository.create(any()));
    });

    test('submit은 작성 모드일 때 create를 호출한다', () async {
      // Arrange
      when(
        () => mockPostRepository.create(any()),
      ).thenAnswer((_) async => testPostNotice);

      final notifier = container.read(
        postCreateNotifierProvider.notifier,
      );
      notifier.updateTitle('테스트 제목');
      notifier.updateContent('테스트 내용입니다. 충분한 길이.');

      // Act
      final result =
          await notifier.submit(testPostNotice.shopId);

      // Assert
      expect(result, true);
      verify(() => mockPostRepository.create(any()))
          .called(1);
      verifyNever(
        () => mockPostRepository.update(any(), any()),
      );
    });
  });
}
