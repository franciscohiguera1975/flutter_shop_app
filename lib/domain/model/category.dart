// lib/domain/model/category.dart

class Category {
  final int    id;
  final String name;
  final String slug;
  final String description;
  final bool   isActive;
  final int    totalProducts;
  final String createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.totalProducts,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id:            j['id']             as int,
    name:          j['name']           as String,
    slug:          j['slug']           as String,
    description:   j['description']    as String,
    isActive:      j['is_active']      as bool,
    totalProducts: j['total_products'] as int,
    createdAt:     j['created_at']     as String,
  );

  Map<String, dynamic> toJson() => {
    'name':        name,
    'slug':        slug,
    'description': description,
    'is_active':   isActive,
  };

  Category copyWith({bool? isActive, String? name, String? slug, String? description}) =>
    Category(
      id:            id,
      name:          name          ?? this.name,
      slug:          slug          ?? this.slug,
      description:   description   ?? this.description,
      isActive:      isActive      ?? this.isActive,
      totalProducts: totalProducts,
      createdAt:     createdAt,
    );
}