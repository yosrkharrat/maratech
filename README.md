# 🏃 Running Club Tunis (RCT) — Application Mobile

<p align="center">
  <strong>Application mobile officielle du Running Club Tunis</strong><br/>
  Flutter • Firebase • Strava API
</p>

---

## 📋 Table des Matières

- [Aperçu](#aperçu)
- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Configuration Firebase](#configuration-firebase)
- [Configuration Strava](#configuration-strava)
- [Structure du Projet](#structure-du-projet)
- [Rôles Utilisateur](#rôles-utilisateur)
- [Accessibilité](#accessibilité)
- [Multilingue](#multilingue)
- [Sécurité](#sécurité)
- [Déploiement](#déploiement)
- [Contribution](#contribution)

---

## 🔍 Aperçu

RCT est une application mobile cross-platform (Android & iOS) conçue pour le Running Club Tunis. Elle permet la gestion des événements sportifs, le suivi des performances via Strava, le partage de médias, et la communication entre membres du club.

### Captures d'écran

| Accueil | Événements | Classement | Profil |
|---------|-----------|------------|--------|
| 📱 | 🏁 | 🏆 | 👤 |

---

## ✨ Fonctionnalités

### 👥 Gestion des Utilisateurs
- Authentification par nom + code CIN (3 chiffres)
- Mode visiteur (accès lecture seule)
- 5 rôles : Admin Principal, Admin Coach, Admin Groupe, Adhérent, Visiteur
- Gestion des groupes de course

### 🏃 Événements
- Création et gestion d'événements (course, trail, entraînement, social)
- Calendrier interactif avec vue mensuelle
- Système de participation (participant / intéressé / organisateur)
- Compteur de vues et de participants

### 📸 Médias
- Galerie photos et vidéos par événement
- Upload depuis galerie ou caméra
- Filtrage par timing (avant / pendant / après)
- Notes et commentaires sur les événements
- Système de likes

### 🏆 Strava & Classement
- Intégration OAuth 2.0 avec Strava
- Synchronisation automatique des activités
- Classement par événement (temps, allure, distance)
- Podium Top 3 avec médailles

### 🔔 Notifications
- Notifications push (FCM)
- Rappels d'événements
- Notifications par groupe

### ♿ Accessibilité (WCAG 2.1)
- Support TalkBack / VoiceOver
- Contraste élevé
- Inversion des couleurs
- Taille de police ajustable (80% - 160%)
- Cibles tactiles minimum 48dp
- Labels sémantiques sur tous les éléments interactifs

### 🌍 Multilingue
- 🇫🇷 Français
- 🇬🇧 English
- 🇹🇳 العربية (Arabe)
- 🇹🇳 تونسي (Dialecte tunisien)
- Support RTL automatique pour l'arabe et le tunisien

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # Point d'entrée
├── firebase_options.dart        # Config Firebase
├── core/
│   ├── theme/                   # Couleurs, typographie, thèmes
│   ├── constants/               # Constantes, enums
│   ├── localization/            # Traductions (4 langues)
│   ├── accessibility/           # Helpers accessibilité
│   ├── providers/               # Riverpod providers
│   └── router/                  # GoRouter navigation
├── models/                      # Modèles de données
├── services/                    # Couche métier (Firebase, Strava)
├── screens/                     # Écrans par fonctionnalité
│   ├── splash/
│   ├── auth/
│   ├── home/
│   ├── events/
│   ├── media/
│   ├── club/
│   ├── profile/
│   ├── admin/
│   └── strava/
└── widgets/                     # Composants réutilisables
    └── layout/
```

### Patterns utilisés
- **State Management**: Riverpod (StateNotifier + StreamProvider)
- **Navigation**: GoRouter (déclarative, type-safe)
- **Architecture**: Feature-first + Layered (Models → Services → Providers → Screens)
- **Separation of Concerns**: UI ↔ Logic ↔ Data complètement séparés

---

## 🛠️ Tech Stack

| Catégorie | Technologie |
|-----------|------------|
| Framework | Flutter 3.x (Dart) |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| State | Riverpod |
| Navigation | GoRouter |
| HTTP | Dio |
| Stockage local | Hive, SharedPreferences, FlutterSecureStorage |
| Cartes | Google Maps Flutter |
| Médias | image_picker, video_player, photo_view |
| Calendrier | table_calendar |
| Notifications | firebase_messaging, flutter_local_notifications |
| API externes | Strava API v3 (OAuth 2.0) |

---

## 🚀 Installation

### Prérequis
- Flutter SDK ≥ 3.0
- Dart SDK ≥ 3.0
- Android Studio / Xcode
- Compte Firebase
- (Optionnel) App Strava API

### Étapes

```bash
# 1. Cloner le repo
git clone https://github.com/your-org/rct_app.git
cd rct_app

# 2. Installer les dépendances
flutter pub get

# 3. Configurer Firebase (voir section suivante)
flutterfire configure

# 4. Lancer l'app
flutter run
```

---

## 🔥 Configuration Firebase

### 1. Créer un projet Firebase
1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Créer un projet "RCT"
3. Activer **Authentication** (Email/Password)
4. Créer une base **Firestore Database**
5. Activer **Cloud Storage**
6. Activer **Cloud Messaging**

### 2. Configurer FlutterFire
```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer (génère firebase_options.dart)
flutterfire configure --project=YOUR_PROJECT_ID
```

### 3. Déployer les règles de sécurité
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Déployer les règles
firebase deploy --only firestore:rules,storage
```

### 4. Créer le premier admin
Dans la console Firestore, créer manuellement un document dans `/users/{uid}` :
```json
{
  "displayName": "Admin Principal",
  "email": "admin@rct.tn",
  "role": "admin_principal",
  "isActive": true,
  "createdAt": "2025-01-01T00:00:00Z"
}
```

---

## 🔗 Configuration Strava

### 1. Créer une App Strava
1. Aller sur [Strava API Settings](https://www.strava.com/settings/api)
2. Créer une application
3. Configurer le **Authorization Callback Domain**: `rctapp://callback`

### 2. Configurer les secrets
```bash
# Build avec les secrets Strava
flutter run --dart-define=STRAVA_CLIENT_ID=your_id --dart-define=STRAVA_CLIENT_SECRET=your_secret
```

Ou créer un fichier `.env` (ne pas committer) :
```env
STRAVA_CLIENT_ID=your_client_id
STRAVA_CLIENT_SECRET=your_client_secret
```

---

## 👥 Rôles Utilisateur

| Rôle | Voir événements | Participer | Créer événements | Gérer médias | Gérer utilisateurs | Admin panel |
|------|:-:|:-:|:-:|:-:|:-:|:-:|
| Visiteur | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Adhérent | ✅ | ✅ | ❌ | ✅ (propres) | ❌ | ❌ |
| Admin Groupe | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Admin Coach | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Admin Principal | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## ♿ Accessibilité

L'application respecte les standards **WCAG 2.1 Level AA** :

- **Ratio de contraste** minimum 4.5:1 (mode normal), 7:1 (mode contraste élevé)
- **Cibles tactiles** minimum 48×48 dp
- **Taille de police** minimum 14sp (body), ajustable de 80% à 160%
- **Labels sémantiques** (Semantics) sur tous les éléments interactifs
- **Support lecteurs d'écran** TalkBack (Android) et VoiceOver (iOS)
- **Inversion des couleurs** via matrice ColorFilter
- **Mode sombre** complet
- **Mode contraste élevé** avec couleurs renforcées
- **Navigation clavier** supportée
- **Annonces dynamiques** pour les changements d'état

### Paramètres accessibilité
Accessibles depuis : **Profil → Paramètres → Accessibilité**

---

## 🌍 Multilingue

| Langue | Code | Direction | Fichier |
|--------|------|-----------|---------|
| Français | `fr` | LTR | `lib/core/localization/translations/fr.dart` |
| English | `en` | LTR | `lib/core/localization/translations/en.dart` |
| العربية | `ar` | RTL | `lib/core/localization/translations/ar.dart` |
| تونسي | `tn` | RTL | `lib/core/localization/translations/tn.dart` |

Chaque fichier contient ~200 clés de traduction couvrant toutes les sections de l'application.

### Ajouter une langue
1. Créer `lib/core/localization/translations/xx.dart`
2. Ajouter l'entrée dans `AppLanguage` enum
3. Ajouter le support dans `AppLocalizations._localizedValues`

---

## 🔒 Sécurité

Voir le rapport complet : [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

### Points clés
- ✅ Firebase Auth pour la gestion des sessions
- ✅ Règles Firestore granulaires avec contrôle par rôle
- ✅ Stockage sécurisé des tokens Strava (Keychain/Keystore)
- ✅ Validation des entrées côté client et serveur
- ✅ HTTPS pour toutes les communications réseau
- ✅ Règle deny-all par défaut dans Firestore
- ⚠️ Secrets API à externaliser via `--dart-define`

---

## 📦 Déploiement

### Android
```bash
# Build APK
flutter build apk --release \
  --dart-define=STRAVA_CLIENT_ID=xxx \
  --dart-define=STRAVA_CLIENT_SECRET=yyy

# Build App Bundle (Google Play)
flutter build appbundle --release \
  --dart-define=STRAVA_CLIENT_ID=xxx \
  --dart-define=STRAVA_CLIENT_SECRET=yyy
```

### iOS
```bash
# Build pour iOS
flutter build ios --release \
  --dart-define=STRAVA_CLIENT_ID=xxx \
  --dart-define=STRAVA_CLIENT_SECRET=yyy
```

### Configuration de signature
- **Android** : Configurer `android/key.properties` et `android/app/build.gradle`
- **iOS** : Configurer les certificats dans Xcode et Apple Developer Portal

---

## 🤝 Contribution

1. Fork le repository
2. Créer une branche (`git checkout -b feature/ma-fonctionnalite`)
3. Committer (`git commit -am 'Ajout fonctionnalité'`)
4. Pusher (`git push origin feature/ma-fonctionnalite`)
5. Ouvrir une Pull Request

### Conventions
- **Code** : Suivre les lint rules de `analysis_options.yaml`
- **Commits** : Format conventionnel (`feat:`, `fix:`, `docs:`, `refactor:`)
- **Branches** : `feature/`, `fix/`, `docs/`

---

## 📄 Licence

Ce projet est la propriété du Running Club Tunis. Tous droits réservés.

---

<p align="center">
  Développé avec ❤️ pour le Running Club Tunis 🏃‍♂️🇹🇳
</p>
