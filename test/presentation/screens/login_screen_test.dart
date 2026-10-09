import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectme_app/core/constants/app_routes.dart';
import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/core/result/result.dart';
import 'package:connectme_app/core/theme/app_theme.dart';
import 'package:connectme_app/domain/entities/community_member.dart';
import 'package:connectme_app/domain/entities/user.dart';
import 'package:connectme_app/domain/repositories/user_repository.dart';
import 'package:connectme_app/domain/usecases/restore_session.dart';
import 'package:connectme_app/domain/usecases/send_password_reset.dart';
import 'package:connectme_app/domain/usecases/sign_in.dart';
import 'package:connectme_app/domain/usecases/sign_out.dart';
import 'package:connectme_app/domain/usecases/sign_up.dart';
import 'package:connectme_app/domain/usecases/watch_auth_state.dart';
import 'package:connectme_app/presentation/blocs/auth/auth_cubit.dart';
import 'package:connectme_app/presentation/blocs/auth/auth_state.dart';
import 'package:connectme_app/presentation/screens/login_screen.dart';
import 'package:connectme_app/services/auth_service.dart';
import 'package:connectme_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/connect_me_test_binding.dart';

/// In-memory [UserRepository] so the login form can be exercised end to end
/// without a Firebase project.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.signedInUser});

  /// Non-null once the fake accepted a sign-in / sign-up.
  User? signedInUser;

  /// Message returned by the next failing call.
  AuthFailure? nextFailure;

  final StreamController<User?> _session = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _session.stream;

  @override
  Future<Result<User?>> restoreSession() async => Success<User?>(signedInUser);

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    final AuthFailure? failure = nextFailure;
    if (failure != null) {
      return ResultFailure<User>(failure);
    }
    final User user =
        signedInUser ?? User(id: 'uid-1', fullName: 'Bruno Pham', email: email);
    signedInUser = user;
    return Success<User>(user);
  }

  @override
  Future<Result<User>> signUp({
    required String fullName,
    required String email,
    required String password,
    String? deviceModel,
    String? osVersion,
  }) async {
    final User user = User(
      id: 'uid-1',
      fullName: fullName,
      email: email,
      deviceModel: deviceModel,
      osVersion: osVersion,
    );
    signedInUser = user;
    return Success<User>(user);
  }

  @override
  Future<Result<void>> signOut() async {
    signedInUser = null;
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async =>
      const Success<void>(null);

  @override
  Future<Result<User>> updateProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async => Success<User>(signedInUser!);

  @override
  Future<Result<User>> updateDisplayName({
    required String userId,
    required String fullName,
  }) async => Success<User>(signedInUser!);

  @override
  Future<Result<User?>> getUserById(String userId) async =>
      Success<User?>(signedInUser);

  @override
  Future<Result<void>> cacheUser(User? user) async => const Success<void>(null);

  @override
  Future<Result<List<CommunityMember>>> getCommunityMembers() async =>
      const Success<List<CommunityMember>>(<CommunityMember>[]);

  Future<void> dispose() => _session.close();
}

const User _member = User(
  id: 'uid-1',
  fullName: 'Bruno Pham',
  email: 'bruno@connectme.app',
);

/// Hosts [child] inside a router that mirrors the production one, so the
/// post-sign-in `pushReplacementNamed('/home')` can be asserted.
Widget _wrap(Widget child, AuthCubit cubit) {
  return BlocProvider<AuthCubit>.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => settings.name == AppRoutes.home
            ? const Scaffold(body: Text('HOME_SHELL'))
            : child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeUserRepository repository;
  late AuthCubit cubit;

  setUp(() async {
    await setUpConnectMe();
    repository = FakeUserRepository();
    cubit = AuthCubit(
      signInUseCase: SignIn(repository),
      signUpUseCase: SignUp(repository),
      sendPasswordResetUseCase: SendPasswordReset(repository),
      signOutUseCase: SignOut(repository),
      restoreSession: RestoreSession(repository),
      watchAuthState: WatchAuthState(repository),
      authService: AuthService.create(
        firestoreService: FirestoreService.instance,
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
    await resetConnectMe();
  });

  group('LoginScreen', () {
    testWidgets('renders the Figma credentials form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('LOG IN'), findsOneWidget);
      expect(find.text('FORGOT PASSWORD'), findsOneWidget);
      expect(find.text('OR LOG IN BY'), findsOneWidget);
    });

    testWidgets('shows the sign-up affordance at the bottom of the sheet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('SIGN UP'), findsOneWidget);
    });

    testWidgets('blocks submission and surfaces the validation message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      await tester.tap(find.text('LOG IN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('accepts a valid email without showing an error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'bruno@connectme.app',
      );
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('rejects a malformed email', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'bruno.example.com',
      );
      await tester.tap(find.text('LOG IN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('signs in and replaces the screen with the home shell', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'bruno@connectme.app',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.tap(find.text('LOG IN'));
      await tester.pumpAndSettle();
      // Let the route-replacement animation finish so the login sheet is gone.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, isNotNull);
      expect(cubit.state.isAuthenticated, isTrue);
      expect(find.text('HOME_SHELL'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('shows the repository failure as a snack bar', (
      WidgetTester tester,
    ) async {
      repository.nextFailure = const AuthFailure(
        'Incorrect email or password. Please try again.',
      );

      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'bruno@connectme.app',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.tap(find.text('LOG IN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.text('Incorrect email or password. Please try again.'),
        findsOneWidget,
      );
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), cubit));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('AuthCubit', () {
    test(
      'bootstrap() reports unauthenticated when no session is stored',
      () async {
        await cubit.bootstrap();

        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.user, isNull);
      },
    );

    test('bootstrap() restores a persisted session', () async {
      repository.signedInUser = _member;
      await cubit.bootstrap();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, _member);
    });

    blocTest<AuthCubit, AuthState>(
      'signUp() surfaces a validation failure without touching Firebase',
      build: () => cubit,
      act: (AuthCubit bloc) => bloc.signUp(
        fullName: 'bruno',
        email: 'bruno@connectme.app',
        password: 'secret123',
        confirmPassword: 'secret123',
      ),
      expect: () => <Matcher>[
        isA<AuthState>().having(
          (AuthState s) => s.status,
          'status',
          AuthStatus.authenticating,
        ),
        isA<AuthState>()
            .having(
              (AuthState s) => s.status,
              'status',
              AuthStatus.unauthenticated,
            )
            .having(
              (AuthState s) => s.errorMessage,
              'errorMessage',
              'Name must start with a capital letter',
            ),
      ],
    );
  });

  group('Failure messages', () {
    test('every failure carries a non empty user facing message', () {
      const List<Failure> failures = <Failure>[
        NetworkFailure(),
        AuthFailure('Incorrect email or password.'),
        ValidationFailure('Please enter a valid email address.'),
        FirestoreFailure('Permission denied.'),
        CacheFailure('Cache unreadable.'),
        BiometricFailure('No fingerprint enrolled.'),
        PaymentFailure('Your card was declined.'),
        DeviceFailure('Device unavailable.'),
        UnexpectedFailure(),
      ];

      for (final Failure failure in failures) {
        expect(failure.message, isNotEmpty);
      }
    });
  });
}
