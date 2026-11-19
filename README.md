# NASARA CM — Application mobile (Flutter)

Client mobile hybride (Android/iOS) pour le backend NASARA Central Market.

## ⚠️ Statut de ce livrable

**Ce code n'a pas pu être compilé ni exécuté** dans l'environnement où il a
été écrit — le SDK Flutter/Dart n'y est pas accessible (contrairement au
backend Go, testé de bout en bout). Le code suit les conventions Dart/Flutter
et l'architecture Riverpod standard, mais **tu dois le valider toi-même** sur
ta machine WSL avant de le considérer comme fiable. Contrairement au backend,
je ne peux pas garantir ici qu'il compile sans erreur du premier coup.

## Installer Flutter sur WSL Ubuntu

```bash
sudo apt update && sudo apt install -y curl git unzip xz-utils zip libglu1-mesa
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
flutter doctor
```

## Lancer le projet

```bash
cd nasara_cm_mobile
flutter pub get
```

Corrige les éventuelles erreurs de compilation signalées à cette étape —
c'est l'étape que je n'ai pas pu exécuter moi-même.

### Lancer sur un émulateur Android

```bash
flutter emulators --launch <nom_emulateur>
flutter run
```

Par défaut, l'app pointe vers `http://10.0.2.2:8080` — l'adresse spéciale
que l'émulateur Android utilise pour joindre le `localhost` de la machine
hôte (donc ton backend Go qui tourne sur WSL).

### Lancer sur un téléphone physique en WiFi local

```bash
flutter run --dart-define=API_BASE_URL=http://<IP_DE_TA_MACHINE>:8080
```

Remplace `<IP_DE_TA_MACHINE>` par l'IP locale de ta machine WSL/Windows sur
le réseau (`ip addr` ou `ipconfig`), et assure-toi que le backend Go écoute
bien sur `0.0.0.0` (déjà le cas par défaut) et que le pare-feu Windows
autorise le port 8080.

## Architecture

```
lib/
├── main.dart                    # point d'entrée, gestion du cycle de vie WebSocket
├── core/
│   ├── api/                      # config URL + client Dio avec intercepteur JWT
│   ├── storage/                   # stockage sécurisé du token (keystore/keychain)
│   └── router/                    # go_router, redirection selon l'état d'auth
├── models/                        # miroirs Dart des structs Go du backend
└── features/                      # une feature = data (repository) + providers (Riverpod) + screens
    ├── auth/
    ├── boutiques/
    ├── produits/
    └── messagerie/                # inclut le service WebSocket temps réel
```

## Points d'attention à vérifier en premier

Ce sont les endroits les plus susceptibles de nécessiter un ajustement une
fois compilés dans un vrai environnement Flutter :

1. **Versions des packages dans `pubspec.yaml`** — j'ai indiqué des versions
   plausibles au moment de l'écriture, mais `flutter pub get` peut demander
   des ajustements selon ce qui est disponible sur pub.dev au moment où tu
   l'exécutes.
2. **`flutter_secure_storage`** — nécessite `minSdkVersion 18+` côté Android
   (à vérifier dans `android/app/build.gradle` généré par `flutter create`,
   que tu devras lancer une fois pour obtenir les dossiers `android/`/`ios/`
   manquants de ce livrable — je n'ai fourni que le code Dart).
3. **Le service WebSocket** (`websocket_service.dart`) — la logique de
   reconnexion automatique après coupure réseau n'a été validée qu'en
   lecture de code, pas en conditions réelles de coupure/reprise.

## Ce qu'il manque encore pour aller vers un premier build complet

```bash
flutter create --org com.nasaracm --project-name nasara_cm_mobile .
```

Cette commande, à lancer **une seule fois** à la racine du dossier
décompressé, génère les dossiers `android/`, `ios/`, `web/` etc. qui ne sont
pas inclus dans ce livrable (ils dépendent de la version exacte du SDK
Flutter installée et ne se transportent pas bien d'une machine à l'autre).
Elle ne touche pas au dossier `lib/` existant.
