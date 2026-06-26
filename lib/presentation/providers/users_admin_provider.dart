// lib/presentation/providers/users_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/user_remote_datasource.dart';
import '../../domain/model/user.dart';

enum UserRoleFilter { all, clients, staff, active, inactive }

extension UserRoleFilterLabel on UserRoleFilter {
  String get label => switch (this) {
    UserRoleFilter.all      => 'Todos',
    UserRoleFilter.clients  => 'Clientes',
    UserRoleFilter.staff    => 'Staff',
    UserRoleFilter.active   => 'Activos',
    UserRoleFilter.inactive => 'Inactivos',
  };
}

// ── Estados del formulario ───────────────────────────────────────
sealed class UserFormState { const UserFormState(); }
class UserFormIdle    extends UserFormState { const UserFormIdle(); }
class UserFormSaving  extends UserFormState { const UserFormSaving(); }
class UserFormSuccess extends UserFormState {
  final String message;
  const UserFormSuccess(this.message);
}
class UserFormError extends UserFormState {
  final String message;
  const UserFormError(this.message);
}

// ── Estado principal ─────────────────────────────────────────────
class UsersAdminState {
  final List<User>     users;
  final bool           isLoading;
  final String?        error;
  final int            total;
  final String         search;
  final UserRoleFilter roleFilter;
  final UserFormState  formState;

  const UsersAdminState({
    this.users      = const [],
    this.isLoading  = false,
    this.error,
    this.total      = 0,
    this.search     = '',
    this.roleFilter = UserRoleFilter.all,
    this.formState  = const UserFormIdle(),
  });

  List<User> get filtered => users.where((u) {
    final matchSearch = search.isEmpty ||
        u.username.toLowerCase().contains(search.toLowerCase()) ||
        u.email.toLowerCase().contains(search.toLowerCase());

    final matchRole = switch (roleFilter) {
      UserRoleFilter.all      => true,
      UserRoleFilter.clients  => !u.isStaff,
      UserRoleFilter.staff    => u.isStaff,
      UserRoleFilter.active   => u.isActive,
      UserRoleFilter.inactive => !u.isActive,
    };
    return matchSearch && matchRole;
  }).toList();

  UsersAdminState copyWith({
    List<User>?    users,
    bool?          isLoading,
    String?        error,
    int?           total,
    String?        search,
    UserRoleFilter? roleFilter,
    UserFormState?  formState,
  }) => UsersAdminState(
    users:      users      ?? this.users,
    isLoading:  isLoading  ?? this.isLoading,
    error:      error,
    total:      total      ?? this.total,
    search:     search     ?? this.search,
    roleFilter: roleFilter ?? this.roleFilter,
    formState:  formState  ?? this.formState,
  );
}

// ── Notifier ─────────────────────────────────────────────────────
class UsersAdminNotifier extends StateNotifier<UsersAdminState> {
  final UserRemoteDatasource _datasource;

  UsersAdminNotifier(this._datasource) : super(const UsersAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getUsers();
      state = state.copyWith(
        users:     result.results,
        total:     result.count,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q)             => state = state.copyWith(search: q);
  void setRoleFilter(UserRoleFilter f) => state = state.copyWith(roleFilter: f);
  void resetFormState()                => state = state.copyWith(formState: const UserFormIdle());

  // Toggle staff — optimista
  void toggleStaff(int id, bool isStaff) {
    state = state.copyWith(
      users: state.users.map((u) =>
        u.id == id ? u.copyWith(isStaff: isStaff) : u,
      ).toList(),
    );
    _doToggleStaff(id, isStaff);
  }

  Future<void> _doToggleStaff(int id, bool isStaff) async {
    final user = state.users.firstWhere((u) => u.id == id);
    try {
      await _datasource.updateUser(id, {
        ...user.toJson(),
        'is_staff': isStaff,
      });
    } catch (_) {
      // revertir si falla
      state = state.copyWith(
        users: state.users.map((u) =>
          u.id == id ? u.copyWith(isStaff: !isStaff) : u,
        ).toList(),
      );
    }
  }

  // Toggle activo — optimista con confirmación del servidor
  void toggleActive(int id) {
    final user = state.users.firstWhere((u) => u.id == id);
    final next = !user.isActive;
    state = state.copyWith(
      users: state.users.map((u) =>
        u.id == id ? u.copyWith(isActive: next) : u,
      ).toList(),
    );
    _datasource.toggleActive(id).then((serverActive) {
      state = state.copyWith(
        users: state.users.map((u) =>
          u.id == id ? u.copyWith(isActive: serverActive) : u,
        ).toList(),
      );
    }).catchError((_) {
      state = state.copyWith(
        users: state.users.map((u) =>
          u.id == id ? u.copyWith(isActive: !next) : u,
        ).toList(),
      );
    });
  }

  Future<void> createUser(Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const UserFormSaving());
    try {
      final created = await _datasource.createUser(payload);
      state = state.copyWith(
        users:     [created, ...state.users],
        total:     state.total + 1,
        formState: const UserFormSuccess('Usuario creado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: UserFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const UserFormSaving());
    try {
      final updated = await _datasource.updateUser(id, payload);
      state = state.copyWith(
        users:     state.users.map((u) => u.id == id ? updated : u).toList(),
        formState: const UserFormSuccess('Usuario actualizado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: UserFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _datasource.deleteUser(id);
      state = state.copyWith(
        users: state.users.where((u) => u.id != id).toList(),
        total: state.total - 1,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final usersAdminProvider =
    StateNotifierProvider<UsersAdminNotifier, UsersAdminState>((ref) {
  return UsersAdminNotifier(ref.watch(userDatasourceProvider));
});
