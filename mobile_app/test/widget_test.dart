import 'package:flutter_test/flutter_test.dart';
import 'package:food_nutrition_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriScanApp());
    expect(find.text('NutriScan'), findsOneWidget);
  });
}
