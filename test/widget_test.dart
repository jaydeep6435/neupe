import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:phonepe_flutter/main.dart';
import 'package:phonepe_flutter/screens/home_screen.dart';
import 'package:phonepe_flutter/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider()..setUser('test-user', mobile: '9999999999'),
          ),
        ],
        child: const PhonePeApp(),
      ),
    );

    // Verify that HomeScreen is present
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
