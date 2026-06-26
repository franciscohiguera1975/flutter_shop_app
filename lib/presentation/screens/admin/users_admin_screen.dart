// lib/presentation/screens/admin/users_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/user.dart';
import '../../providers/users_admin_provider.dart';
import '../../widgets/user_form.dart';

class UsersAdminScreen extends ConsumerWidget {
  const UsersAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(usersAdminProvider);
    final filtered = state.filtered;
    final tt       = Theme.of(context).textTheme;

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────
        Container(
          color:   AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child:   Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuarios', style: tt.headlineMedium),
                      Text(
                        '${state.total} usuarios',
                        style: const TextStyle(
                          color:    AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            ref.read(usersAdminProvider.notifier).load(),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => showUserForm(context, ref),
                        icon:  const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Nuevo'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Búsqueda
              TextField(
                onChanged:  ref.read(usersAdminProvider.notifier).setSearch,
                decoration: const InputDecoration(
                  hintText:   'Buscar usuario o email...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              // Chips de filtro de rol
              SizedBox(
                height: 34,
                child:  ListView(
                  scrollDirection: Axis.horizontal,
                  children: UserRoleFilter.values.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child:   ChoiceChip(
                      label:    Text(f.label),
                      selected: state.roleFilter == f,
                      onSelected: (_) =>
                          ref.read(usersAdminProvider.notifier).setRoleFilter(f),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Lista ─────────────────────────────────────────────
        Expanded(
          child: Builder(builder: (_) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(usersAdminProvider.notifier).load(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (filtered.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('👤', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text(
                      'Sin usuarios',
                      style: TextStyle(
                        color:      AppColors.textPrimary,
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding:          const EdgeInsets.all(16),
              itemCount:        filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _UserCard(
                user:           filtered[i],
                onToggleStaff:  () => ref
                    .read(usersAdminProvider.notifier)
                    .toggleStaff(filtered[i].id, !filtered[i].isStaff),
                onToggleActive: () => ref
                    .read(usersAdminProvider.notifier)
                    .toggleActive(filtered[i].id),
                onEdit:   () => showUserForm(context, ref, initial: filtered[i]),
                onDelete: () => _confirmDelete(context, ref, filtered[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '¿Eliminar usuario?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '"${user.username}" se eliminará permanentemente.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:     const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(usersAdminProvider.notifier).deleteUser(user.id);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color:      AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── UserCard ──────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final User         user;
  final VoidCallback onToggleStaff;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onToggleStaff,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: user.isActive ? 1.0 : 0.55,
    child:   Container(
      padding:    const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width:  46,
            height: 46,
            decoration: BoxDecoration(
              gradient: user.isStaff
                  ? const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    )
                  : const LinearGradient(
                      colors: [AppColors.surface2, AppColors.border],
                    ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.username.isNotEmpty
                    ? user.username[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color:      user.isStaff
                      ? AppColors.onAccent
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize:   18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        style: const TextStyle(
                          color:      AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (user.isStaff)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Staff',
                          style: TextStyle(
                            color:      AppColors.accent,
                            fontSize:   10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (!user.isActive) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Inactivo',
                          style: TextStyle(
                            color:      AppColors.error,
                            fontSize:   10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    color:    AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user.numOrders} pedido${user.numOrders != 1 ? "s" : ""}',
                  style: const TextStyle(
                    color:      AppColors.accent,
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Acciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle staff
                  GestureDetector(
                    onTap: onToggleStaff,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child:   Icon(
                        user.isStaff
                            ? Icons.admin_panel_settings
                            : Icons.person_outline,
                        color: user.isStaff
                            ? AppColors.accent
                            : AppColors.textFaint,
                        size:  20,
                      ),
                    ),
                  ),
                  // Toggle activo
                  GestureDetector(
                    onTap: onToggleActive,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child:   Icon(
                        user.isActive
                            ? Icons.toggle_on
                            : Icons.toggle_off,
                        color: user.isActive
                            ? AppColors.success
                            : AppColors.textFaint,
                        size:  26,
                      ),
                    ),
                  ),
                  // Editar
                  GestureDetector(
                    onTap: onEdit,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child:   Icon(
                        Icons.edit_outlined,
                        color: AppColors.textSecondary,
                        size:  20,
                      ),
                    ),
                  ),
                  // Eliminar
                  GestureDetector(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child:   Icon(
                        Icons.person_remove_outlined,
                        color: AppColors.error,
                        size:  20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
