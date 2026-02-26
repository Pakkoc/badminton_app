import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('PostCreateScreen', () {
    Widget createApp() {
      return ProviderScope(
        overrides: [
          postCreateNotifierProvider.overrideWith(
            PostCreateNotifier.new,
          ),
        ],
        child: MaterialApp(
          home: PostCreateScreen(shopId: testShop.id),
        ),
      );
    }

    testWidgets(
      'AppBar에 "게시글 작성" 텍스트가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(find.text('게시글 작성'), findsOneWidget);
      },
    );

    testWidgets(
      '카테고리 선택 칩이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(find.text('공지사항'), findsOneWidget);
        expect(find.text('이벤트'), findsOneWidget);
      },
    );

    testWidgets(
      '제목과 내용 입력 필드가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(find.text('제목 *'), findsOneWidget);
        expect(find.text('내용 *'), findsOneWidget);
      },
    );

    testWidgets(
      '등록하기 버튼이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(find.text('등록하기'), findsOneWidget);
      },
    );

    testWidgets(
      '이미지 카운트가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(find.text('최대 5장'), findsOneWidget);
      },
    );
  });
}
