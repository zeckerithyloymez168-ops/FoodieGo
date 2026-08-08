class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final String time;
  final String kcal;
  final List<String> ingredients;
  final bool isPopular;
  final bool isVeg;
  final int reviewCount;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 4.5,
    this.time = '20 min',
    this.kcal = '250 Kcal',
    this.ingredients = const [],
    this.isPopular = false,
    this.isVeg = true,
    this.reviewCount = 120,
  });

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      imageUrl: (map['imageUrl'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Food',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      time: (map['time'] as String?) ?? '20 min',
      kcal: (map['kcal'] as String?) ?? '250 Kcal',
      ingredients: (map['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isPopular: map['isPopular'] as bool? ?? false,
      isVeg: map['isVeg'] as bool? ?? true,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'time': time,
      'kcal': kcal,
      'ingredients': ingredients,
      'isPopular': isPopular,
      'isVeg': isVeg,
      'reviewCount': reviewCount,
    };
  }

  FoodItem copyWith({String? id}) {
    return FoodItem(
      id: id ?? this.id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      rating: rating,
      time: time,
      kcal: kcal,
      ingredients: ingredients,
      isPopular: isPopular,
      isVeg: isVeg,
      reviewCount: reviewCount,
    );
  }
}
