import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/user.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  UserAccount? _currentUser;
  int _cartCount = 0;

  // Clés globales pour pouvoir forcer le rafraîchissement des écrans
  final GlobalKey<State> _cartScreenKey = GlobalKey<State>();
  final GlobalKey<State> _homeScreenKey = GlobalKey<State>();
  final GlobalKey<State> _searchScreenKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    _updateCartBadge();
  }

  Future<void> _updateCartBadge() async {
    if (_currentUser == null) {
      setState(() {
        _cartCount = 0;
      });
      return;
    }
    final items = await DatabaseHelper.instance.getCartItems(_currentUser!.id!);
    int count = items.fold(0, (sum, item) => sum + item.quantity);
    setState(() {
      _cartCount = count;
    });
  }

  void _onUserChanged(UserAccount? newUser) {
    setState(() {
      _currentUser = newUser;
      _currentIndex = 0; // Redirige vers l'accueil à la connexion/déconnexion
    });
    _updateCartBadge();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        key: _homeScreenKey,
        currentUser: _currentUser,
        onCartUpdated: _updateCartBadge,
      ),
      SearchScreen(
        key: _searchScreenKey,
        currentUser: _currentUser,
        onCartUpdated: _updateCartBadge,
      ),
      CartScreen(
        key: _cartScreenKey,
        currentUser: _currentUser,
        onCartUpdated: _updateCartBadge,
      ),
      AccountScreen(
        currentUser: _currentUser,
        onUserChanged: _onUserChanged,
      ),
    ];

    final List<String> titles = [
      'Débridé 🩴',
      'Catalogue de Brides',
      'Mon Panier',
      'Mon Compte',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _currentIndex == 0
            ? Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.beach_access, color: Color(0xFFE58B24), size: 32);
                    },
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat',
                      ),
                      children: [
                        TextSpan(
                          text: 'Dé',
                          style: TextStyle(color: Color(0xFF264C72)),
                        ),
                        TextSpan(
                          text: 'bridé',
                          style: TextStyle(color: Color(0xFFE58B24)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                titles[_currentIndex],
                style: const TextStyle(
                  color: Color(0xFF264C72),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Met à jour le panier à chaque fois qu'on change d'onglet
            _updateCartBadge();
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFE58B24),
          unselectedItemColor: const Color(0xFF94A3B8),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Recherche',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (_cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE58B24),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
              label: 'Panier',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Compte',
            ),
          ],
        ),
      ),
    );
  }
}
