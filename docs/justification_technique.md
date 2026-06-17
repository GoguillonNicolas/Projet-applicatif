# Justification des choix techniques — Débridé

## Framework : Flutter

Flutter a été choisi pour livrer une application mobile avec un seul codebase Dart,
sans avoir à maintenir deux implémentations natives (Android/iOS). Le hot reload accélère
les itérations sur l'UI, et le rendu par moteur graphique propre (Skia) garantit un
rendu visuel identique sur toutes les plateformes — important ici car l'identité
visuelle (palette bleu/orange, coins arrondis, badges) est un axe fort du projet.

## Persistance : SQLite local via `sqflite`

Le sujet impose une persistance des données, au choix entre SQL local (`sqflite`/`drift`)
ou distant (Firebase/API custom). `sqflite` a été retenu plutôt qu'une solution distante :

- **Pas de backend à héberger ni de compte cloud à configurer** : le projet doit pouvoir
  être cloné et lancé en autonomie (`flutter pub get` + `flutter run`), sans dépendance
  réseau ni clé d'API à fournir.
- **Fonctionnement hors-ligne** : cohérent avec un usage mobile (catalogue, panier
  consultables sans connexion).
- **Modèle relationnel adapté** : les données du projet (utilisateurs, produits, panier)
  sont structurées et liées par clés étrangères (`user_id`, `product_id`) — un modèle
  relationnel SQL est plus naturel ici qu'une base NoSQL orientée documents.

`path` est utilisé uniquement comme utilitaire pour construire le chemin du fichier
`.db` de façon portable entre plateformes (`getDatabasesPath()` + `join()`).

## Pas de gestion d'état externe (Provider/Bloc/Riverpod)

L'état partagé entre écrans se limite à deux choses : l'utilisateur connecté et le
nombre d'articles dans le panier (badge de la bottom nav). Ce périmètre est volontairement
restreint :

- L'état est porté par le widget racine `MainNavigation` (`_currentUser`, `_cartCount`)
  et redescendu aux écrans enfants via des paramètres de constructeur (`currentUser`,
  `onCartUpdated`, `onUserChanged`).
- Ajouter une librairie de state management pour 2 valeurs partagées entre 5 écrans
  aurait été une sur-ingénierie pour le périmètre du projet. `setState` + callbacks
  reste lisible et suffisant tant que l'arbre de widgets ne s'étend pas.
- Ce choix est documenté comme limite connue : si l'application devait grossir
  (plus d'écrans consommant le panier, données partagées plus profondément imbriquées),
  une solution comme `Provider` deviendrait pertinente pour éviter le "prop drilling".

## Material 3 + `ColorScheme.fromSeed`

Le thème custom (bleu `#264C72` / orange `#E58B24`) est déclaré une seule fois dans
`ThemeData` via `ColorScheme.fromSeed`, l'approche recommandée par Flutter pour générer
une palette cohérente (couleurs primaire/secondaire/surface) à partir d'une couleur de
référence, plutôt que de définir manuellement chaque nuance.

## `IndexedStack` pour la navigation par onglets

`MainNavigation` utilise un `IndexedStack` plutôt que de reconstruire l'écran actif à
chaque changement d'onglet. Cela conserve l'état de chaque écran (résultats de recherche,
position de scroll, panier chargé) lors de la navigation entre les 4 onglets, évitant
des rechargements réseau/DB inutiles à chaque tap.

## `flutter_launcher_icons`

Génère automatiquement les icônes d'application pour toutes les plateformes cibles à
partir d'une seule image source (`assets/images/app_icon.png`), évitant de produire et
maintenir manuellement les multiples résolutions requises par Android/iOS.

## Limite connue : accès aux données non isolé

`DatabaseHelper` cumule actuellement le rôle de datasource (ouverture/connexion SQLite)
et de repository (requêtes CRUD métier) dans une seule classe. Ce n'est pas l'état cible :
une séparation repository/datasource est prévue (voir `docs/diagrams/architecture.puml`)
pour isoler la logique d'accès aux données de la couche de persistance brute, et faciliter
les tests (mock du repository sans dépendre de SQLite).
