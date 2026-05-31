import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../../presentation/pages/settings_page.dart';

class AppRouter {
  static GoRouter router({required bool isAuthenticated}) {
    return GoRouter(
      initialLocation: isAuthenticated ? '/' : '/login',
      redirect: (context, state) {
        final loggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!isAuthenticated && !loggingIn) return '/login';
        if (isAuthenticated && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/task/:id',
          builder: (context, state) => TaskDetailPage(
            taskId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }
}
