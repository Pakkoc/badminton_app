import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockMemberRepository extends Mock
    implements MemberRepository {}

class MockOrderRepository extends Mock
    implements OrderRepository {}

class FakeGutOrder extends Fake implements GutOrder {}

void main() {
  late MockMemberRepository mockMemberRepo;
  late MockOrderRepository mockOrderRepo;
  late OrderCreateNotifier notifier;

  setUpAll(() {
    registerFallbackValue(FakeGutOrder());
  });

  setUp(() {
    mockMemberRepo = MockMemberRepository();
    mockOrderRepo = MockOrderRepository();
    notifier = OrderCreateNotifier(
      memberRepository: mockMemberRepo,
      orderRepository: mockOrderRepo,
    );
  });

  group('OrderCreateNotifier', () {
    group('searchMembers', () {
      test('빈 쿼리는 결과를 비운다', () async {
        // Act
        await notifier.searchMembers(testShop.id, '');

        // Assert
        expect(notifier.state.searchResults, isEmpty);
      });

      test('쿼리로 회원을 검색한다', () async {
        // Arrange
        when(
          () => mockMemberRepo.search(
            testShop.id,
            '홍',
          ),
        ).thenAnswer((_) async => [testMember]);

        // Act
        await notifier.searchMembers(testShop.id, '홍');

        // Assert
        expect(notifier.state.searchResults.length, 1);
        expect(
          notifier.state.searchResults.first.name,
          '홍길동',
        );
      });

      test('검색 에러 시 에러 메시지를 설정한다', () async {
        // Arrange
        when(
          () => mockMemberRepo.search(any(), any()),
        ).thenThrow(AppException.server());

        // Act
        await notifier.searchMembers(testShop.id, '홍');

        // Assert
        expect(notifier.state.error, isNotNull);
      });
    });

    group('selectMember', () {
      test('회원을 선택하면 검색 결과가 비워진다', () {
        // Act
        notifier.selectMember(testMember);

        // Assert
        expect(
          notifier.state.selectedMember,
          testMember,
        );
        expect(notifier.state.searchResults, isEmpty);
        expect(notifier.state.searchQuery, isEmpty);
      });
    });

    group('updateMemo', () {
      test('메모를 업데이트한다', () {
        // Act
        notifier.updateMemo('2본 작업');

        // Assert
        expect(notifier.state.memo, '2본 작업');
      });
    });

    group('submit', () {
      test('회원 미선택 시 에러 메시지를 설정한다', () async {
        // Act
        await notifier.submit(testShop.id);

        // Assert
        expect(notifier.state.error, '회원을 선택해주세요');
        expect(notifier.state.isSubmitting, isFalse);
      });

      test('작업 접수 성공 시 isSuccess가 true이다', () async {
        // Arrange
        notifier.selectMember(testMember);
        notifier.updateMemo('2본 작업');

        when(() => mockOrderRepo.create(any()))
            .thenAnswer((_) async => testOrderReceived);

        // Act
        await notifier.submit(testShop.id);

        // Assert
        expect(notifier.state.isSubmitting, isFalse);
        expect(notifier.state.isSuccess, isTrue);
      });

      test('작업 접수 실패 시 에러 메시지를 설정한다', () async {
        // Arrange
        notifier.selectMember(testMember);
        when(() => mockOrderRepo.create(any()))
            .thenThrow(AppException.server());

        // Act
        await notifier.submit(testShop.id);

        // Assert
        expect(notifier.state.isSubmitting, isFalse);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isSuccess, isFalse);
      });
    });

    group('reset', () {
      test('상태를 초기 상태로 리셋한다', () {
        // Arrange
        notifier.selectMember(testMember);
        notifier.updateMemo('test');

        // Act
        notifier.reset();

        // Assert
        expect(notifier.state.selectedMember, isNull);
        expect(notifier.state.memo, isEmpty);
        expect(notifier.state.isSuccess, isFalse);
      });
    });
  });
}
