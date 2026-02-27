import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_notifier.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockShopRepository extends Mock
    implements ShopRepository {}

class MockMemberRepository extends Mock
    implements MemberRepository {}

class MockPostRepository extends Mock
    implements PostRepository {}

class MockOrderRepository extends Mock
    implements OrderRepository {}

class MockInventoryRepository extends Mock
    implements InventoryRepository {}

class MockUserRepository extends Mock
    implements UserRepository {}

class FakeMember extends Fake implements Member {}

void main() {
  late MockShopRepository mockShopRepository;
  late MockMemberRepository mockMemberRepository;
  late MockPostRepository mockPostRepository;
  late MockOrderRepository mockOrderRepository;
  late MockInventoryRepository mockInventoryRepository;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeMember());
  });

  setUp(() {
    mockShopRepository = MockShopRepository();
    mockMemberRepository = MockMemberRepository();
    mockPostRepository = MockPostRepository();
    mockOrderRepository = MockOrderRepository();
    mockInventoryRepository = MockInventoryRepository();
    mockUserRepository = MockUserRepository();
    when(
      () => mockUserRepository.getById(testUser.id),
    ).thenAnswer((_) async => testUser);
    container = ProviderContainer(
      overrides: [
        shopRepositoryProvider
            .overrideWithValue(mockShopRepository),
        memberRepositoryProvider
            .overrideWithValue(mockMemberRepository),
        postRepositoryProvider
            .overrideWithValue(mockPostRepository),
        orderRepositoryProvider
            .overrideWithValue(mockOrderRepository),
        inventoryRepositoryProvider
            .overrideWithValue(mockInventoryRepository),
        userRepositoryProvider
            .overrideWithValue(mockUserRepository),
        currentAuthUserIdProvider.overrideWithValue(
          testUser.id,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopDetailNotifier', () {
    test('초기 상태는 로딩 false이다', () {
      final state =
          container.read(shopDetailNotifierProvider);

      expect(state, const ShopDetailState());
      expect(state.shop, isNull);
      expect(state.isLoading, false);
    });

    test(
      'loadShop 성공 시 샵 정보, 회원, 재고를 반환한다',
      () async {
        when(
          () =>
              mockShopRepository.getById(testShop.id),
        ).thenAnswer((_) async => testShop);
        when(
          () => mockMemberRepository.getByShopAndUser(
            testShop.id,
            testUser.id,
          ),
        ).thenAnswer((_) async => testMember);
        when(
          () =>
              mockPostRepository.getByShopAndCategory(
            testShop.id,
            'notice',
          ),
        ).thenAnswer((_) async => [testPostNotice]);
        when(
          () =>
              mockPostRepository.getByShopAndCategory(
            testShop.id,
            'event',
          ),
        ).thenAnswer((_) async => [testPostEvent]);
        when(
          () => mockOrderRepository
              .getByShop(testShop.id),
        ).thenAnswer((_) async => []);
        when(
          () => mockInventoryRepository
              .getByShop(testShop.id),
        ).thenAnswer(
          (_) async => [testInventoryItem],
        );

        final notifier = container.read(
          shopDetailNotifierProvider.notifier,
        );

        await notifier.loadShop(testShop.id);

        final state = container
            .read(shopDetailNotifierProvider);
        expect(state.shop, testShop);
        expect(state.isMember, true);
        expect(
          state.noticePosts,
          [testPostNotice],
        );
        expect(
          state.eventPosts,
          [testPostEvent],
        );
        expect(
          state.inventoryItems,
          [testInventoryItem],
        );
        expect(state.isLoading, false);
      },
    );

    test(
      'loadShop 샵이 없으면 에러 메시지를 설정한다',
      () async {
        when(
          () => mockShopRepository
              .getById('nonexistent'),
        ).thenAnswer((_) async => null);

        final notifier = container.read(
          shopDetailNotifierProvider.notifier,
        );

        await notifier.loadShop('nonexistent');

        final state = container
            .read(shopDetailNotifierProvider);
        expect(state.error, '샵을 찾을 수 없습니다');
      },
    );

    test(
      'registerMember 성공 시 isMember가 true가 된다',
      () async {
        when(
          () => mockMemberRepository.create(any()),
        ).thenAnswer((_) async => testMember);

        final notifier = container.read(
          shopDetailNotifierProvider.notifier,
        );

        await notifier.registerMember(testShop.id);

        final state = container
            .read(shopDetailNotifierProvider);
        expect(state.isMember, true);
        expect(state.isRegistering, false);
      },
    );

    test(
      'registerMember 실패 시 에러 메시지를 설정한다',
      () async {
        when(
          () => mockMemberRepository.create(any()),
        ).thenThrow(Exception('error'));

        final notifier = container.read(
          shopDetailNotifierProvider.notifier,
        );

        await notifier.registerMember(testShop.id);

        final state = container
            .read(shopDetailNotifierProvider);
        expect(state.error, '회원 등록에 실패했습니다');
        expect(state.isRegistering, false);
      },
    );
  });
}
