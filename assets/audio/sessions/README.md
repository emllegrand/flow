# Séances guidées (voix)

Déposer ici les fichiers audio des séances guidées (MP3, OGG ou M4A).

Noms de fichiers attendus par le catalogue (`lib/features/sessions/data/catalogue_seances.dart`) :

| Fichier                    | Séance                          | Durée cible |
|----------------------------|---------------------------------|-------------|
| `respiration_decouverte.mp3` | Découvrir sa respiration      | ~5 min      |
| `scan_corporel.mp3`        | Scan corporel                   | ~15 min     |
| `sommeil_profond.mp3`      | Vers un sommeil profond         | ~20 min     |
| `pause_express.mp3`        | Pause express                   | ~4 min      |
| `ancrage_matin.mp3`        | Ancrage du matin                | ~10 min     |
| `lacher_prise.mp3`         | Lâcher-prise                    | ~12 min     |
| `concentration_calme.mp3`  | Concentration calme             | ~10 min     |
| `apaiser_anxiete.mp3`      | Apaiser l'anxiété               | ~15 min     |

Si un fichier est absent, l'écran de lecture l'indique calmement (aucun plantage).
La durée affichée dans la bibliothèque vient du catalogue ; la durée réelle vient
du fichier une fois chargé.

## Génération d'une première version

`python tools/generer_voix.py` synthétise les huit séances : voix neurale
française (edge-tts, gratuite), débit ralenti, silences calibrés entre les
consignes pour atteindre la durée cible de chaque séance. Les textes sont
dans `tools/voix/textes/` — modifiez-les puis relancez le script
(`python tools/generer_voix.py sommeil_profond` pour une seule séance,
`--voix fr-FR-HenriNeural` pour une voix masculine).

Pour une version finale, remplacez ces fichiers par de vrais enregistrements
(voix humaine, ou TTS premium type ElevenLabs) en gardant les mêmes noms.
