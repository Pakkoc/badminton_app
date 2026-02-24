import 'package:badminton_app/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock
    implements FirebaseMessaging {}

void main() {
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
  });
}
