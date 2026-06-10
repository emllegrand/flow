# Flow — Document de design

Date : 2026-06-10 · Statut : validé (spec complète fournie par l'utilisateur dans CLAUDE.md + prompt ; ambiguïtés tranchées « dans le sens du plus calme », comme demandé)

## Objectif

Application Android complète de méditation et respiration, esthétique japonaise zen, livrée fonctionnelle de bout en bout. Flutter 3.44 / Dart 3.12, Riverpod, Hive, audio en arrière-plan, notifications locales.

## Dépendances retenues

| Package | Rôle |
|---|---|
| `flutter_riverpod` | gestion d'état |
| `hive` + `hive_flutter` | persistance (historique, réglages) — stockage en Map JSON, pas de codegen |
| `just_audio` + `audio_service` + `audio_session` | lecture/mixage audio, arrière-plan (foreground service Android) |
| `flutter_local_notifications` + `timezone` + `flutter_timezone` | rappels quotidiens |
| `google_fonts` | typographie (Cormorant Garamond titres / Karla corps) |
| `intl` | dates en français |

Pas de `go_router` (Navigator simple suffit), pas de lib de charts (graphiques custom épurés).

## Architecture

Organisation par feature (cf. CLAUDE.md). Logique métier dans des `Notifier` Riverpod, widgets purs.

```
lib/
  core/
    theme/        # palette, typographie, ThemeData clair/sombre
    services/     # audio (handler audio_service multi-lecteurs), notifications, haptique, hive
    utils/        # formatage durées/dates
  features/
    breathing/    # moteur de respiration (Notifier + Ticker), bulle animée, config rythmes
    sessions/     # catalogue statique, écran bibliothèque, écran lecteur
    sounds/       # catalogue sons d'ambiance, mixeur multi-pistes avec volumes indépendants
    themes/       # parcours par besoin (stress, sommeil, concentration, anxiété, réveil)
    tracking/     # historique Hive, streaks, statistiques, graphique hebdo custom
    settings/     # thème, haptique, rappels
  shared/         # fond dégradé animé, transitions fondu, widgets zen réutilisables
  main.dart
```

## Décisions clés

- **Navigation** : `IndexedStack` + barre de navigation basse custom (5 onglets : Accueil, Respirer, Séances, Sons, Suivi). Réglages accessibles depuis l'Accueil. Routes de détail en `PageRouteBuilder` avec fondu lent (≈ 600 ms).
- **Moteur de respiration** : `Notifier` pilotant les phases (inspiration / rétention / expiration / pause) via timers ; la bulle écoute la phase courante et anime un `AnimationController` re-ciblé à chaque phase avec courbes organiques (`Curves.easeInOutSine`). Compteur de cycles, minuteur de séance, haptique légère optionnelle à chaque transition.
- **Audio** : un `AudioHandler` unique (audio_service) possédant un lecteur « séance » + un lecteur par son d'ambiance actif (just_audio), mixage par volumes indépendants, boucle pour les ambiances. `MainActivity` étend `AudioServiceActivity`. Fallback gracieux : si l'asset est absent, l'UI l'indique calmement sans planter.
- **Assets audio** : emplacements `assets/audio/ambiance/` et `assets/audio/sessions/` documentés (fichiers fournis par l'utilisateur, jamais inventés).
- **Persistance** : boxes Hive `historique` et `reglages`, données en Map (pas d'adaptateurs générés). Streaks calculés à partir de l'historique.
- **Notifications** : rappel quotidien par heure choisie, `zonedSchedule` en mode inexact (pas de permission exact alarm), demande `POST_NOTIFICATIONS` Android 13+.
- **Direction artistique** : palette sable `#F5F0E8`/`#E8DFD3`, vert mousse `#7D8B6A`, indigo profond `#1F2A44` (fond sombre `#121826`), terracotta `#C8836B`. Mode sombre conçu à part. Beaucoup d'espace négatif, fond à dégradés radiaux mouvants très lents, apparitions en fondu progressif, ensō et cercles comme motifs.

## Gestion d'erreurs

- Asset audio manquant → message doux à l'écran, lecture désactivée pour cet élément.
- Permissions notifications refusées → réglage visible mais rappels inactifs, sans nag.
- Boxes Hive : ouverture au démarrage avant `runApp`, valeurs par défaut si vide.

## Tests

`flutter analyze` sans erreur ; tests unitaires sur le moteur de respiration (séquence des phases, cycles) et le calcul des streaks/statistiques ; test widget de fumée sur le démarrage de l'app.
