import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityReportRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityReportRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityReportRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityReportRepository>());
    });

    test('reportPost 메서드가 정의되어 있다', () {
      expect(repository.reportPost, isA<Function>());
    });

    test('reportComment 메서드가 정의되어 있다', () {
      expect(repository.reportComment, isA<Function>());
    });

    test('getPendingReports 메서드가 정의되어 있다', () {
      expect(repository.getPendingReports, isA<Function>());
    });

    test('updateStatus 메서드가 정의되어 있다', () {
      expect(repository.updateStatus, isA<Function>());
    });
  });
}
