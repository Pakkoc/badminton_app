import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/admin/shop_request_detail/shop_request_detail_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockShopRepository extends Mock
    implements ShopRepository {}

class _MockUserRepository extends Mock
    implements UserRepository {}

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late _MockShopRepository mockShopRepo;
  late _MockUserRepository mockUserRepo;
  late _MockNotificationRepository mockNotifRepo;
  late ShopRequestDetailNotifier notifier;

  setUpAll(() {
    registerFallbackValue(NotificationType.notice);
  });

  setUp(() {
    mockShopRepo = _MockShopRepository();
    mockUserRepo = _MockUserRepository();
    mockNotifRepo = _MockNotificationRepository();
    notifier = ShopRequestDetailNotifier(
      shopRepository: mockShopRepo,
      userRepository: mockUserRepo,
      notificationRepository: mockNotifRepo,
    );
  });

  group('loadDetail', () {
    test('샵 상세 정보를 로드한다', () async {
      // Arrange
      when(() => mockShopRepo.getById(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockUserRepo.getById(any()))
          .thenAnswer((_) async => testOwner);

      // Act
      await notifier.loadDetail(testShop.id);

      // Assert
      expect(notifier.state.shop, testShop);
      expect(notifier.state.owner, testOwner);
      expect(notifier.state.isLoading, isFalse);
    });

    test('샵이 없으면 에러를 설정한다', () async {
      // Arrange
      when(() => mockShopRepo.getById(any()))
          .thenAnswer((_) async => null);

      // Act
      await notifier.loadDetail('nonexistent');

      // Assert
      expect(notifier.state.shop, isNull);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, isFalse);
    });
  });

  group('approve', () {
    setUp(() {
      when(() => mockShopRepo.getById(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockUserRepo.getById(any()))
          .thenAnswer((_) async => testOwner);
    });

    test('샵을 승인하고 알림을 생성한다', () async {
      // Arrange
      await notifier.loadDetail(testShop.id);

      when(() => mockShopRepo.approve(any()))
          .thenAnswer((_) async => testShop.copyWith(
                status: ShopStatus.approved,
              ));
      when(() => mockNotifRepo.create(
            userId: any(named: 'userId'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async {});

      // Act
      final result = await notifier.approve();

      // Assert
      expect(result, isTrue);
      expect(notifier.state.isProcessing, isFalse);

      verify(() => mockShopRepo.approve(testShop.id))
          .called(1);
      verify(() => mockNotifRepo.create(
            userId: testShop.ownerId,
            type: NotificationType.shopApproval,
            title: '샵 등록 승인',
            body: '샵 등록이 승인되었습니다! '
                '사장님 모드로 전환할 수 있습니다.',
          )).called(1);
    });

    test('샵이 없으면 false를 반환한다', () async {
      // Act (loadDetail 호출하지 않음 — shop이 null)
      final result = await notifier.approve();

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockShopRepo.approve(any()));
    });

    test('승인 실패 시 에러를 설정한다', () async {
      // Arrange
      await notifier.loadDetail(testShop.id);

      when(() => mockShopRepo.approve(any()))
          .thenThrow(AppException.validation('승인 실패'));

      // Act
      final result = await notifier.approve();

      // Assert
      expect(result, isFalse);
      expect(notifier.state.error, '승인 실패');
      expect(notifier.state.isProcessing, isFalse);
    });
  });

  group('reject', () {
    const reason = '사업자등록증 불일치';

    setUp(() {
      when(() => mockShopRepo.getById(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockUserRepo.getById(any()))
          .thenAnswer((_) async => testOwner);
    });

    test('샵을 거절하고 알림을 생성한다', () async {
      // Arrange
      await notifier.loadDetail(testShop.id);

      when(() => mockShopRepo.reject(any(), any()))
          .thenAnswer((_) async => testShop.copyWith(
                status: ShopStatus.rejected,
                rejectReason: reason,
              ));
      when(() => mockNotifRepo.create(
            userId: any(named: 'userId'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async {});

      // Act
      final result = await notifier.reject(reason);

      // Assert
      expect(result, isTrue);
      expect(notifier.state.isProcessing, isFalse);

      verify(
        () => mockShopRepo.reject(testShop.id, reason),
      ).called(1);
      verify(() => mockNotifRepo.create(
            userId: testShop.ownerId,
            type: NotificationType.shopRejection,
            title: '샵 등록 거절',
            body: '샵 등록이 거절되었습니다. 사유: $reason',
          )).called(1);
    });

    test('샵이 없으면 false를 반환한다', () async {
      // Act
      final result = await notifier.reject(reason);

      // Assert
      expect(result, isFalse);
      verifyNever(
        () => mockShopRepo.reject(any(), any()),
      );
    });

    test('거절 실패 시 에러를 설정한다', () async {
      // Arrange
      await notifier.loadDetail(testShop.id);

      when(() => mockShopRepo.reject(any(), any()))
          .thenThrow(AppException.validation('거절 실패'));

      // Act
      final result = await notifier.reject(reason);

      // Assert
      expect(result, isFalse);
      expect(notifier.state.error, '거절 실패');
      expect(notifier.state.isProcessing, isFalse);
    });
  });
}
