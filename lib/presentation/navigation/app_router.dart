// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/model/auth_state.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Pantalla temporal para los placeholders
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

class _PlaceholderScreen extends ConsumerWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Cerrar sesión y volver al login
              await ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isChecking = authState.isChecking;
      final isAuth     = authState.isAuthenticated;
      final isStaff    = authState.isStaff;
      final location   = state.matchedLocation;

      // Mientras se verifica la sesión, mostrar splash.
      if (isChecking) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuthRoute = location == '/login' || location == '/register';
      final isSplash    = location == '/splash';

      // Al terminar la verificación, salir del splash.
      if (isSplash) return isAuth ? (isStaff ? '/admin' : '/') : '/login';

      // No autenticado → solo puede ir a auth
      if (!isAuth && !isAuthRoute) return '/login';

      // Autenticado → no puede ir a auth
      if (isAuth && isAuthRoute) return isStaff ? '/admin' : '/';

      // Cliente intenta acceder a admin → redirigir a home
      if (isAuth && !isStaff && location.startsWith('/admin')) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path:    '/splash',
        builder: (_, __) => const _SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────
      GoRoute(
        path:    '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path:    '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Público ───────────────────────────────────────────
      GoRoute(
        path:    '/',
        builder: (_, __) => const _PlaceholderScreen('Home — M5'),
      ),
      GoRoute(
        path:    '/catalog',
        builder: (_, __) => const _PlaceholderScreen('Catálogo — M5'),
      ),
      GoRoute(
        path:    '/product/:id',
        builder: (_, __) => const _PlaceholderScreen('Detalle — M5'),
      ),

      // ── Cliente privado ───────────────────────────────────
      GoRoute(
        path:    '/orders',
        builder: (_, __) => const _PlaceholderScreen('Mis pedidos — M7'),
      ),
      GoRoute(
        path:    '/profile',
        builder: (_, __) => const _PlaceholderScreen('Perfil — M7'),
      ),

      // ── Admin ─────────────────────────────────────────────
      GoRoute(
        path:    '/admin',
        builder: (_, __) => const _PlaceholderScreen('Dashboard — M8'),
      ),
    ],
  );
});

// Listenable que notifica al router cuando cambia el AuthState
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}