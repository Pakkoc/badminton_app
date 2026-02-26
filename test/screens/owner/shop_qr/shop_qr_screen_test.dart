import 'package:badminton_app/screens/owner/shop_qr/shop_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('ShopQrScreen', () {
    // 콘텐츠가 충분히 표시되도록 큰 화면 크기를 설정한다
    setUp(() {});

    Widget buildApp() => MaterialApp(
          home: ShopQrScreen(shop: testShop),
        );

    testWidgets('AppBar에 내 샵 QR코드를 표시한다', (tester) async {
      // Arrange: 화면 높이를 충분히 크게 설정한다
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());

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

      // Assert
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('샵 이름과 주소를 표시한다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());

      // Assert
      expect(find.text('거트 프로샵'), findsOneWidget);
      expect(
        find.text('서울시 강남구 역삼동 123'),
        findsOneWidget,
      );
    });

    testWidgets('안내 문구를 표시한다', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildApp());

      // Assert
      expect(
        find.text('고객이 이 QR 코드를 스캔하면\n자동으로 회원 등록됩니다'),
        findsOneWidget,
      );
    });
  });
}
