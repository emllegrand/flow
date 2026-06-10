# CLAUDE.md — Flow

Contexte projet pour Claude Code. À lire au début de chaque session.

## Vue d'ensemble

**Flow** est une application mobile **Android** de méditation et de respiration.
Objectif : offrir une expérience apaisante, lente et soignée qui « respire la zénitude ».
Identité de marque entièrement construite autour d'une **esthétique japonaise zen**.

L'application doit être livrée **complète et fonctionnelle de bout en bout** (pas un MVP, pas une démo).

## Stack technique

- **Flutter 3.44** / **Dart 3.12** (ne pas utiliser de version antérieure)
- Cible : **Android** (architecture pensée pour un portage iOS futur, mais ne pas s'en préoccuper maintenant)
- **Gestion d'état : Riverpod** (ne pas introduire Bloc/Provider/GetX)
- **Persistance locale : Hive** pour les données structurées (historique, séries, réglages) ; `shared_preferences` toléré pour quelques préférences simples
- **Audio** : lecture en arrière-plan (typiquement `just_audio` + `audio_service`), mixage de plusieurs sources (son d'ambiance + séance)
- **Notifications locales** pour les rappels de pratique
- **Material 3** comme base, mais **entièrement personnalisé** (fuir le look « Material par défaut »)

Avant d'ajouter une dépendance hors de cette liste, vérifier qu'elle est maintenue et compatible Flutter 3.44, et privilégier les packages officiels/largement adoptés.

## Architecture & conventions

- Architecture **claire et modulaire** : séparation nette UI / logique métier / données.
- Organisation par **feature** plutôt que par type technique. Structure cible :
  ```
  lib/
    core/            # thème, constantes, utils, services transverses
    features/
      breathing/     # cohérence cardiaque, 4-7-8, respiration carrée
      sessions/      # séances guidées
      sounds/        # sons d'ambiance
      themes/        # parcours par besoin (stress, sommeil…)
      tracking/      # historique, séries, statistiques
      settings/      # réglages
    shared/          # widgets réutilisables, animations communes
    main.dart
  ```
- **Code et commentaires en français.**
- Nommer clairement, préférer des widgets courts et composables. Éviter les fichiers fourre-tout.
- `const` partout où c'est possible (performances + clarté).
- Pas de logique métier dans les widgets : elle vit dans les providers Riverpod.

## Fonctionnalités attendues

1. **Cohérence cardiaque** — bulle animée qui gonfle/dégonfle au rythme respiratoire.
   Rythmes : cohérence cardiaque (5-5), 4-7-8, respiration carrée (4-4-4-4), + durées personnalisables.
   Minuteur de séance, compteur de cycles, retour haptique léger optionnel à chaque transition.
2. **Séances guidées** — bibliothèque classée par durée et objectif, écran de lecture (titre, progression, contrôles).
3. **Sons d'ambiance** — pluie, vagues, forêt, ruisseau, vent… seuls ou en fond, volume indépendant et mixage.
4. **Thèmes par besoin** — parcours (stress avant un examen, sommeil, concentration, anxiété, réveil en douceur…) regroupant exercices, séances et sons adaptés.
5. **Suivi** — historique des séances, séries (streaks), statistiques simples.
6. **Réglages** — thème clair/sombre, gestion sons & haptique, rappels/notifications.

## Direction artistique

- **Palette** : tons sable, vert mousse, indigo profond, terracotta léger. Douce et naturelle.
- **Typographie** épurée, beaucoup d'**espace négatif**.
- Inspiration **wabi-sabi** et **ma** (la beauté du vide).
- **Mode sombre soigné dès le départ** (pas un simple inversement de couleurs).

## Animations & atmosphère — exigence forte

L'application doit **respirer la zénitude**. Règle d'or : **rien ne doit jamais sembler pressé.**

- Animations **lentes, douces, fluides** ; jamais brusques ni rapides.
- Courbes organiques (`easeInOut` et dérivés), transitions en fondu, mouvements amples.
- La **bulle de respiration** : mouvement particulièrement naturel et hypnotique, comme une vraie inspiration/expiration. C'est la pièce maîtresse, à soigner en priorité.
- Micro-détails apaisants : dégradés mouvants subtils en fond, légères ondulations, apparition progressive des éléments.
- Toute l'expérience invite au **ralentissement et à la sérénité**.

## Audio — à savoir

Les fichiers audio (sons d'ambiance, voix des séances) **ne sont pas fournis par Claude Code**.
- Prévoir l'**architecture de lecture** et des **emplacements clairs** (`assets/audio/ambiance/`, `assets/audio/sessions/`) où les fichiers seront déposés.
- Déclarer proprement les assets dans `pubspec.yaml`.
- Ne **pas inventer** de fichiers audio : utiliser des placeholders documentés et un fallback gracieux si un fichier est absent.

## Commandes utiles

```bash
flutter pub get          # installer les dépendances
flutter run              # lancer en debug sur l'appareil/émulateur
flutter analyze          # analyse statique (doit rester sans erreur)
flutter test             # tests
flutter build apk        # build Android
```

## Règles de travail

- Tenir le projet **toujours compilable** : `flutter analyze` sans erreur après chaque étape significative.
- Documenter brièvement la structure du projet et la marche à suivre dans un `README.md`.
- En cas d'ambiguïté sur le design, **trancher dans le sens du plus calme / du plus épuré**.
- Mettre à jour ce fichier si une décision d'architecture importante est prise.