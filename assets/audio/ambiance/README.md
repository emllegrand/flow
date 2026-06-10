# Sons d'ambiance

Déposer ici les fichiers audio d'ambiance (MP3, OGG ou M4A), en boucle de préférence.

Noms de fichiers attendus par le catalogue (`lib/features/sounds/data/catalogue_sons.dart`) :

| Fichier        | Son              |
|----------------|------------------|
| `pluie.mp3`    | Pluie            |
| `vagues.mp3`   | Vagues           |
| `foret.mp3`    | Forêt            |
| `ruisseau.mp3` | Ruisseau         |
| `vent.mp3`     | Vent             |
| `feu.mp3`      | Feu de bois      |
| `bol.mp3`      | Bol tibétain     |

Si un fichier est absent, l'application l'indique calmement et désactive sa lecture
(aucun plantage). Pour ajouter un nouveau son, déposer le fichier ici puis
l'ajouter au catalogue.

## Génération d'une première version

`python tools/generer_ambiances.py` synthétise des versions honnêtes de
**pluie, vent, vagues et ruisseau** (bruit coloré filtré et modulé, via ffmpeg).

**Forêt, feu et bol tibétain** ne se synthétisent pas bien : utiliser de vrais
enregistrements libres de droits, par exemple sur [Pixabay](https://pixabay.com/sound-effects/)
(licence libre, sans attribution) ou [Freesound](https://freesound.org)
(filtrer licence CC0). Chercher « forest birds loop », « campfire crackling loop »,
« singing bowl ». Renommer le fichier téléchargé selon la table ci-dessus.
