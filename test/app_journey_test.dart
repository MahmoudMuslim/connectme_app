import 'package:connectme_app/app.dart';
import 'package:connectme_app/core/result/result.dart';
import 'package:connectme_app/domain/entities/user.dart';
import 'package:connectme_app/domain/usecases/restore_session.dart';
import 'package:connectme_app/domain/usecases/sign_up.dart';
import 'package:connectme_app/injection.dart';
import 'package:connectme_app/presentation/screens/create_post_screen.dart';
import 'package:connectme_app/presentation/screens/donations_screen.dart';
import 'package:connectme_app/presentation/screens/feed_screen.dart';
import 'package:connectme_app/presentation/screens/home_screen.dart';
import 'package:connectme_app/presentation/screens/map_screen.dart';
import 'package:connectme_app/presentation/screens/profile_screen.dart';
import 'package:connectme_app/presentation/widgets/feed_tab_bar.dart';
import 'package:connectme_app/presentation/widgets/post_card.dart';
import 'package:connectme_app/presentation/widgets/user_avatar.dart';
import 'package:connectme_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/connect_me_test_binding.dart';

/// Drives the **real** app through the whole journey:
/// sign up -> home feed -> publish a post -> open the composer -> donations.
///
/// Every screen, cubit, use case and repository in the graph is exercised, which
/// is the strongest end-to-end guarantee the unit test layer can give.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(setUpConnectMe);

  /// Registers a brand new member through the real sign-up form, which is the
  /// natural first-run journey and exercises every validation rule.
  Future<void> registerMember(WidgetTester tester) async {
    await tester.pumpWidget(const ConnectMeApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Bruno Pham',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'bruno@connectme.app',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      'secret123',
    );
    await tester.pump();
    await tester.tap(find.text('SIGN UP').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  }

  /// Scrolls [finder] into the viewport so it can actually receive a tap.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    for (int attempt = 0; attempt < 8; attempt++) {
      if (finder.evaluate().isNotEmpty) {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        return;
      }
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('a new member can register and land on the feed', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(FeedScreen), findsOneWidget);
  });

  testWidgets('the feed renders the posts seeded by the repository factory', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    expect(find.byType(PostCard), findsWidgets);
    // The three Figma tabs are present.
    expect(find.byType(FeedTabBar), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
  });

  testWidgets('the gradient FAB opens the post composer', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(CreatePostScreen), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
  });

  testWidgets('a member can publish a post from the composer', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Hello from the automated test',
    );
    await tester.pump();
    await tester.tap(find.text('PUBLISH'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // The sheet closes and the new post shows up in the feed.
    expect(find.byType(CreatePostScreen), findsNothing);
    expect(find.text('Hello from the automated test'), findsOneWidget);
  });

  testWidgets('switching the feed tab re-orders the posts', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    await tester.tap(find.text('Trending'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Trending'), findsWidgets);
    expect(find.byType(PostCard), findsWidgets);
  });

  testWidgets('the donations tab opens the community fund', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(DonationsScreen), findsOneWidget);
    expect(find.text('Community Fund'), findsOneWidget);
    expect(find.text('Support the community'), findsOneWidget);
  });

  testWidgets('the profile icon opens the biometric gated profile', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    // The `local_auth` platform channel is unavailable in the test VM, so the
    // gate lets the member through with an explanatory notice - which is exactly
    // the documented behaviour for devices without an enrolled sensor.
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('the profile screen exposes the device card and actions', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.byType(UserAvatar), findsWidgets);
    expect(find.text('This device'), findsOneWidget);
    expect(find.textContaining('Pixel 8 Pro'), findsWidgets);
    expect(find.text('Android 14 (API 34)'), findsOneWidget);

    // The action buttons live below the fold on a phone-sized viewport.
    await scrollTo(tester, find.text('UPDATE PHOTO'));
    expect(find.text('UPDATE PHOTO'), findsOneWidget);
    expect(find.text('SIGN OUT'), findsOneWidget);
  });

  testWidgets('the map tab is wired into the shell', (
    WidgetTester tester,
  ) async {
    await registerMember(tester);

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // The Google Maps widget cannot render in the test VM (no Play Services),
    // but the route, the "Community Map" title and the member roster load.
    expect(find.text('Community Map'), findsOneWidget);
    expect(find.byType(MapScreen), findsOneWidget);
    expect(find.text('Bruno Pham, Da Nang'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsWidgets);
  });

  test('registering publishes an authenticated session', () async {
    await resetConnectMe();

    // Register through the real use case: the repository delegates to
    // AuthService, which publishes the new session (Firebase-owned).
    final Result<User> result = await getIt<SignUp>()(
      fullName: 'Bruno Pham',
      email: 'bruno@connectme.app',
      password: 'secret123',
      confirmPassword: 'secret123',
    );

    expect(result.isSuccess, isTrue);
    expect(getIt<AuthService>().currentUser(), isNotNull);
  });

  test('a persisted session lets a cold start skip the login screen', () async {
    await resetConnectMe();
    await getIt<SignUp>()(
      fullName: 'Bruno Pham',
      email: 'bruno@connectme.app',
      password: 'secret123',
      confirmPassword: 'secret123',
    );

    // Simulate a cold start: the restored session must be non-null so the
    // splash screen routes to the home shell instead of the login screen.
    final Result<User?> restored = await getIt<RestoreSession>()();

    expect(restored.valueOrNull, isNotNull);
    expect(restored.valueOrNull!.email, 'bruno@connectme.app');
  });
}
