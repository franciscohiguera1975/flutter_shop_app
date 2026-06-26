// lib/presentation/widgets/filters_sheet.dart

import 'package:flutter/material.dart';
import '../../domain/model/category.dart';
import '../../theme/app_colors.dart';

const _orderOptions = [
  ('Name A→Z',    'name'),
  ('Name Z→A',    '-name'),
  ('Price low',   'price'),
  ('Price high',  '-price'),
  ('Newest',      '-created_at'),
];

/// Muestra el BottomSheet de filtros y devuelve los filtros seleccionados.
Future<ProductFilters?> showFiltersSheet({
  required BuildContext context,
  required ProductFilters activeFilters,
  required List<Category> categories,
}) {
  return showModalBottomSheet<ProductFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FiltersSheet(
      activeFilters: activeFilters,
      categories: categories,
    ),
  );
}

class _FiltersSheet extends StatefulWidget {
  final ProductFilters activeFilters;
  final List<Category> categories;

  const _FiltersSheet({required this.activeFilters, required this.categories});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late int? _categoryId;
  late String? _ordering;
  final _ctrlMin = TextEditingController();
  final _ctrlMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoryId = widget.activeFilters.categoryId;
    _ordering = widget.activeFilters.ordering;
    _ctrlMin.text = widget.activeFilters.minPrice?.toStringAsFixed(0) ?? '';
    _ctrlMax.text = widget.activeFilters.maxPrice?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _ctrlMin.dispose();
    _ctrlMax.dispose();
    super.dispose();
  }

  void _apply() {
    Navigator.pop(
      context,
      ProductFilters(
        categoryId: _categoryId,
        ordering: _ordering,
        minPrice: double.tryParse(_ctrlMin.text),
        maxPrice: double.tryParse(_ctrlMax.text),
      ),
    );
  }

  void _clear() {
    Navigator.pop(context, const ProductFilters());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                    onPressed: _clear,
                    child: const Text('Clear',
                        style: TextStyle(color: AppColors.error))),
              ],
            ),
          ),
          const Divider(),

          // Contenido scrollable
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                // ── Category ────────────────────────────────
                const _SectionTitle('Category'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      active: _categoryId == null,
                      onTap: () => setState(() => _categoryId = null),
                    ),
                    ...widget.categories.map((cat) => _FilterChip(
                      label: cat.name,
                      active: _categoryId == cat.id,
                      onTap: () => setState(() => _categoryId = cat.id),
                    )),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Price range ───────────────────────────
                const _SectionTitle('Price Range'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrlMin,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('—',
                        style: TextStyle(
                            color: AppColors.textFaint, fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _ctrlMax,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Sort by ───────────────────────────────
                const _SectionTitle('Sort by'),
                const SizedBox(height: 8),
                ..._orderOptions.map((o) => RadioListTile<String>(
                      title: Text(o.$1),
                      value: o.$2,
                      groupValue: _ordering,
                      onChanged: (v) => setState(() => _ordering = v),
                      activeColor: AppColors.accent,
                      contentPadding: EdgeInsets.zero,
                    )),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('Apply filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.accent : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              color: active ? AppColors.onAccent : AppColors.textSecondary,
            ),
          ),
        ),
      );
}

// ── Modelos de filtros ───────────────────────────────────────

class ProductFilters {
  final int? categoryId;
  final String? ordering;
  final double? minPrice;
  final double? maxPrice;

  const ProductFilters({
    this.categoryId,
    this.ordering,
    this.minPrice,
    this.maxPrice,
  });

  int get activeCount {
    int count = 0;
    if (categoryId != null) count++;
    if (ordering != null) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    return count;
  }
}