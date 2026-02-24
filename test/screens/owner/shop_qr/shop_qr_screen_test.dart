import 'package:badminton_app/screens/owner/shop_qr/shop_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('ShopQrScreen', () {
    testWidgets('AppBar에 샵 QR 코드를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ShopQrScreen(shop: testShop),
        ),
      );

      // Assert
      expect(find.text('샵 QR 코드'), findsOneWidget);
    });

    testWidgets('QR 코드를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ShopQrScreen(shop: testShop),
        ),
      );

      // Assert
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('샵 이름과 주소를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ShopQrScreen(shop: testShop),
        ),
      );

      // Assert
      expect(find.text('거트 프로샵'), findsOneWidget);
      expect(
        find.text('서울시 강남구 역삼동 123'),
        findsOneWidget,
      );
    });

    testWidgets('안내 문구를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ShopQrScreen(shop: testShop),
        ),
      );

      // Assert
      expect(
        find.text('고객이 이 QR 코드를 스캔하면\n자동으로 회원 등록됩니다'),
        findsOneWidget,
      );
    });
  });
}
