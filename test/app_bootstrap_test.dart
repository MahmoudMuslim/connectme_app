import 'package:connectme_app/app.dart';
import 'package:connectme_app/injection.dart';
import 'package:connectme_app/presentation/screens/login_screen.dart';
import 'package:connectme_app/presentation/screens/sign_up_screen.dart';
import 'package:connectme_app/presentation/widgets/app_primary_button.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/connect_me_test_binding.dart';

/// End-to-end smoke test of the **real** object graph.
///
/// It boots `injection.dart` exactly like `main.dart` does and asserts that the
/// app reaches the sign-in screen. If a use case, repository, data source or
/// service fails to register, this test fails before the app even starts.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(setUpConnectMe);
  tearDownAll(resetDependencies);

  testWidgets('the app boots and lands on the login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConnectMeApp());
    await tester.pump();
    // The splash screen replaces itself once the session has been restored.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.widgetWithText(AppPrimaryButton, 'LOG IN'), findsOneWidget);
  });

  testWidgets('the login screen navigates to the sign-up screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConnectMeApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });
}
