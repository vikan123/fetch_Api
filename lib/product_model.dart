class Model {
  final int id;
  final String title;
  final double price;
  final String category;
  final String image;
  final Rating rating; // Nested Rating object
  bool addedToCart;

  Model({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
    this.addedToCart = false,
  });

  // Factory method to parse from JSON
  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      category: json['category'],
      image: json['image'],
      rating: Rating.fromJson(json['rating']), // Parse nested Rating object
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({
    required this.rate,
    required this.count,
  });

  // Factory method to parse from JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: json['rate'].toDouble(),
      count: json['count'],
    );
  }
}
