import 'package:badminton_app/screens/owner/shop_settings/shop_settings_notifier.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_screen.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_state.dart';
import 'package:badminton_app/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

void main() {
  setUpAll(() {
    MapPreview.usePlaceholder = true;
  });

  group('ShopSettingsScreen', () {
    testWidgets('로딩 중일 때 로딩 인디케이터를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              const ShopSettingsState(isLoading: true),
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

    testWidgets('AppBar 제목이 "샵 설정"이다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              ShopSettingsState(shop: testShop),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('샵 설정'), findsOneWidget);
    });

    testWidgets('샵 정보 필드들이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              ShopSettingsState(shop: testShop),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('샵 이름'), findsOneWidget);
      expect(find.text('주소'), findsOneWidget);
      expect(find.text('전화번호'), findsWidgets);
      expect(find.text('소개글'), findsOneWidget);
      // 섹션 헤더 확인
      expect(find.text('샵 정보'), findsOneWidget);
      expect(find.text('사장님 정보'), findsOneWidget);
      // 주소 검색 아이콘 확인
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('저장 버튼이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              ShopSettingsState(shop: testShop),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('저장하기'), findsOneWidget);
    });

    testWidgets('제출 중일 때 저장 버튼에 로딩을 표시한다',
        (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              ShopSettingsState(
                shop: testShop,
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

    testWidgets('지도 미리보기가 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              ShopSettingsState(shop: testShop),
            ),
          ),
        ],
      );

      // Assert
      expect(find.byType(MapPreview), findsOneWidget);
      expect(find.text('지도 미리보기'), findsOneWidget);
    });

    testWidgets('샵 정보가 텍스트 필드에 채워진다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const ShopSettingsScreen(),
        overrides: [
          shopSettingsNotifierProvider.overrideWith(
            () => _FakeShopSettingsNotifier(
              ShopSettingsState(shop: testShop),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.text(testShop.name),
        findsOneWidget,
      );
      expect(
        find.text(testShop.address),
        findsOneWidget,
      );
    });
  });
}

class _FakeShopSettingsNotifier
    extends ShopSettingsNotifier {
  final ShopSettingsState _initialState;

  _FakeShopSettingsNotifier(this._initialState);

  @override
  ShopSettingsState build() => _initialState;

  @override
  Future<void> loadShop() async {}

  @override
  void updateShopName(String name) {}

  @override
  void updateAddress(String address) {}

  @override
  void updatePhone(String phone) {}

  @override
  void updateDescription(String description) {}

  @override
  void updateOwnerName(String name) {}

  @override
  void updateOwnerPhone(String phone) {}

  @override
  Future<bool> submit() async => true;
}
