import 'package:badminton_app/screens/customer/profile_edit/profile_edit_notifier.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_screen.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

void main() {
  group('ProfileEditScreen', () {
    testWidgets('AppBar 제목이 "프로필 수정"이다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ProfileEditScreen(),
        overrides: [
          profileEditNotifierProvider.overrideWith(
            () => _FakeProfileEditNotifier(
              const ProfileEditState(
                name: '홍길동',
                phone: '010-1234-5678',
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('프로필 수정'), findsOneWidget);
    });

    testWidgets('이름과 전화번호 필드가 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ProfileEditScreen(),
        overrides: [
          profileEditNotifierProvider.overrideWith(
            () => _FakeProfileEditNotifier(
              const ProfileEditState(
                name: '홍길동',
                phone: '010-1234-5678',
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('이름'), findsOneWidget);
      expect(find.text('전화번호'), findsOneWidget);
    });

    testWidgets('저장 버튼이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ProfileEditScreen(),
        overrides: [
          profileEditNotifierProvider.overrideWith(
            () => _FakeProfileEditNotifier(
              const ProfileEditState(
                name: '홍길동',
                phone: '010-1234-5678',
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('제출 중일 때 로딩 인디케이터를 표시한다',
        (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ProfileEditScreen(),
        overrides: [
          profileEditNotifierProvider.overrideWith(
            () => _FakeProfileEditNotifier(
              const ProfileEditState(
                name: '홍길동',
                phone: '010-1234-5678',
                isSubmitting: true,
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );
    });

    testWidgets('프로필 이미지 영역이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ProfileEditScreen(),
        overrides: [
          profileEditNotifierProvider.overrideWith(
            () => _FakeProfileEditNotifier(
              const ProfileEditState(
                name: '홍길동',
                phone: '010-1234-5678',
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(
        find.byIcon(Icons.camera_alt),
        findsOneWidget,
      );
    });
  });
}

class _FakeProfileEditNotifier extends ProfileEditNotifier {
  final ProfileEditState _initialState;

  _FakeProfileEditNotifier(this._initialState);

  @override
  ProfileEditState build() => _initialState;

  @override
  Future<void> loadProfile() async {}

  @override
  void updateName(String name) {}

  @override
  void updatePhone(String phone) {}

  @override
  Future<bool> submit() async => true;
}
