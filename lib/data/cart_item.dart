import 'product.dart';

class CartItem {
  final int? id;
  final Product product;
  final int quantity;
  final String side; // 'Gauche', 'Droite', 'Universel'

  CartItem({
    this.id,
    required this.product,
    required this.quantity,
    required this.side,
  });

  Map<String, dynamic> toMap(int userId) {
    return {
      'id': id,
      'user_id': userId,
      'product_id': product.id,
      'quantity': quantity,
      'side': side,
    };
  }
}
