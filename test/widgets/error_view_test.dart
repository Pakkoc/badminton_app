import 'package:badminton_app/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorView', () {
    testWidgets('에러 메시지와 재시도 버튼을 표시한다', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: '오류가 발생했습니다',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      expect(retried, isTrue);
    });
  });
}
