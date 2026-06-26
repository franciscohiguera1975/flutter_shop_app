// lib/presentation/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/auth_state.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _userCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _pass2Ctrl   = TextEditingController();
  bool  _submitted   = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
      _userCtrl.text,
      _emailCtrl.text,
      _passCtrl.text,
      _pass2Ctrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isChecking;
    final error     = authState.error;
    final tt        = Theme.of(context).textTheme;

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.isAuthenticated) {
        context.go(next.isStaff ? '/admin' : '/');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text('Flutter Shop App', style: tt.displayMedium?.copyWith(color: AppColors.accent)),
              const SizedBox(height: 8),
              Text('Crea tu cuenta gratis', style: tt.bodyMedium),
              const SizedBox(height: 40),

              Container(
                padding:    const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border:       Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      if (error != null) ...[
                        Container(
                          width:   double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:        AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            error,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Usuario
                      AuthTextField(
                        label:      'Usuario',
                        hint:       'mínimo 3 caracteres',
                        controller: _userCtrl,
                        enabled:    !isLoading,
                        validator:  _submitted ? validateUsername : null,
                        onChanged:  (_) => ref.read(authProvider.notifier).clearError(),
                      ),
                      const SizedBox(height: 14),

                      // Email
                      AuthTextField(
                        label:       'Email',
                        hint:        'tu@email.com',
                        controller:  _emailCtrl,
                        enabled:     !isLoading,
                        keyboardType:TextInputType.emailAddress,
                        validator:   _submitted ? validateEmail : null,
                        onChanged:   (_) => ref.read(authProvider.notifier).clearError(),
                      ),
                      const SizedBox(height: 14),

                      // Contraseña
                      AuthTextField(
                        label:      'Contraseña',
                        hint:       'mínimo 8 caracteres',
                        controller: _passCtrl,
                        isPassword: true,
                        enabled:    !isLoading,
                        validator:  _submitted ? validatePassword : null,
                        onChanged:  (_) => ref.read(authProvider.notifier).clearError(),
                      ),
                      const SizedBox(height: 14),

                      // Confirmar contraseña
                      AuthTextField(
                        label:           'Confirmar contraseña',
                        hint:            'repite la contraseña',
                        controller:      _pass2Ctrl,
                        isPassword:      true,
                        enabled:         !isLoading,
                        textInputAction: TextInputAction.done,
                        validator:       _submitted
                            ? (v) {
                                if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                                return null;
                              }
                            : null,
                        onChanged: (_) => ref.read(authProvider.notifier).clearError(),
                      ),
                      const SizedBox(height: 24),

                      AuthButton(
                        label:     'Crear mi cuenta',
                        onPressed: _submit,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Ya tienes cuenta? ', style: tt.bodyMedium),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Inicia sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}