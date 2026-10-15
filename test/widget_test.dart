import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_cyber_maze/main.dart';

void main() {
  testWidgets('Neon Cyber Maze app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const NeonCyberMazeApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
