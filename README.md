# Débridé 🩴

**Débridé** est une application mobile e-commerce décalée, développée en Flutter, spécialisée dans la vente de pièces détachées de tongs (lanières, plugs de maintien, demi-semelles). Pourquoi racheter une paire complète quand on peut réparer uniquement sa bride ?

---

## 🚀 Fonctionnalités

- 🔐 **Authentification locale** : Connexion et inscription d'utilisateurs.
- 📦 **Catalogue insolite** : Recherche et filtrage de pièces détachées (lanières de rechange, plugs renforcés, semelle gauche/droite à l'unité).
- 🛒 **Gestion du panier** : Ajout de pièces, choix du côté (gauche/droite/universel) et persistance du panier par utilisateur.
- 🗃️ **Base de données SQLite** : Persistance des données utilisateur, produits et paniers en local.

---

## 🗺️ Navigation & Architecture

- **Structure du code** : séparation entre `lib/data` (modèles + accès aux données) et
  `lib/screens` (UI). Voir [docs/diagrams/architecture.puml](docs/diagrams/architecture.puml)
  pour le schéma des couches et leurs dépendances.
- Le schéma de navigation complet est disponible dans [`User flow.png`](User%20flow.png)
  (capture d'écran) et sa version diagramme source dans
  [docs/diagrams/user_flow.puml](docs/diagrams/user_flow.puml).
- La structure de la base de données est définie dans [schema.sql](schema.sql) et
  schématisée dans [docs/diagrams/database_er.puml](docs/diagrams/database_er.puml).
- La description fonctionnelle (contexte, utilisateurs, cas d'usage) est disponible dans
  [docs/description_fonctionnelle.md](docs/description_fonctionnelle.md).
- La justification des choix techniques (Flutter, sqflite, absence de state management
  externe, etc.) est détaillée dans
  [docs/justification_technique.md](docs/justification_technique.md).

---

## 🛠️ Installation & Lancement

1. S'assurer d'avoir Flutter installé sur sa machine.
2. Cloner le projet.
3. Lancer la commande suivante pour récupérer les dépendances :
   ```bash
   flutter pub get
   ```
4. Lancer l'application :
   ```bash
   flutter run
   ```
