import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

Future<void> pumpTestApp(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    createTestApp(
      child: child,
      overrides: overrides,
    ),
  );
}
