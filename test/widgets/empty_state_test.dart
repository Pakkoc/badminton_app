import 'package:badminton_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyState', () {
    testWidgets('아이콘과 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: '데이터가 없습니다',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('데이터가 없습니다'), findsOneWidget);
    });

    testWidgets('CTA 버튼을 표시한다', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: '데이터가 없습니다',
              actionLabel: '추가하기',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('추가하기'), findsOneWidget);
      await tester.tap(find.text('추가하기'));
      expect(tapped, isTrue);
    });

    testWidgets('CTA 없이도 동작한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: '데이터가 없습니다',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
