import 'package:flutter_test/flutter_test.dart';
//import 'package:material_ui/material_ui.dart';

import 'package:estoke_app/app/app.dart';

void main() {
  testWidgets('EstokeApp inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const EstokeApp());

    expect(find.byType(EstokeApp), findsOneWidget);
  });
}
