# Sons de la bulle de respiration

Trois sons courts accompagnent la bulle pendant un exercice de respiration.

Noms de fichiers attendus par le service (`lib/core/services/sons_respiration.dart`) :

| Fichier                    | Rôle                                                | Durée   |
|----------------------------|-----------------------------------------------------|---------|
| `souffle_inspiration.mp3`  | Souffle doux qui monte pendant l'inspiration        | 6 s     |
| `souffle_expiration.mp3`   | Souffle qui redescend pendant l'expiration          | 6 s     |
| `inversion.mp3`            | Son cristallin discret à chaque changement de phase | ~3 s    |

L'application ajuste la **vitesse de lecture** des souffles à la durée de la
phase (4 s, 5 s, 8 s…), sans changer la hauteur. Leur enveloppe doit donc
**revenir au silence en fin de fichier** — jamais de coupure sèche. Si les
fichiers sont absents, les exercices fonctionnent simplement sans sons.

## Génération d'une première version

`python tools/generer_sons_respiration.py` synthétise les trois sons
(bruit filtré modelé pour les souffles, partiels de bol chantant pour
l'inversion, via Python + ffmpeg).

Pour une version premium, générer des sons avec
[ElevenLabs Sound Effects](https://elevenlabs.io/sound-effects) (texte →
effet sonore, ex. « soft slow inhale whoosh, airy, gentle, fades out »)
et les déposer ici sous les mêmes noms, en respectant la contrainte
d'enveloppe ci-dessus (6 s pour les souffles).
