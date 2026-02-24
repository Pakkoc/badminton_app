import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('제목과 내용을 표시한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showConfirmDialog(
                context: context,
                title: '삭제 확인',
                content: '정말 삭제하시겠습니까?',
                onConfirm: () {},
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      expect(find.text('삭제 확인'), findsOneWidget);
      expect(find.text('정말 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('확인 버튼 탭 시 onConfirm이 호출된다', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showConfirmDialog(
                context: context,
                title: '삭제',
                content: '진행하시겠습니까?',
                confirmLabel: '삭제하기',
                onConfirm: () => confirmed = true,
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제하기'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });
}
