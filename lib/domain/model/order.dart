// lib/domain/model/order.dart

enum OrderStatus {
  pending  ('pending',   'Pendiente'),
  confirmed('confirmed', 'Confirmado'),
  shipped  ('shipped',   'Enviado'),
  delivered('delivered', 'Entregado'),
  cancelled('cancelled', 'Cancelado');

  const OrderStatus(this.value, this.label);
  final String value;
  final String label;

  static OrderStatus fromValue(String v) =>
      OrderStatus.values.firstWhere((s) => s.value == v, orElse: () => OrderStatus.pending);
}

class OrderItem {
  final int    id;
  final int    productId;
  final String productName;
  final int    quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id:          j['id']                                       as int,
    productId:   (j['product'] as Map<String, dynamic>)['id'] as int,
    productName: (j['product'] as Map<String, dynamic>)['name'] as String,
    quantity:    j['quantity']                                 as int,
    unitPrice:   double.parse(j['unit_price'].toString()),
    subtotal:    (j['subtotal'] as num).toDouble(),
  );
}

class Order {
  final int         id;
  final String      username;
  final OrderStatus status;
  final double      total;
  final int         numItems;
  final List<OrderItem> items;
  final String      createdAt;
  final String      updatedAt;

  const Order({
    required this.id,
    required this.username,
    required this.status,
    required this.total,
    required this.numItems,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id:        j['id']                                 as int,
    username:  j['username']                           as String,
    status:    OrderStatus.fromValue(j['status']       as String),
    total:     double.parse(j['total'].toString()),
    numItems:  j['num_items']                          as int,
    items:     (j['items'] as List)
               .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
               .toList(),
    createdAt: j['created_at']                         as String,
    updatedAt: j['updated_at']                         as String,
  );

  Order copyWith({OrderStatus? status}) => Order(
    id:        id,
    username:  username,
    status:    status ?? this.status,
    total:     total,
    numItems:  numItems,
    items:     items,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class PaginatedOrders {
  final int         count;
  final String?     next;
  final List<Order> results;

  const PaginatedOrders({
    required this.count,
    required this.next,
    required this.results,
  });

  factory PaginatedOrders.fromJson(Map<String, dynamic> j) => PaginatedOrders(
    count:   j['count']   as int,
    next:    j['next']    as String?,
    results: (j['results'] as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}