// lib/presentation/widgets/admin_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../providers/auth_provider.dart';

class AdminNavItem {
  final String   label;
  final IconData icon;
  final String   route;
  const AdminNavItem({required this.label, required this.icon, required this.route});
}

const adminNavItems = [
  AdminNavItem(label: 'Dashboard',  icon: Icons.dashboard_outlined,    route: '/admin'),
  AdminNavItem(label: 'Categorías', icon: Icons.category_outlined,     route: '/admin/categories'),
  AdminNavItem(label: 'Productos',  icon: Icons.inventory_2_outlined,  route: '/admin/products'),
  AdminNavItem(label: 'Pedidos',    icon: Icons.shopping_bag_outlined, route: '/admin/orders'),
  AdminNavItem(label: 'Usuarios',   icon: Icons.people_outline,        route: '/admin/users'),
];

int adminSelectedIndex(String currentRoute) {
  if (currentRoute == '/admin') return 0;
  final idx = adminNavItems.indexWhere(
    (i) => i.route != '/admin' &&
        (currentRoute == i.route || currentRoute.startsWith('${i.route}/')),
  );
  return idx >= 0 ? idx : 0;
}

class AdminShell extends ConsumerWidget {
  final Widget child;
  final String title;
  final String currentRoute;

  const AdminShell({
    super.key,
    required this.child,
    required this.title,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('← Tienda',
                style: TextStyle(color: AppColors.accent, fontSize: 13)),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: adminSelectedIndex(currentRoute),
        onDestinationSelected: (idx) {
          Navigator.pop(context);
          context.go(adminNavItems[idx].route);
        },
        children: [
          Container(
            color:   AppColors.surface2,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width:  48, height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.username.isNotEmpty == true
                              ? user!.username[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color:      AppColors.onAccent,
                            fontWeight: FontWeight.bold,
                            fontSize:   20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? '—',
                          style: const TextStyle(
                            color:      AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize:   16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:        AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Staff',
                            style: TextStyle(
                              color:      AppColors.accent,
                              fontSize:   11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Panel de administración',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...adminNavItems.map((item) => NavigationDrawerDestination(
            icon:         Icon(item.icon),
            selectedIcon: Icon(item.icon, color: AppColors.accent),
            label:        Text(item.label),
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title:   const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: child,
    );
  }
}
