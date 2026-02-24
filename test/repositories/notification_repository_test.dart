import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('NotificationRepository', () {
    late MockSupabaseClient mockClient;
    late NotificationRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = NotificationRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<NotificationRepository>());
    });

    test('SupabaseClient를 생성자로 주입받는다', () {
      expect(repository.client, equals(mockClient));
    });
  });

  group('notificationRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(
        notificationRepositoryProvider,
        isA<Provider<NotificationRepository>>(),
      );
    });
  });
}
