// lib/presentation/widgets/product_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../providers/image_upload_provider.dart';
import '../providers/products_admin_provider.dart';
import './product_image.dart';

Future<void> showProductForm(
  BuildContext context,
  WidgetRef ref, {
  Product? initial,
  required List<Category> categories,
}) {
  ref.read(productsAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child:  ProductFormSheet(initial: initial, categories: categories),
    ),
  );
}

class ProductFormSheet extends ConsumerStatefulWidget {
  final Product?       initial;
  final List<Category> categories;
  const ProductFormSheet({super.key, this.initial, required this.categories});

  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  bool    _isActive        = true;
  int?    _categoryId;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final p = widget.initial!;
      _nameCtrl.text  = p.name;
      _descCtrl.text  = p.description;
      _priceCtrl.text = p.price.toStringAsFixed(2);
      _stockCtrl.text = p.stock.toString();
      _isActive        = p.isActive;
      _categoryId      = p.category?.id;
      _currentImageUrl = p.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name':        _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price':       double.parse(_priceCtrl.text),
      'stock':       int.parse(_stockCtrl.text),
      'is_active':   _isActive,
      'category_id': _categoryId,
    };
    if (widget.initial != null) {
      await ref
          .read(productsAdminProvider.notifier)
          .updateProduct(widget.initial!.id, payload);
    } else {
      await ref.read(productsAdminProvider.notifier).createProduct(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(productsAdminProvider.select((s) => s.formState));
    final isSaving = formSt is ProductFormSaving;
    final isEdit   = widget.initial != null;

    ref.listen<ImageUploadState>(imageUploadProvider, (_, next) {
      if (next is ImageUploadSuccess && next.imageUrl != null) {
        setState(() => _currentImageUrl = next.imageUrl);
      }
    });
    final isUploadingImage = ref.watch(imageUploadProvider) is ImageUploadLoading;

    if (formSt is ProductFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    final activeCategories =
        widget.categories.where((c) => c.isActive).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              isEdit ? 'Editar: ${widget.initial!.name}' : 'Nuevo producto',
              style: const TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isEdit)
              GestureDetector(
                onTap: isUploadingImage
                    ? null
                    : () => ref
                        .read(imageUploadProvider.notifier)
                        .pickAndUploadProductImage(widget.initial!.id),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 160,
                    width:  double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImage(
                          imageUrl:     _currentImageUrl,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        if (isUploadingImage)
                          const ColoredBox(
                            color: Colors.black45,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            color: Colors.black38,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera_outlined,
                                  color: Colors.white,
                                  size:  32,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Cambiar imagen',
                                  style: TextStyle(
                                    color:      Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                height:      100,
                decoration: BoxDecoration(
                  color:        AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: AppColors.textFaint,
                      size:  32,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'La imagen se puede añadir\ntras crear el producto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:    AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (formSt is ProductFormError) ...[
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
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    enabled:    !isSaving,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                    style:      const TextStyle(color: AppColors.textPrimary),
                    validator:  (v) => validateRequired(v, 'Nombre'),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:   _priceCtrl,
                          enabled:      !isSaving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText:  'Precio *',
                            prefixText: '\$ ',
                          ),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) =>
                              validatePositiveNumber(v, 'Precio'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller:   _stockCtrl,
                          enabled:      !isSaving,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock *',
                          ),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) =>
                              validateNonNegativeInt(v, 'Stock'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value:        _categoryId,
                    decoration:   const InputDecoration(labelText: 'Categoría *'),
                    dropdownColor: AppColors.surface2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          '— Seleccionar —',
                          style: TextStyle(color: AppColors.textFaint),
                        ),
                      ),
                      ...activeCategories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                    ],
                    onChanged: isSaving
                        ? null
                        : (v) => setState(() => _categoryId = v),
                    validator: (v) =>
                        v == null ? 'Selecciona una categoría' : null,
                  ),
                  const SizedBox(height: 12),
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
                              'Producto activo',
                              style: TextStyle(
                                color:      AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Visible en el catálogo',
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
                                  isEdit ? 'Guardar cambios' : 'Crear producto',
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
