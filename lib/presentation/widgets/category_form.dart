// lib/presentation/widgets/category_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/category.dart';
import '../providers/categories_admin_provider.dart';

String toSlug(String input) => input
    .toLowerCase()
    .replaceAll(RegExp(r'[áàäâ]'), 'a')
    .replaceAll(RegExp(r'[éèëê]'), 'e')
    .replaceAll(RegExp(r'[íìïî]'), 'i')
    .replaceAll(RegExp(r'[óòöôõ]'), 'o')
    .replaceAll(RegExp(r'[úùüû]'), 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
    .trim()
    .replaceAll(RegExp(r'\s+'), '-');

Future<void> showCategoryForm(
  BuildContext context,
  WidgetRef ref, {
  Category? initial,
}) {
  ref.read(categoriesAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child:  CategoryFormSheet(initial: initial),
    ),
  );
}

class CategoryFormSheet extends ConsumerStatefulWidget {
  final Category? initial;
  const CategoryFormSheet({super.key, this.initial});

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isActive   = true;
  bool _slugEdited = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final c = widget.initial!;
      _nameCtrl.text = c.name;
      _slugCtrl.text = c.slug;
      _descCtrl.text = c.description;
      _isActive      = c.isActive;
      _slugEdited    = true;
    }
    _nameCtrl.addListener(() {
      if (!_slugEdited) {
        setState(() => _slugCtrl.text = toSlug(_nameCtrl.text));
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name':        _nameCtrl.text.trim(),
      'slug':        _slugCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'is_active':   _isActive,
    };
    if (widget.initial != null) {
      await ref
          .read(categoriesAdminProvider.notifier)
          .updateCategory(widget.initial!.id, payload);
    } else {
      await ref.read(categoriesAdminProvider.notifier).createCategory(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(categoriesAdminProvider.select((s) => s.formState));
    final isSaving = formSt is CategoryFormSaving;
    final isEdit   = widget.initial != null;

    if (formSt is CategoryFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width:  40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEdit ? 'Editar: ${widget.initial!.name}' : 'Nueva categoría',
              style: const TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (formSt is CategoryFormError) ...[
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    enabled:    !isSaving,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                    style:      const TextStyle(color: AppColors.textPrimary),
                    validator:  (v) => validateRequired(v, 'Nombre'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _slugCtrl,
                    enabled:    !isSaving,
                    decoration: InputDecoration(
                      labelText:  'Slug (URL) *',
                      helperText: 'URL: /catalog?category=${_slugCtrl.text}',
                    ),
                    style: const TextStyle(
                      color:      AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                    onChanged: (_) => setState(() => _slugEdited = true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Slug es obligatorio';
                      }
                      if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v.trim())) {
                        return 'Solo minúsculas, números y guiones';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descCtrl,
                    enabled:    !isSaving,
                    maxLines:   3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:        AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categoría activa',
                              style: TextStyle(
                                color:      AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Visible en el catálogo público',
                              style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value:     _isActive,
                          onChanged: isSaving
                              ? null
                              : (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.accent,
                          trackColor: WidgetStateProperty.resolveWith((s) =>
                            s.contains(WidgetState.selected)
                                ? AppColors.accent.withValues(alpha: 0.4)
                                : AppColors.border,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.onAccent,
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Guardar cambios' : 'Crear categoría',
                                ),
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
