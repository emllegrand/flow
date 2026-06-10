# Flow — méditation & respiration

Application Android de méditation et de respiration à l'esthétique japonaise zen :
animations lentes, palette naturelle (sable, vert mousse, indigo profond, terracotta),
beaucoup d'espace négatif. Rien ne doit jamais sembler pressé.

## Lancer l'application

```bash
flutter pub get          # installer les dépendances
flutter run              # lancer en debug sur l'appareil/émulateur Android
flutter analyze          # analyse statique
flutter test             # tests
flutter build apk        # build Android
```

Prérequis : **Flutter 3.44 / Dart 3.12**, un appareil ou émulateur **Android**.

## Fichiers audio (à fournir)

Les fichiers audio ne sont **pas inclus**. Déposez vos propres fichiers
(MP3/OGG/M4A) dans :

- `assets/audio/ambiance/` — sons d'ambiance (pluie, vagues, forêt…)
- `assets/audio/sessions/` — voix des séances guidées

Les noms de fichiers attendus sont documentés dans le **README de chaque
dossier**. Tant qu'un fichier est absent, l'application l'indique calmement
et désactive sa lecture (aucun plantage). Après dépôt, relancez `flutter run`
(les assets sont embarqués au build).

## Fonctionnalités

- **Respiration** — bulle animée guidant cohérence cardiaque (5-5),
  4-7-8, respiration carrée (4-4-4-4) et rythme personnalisé ; minuteur de
  séance, compteur de cycles, retour haptique léger optionnel.
- **Séances guidées** — bibliothèque classée par durée, filtrable par objectif,
  écran de lecture complet (progression, ±15 s, lecture en arrière-plan).
- **Sons d'ambiance** — mixeur multi-pistes : chaque son a son volume
  indépendant et continue en arrière-plan, seul ou pendant un exercice.
- **Parcours par besoin** — stress avant un examen, sommeil, concentration,
  anxiété, réveil en douceur : chaque parcours enchaîne exercice, séance et sons.
- **Suivi** — historique, séries (streaks), statistiques et graphique de la semaine.
- **Réglages** — thème clair/sombre/système, haptique, rappel quotidien.

## Structure du projet

```
lib/
  core/
    constants/    # rythme des animations (durées, courbes)
    theme/        # palette et thèmes Material 3 personnalisés (clair + sombre)
    services/     # Hive, mixeur audio (audio_service), notifications, haptique
    utils/        # formatage (durées, salutations, dates)
  features/       # une logique par dossier : data / logic / presentation
    breathing/    # moteur de respiration (Notifier + minuteur) et bulle animée
    sessions/     # catalogue, lecteur de séances guidées
    sounds/       # catalogue et mixeur de sons d'ambiance
    themes/       # parcours par besoin
    tracking/     # historique, streaks, statistiques
    settings/     # préférences (persistées dans Hive)
    home/         # accueil et navigation principale
  shared/         # fond animé, apparitions en fondu, cartes, transitions
  main.dart       # initialisation des services puis ProviderScope
```

## Choix techniques

- **Riverpod** (`Notifier`/`Provider`) : toute la logique métier vit dans les
  providers, les widgets restent purs.
- **Hive** : boxes `reglages` et `historique`, données en Map JSON (pas de codegen).
- **just_audio + audio_service** : un `AudioHandler` unique possède tous les
  lecteurs (séance + une piste par ambiance) → mixage libre et lecture en
  arrière-plan via un service de premier plan Android (`MainActivity` étend
  `AudioServiceActivity`).
- **flutter_local_notifications** : rappel quotidien en mode inexact
  (aucune permission « alarme exacte » requise).
- Animations : durées et courbes centralisées dans
  `core/constants/rythme_animations.dart` — tout est lent, fluide, organique.
