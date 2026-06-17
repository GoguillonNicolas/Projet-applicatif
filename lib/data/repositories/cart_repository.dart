import '../database_helper.dart';
import '../cart_item.dart';

class CartRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CartItem>> getCartForUser(int userId) {
    return _dbHelper.getCartItems(userId);
  }

  Future<void> addItem(int userId, int productId, String side, int quantity) {
    return _dbHelper.addToCart(userId, productId, side, quantity);
  }

  Future<void> updateQuantity(int cartId, int quantity) {
    return _dbHelper.updateCartQuantity(cartId, quantity);
  }

  Future<void> removeItem(int cartId) {
    return _dbHelper.removeFromCart(cartId);
  }

  Future<void> clear(int userId) {
    return _dbHelper.clearCart(userId);
  }
}
