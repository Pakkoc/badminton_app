import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('received 상태를 올바르게 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: OrderStatus.received),
          ),
        ),
      );

      expect(find.text('접수됨'), findsOneWidget);
    });

    testWidgets('inProgress 상태를 올바르게 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: OrderStatus.inProgress),
          ),
        ),
      );

      expect(find.text('작업중'), findsOneWidget);
    });

    testWidgets('completed 상태를 올바르게 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: OrderStatus.completed),
          ),
        ),
      );

      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('large 사이즈를 지원한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: OrderStatus.received,
              size: StatusBadgeSize.large,
            ),
          ),
        ),
      );

      expect(find.text('접수됨'), findsOneWidget);
    });
  });
}
