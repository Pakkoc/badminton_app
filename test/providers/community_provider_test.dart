import 'package:badminton_app/providers/community_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('communityPostListProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostListProvider, isNotNull);
    });
  });

  group('communityPostDetailProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostDetailProvider, isNotNull);
    });
  });

  group('communityCommentsProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityCommentsProvider, isNotNull);
    });
  });

  group('communityPostLikeStatusProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communityPostLikeStatusProvider, isNotNull);
    });
  });

  group('communitySearchProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(communitySearchProvider, isNotNull);
    });
  });
}
