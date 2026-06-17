import 'package:flutter/material.dart';
import '../data/cart_item.dart';
import '../data/repositories/cart_repository.dart';
import '../data/user.dart';

class CartScreen extends StatefulWidget {
  final UserAccount? currentUser;
  final VoidCallback onCartUpdated;
  final int refreshTrigger;

  const CartScreen({
    super.key,
    required this.currentUser,
    required this.onCartUpdated,
    required this.refreshTrigger,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger || oldWidget.currentUser != widget.currentUser) {
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    if (widget.currentUser == null) {
      setState(() {
        _cartItems = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final items = await CartRepository().getCartForUser(widget.currentUser!.id!);
    setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get _shipping {
    return _cartItems.isEmpty ? 0.0 : 4.99; // Frais fixes de livraison
  }

  double get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFF64748B)),
                SizedBox(height: 15),
                Text(
                  'Connectez-vous pour voir votre panier',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos brides de rechange vous attendent sagement.',
                  style: TextStyle(color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE58B24)))
          : _cartItems.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Color(0xFF94A3B8)),
                        SizedBox(height: 15),
                        Text(
                          'Votre panier est vide',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ajoutez quelques brides de rechange pour commencer à réparer.',
                          style: TextStyle(color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _buildCartItemCard(item);
                        },
                      ),
                    ),
                    _buildSummaryCard(),
                  ],
                ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    final cardColor = Color(item.product.colorHex);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                item.product.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, color: cardColor.withOpacity(0.4));
                },
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Côté : ${item.side}',
                  style: TextStyle(fontSize: 12, color: cardColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.product.price.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF264C72)),
                ),
              ],
            ),
          ),

          // Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                onPressed: () => _removeItem(item.id!),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _updateQuantity(item.id!, item.quantity - 1),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _updateQuantity(item.id!, item.quantity + 1),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total', style: TextStyle(color: Color(0xFF64748B))),
                Text('${_subtotal.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Livraison (Frais fixes)', style: TextStyle(color: Color(0xFF64748B))),
                Text('${_shipping.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 25, color: Color(0xFFE2E8F0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                Text(
                  '${_total.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF264C72)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE58B24),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text('Valider la commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateQuantity(int cartId, int newQuantity) async {
    await CartRepository().updateQuantity(cartId, newQuantity);
    _loadCart();
    widget.onCartUpdated();
  }

  Future<void> _removeItem(int cartId) async {
    await CartRepository().removeItem(cartId);
    _loadCart();
    widget.onCartUpdated();
  }

  Future<void> _checkout() async {
    await CartRepository().clear(widget.currentUser!.id!);
    _loadCart();
    widget.onCartUpdated();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Commande validée ! 🎉'),
        content: const Text(
          'Merci pour votre commande. Vos brides sont déjà en préparation et arriveront bientôt dans votre boîte aux lettres !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Super !', style: TextStyle(color: Color(0xFFE58B24), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
