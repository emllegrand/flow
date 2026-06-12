# Marque Flow — « la goutte-feuille »

SVG de production du repère de Flow, issus de la planche de marque
(`Flow Brand Sheet.dc.html`, handoff design du 12/06/2026).

Ces fichiers servent de **source vectorielle** (exports, stores, communication).
Ils ne sont pas embarqués dans l'application : à l'écran, le repère est tracé
par `lib/shared/widgets/logo_flow.dart`, et les icônes Android sont générées
par `outils/generer_icones.py`.

## Géométrie canonique

- viewBox : `0 0 104 120` (portrait).
- Corps : `M52 8 C24 40 14 64 14 80 a38 38 0 0 0 76 0 C90 64 80 40 52 8 Z`
- Nervure : `M52 34 C40 52 36 68 36 84` — épaisseur `3.5`, bouts ronds.
- Zone de respect : ≥ la moitié de la hauteur du repère.
- Taille minimale : 24 px de hauteur.

## Appariements (fond → fichier)

| Fond | Fichier | Corps | Nervure |
|---|---|---|---|
| Nuit `#0d1a2b` | `goutte_feuille.svg` | sauge `#a6bd86` | nuit, opacité 0.55 |
| Sauge `#a6bd86` | `goutte_feuille_sur_sauge.svg` | encre nuit `#152234` | sauge, opacité 0.65 |
| Crème `#ece7da` | `goutte_feuille_sur_creme.svg` | sauge `#a6bd86` | crème, opacité 0.85 |
| Monochrome sombre | `goutte_feuille_mono_creme.svg` | crème `#ece7da` | — |
| Monochrome clair | `goutte_feuille_mono_nuit.svg` | encre nuit `#152234` | — |

## Typographie de marque

- Mot « Flow » : Cormorant Garamond 600, interlettrage `0.01em`
  (italique 500 en variante signature ; Outfit 300 en variante sans).
- Tagline « Respirer · Méditer » / « Méditation » : Outfit 400, majuscules,
  interlettrage `0.40–0.42em`, ardoise `#8493a3`.

Les tokens Dart correspondants vivent dans `lib/core/theme/marque_flow.dart`.
