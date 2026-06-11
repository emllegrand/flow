# -*- coding: utf-8 -*-
"""Génère les sons de la bulle de respiration (synthèse Python + ffmpeg).

Trois sons accompagnent la bulle pendant un exercice :
  - souffle_inspiration : un souffle doux qui monte, comme l'air qui entre ;
  - souffle_expiration  : un souffle qui redescend et s'éteint ;
  - inversion           : un son cristallin très discret (type bol), joué
                          à chaque changement de phase.

Les souffles sont du bruit blanc filtré dont la brillance et le volume
suivent le geste respiratoire ; leur enveloppe revient à zéro en fin de
fichier, l'application ajuste la vitesse de lecture à la durée de la
phase. Le son d'inversion est une somme de partiels inharmoniques
amortis, à la manière d'un bol chantant.

Usage :
    python tools/generer_sons_respiration.py              # les trois
    python tools/generer_sons_respiration.py inversion    # une sélection

Pour une version premium, remplacer les MP3 par des sons générés avec
ElevenLabs Sound Effects (texte → effet sonore), mêmes noms de fichiers.
"""

import argparse
import math
import random
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_SORTIE = RACINE / "assets" / "audio" / "respiration"

TAUX = 44100  # Hz

DUREE_SOUFFLE_S = 6.0   # l'application étire/compresse vers la durée de phase
DUREE_INVERSION_S = 3.2


def ecrire_wav(chemin: Path, echantillons: list) -> None:
    """Écrit une liste de flottants [-1, 1] en WAV mono 16 bits."""
    import struct
    donnees = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, e)) * 32767))
        for e in echantillons
    )
    with wave.open(str(chemin), "w") as fichier:
        fichier.setnchannels(1)
        fichier.setsampwidth(2)
        fichier.setframerate(TAUX)
        fichier.writeframes(donnees)


def normaliser(echantillons: list, crete: float) -> list:
    maxi = max(abs(e) for e in echantillons) or 1.0
    facteur = crete / maxi
    return [e * facteur for e in echantillons]


def souffle(montant: bool) -> list:
    """Bruit blanc filtré : la coupure et le volume suivent la respiration.

    Inspiration : le souffle enfle, s'éclaircit, puis se pose (pic vers 60 %).
    Expiration : il part plein, s'assombrit et s'éteint (pic vers 40 %).
    L'enveloppe vaut zéro aux deux extrémités : aucune coupure audible.
    """
    random.seed(7 if montant else 11)
    nb = int(DUREE_SOUFFLE_S * TAUX)
    dt = 1.0 / TAUX

    # Passe-bas à un pôle (deux étages en cascade), coupure variable.
    y1 = y2 = 0.0
    # Passe-haut à un pôle : enlève le grondement sous ~120 Hz.
    yh = xh = 0.0
    rc_haut = 1.0 / (2 * math.pi * 120.0)
    a_haut = rc_haut / (rc_haut + dt)

    sortie = []
    for i in range(nb):
        x = i / nb
        if montant:
            enveloppe = math.sin(math.pi * x ** 1.3) ** 1.2
            coupure = 350.0 * (1600.0 / 350.0) ** x
        else:
            enveloppe = math.sin(math.pi * x ** 0.75) ** 1.2
            coupure = 1600.0 * (300.0 / 1600.0) ** x

        rc = 1.0 / (2 * math.pi * coupure)
        a = dt / (rc + dt)
        bruit = random.uniform(-1.0, 1.0)
        y1 += a * (bruit - y1)
        y2 += a * (y1 - y2)
        yh = a_haut * (yh + y2 - xh)
        xh = y2
        sortie.append(yh * enveloppe)

    return normaliser(sortie, 0.85)


def inversion() -> list:
    """Son cristallin amorti, comme un petit bol chantant effleuré.

    Partiels inharmoniques (ratios proches d'un bol réel), chacun doublé
    et légèrement désaccordé pour un battement lent et vivant.
    """
    nb = int(DUREE_INVERSION_S * TAUX)
    f0 = 396.0
    partiels = [  # (ratio, amplitude, amortissement en s)
        (1.0, 1.0, 1.6),
        (2.756, 0.40, 0.8),
        (5.404, 0.12, 0.45),
    ]
    attaque_s = 0.012

    sortie = []
    for i in range(nb):
        t = i / TAUX
        valeur = 0.0
        for ratio, amplitude, tau in partiels:
            f = f0 * ratio
            decroissance = math.exp(-t / tau)
            valeur += amplitude * decroissance * (
                math.sin(2 * math.pi * f * t)
                + 0.5 * math.sin(2 * math.pi * (f + 0.6) * t)
            )
        if t < attaque_s:
            valeur *= t / attaque_s
        sortie.append(valeur)

    return normaliser(sortie, 0.8)


SONS = {
    "souffle_inspiration": lambda: souffle(montant=True),
    "souffle_expiration": lambda: souffle(montant=False),
    "inversion": inversion,
}


def generer(nom: str) -> None:
    echantillons = SONS[nom]()
    sortie = DOSSIER_SORTIE / f"{nom}.mp3"
    with tempfile.TemporaryDirectory(prefix=f"flow_{nom}_") as tmp:
        brut = Path(tmp) / f"{nom}.wav"
        ecrire_wav(brut, echantillons)
        subprocess.run(
            ["ffmpeg", "-y", "-v", "error", "-i", str(brut),
             "-c:a", "libmp3lame", "-b:a", "96k", str(sortie)],
            check=True,
        )
    taille_ko = sortie.stat().st_size // 1024
    duree = len(echantillons) / TAUX
    print(f"  ok  {sortie.relative_to(RACINE)}  ({duree:.1f} s, {taille_ko} Ko)")


def principal() -> None:
    analyseur = argparse.ArgumentParser(description=__doc__)
    analyseur.add_argument("sons", nargs="*",
                           help=f"parmi : {', '.join(SONS)} (défaut : tous)")
    options = analyseur.parse_args()

    cibles = options.sons or list(SONS)
    inconnus = [n for n in cibles if n not in SONS]
    if inconnus:
        sys.exit(f"Sons inconnus : {', '.join(inconnus)} "
                 f"(disponibles : {', '.join(SONS)})")

    DOSSIER_SORTIE.mkdir(parents=True, exist_ok=True)
    for nom in cibles:
        generer(nom)
    print("Termine. Relancez `flutter run` pour embarquer les nouveaux assets.")


if __name__ == "__main__":
    principal()
