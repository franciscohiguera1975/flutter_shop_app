// lib/presentation/widgets/restock_dialog.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/product.dart';

Future<int?> showRestockDialog(BuildContext context, Product product) {
  return showDialog<int>(
    context: context,
    builder: (_) => _RestockDialog(product: product),
  );
}

class _RestockDialog extends StatefulWidget {
  final Product product;
  const _RestockDialog({required this.product});

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qty    = int.tryParse(_qtyCtrl.text);
    final newQty = qty != null ? widget.product.stock + qty : null;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restock: ${widget.product.name}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Stock actual: ${widget.product.stock} unidades',
            style: TextStyle(
              color: widget.product.stock == 0
                  ? AppColors.error
                  : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller:   _qtyCtrl,
              keyboardType: TextInputType.number,
              autofocus:    true,
              decoration: const InputDecoration(
                labelText: 'Cantidad a añadir *',
              ),
              style:     const TextStyle(color: AppColors.textPrimary),
              validator: (v) => validatePositiveNumber(v, 'Cantidad'),
              onChanged: (_) => setState(() {}),
            ),
            if (newQty != null) ...[
              const SizedBox(height: 8),
              Text(
                'Nuevo stock: $newQty unidades',
                style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:     const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, int.parse(_qtyCtrl.text));
            }
          },
          child: const Text('Añadir stock'),
        ),
      ],
    );
  }
}
