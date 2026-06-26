// lib/main.dart — actualizar VerificationScreen con llamada real al backend

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'data/repository/category_repository_impl.dart';
import 'domain/model/category.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: FlutterShopApp()));
}

class FlutterShopApp extends StatelessWidget {
  const FlutterShopApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title:            AppConfig.appName,
    debugShowCheckedModeBanner: false,
    theme:            AppTheme.dark,
    home:             const VerificationScreen(),
  );
}

// Provider de verificación
final _categoriesVerifyProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(_categoriesVerifyProvider);
    final tt              = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Text(AppConfig.appName, style: tt.displayMedium?.copyWith(color: AppColors.accent)),
                    const SizedBox(height: 6),
                    Text('Módulo 2 · Conexión real con Django', style: tt.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Estado de la conexión
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.border),
                ),
                child: categoriesAsync.when(
                  loading: () => const Row(
                    children: [
                      SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:       AppColors.accent,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Conectando con Django...', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  error: (err, _) => Row(
                    children: [
                      const Text('❌ ', style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: Text(
                          err.toString(),
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  data: (cats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ ${cats.length} categorías del backend',
                        style: const TextStyle(
                          color:      AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cats.take(3).map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                            Text(
                              '${c.totalProducts} prod.',
                              style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Capa de datos
              Text(
                'CAPA DE DATOS',
                style: tt.labelSmall?.copyWith(letterSpacing: 1.2, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...[
                'data/local/secure_storage.dart',
                'data/remote/api/dio_client.dart',
                'core/error/api_exception.dart',
                'data/remote/api/category_remote_datasource.dart',
                'data/remote/api/product_remote_datasource.dart',
                'data/remote/api/order_remote_datasource.dart',
                'data/remote/api/user_remote_datasource.dart',
              ].map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'lib/$f',
                        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text('✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}