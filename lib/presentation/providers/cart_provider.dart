// lib/presentation/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/product.dart';

class CartItem {
  final Product product;
  final int     quantity;
  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  double get subtotal => product.price * quantity;
}

class CartState {
  final List<CartItem> items;
  const CartState({this.items = const []});

  int    get totalItems   => items.fold(0, (s, i) => s + i.quantity);
  double get subtotal     => items.fold(0.0, (s, i) => s + i.subtotal);
  double get totalWithTax => items.fold(0.0, (s, i) => s + i.product.priceWithTax * i.quantity);

  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(Product product, {int quantity = 1}) {
    final idx = state.items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state.items);
      final newQty  = (updated[idx].quantity + quantity).clamp(1, product.stock);
      updated[idx]  = updated[idx].copyWith(quantity: newQty);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(product: product, quantity: quantity)]);
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) =>
        i.product.id == productId ? i.copyWith(quantity: quantity) : i,
      ).toList(),
    );
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void clearCart() => state = const CartState();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (_) => CartNotifier(),
);