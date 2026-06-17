class Product {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String imagePath;
  final int colorHex; // Pour afficher des teintes différentes dans l'UI
  final double rating;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.colorHex,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category': 'laniere', // Toujours une lanière (bride en T)
      'image_path': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    // Mapping des couleurs factices selon l'ID ou le nom pour l'esthétique
    int color = 0xFFE58B24; // Couleur orange par défaut
    if (map['name'].toString().contains('Noire')) {
      color = 0xFF1E293B;
    } else if (map['name'].toString().contains('Carbone')) {
      color = 0xFF475569;
    } else if (map['name'].toString().contains('Vegan')) {
      color = 0xFF8D6E63;
    } else if (map['name'].toString().contains('Transparente')) {
      color = 0xFF90CAF9;
    } else if (map['name'].toString().contains('Vintage')) {
      color = 0xFFD4AF37;
    }

    // Notation factice
    double rating = 4.5;
    if (map['id'] != null) {
      rating = 4.0 + ((map['id'] * 3) % 10) / 10.0;
    }

    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'] ?? 'Une superbe bride en T pour réparer ou personnaliser votre tong préférée.',
      imagePath: map['image_path'] ?? 'assets/images/logo.png',
      colorHex: color,
      rating: rating,
    );
  }
}
