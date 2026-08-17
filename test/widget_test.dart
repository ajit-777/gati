import 'package:flutter_test/flutter_test.dart';

import 'package:gati/main.dart';

void main() {
  testWidgets('Gati app boots to the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GatiApp());
    await tester.pump();

    expect(find.text('GATI'), findsOneWidget);
    expect(find.text('RUN'), findsOneWidget);
  });
}
