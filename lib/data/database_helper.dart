import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product.dart';
import 'user.dart';
import 'cart_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('debride.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print("📂 SQLITE DB PATH: $path");

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS cart');
          await db.execute('DROP TABLE IF EXISTS products');
          await db.execute('DROP TABLE IF EXISTS users');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table Utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Table Produits (uniquement des lanières)
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        image_path TEXT
      )
    ''');

    // Table Panier
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        side TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    // Pré-remplissage des produits (Lanières / Brides en T uniquement)
    await _prepopulateProducts(db);
  }

  Future<void> _prepopulateProducts(Database db) async {
    final List<Map<String, dynamic>> initialProducts = [
      {
        'name': 'La Bride Classique Noire',
        'category': 'laniere',
        'price': 1.99,
        'description': 'Le modèle de base en plastique noir ultra-résistant. Passe-partout, s\'adapte à toutes les semelles.',
        'image_path': 'assets/images/black_strap.png',
      },
      {
        'name': 'La Lanière Orange Fluo',
        'category': 'laniere',
        'price': 2.99,
        'description': 'La couleur officielle Débridé ! Mandarine vibrante rétro-réfléchissante pour être vu de loin sur le sable.',
        'image_path': 'assets/images/orange_strap.png',
      },
      {
        'name': 'La Bride Cuir Vegan',
        'category': 'laniere',
        'price': 6.99,
        'description': 'Finition cuir marron synthétique de haute qualité. Idéal pour donner un look chic et habillé à vos tongs abîmées.',
        'image_path': 'assets/images/leather_strap.png',
      },
      {
        'name': 'La Bride Transparente Pailletée',
        'category': 'laniere',
        'price': 3.49,
        'description': 'Translucide avec des incrustations de paillettes argentées. Discrète mais avec ce petit côté festif.',
        'image_path': 'assets/images/glitter_strap.png',
      },
      {
        'name': 'La Bride Carbone Aérodynamique',
        'category': 'laniere',
        'price': 8.99,
        'description': 'Look fibre de carbone brute. Légère, rigide et testée en soufflerie pour une vitesse de marche maximale.',
        'image_path': 'assets/images/carbon_strap.png',
      },
      {
        'name': 'La Bride Vintage Tressée',
        'category': 'laniere',
        'price': 5.49,
        'description': 'Tressage coton bohème pour un confort optimal sans irritation. Le charme rétro absolu.',
        'image_path': 'assets/images/braided_strap.png',
      },
    ];

    for (var product in initialProducts) {
      await db.insert('products', product);
    }
  }

  // --- CRUD UTILISATEURS ---

  Future<UserAccount?> registerUser(String username, String email, String password) async {
    final db = await instance.database;
    try {
      final id = await db.insert('users', {
        'username': username,
        'email': email,
        'password': password,
      });
      return UserAccount(id: id, username: username, email: email, password: password);
    } catch (e) {
      return null; // Erreur (ex: email déjà existant)
    }
  }

  Future<UserAccount?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserAccount.fromMap(maps.first);
    }
    return null;
  }

  // --- ACTIONS PRODUITS ---

  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // --- ACTIONS PANIER ---

  Future<List<CartItem>> getCartItems(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        cart.id as cart_id, 
        cart.quantity as cart_quantity, 
        cart.side as cart_side, 
        products.id as product_id,
        products.name as product_name,
        products.category as product_category,
        products.price as product_price,
        products.description as product_description,
        products.image_path as product_image_path
      FROM cart 
      INNER JOIN products ON cart.product_id = products.id 
      WHERE cart.user_id = ?
    ''', [userId]);

    return result.map((map) {
      final productMap = {
        'id': map['product_id'],
        'name': map['product_name'],
        'category': map['product_category'],
        'price': map['product_price'],
        'description': map['product_description'],
        'image_path': map['product_image_path'],
      };
      
      final cartId = map['cart_id'] != null ? int.tryParse(map['cart_id'].toString()) : null;
      final quantity = map['cart_quantity'] != null ? int.tryParse(map['cart_quantity'].toString()) ?? 1 : 1;
      final side = map['cart_side']?.toString() ?? 'Universel';

      return CartItem(
        id: cartId,
        product: Product.fromMap(productMap),
        quantity: quantity,
        side: side,
      );
    }).toList();
  }

  Future<void> addToCart(int userId, int productId, String side, int quantity) async {
    final db = await instance.database;

    // Vérifier si la même lanière du même côté existe déjà dans le panier
    final existing = await db.query(
      'cart',
      where: 'user_id = ? AND product_id = ? AND side = ?',
      whereArgs: [userId, productId, side],
    );

    if (existing.isNotEmpty) {
      final currentQuantity = int.tryParse(existing.first['quantity'].toString()) ?? 1;
      await db.update(
        'cart',
        {'quantity': currentQuantity + quantity},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('cart', {
        'user_id': userId,
        'product_id': productId,
        'side': side,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateCartQuantity(int cartId, int quantity) async {
    final db = await instance.database;
    if (quantity <= 0) {
      await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
    } else {
      await db.update(
        'cart',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [cartId],
      );
    }
  }

  Future<void> removeFromCart(int cartId) async {
    final db = await instance.database;
    await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> clearCart(int userId) async {
    final db = await instance.database;
    await db.delete('cart', where: 'user_id = ?', whereArgs: [userId]);
  }
}
