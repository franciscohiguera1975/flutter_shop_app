// lib/presentation/widgets/user_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/user.dart';
import '../providers/users_admin_provider.dart';

Future<void> showUserForm(
  BuildContext context,
  WidgetRef    ref, {
  User? initial,
}) {
  return showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child:  UserFormSheet(initial: initial),
    ),
  );
}

class UserFormSheet extends ConsumerStatefulWidget {
  final User? initial;
  const UserFormSheet({super.key, this.initial});

  @override
  ConsumerState<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<UserFormSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _userCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _fnCtrl    = TextEditingController();
  final _lnCtrl    = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _isStaff   = false;
  bool  _isActive  = true;
  bool  _showPass  = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final u         = widget.initial!;
      _userCtrl.text  = u.username;
      _emailCtrl.text = u.email;
      _fnCtrl.text    = u.firstName;
      _lnCtrl.text    = u.lastName;
      _isStaff        = u.isStaff;
      _isActive       = u.isActive;
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _fnCtrl.dispose();
    _lnCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'username':   _userCtrl.text.trim(),
      'email':      _emailCtrl.text.trim(),
      'first_name': _fnCtrl.text.trim(),
      'last_name':  _lnCtrl.text.trim(),
      'is_staff':   _isStaff,
      'is_active':  _isActive,
      if (_passCtrl.text.isNotEmpty) 'password': _passCtrl.text,
    };
    if (widget.initial != null) {
      await ref
          .read(usersAdminProvider.notifier)
          .updateUser(widget.initial!.id, payload);
    } else {
      await ref.read(usersAdminProvider.notifier).createUser(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(usersAdminProvider).formState;
    final isSaving = formSt is UserFormSaving;
    final isEdit   = widget.initial != null;

    if (formSt is UserFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(usersAdminProvider.notifier).resetFormState();
          Navigator.pop(context);
        }
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child:   Column(
          mainAxisSize:        MainAxisSize.min,
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin:     const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEdit ? 'Editar: ${widget.initial!.username}' : 'Nuevo usuario',
              style: const TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Error banner
            if (formSt is UserFormError) ...[
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:        AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formSt.message,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],

            Form(
              key:  _formKey,
              child: Column(
                children: [
                  // Usuario y Email
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _userCtrl,
                          enabled:    !isSaving,
                          decoration: const InputDecoration(labelText: 'Usuario *'),
                          style:      const TextStyle(color: AppColors.textPrimary),
                          validator:  validateUsername,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller:   _emailCtrl,
                          enabled:      !isSaving,
                          keyboardType: TextInputType.emailAddress,
                          decoration:   const InputDecoration(labelText: 'Email *'),
                          style:        const TextStyle(color: AppColors.textPrimary),
                          validator:    validateEmail,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nombre y Apellido
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _fnCtrl,
                          enabled:    !isSaving,
                          decoration: const InputDecoration(labelText: 'Nombre'),
                          style:      const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lnCtrl,
                          enabled:    !isSaving,
                          decoration: const InputDecoration(labelText: 'Apellido'),
                          style:      const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Contraseña
                  TextFormField(
                    controller:  _passCtrl,
                    obscureText: !_showPass,
                    enabled:     !isSaving,
                    decoration:  InputDecoration(
                      labelText: isEdit
                          ? 'Nueva contraseña (vacío = no cambiar)'
                          : 'Contraseña *',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size:  20,
                        ),
                        onPressed: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                    ),
                    style:     const TextStyle(color: AppColors.textPrimary),
                    validator: isEdit
                        ? null
                        : (v) => (v == null || v.isEmpty)
                            ? 'Contraseña obligatoria'
                            : (v.length < 8 ? 'Mínimo 8 caracteres' : null),
                  ),
                  const SizedBox(height: 12),

                  // Toggles Staff y Activo en fila
                  Row(
                    children: [
                      Expanded(
                        child: _ToggleCard(
                          label:       'Rol Staff',
                          description: 'Acceso al admin',
                          value:       _isStaff,
                          onChanged:   isSaving
                              ? null
                              : (v) => setState(() => _isStaff = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ToggleCard(
                          label:       'Activo',
                          description: 'Puede iniciar sesión',
                          value:       _isActive,
                          onChanged:   isSaving
                              ? null
                              : (v) => setState(() => _isActive = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          child:     const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? const SizedBox(
                                  width:  18,
                                  height: 18,
                                  child:  CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color:       AppColors.onAccent,
                                  ),
                                )
                              : Text(isEdit ? 'Guardar cambios' : 'Crear usuario'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Card ──────────────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  final String              label;
  final String              description;
  final bool                value;
  final ValueChanged<bool>? onChanged;

  const _ToggleCard({
    required this.label,
    required this.description,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding:    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color:      AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize:   13,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color:    AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value:       value,
          onChanged:   onChanged,
          activeColor: AppColors.accent,
        ),
      ],
    ),
  );
}
