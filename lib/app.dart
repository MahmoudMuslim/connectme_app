import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'injection.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/splash_screen.dart';

/// Root widget of the application.
///
/// It wires the global [AuthCubit] and registers the route table. The very first
/// frame is always the splash screen, which awaits [AuthCubit.bootstrap] and then
/// redirects to the login screen or to the home shell — that is how "persist
/// auth state" is honoured without any routing framework.
class ConnectMeApp extends StatelessWidget {
  const ConnectMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (BuildContext context) => getIt<AuthCubit>()..bootstrap(),
      child: MaterialApp(
        title: 'ConnectMe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Named route table, kept in one place for reviewability.
  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final Widget screen = switch (settings.name) {
      AppRoutes.login => const LoginScreen(),
      AppRoutes.signUp => const SignUpScreen(),
      AppRoutes.home => const HomeScreen(),
      _ => const SplashScreen(),
    };
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (BuildContext context) => screen,
    );
  }
}
