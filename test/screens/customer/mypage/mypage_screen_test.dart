import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/screens/customer/mypage/mypage_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

class _MockAuthRepository extends Mock
    implements AuthRepository {}

void main() {
  group('MypageScreen', () {
    testWidgets('AppBar 제목이 "마이페이지"이다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => testUser,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('마이페이지'), findsOneWidget);
    });

    testWidgets('사용자 이름과 전화번호를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => testUser,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('010-1234-5678'), findsOneWidget);
    });

    testWidgets('메뉴 항목들이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => testUser,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('프로필 편집'), findsOneWidget);
      expect(find.text('작업 내역'), findsOneWidget);
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('로그아웃'), findsOneWidget);
    });

    testWidgets('앱 버전이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => testUser,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('앱 버전 1.0.0'), findsOneWidget);
    });

    testWidgets('로그아웃 탭 시 확인 다이얼로그를 표시한다',
        (tester) async {
      // Arrange
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => testUser,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('로그아웃 하시겠습니까?'), findsOneWidget);
    });

    testWidgets('사용자가 null일 때 로그인 안내를 표시한다',
        (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => null,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('로그인이 필요합니다'), findsOneWidget);
    });
  });
}
