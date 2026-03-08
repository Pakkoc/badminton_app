import 'package:badminton_app/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('FcmService', () {
    late MockFirebaseMessaging mockMessaging;

    setUp(() {
      mockMessaging = MockFirebaseMessaging();
    });

    test('인스턴스를 생성할 수 있다', () {
      // Arrange & Act
      final service = FcmService(messaging: mockMessaging);

      // Assert
      expect(service, isA<FcmService>());
    });

    group('navigateFromData', () {
      late MockGoRouter mockRouter;
      late FcmService service;

      setUp(() {
        mockRouter = MockGoRouter();
        service = FcmService(messaging: mockMessaging);
        FcmService.setRouter(mockRouter);
        // GoRouter.push()는 Future<Object?>를 반환하므로 stub 필요
        when(() => mockRouter.push(any()))
            .thenAnswer((_) async => null);
      });

      tearDown(() {
        // 테스트 간 라우터 상태 초기화
        FcmService.setRouter(GoRouter(routes: []));
      });

      test('post_id가 있으면 커뮤니티 게시글 상세로 이동한다', () {
        // Arrange
        const postId = 'test-post-id-123';
        final data = <String, dynamic>{
          'type': 'comment_on_post',
          'post_id': postId,
          'notification_id': 'notif-id-1',
        };

        // Act
        service.navigateFromData(data);

        // Assert
        verify(() => mockRouter.push('/community/$postId')).called(1);
      });

      test('reply_on_comment 타입에서 post_id가 있으면 커뮤니티 게시글 상세로 이동한다', () {
        // Arrange
        const postId = 'test-post-id-456';
        final data = <String, dynamic>{
          'type': 'reply_on_comment',
          'post_id': postId,
          'notification_id': 'notif-id-2',
        };

        // Act
        service.navigateFromData(data);

        // Assert
        verify(() => mockRouter.push('/community/$postId')).called(1);
      });

      test('order_id가 있으면 주문 상세로 이동한다', () {
        // Arrange
        const orderId = 'test-order-id-789';
        final data = <String, dynamic>{
          'type': 'status_change',
          'order_id': orderId,
        };

        // Act
        service.navigateFromData(data);

        // Assert
        verify(() => mockRouter.push('/customer/order/$orderId')).called(1);
      });

      test('post_id와 order_id가 모두 있으면 post_id를 우선한다', () {
        // Arrange
        const postId = 'post-id-priority';
        const orderId = 'order-id-ignored';
        final data = <String, dynamic>{
          'type': 'comment_on_post',
          'post_id': postId,
          'order_id': orderId,
        };

        // Act
        service.navigateFromData(data);

        // Assert
        verify(() => mockRouter.push('/community/$postId')).called(1);
        verifyNever(() => mockRouter.push('/customer/order/$orderId'));
      });

      test('post_id도 order_id도 없으면 아무것도 하지 않는다', () {
        // Arrange
        final data = <String, dynamic>{
          'type': 'unknown',
        };

        // Act
        service.navigateFromData(data);

        // Assert
        verifyNever(() => mockRouter.push(any()));
      });
    });
  });
}
