import 'package:flutter/material.dart';
import '../data/cart_item.dart';
import '../logic/auth_controller.dart';
import '../logic/cart_controller.dart';

class CartScreen extends StatefulWidget {
  final AuthController authController;
  final CartController cartController;

  const CartScreen({
    super.key,
    required this.authController,
    required this.cartController,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    widget.cartController.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    widget.cartController.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartController != widget.cartController) {
      oldWidget.cartController.removeListener(_onCartChanged);
      widget.cartController.addListener(_onCartChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.authController.isAuthenticated) {
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

    final cartController = widget.cartController;

    return Scaffold(
      body: cartController.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE58B24)))
          : cartController.items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                        const SizedBox(height: 15),
                        Text(
                          'Votre panier est vide',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez quelques brides de rechange pour commencer à réparer.',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
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
                        itemCount: cartController.items.length,
                        itemBuilder: (context, index) {
                          final item = cartController.items[index];
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                item.product.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.broken_image, color: cardColor.withOpacity(0.4)),
                  );
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
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
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.secondary),
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
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.remove, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
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
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
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
    final cartController = widget.cartController;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                Text('Sous-total', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                Text('${cartController.subtotal.toStringAsFixed(2)} €', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Livraison (Frais fixes)', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                Text('${cartController.shippingFee.toStringAsFixed(2)} €', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Divider(height: 25, color: Theme.of(context).dividerColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                Text(
                  '${cartController.total.toStringAsFixed(2)} €',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Theme.of(context).colorScheme.secondary),
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
    await widget.cartController.updateQuantity(cartId, newQuantity);
  }

  Future<void> _removeItem(int cartId) async {
    await widget.cartController.removeItem(cartId);
  }

  Future<void> _checkout() async {
    await widget.cartController.clearCart();

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
