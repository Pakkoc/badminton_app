import 'package:badminton_app/repositories/community_like_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityLikeRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityLikeRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityLikeRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityLikeRepository>());
    });

    test('togglePostLike 메서드가 정의되어 있다', () {
      expect(repository.togglePostLike, isA<Function>());
    });

    test('toggleCommentLike 메서드가 정의되어 있다', () {
      expect(repository.toggleCommentLike, isA<Function>());
    });

    test('getPostLikeStatus 메서드가 정의되어 있다', () {
      expect(repository.getPostLikeStatus, isA<Function>());
    });

    test('getCommentLikedIds 메서드가 정의되어 있다', () {
      expect(repository.getCommentLikedIds, isA<Function>());
    });
  });
}
