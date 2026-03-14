import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../helpers/fixtures.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockShopRepository mockShopRepo;

  setUp(() {
    mockShopRepo = MockShopRepository();
    when(() => mockShopRepo.getById(testShop.id))
        .thenAnswer((_) async => testShop);
  });

  group('ShopQrScreen', () {
    Widget buildApp() => ProviderScope(
          overrides: [
            shopRepositoryProvider
                .overrideWithValue(mockShopRepo),
          ],
          child: MaterialApp(
            home: ShopQrScreen(shopId: testShop.id),
          ),
        );

    testWidgets('AppBar에 내 샵 QR코드를 표시한다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('내 샵 QR코드'), findsOneWidget);
    });

    testWidgets('QR 코드를 표시한다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('샵 이름을 표시한다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('거트 프로샵'), findsOneWidget);
    });

    testWidgets('안내 문구를 표시한다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(
          '고객이 이 QR을 스캔하면 자동으로 회원 등록됩니다',
        ),
        findsOneWidget,
      );
    });

    testWidgets('이미지 저장 버튼이 렌더링된다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('이미지 저장'), findsOneWidget);
    });

    testWidgets('공유하기 버튼이 렌더링된다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('공유하기'), findsOneWidget);
    });

    testWidgets('InfoCard에 가게에 QR을 비치하세요 메시지를 표시한다',
        (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.textContaining('가게에 QR을 비치하세요'),
        findsOneWidget,
      );
    });
  });
}
