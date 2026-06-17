import 'package:flutter/foundation.dart';
import '../data/repositories/cart_repository.dart';
import '../data/cart_item.dart';
import '../data/product.dart';

class CartController extends ChangeNotifier {
  final CartRepository _cartRepository;
  List<CartItem> _items = [];
  bool _isLoading = false;
  int? _currentUserId;

  CartController({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository();

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  double get shippingFee => _items.isEmpty ? 0.0 : 4.99;
  double get total => subtotal + shippingFee;

  // Initialise le panier pour un utilisateur donné
  Future<void> initUserCart(int? userId) async {
    _currentUserId = userId;
    await loadCart();
  }

  Future<void> loadCart() async {
    if (_currentUserId == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items = await _cartRepository.getCartForUser(_currentUserId!);
    } catch (e) {
      // Log error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(Product product, String side, int quantity) async {
    if (_currentUserId == null) return false;

    try {
      await _cartRepository.addItem(_currentUserId!, product.id!, side, quantity);
      await loadCart();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateQuantity(int cartId, int newQuantity) async {
    try {
      await _cartRepository.updateQuantity(cartId, newQuantity);
      await loadCart();
    } catch (e) {
      // Log error
    }
  }

  Future<void> removeItem(int cartId) async {
    try {
      await _cartRepository.removeItem(cartId);
      await loadCart();
    } catch (e) {
      // Log error
    }
  }

  Future<void> clearCart() async {
    if (_currentUserId == null) return;
    try {
      await _cartRepository.clear(_currentUserId!);
      await loadCart();
    } catch (e) {
      // Log error
    }
  }
}
