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

- **Architecture** : Séparation propre des couches (Logic/UI, Repositories, Data sources).
- Le schéma de navigation complet et la description fonctionnelle sont disponibles dans le fichier [user_flow.md](user_flow.md).
- La structure de la base de données est définie dans le fichier [schema.sql](schema.sql).

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
