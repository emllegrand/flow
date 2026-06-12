# -*- coding: utf-8 -*-
"""Génère les icônes Android et les repères du splash depuis la géométrie
canonique de la goutte-feuille (planche de marque Flow).

Usage : python outils/generer_icones.py   (depuis la racine du projet)

Produit :
- android/app/src/main/res/mipmap-*/ic_launcher.png  (icône héritée, tuile
  « Sauge · nuit » : carré arrondi nuit #0d1a2b, rayon ~23 % du côté,
  repère sauge avec nervure)
- android/app/src/main/res/drawable-*/marque_splash.png  (verrouillage
  empilé : repère + mot « Flow » en Cormorant Garamond 600, pour l'écran
  de lancement avant Android 12, décliné clair/sombre)
- android/app/src/main/res/drawable-*/marque_mot.png  (mot « Flow » seul,
  image de marque du splash système Android 12+ — zone de 200 × 80 dp
  ancrée en bas, décliné clair/sombre)

Nécessite Pillow et la fonte outils/polices/CormorantGaramond-Variable.ttf.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

RACINE = Path(__file__).resolve().parent.parent
RES = RACINE / "android" / "app" / "src" / "main" / "res"

# Couleurs de marque (cf. lib/core/theme/marque_flow.dart)
NUIT = (0x0D, 0x1A, 0x2B)
NUIT_ENCRE = (0x15, 0x22, 0x34)
SAUGE = (0xA6, 0xBD, 0x86)
CREME = (0xEC, 0xE7, 0xDA)
POLICE_MOT = RACINE / "outils" / "polices" / "CormorantGaramond-Variable.ttf"
# Fonds réels de l'application au lancement (PaletteFlow)
FOND_CLAIR = (0xF6, 0xF1, 0xE8)
FOND_SOMBRE = (0x12, 0x18, 0x26)

SUR_ECHANTILLONNAGE = 8  # rendu suréchantillonné puis réduit (anticrénelage)


def _cubique(p0, p1, p2, p3, n=64):
    """Échantillonne une courbe de Bézier cubique."""
    points = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        x = u**3 * p0[0] + 3 * u**2 * t * p1[0] + 3 * u * t**2 * p2[0] + t**3 * p3[0]
        y = u**3 * p0[1] + 3 * u**2 * t * p1[1] + 3 * u * t**2 * p2[1] + t**3 * p3[1]
        points.append((x, y))
    return points


def _arc(centre, rayon, deg_debut, deg_fin, n=96):
    """Échantillonne un arc de cercle (degrés, y vers le bas)."""
    from math import cos, radians, sin

    points = []
    for i in range(n + 1):
        a = radians(deg_debut + (deg_fin - deg_debut) * i / n)
        points.append((centre[0] + rayon * cos(a), centre[1] + rayon * sin(a)))
    return points


def _contour_corps():
    """Contour du corps, dans le viewBox 104 × 120.

    M52 8 C24 40 14 64 14 80 a38 38 0 0 0 76 0 C90 64 80 40 52 8 Z
    L'arc va de (14,80) à (90,80) en passant par la base (52,118).
    """
    points = _cubique((52, 8), (24, 40), (14, 64), (14, 80))
    points += _arc((52, 80), 38, 180, 0)[1:]  # 180° -> 90° -> 0° : base ronde
    points += _cubique((90, 80), (90, 64), (80, 40), (52, 8))[1:]
    return points


def _chemin_nervure():
    """Nervure : M52 34 C40 52 36 68 36 84 (épaisseur 3.5, bouts ronds)."""
    return _cubique((52, 34), (40, 52), (36, 68), (36, 84))


def _calque_repere(taille, origine, echelle, corps, nervure, opacite_nervure):
    """Rend le repère sur un calque RGBA transparent.

    La nervure est tracée opaque sur son propre calque puis voilée d'un
    seul tenant, pour éviter l'empilement d'alpha des disques successifs.
    """
    ox, oy = origine

    def tr(p):
        return (ox + p[0] * echelle, oy + p[1] * echelle)

    calque = Image.new("RGBA", taille, (0, 0, 0, 0))
    dessin = ImageDraw.Draw(calque)
    dessin.polygon([tr(p) for p in _contour_corps()], fill=corps + (255,))

    if nervure is not None and opacite_nervure > 0:
        trait = Image.new("RGBA", taille, (0, 0, 0, 0))
        dessin_trait = ImageDraw.Draw(trait)
        largeur = 3.5 * echelle
        for x, y in (tr(p) for p in _chemin_nervure()):
            dessin_trait.ellipse(
                [x - largeur / 2, y - largeur / 2, x + largeur / 2, y + largeur / 2],
                fill=nervure + (255,),
            )
        trait.putalpha(trait.getchannel("A").point(
            lambda a: round(a * opacite_nervure)
        ))
        calque = Image.alpha_composite(calque, trait)
    return calque


def icone_lanceur(taille):
    """Tuile « Sauge · nuit » : carré arrondi nuit, repère sauge centré.

    Proportions de la planche : rayon 30/128 du côté, repère large de 60/128.
    """
    s = taille * SUR_ECHANTILLONNAGE
    tuile = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    dessin = ImageDraw.Draw(tuile)
    rayon = s * 30 / 128
    dessin.rounded_rectangle([0, 0, s - 1, s - 1], radius=rayon, fill=NUIT + (255,))

    echelle = (s * 60 / 128) / 104
    origine = ((s - 104 * echelle) / 2, (s - 120 * echelle) / 2)
    repere = _calque_repere((s, s), origine, echelle, SAUGE, NUIT, 0.55)

    tuile = Image.alpha_composite(tuile, repere)
    return tuile.resize((taille, taille), Image.LANCZOS)


def _mot_flow(taille_police, couleur):
    """Rend le mot « Flow » en Cormorant Garamond 600 (interlettrage 0.01em)."""
    police = ImageFont.truetype(str(POLICE_MOT), taille_police)
    police.set_variation_by_axes([600])
    interlettrage = 0.01 * taille_police

    boites = []
    largeur_totale = 0.0
    for lettre in "Flow":
        boite = police.getbbox(lettre)
        avance = police.getlength(lettre)
        boites.append((lettre, boite, largeur_totale))
        largeur_totale += avance + interlettrage
    largeur_totale -= interlettrage

    ascension, descente = police.getmetrics()
    image = Image.new(
        "RGBA", (round(largeur_totale), ascension + descente), (0, 0, 0, 0)
    )
    dessin = ImageDraw.Draw(image)
    for lettre, _, x in boites:
        dessin.text((x, 0), lettre, font=police, fill=couleur + (255,))
    return image.crop(image.getbbox())


def verrouillage_splash(echelle_dp, fond, opacite_nervure, couleur_mot):
    """Verrouillage empilé pour l'écran de lancement : repère + « Flow ».

    Proportions de la planche (repère 60, espace 16, mot 46), rendues
    à `echelle_dp` pixels par dp ; la nervure reprend la couleur du fond.
    """
    s = SUR_ECHANTILLONNAGE * echelle_dp
    h_repere = round(120 * s)
    l_repere = round(104 * s)
    espace = round(32 * s)

    mot = _mot_flow(round(92 * s), couleur_mot)

    largeur = max(l_repere, mot.width)
    image = Image.new(
        "RGBA", (largeur, h_repere + espace + mot.height), (0, 0, 0, 0)
    )
    repere = _calque_repere(
        (largeur, h_repere),
        ((largeur - l_repere) / 2, 0),
        h_repere / 120,
        SAUGE,
        fond,
        opacite_nervure,
    )
    image.paste(repere, (0, 0))
    image.paste(mot, ((largeur - mot.width) // 2, h_repere + espace), mot)

    return image.resize(
        (round(image.width / SUR_ECHANTILLONNAGE),
         round(image.height / SUR_ECHANTILLONNAGE)),
        Image.LANCZOS,
    )


def marque_mot(echelle_dp, couleur_mot):
    """Image de marque du splash Android 12+ : « Flow » dans 200 × 80 dp."""
    s = SUR_ECHANTILLONNAGE * echelle_dp
    canevas = Image.new("RGBA", (round(200 * s), round(80 * s)), (0, 0, 0, 0))
    mot = _mot_flow(round(44 * s), couleur_mot)
    canevas.paste(
        mot,
        ((canevas.width - mot.width) // 2, (canevas.height - mot.height) // 2),
        mot,
    )
    return canevas.resize(
        (round(200 * echelle_dp), round(80 * echelle_dp)), Image.LANCZOS
    )


DENSITES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}

if __name__ == "__main__":
    for densite, facteur in DENSITES.items():
        dossier = RES / f"mipmap-{densite}"
        dossier.mkdir(exist_ok=True)
        icone_lanceur(round(48 * facteur)).save(dossier / "ic_launcher.png")

        # Appariements de la planche : nervure = couleur du fond,
        # opacité 0.85 sur fond clair (crème), 0.55 sur fond sombre (nuit) ;
        # mot encre nuit sur clair, crème sur sombre.
        dossier = RES / f"drawable-{densite}"
        dossier.mkdir(exist_ok=True)
        verrouillage_splash(facteur, FOND_CLAIR, 0.85, NUIT_ENCRE).save(
            dossier / "marque_splash.png"
        )
        marque_mot(facteur, NUIT_ENCRE).save(dossier / "marque_mot.png")
        dossier = RES / f"drawable-night-{densite}"
        dossier.mkdir(exist_ok=True)
        verrouillage_splash(facteur, FOND_SOMBRE, 0.55, CREME).save(
            dossier / "marque_splash.png"
        )
        marque_mot(facteur, CREME).save(dossier / "marque_mot.png")
    print("Icônes et repères de splash générés.")
