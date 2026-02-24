import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_notifier.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockMemberRepository extends Mock
    implements MemberRepository {}

class MockPostRepository extends Mock implements PostRepository {}

class FakeMember extends Fake implements Member {}

void main() {
  late MockShopRepository mockShopRepository;
  late MockMemberRepository mockMemberRepository;
  late MockPostRepository mockPostRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeMember());
  });

  setUp(() {
    mockShopRepository = MockShopRepository();
    mockMemberRepository = MockMemberRepository();
    mockPostRepository = MockPostRepository();
    container = ProviderContainer(
      overrides: [
        shopRepositoryProvider
            .overrideWithValue(mockShopRepository),
        memberRepositoryProvider
            .overrideWithValue(mockMemberRepository),
        postRepositoryProvider
            .overrideWithValue(mockPostRepository),
        currentUserProvider.overrideWith(
          (ref) => Future.value(testUser),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopDetailNotifier', () {
    test('초기 상태는 로딩 false이다', () {
      // Arrange & Act
      final state =
          container.read(shopDetailNotifierProvider);

      // Assert
      expect(state, const ShopDetailState());
      expect(state.shop, isNull);
      expect(state.isLoading, false);
    });

    test('loadShop 성공 시 샵 정보와 회원 여부를 반환한다', () async {
      // Arrange
      when(
        () => mockShopRepository.getById(testShop.id),
      ).thenAnswer((_) async => testShop);
      when(
        () => mockMemberRepository.getByShopAndUser(
          testShop.id,
          testUser.id,
        ),
      ).thenAnswer((_) async => testMember);
      when(
        () => mockPostRepository.getByShopAndCategory(
          testShop.id,
          'notice',
        ),
      ).thenAnswer((_) async => [testPostNotice]);
      when(
        () => mockPostRepository.getByShopAndCategory(
          testShop.id,
          'event',
        ),
      ).thenAnswer((_) async => [testPostEvent]);

      final notifier = container.read(
        shopDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.loadShop(testShop.id);

      // Assert
      final state =
          container.read(shopDetailNotifierProvider);
      expect(state.shop, testShop);
      expect(state.isMember, true);
      expect(state.noticePosts, [testPostNotice]);
      expect(state.eventPosts, [testPostEvent]);
      expect(state.isLoading, false);
    });

    test('loadShop 샵이 없으면 에러 메시지를 설정한다', () async {
      // Arrange
      when(
        () => mockShopRepository.getById('nonexistent'),
      ).thenAnswer((_) async => null);

      final notifier = container.read(
        shopDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.loadShop('nonexistent');

      // Assert
      final state =
          container.read(shopDetailNotifierProvider);
      expect(state.error, '샵을 찾을 수 없습니다');
    });

    test('registerMember 성공 시 isMember가 true가 된다', () async {
      // Arrange
      when(
        () => mockMemberRepository.create(any()),
      ).thenAnswer((_) async => testMember);

      final notifier = container.read(
        shopDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.registerMember(testShop.id);

      // Assert
      final state =
          container.read(shopDetailNotifierProvider);
      expect(state.isMember, true);
      expect(state.isRegistering, false);
    });

    test('registerMember 실패 시 에러 메시지를 설정한다', () async {
      // Arrange
      when(
        () => mockMemberRepository.create(any()),
      ).thenThrow(Exception('error'));

      final notifier = container.read(
        shopDetailNotifierProvider.notifier,
      );

      // Act
      await notifier.registerMember(testShop.id);

      // Assert
      final state =
          container.read(shopDetailNotifierProvider);
      expect(state.error, '회원 등록에 실패했습니다');
      expect(state.isRegistering, false);
    });
  });
}
