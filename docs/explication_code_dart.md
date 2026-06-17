# Explication du code Dart — Débridé

Ce document explique tout le code de l'application, fichier par fichier, avec des commentaires simples (niveau étudiant) pour préparer une présentation. Les extraits de code ci-dessous reprennent le code réel du projet avec des commentaires ajoutés pour l'explication — **le code source dans `lib/` n'a pas été modifié**.

## Plan du projet

```
lib/
├── main.dart                  → point d'entrée + thème de l'app
├── data/                      → les données (modèles + base SQLite)
│   ├── product.dart
│   ├── user.dart
│   ├── cart_item.dart
│   ├── database_helper.dart
│   └── repositories/
│       ├── product_repository.dart
│       ├── user_repository.dart
│       └── cart_repository.dart
├── logic/                     → l'état de l'app (qui est connecté, quoi dans le panier)
│   ├── auth_controller.dart
│   └── cart_controller.dart
└── screens/                   → les écrans (l'interface visible)
    ├── main_navigation.dart
    ├── home_screen.dart
    ├── search_screen.dart
    ├── cart_screen.dart
    ├── product_detail_screen.dart
    └── account_screen.dart
```

C'est une **architecture en 3 couches** :
1. **data** : comment les données sont stockées et lues
2. **logic** : comment l'état de l'app est géré et partagé
3. **screens** : ce que l'utilisateur voit et touche

---

## 1. `main.dart` — le point de départ

```dart
void main() {
  runApp(const DebrideApp());           // démarre l'app Flutter avec DebrideApp comme racine
}

class DebrideApp extends StatelessWidget {
  // StatelessWidget = un widget qui ne change jamais une fois affiché
  const DebrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(                 // MaterialApp configure toute l'app (thème, écran de départ...)
      title: 'Débridé',
      theme: ThemeData(                 // définit les couleurs et polices utilisées partout
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF264C72),
        ),
      ),
      home: const MainNavigation(),     // premier écran affiché au lancement
    );
  }
}
```

**Idée à retenir** : `main()` est le point d'entrée obligatoire de tout programme Dart. `runApp()` accroche notre widget racine à l'écran du téléphone.

---

## 2. La couche `data/` — modèles

Un **modèle** est juste une classe qui transporte des données (comme une fiche). On en a 3 : `Product`, `UserAccount`, `CartItem`.

### `product.dart`

```dart
class Product {
  final int? id;        // le "?" veut dire que ça peut être null (pas encore en base)
  final String name;
  final double price;
  final String description;
  final String imagePath;
  final int colorHex;   // couleur utilisée pour décorer la carte produit
  final double rating;  // note en étoiles

  Product({
    this.id,
    required this.name,   // "required" = obligatoire à la création
    required this.price,
    required this.description,
    required this.imagePath,
    required this.colorHex,
    required this.rating,
  });

  // Transforme l'objet en Map (clé/valeur) pour pouvoir l'enregistrer en base SQLite
  Map<String, dynamic> toMap() { ... }

  // Fait l'inverse : transforme une ligne lue dans la base en objet Product
  factory Product.fromMap(Map<String, dynamic> map) { ... }
}
```

Petite astuce dans `fromMap` : la **couleur** et la **note** ne sont pas stockées dans la base, elles sont devinées à partir du nom/id du produit (juste pour varier l'affichage visuellement).

### `user.dart` et `cart_item.dart`

Même principe :
- `UserAccount` transporte `username`, `email`, `password`.
- `CartItem` transporte un `Product`, une `quantity` et un `side` (côté gauche/droite/universel).

**Idée à retenir** : `toMap()` et `fromMap()` sont le pont entre "objet Dart" (ce qu'on manipule dans le code) et "ligne de base de données" (ce que SQLite comprend, juste du texte/nombres).

---

## 3. `database_helper.dart` — la base de données SQLite

C'est le seul fichier qui parle directement à SQLite (le système de base de données local du téléphone).

```dart
class DatabaseHelper {
  // Singleton : on veut une SEULE instance de la base dans toute l'app,
  // pas une nouvelle connexion chaque fois qu'on en a besoin.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init(); // constructeur privé (le "_" interdit de l'appeler depuis l'extérieur)

  Future<Database> get database async {
    if (_database != null) return _database!;     // déjà ouverte ? on la réutilise
    _database = await _initDB('debride.db');      // sinon on l'ouvre
    return _database!;
  }
}
```

**Idée à retenir : `Future` et `async/await`**
- `Future<Database>` veut dire "une Database qui arrivera plus tard" (ouvrir un fichier prend du temps).
- `async` marque une fonction qui peut faire des pauses.
- `await` met en pause JUSTE cette fonction (pas toute l'app) en attendant le résultat.

### Création des tables

```dart
Future<void> _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL
    )
  ''');
  // + table "products" et table "cart" (avec FOREIGN KEY vers users et products)
}
```

Au premier lancement, 3 tables sont créées en SQL pur, et 6 produits de démonstration sont insérés automatiquement (`_prepopulateProducts`).

### Les opérations principales (CRUD = Create, Read, Update, Delete)

| Méthode | Rôle |
|---|---|
| `registerUser` / `loginUser` | créer un compte / vérifier email+mot de passe |
| `getProducts` / `searchProducts` | lire tous les produits / chercher par mot-clé (`LIKE`) |
| `addToCart` | ajoute un produit au panier (ou augmente la quantité s'il y est déjà) |
| `updateCartQuantity` | change la quantité (supprime la ligne si elle tombe à 0) |
| `removeFromCart` / `clearCart` | supprime une ligne / vide tout le panier |
| `getCartItems` | récupère le panier complet avec une requête `JOIN` (panier + infos produit en une seule requête) |

**Point à souligner en présentation** : les mots de passe sont stockés **en clair**, sans hash — ce n'est pas sécurisé, c'est un raccourci pédagogique acceptable pour un projet d'école mais à mentionner comme limite si on te le demande.

---

## 4. `repositories/` — la couche intermédiaire

Les repositories ne font (presque) que **déléguer** à `DatabaseHelper`. Exemple complet (`product_repository.dart`) :

```dart
class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getAllProducts() => _dbHelper.getProducts();
  Future<List<Product>> search(String query) => _dbHelper.searchProducts(query);
}
```

**Pourquoi cette couche si elle ne fait "rien" ?** C'est le **pattern Repository** : il sert à isoler le reste de l'app (les écrans, les controllers) de la façon exacte dont les données sont stockées. Si un jour on remplace SQLite par une API internet, seul le repository changerait — pas les écrans.

`UserRepository` et `CartRepository` suivent exactement le même principe.

---

## 5. `logic/` — les Controllers (gestion d'état)

C'est le cœur de l'app : comment l'information "qui est connecté ?" et "qu'y a-t-il dans le panier ?" est partagée entre tous les écrans.

### Le principe `ChangeNotifier`

```dart
class CartController extends ChangeNotifier {
  List<CartItem> _items = [];     // donnée privée (le "_" = privé au fichier)
  bool _isLoading = false;

  List<CartItem> get items => _items;     // getter public en lecture seule
  bool get isLoading => _isLoading;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();              // 🔔 prévient tous les écrans qui écoutent : "ça a changé !"

    _items = await _cartRepository.getCartForUser(_currentUserId!);

    _isLoading = false;
    notifyListeners();              // 🔔 re-prévient : les données sont prêtes
  }
}
```

**Idée à retenir** : `ChangeNotifier` est une classe Flutter toute prête qui implémente le **pattern Observer**. N'importe quel widget peut "s'abonner" avec `addListener(...)`. Quand on appelle `notifyListeners()`, tous les widgets abonnés sont prévenus et peuvent se redessiner.

### Getters calculés (pas stockés, calculés à la demande)

```dart
double get subtotal => _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
double get shippingFee => _items.isEmpty ? 0.0 : 4.99;
double get total => subtotal + shippingFee;
```

`fold` parcourt la liste pour additionner `prix × quantité` de chaque article — comme une boucle `for` mais en une ligne.

### `AuthController`

Même logique pour la connexion :

```dart
class AuthController extends ChangeNotifier {
  UserAccount? _currentUser;             // null = pas connecté
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    final user = await _userRepository.login(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }
}
```

**Pourquoi pas un package genre Provider ?** Ici, les deux controllers sont créés **à la main** dans `MainNavigation` et **transmis en paramètre** à chaque écran (`HomeScreen(authController: ..., cartController: ...)`). Ça marche bien pour une petite app, mais demande de faire "descendre" les controllers manuellement partout — un axe d'amélioration possible serait d'utiliser `Provider` ou `Riverpod`.

---

## 6. `screens/` — l'interface utilisateur

### `StatefulWidget` vs `StatelessWidget`

Tous les écrans sont des `StatefulWidget` car ils ont des données qui changent (liste de produits chargée, texte tapé, quantité sélectionnée...).

```dart
class HomeScreen extends StatefulWidget {
  // Le Widget lui-même est IMMUABLE (final partout)
  final AuthController authController;
  const HomeScreen({super.key, required this.authController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // C'est ICI que vivent les données qui peuvent changer
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();   // appelé UNE SEULE fois, à la création de l'écran
  }

  Future<void> _loadProducts() async {
    final products = await ProductRepository().getAllProducts();
    setState(() {                 // 🔁 dit à Flutter : "redessine cet écran"
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // décrit ce qui s'affiche, à partir de l'état actuel (_products, _isLoading)
  }
}
```

**Idée à retenir** : sans `setState()`, même si on change `_products` en mémoire, l'écran ne se redessine pas. C'est `setState()` qui déclenche le nouveau `build()`.

### `main_navigation.dart` — le squelette

- Crée les deux controllers (`AuthController`, `CartController`) une seule fois.
- Utilise `IndexedStack` pour garder les 4 écrans (Accueil/Recherche/Panier/Compte) "en vie" en mémoire, et juste changer celui qui est visible (plus rapide que de les recréer à chaque clic).
- Affiche un badge avec le nombre d'articles sur l'icône du panier (`Positioned` + `Stack`).
- Écoute les deux controllers : quand on se connecte/déconnecte ou que le panier change, l'écran se met à jour automatiquement.

### `home_screen.dart` et `search_screen.dart`

Très similaires :
- Chargent les produits (`ProductRepository`).
- Affichent une grille (`GridView.builder`) de cartes produit, avec un bouton "+" pour ajouter rapidement au panier.
- Un clic sur une carte ouvre `ProductDetailScreen` via `Navigator.push`.
- `search_screen.dart` ajoute un champ de recherche (`TextField`) qui relance une recherche à chaque caractère tapé.

### `product_detail_screen.dart`

- Affiche le détail d'un produit avec une animation `Hero` (transition fluide de l'image).
- Permet de choisir le côté (`ChoiceChip`) et la quantité (boutons +/-).
- Bouton "Ajouter au panier" → vérifie qu'on est connecté → appelle `cartController.addToCart(...)`.

### `cart_screen.dart`

- Si pas connecté → message d'invitation à se connecter.
- Sinon → liste des articles avec contrôles quantité/suppression, et une carte récapitulative (sous-total + livraison + total) avec un bouton "Valider la commande" qui vide le panier.

### `account_screen.dart`

- Utilise un `TabController` pour basculer entre "Connexion" et "Inscription".
- Si connecté → affiche le profil (avatar, nom, email, bouton déconnexion).
- Sinon → formulaires avec `TextEditingController` pour chaque champ et validation simple (champs non vides).

---

## Exemple de flux complet à présenter à l'oral

**"J'ajoute une bride au panier"** — un bon fil rouge pour montrer que chaque couche a un rôle précis :

1. **screens** — l'utilisateur clique sur "+" → `HomeScreen._quickAddToCart()`.
2. **logic** — appelle `cartController.addToCart(product, 'Universel', 1)`.
3. **data/repositories** — `CartRepository.addItem(...)` est appelé.
4. **data** — `DatabaseHelper.addToCart(...)` vérifie si la ligne existe déjà en SQLite, puis insère ou met à jour la quantité.
5. Retour en haut : `CartController` recharge les données (`loadCart()`) et appelle `notifyListeners()`.
6. **screens** — `MainNavigation` et `CartScreen` (qui écoutent le controller) se redessinent automatiquement → le badge du panier se met à jour.

---

## Concepts Dart/Flutter à connaître pour les questions du jury

| Concept | Explication courte |
|---|---|
| `final` | la valeur ne peut être définie qu'une fois |
| `int?` (nullable) | le type peut valoir `null` |
| `required` | paramètre obligatoire dans un constructeur |
| `factory` constructor | constructeur spécial utilisé ici pour convertir une Map en objet |
| `Future<T>` | une valeur de type T qui sera disponible plus tard (opération asynchrone) |
| `async` / `await` | marquer une fonction asynchrone / attendre son résultat sans bloquer l'app |
| `StatelessWidget` | widget figé, sans donnée mutable |
| `StatefulWidget` + `State` | widget avec une donnée mutable, redessiné via `setState()` |
| `ChangeNotifier` + `notifyListeners()` | pattern Observer : prévenir tous les widgets abonnés qu'une donnée a changé |
| Singleton (`DatabaseHelper.instance`) | une seule instance partagée dans toute l'app |
| Pattern Repository | couche qui isole l'accès aux données du reste de l'app |

## Limites du projet (à mentionner si on te les demande)

- Mots de passe stockés en clair en base (pas de hash).
- Beaucoup de code dupliqué entre `home_screen.dart` et `search_screen.dart` (même carte produit copiée-collée).
- Pas de "debounce" sur la recherche : une requête SQL est lancée à chaque caractère tapé.
- La migration de base de données (`onUpgrade`) supprime et recrée les tables : ça marche en développement mais ferait perdre les données des utilisateurs en production.
- Pas de vrai paiement/commande : "Valider la commande" vide juste le panier localement.
