# -*- coding: utf-8 -*-
"""Génère des sons d'ambiance de synthèse pour Flow (ffmpeg).

Première version « placeholder » de qualité honnête : du bruit coloré,
filtré et modulé lentement — c'est la matière même d'une pluie ou d'un
ressac. Quatre ambiances sont synthétisables ainsi : pluie, vent,
vagues, ruisseau. Les autres (forêt, feu, bol tibétain) demandent de
vrais enregistrements : voir assets/audio/ambiance/README.md.

Les pistes durent 2 minutes et bouclent proprement (fréquences de
modulation choisies pour un nombre entier de périodes), l'application
les joue en boucle.

Usage :
    python tools/generer_ambiances.py            # les quatre
    python tools/generer_ambiances.py pluie vent # une sélection
"""

import argparse
import subprocess
import sys
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_SORTIE = RACINE / "assets" / "audio" / "ambiance"

DUREE_S = 120  # les fréquences de modulation doivent diviser cette durée

# Chaque ambiance : une source de bruit + une chaîne de filtres ffmpeg.
AMBIANCES = {
    # Pluie : bruit rose, aigus présents mais doux, niveau stable.
    "pluie": (
        "anoisesrc=color=pink:r=44100:a=0.8",
        "highpass=f=300,lowpass=f=8000,volume=0.55",
    ),
    # Vent : bruit brun grave, souffle qui enfle et retombe lentement.
    "vent": (
        "anoisesrc=color=brown:r=44100:a=0.9",
        "lowpass=f=650,tremolo=f=0.1:d=0.75,volume=0.9",
    ),
    # Vagues : bruit brun, ressac profond toutes les 12 secondes
    # (modulation par expression : tremolo refuse les fréquences si basses).
    "vagues": (
        "anoisesrc=color=brown:r=44100:a=0.9",
        "lowpass=f=900,volume=volume=0.55+0.42*sin(2*PI*t/12):eval=frame",
    ),
    # Ruisseau : bruit rose clair, babillage rapide et léger.
    "ruisseau": (
        "anoisesrc=color=pink:r=44100:a=0.7",
        "highpass=f=900,lowpass=f=6500,tremolo=f=1.5:d=0.25,volume=0.5",
    ),
}


def generer(nom: str) -> None:
    source, filtres = AMBIANCES[nom]
    sortie = DOSSIER_SORTIE / f"{nom}.mp3"
    subprocess.run(
        ["ffmpeg", "-y", "-v", "error",
         "-f", "lavfi", "-i", source,
         "-t", str(DUREE_S), "-af", filtres,
         "-c:a", "libmp3lame", "-b:a", "96k",
         str(sortie)],
        check=True,
    )
    taille_ko = sortie.stat().st_size // 1024
    print(f"  ok  {sortie.relative_to(RACINE)}  ({taille_ko} Ko)")


def principal() -> None:
    analyseur = argparse.ArgumentParser(description=__doc__)
    analyseur.add_argument("ambiances", nargs="*",
                           help=f"parmi : {', '.join(AMBIANCES)} (défaut : toutes)")
    options = analyseur.parse_args()

    cibles = options.ambiances or list(AMBIANCES)
    inconnues = [n for n in cibles if n not in AMBIANCES]
    if inconnues:
        sys.exit(f"Ambiances inconnues : {', '.join(inconnues)} "
                 f"(synthétisables : {', '.join(AMBIANCES)})")

    DOSSIER_SORTIE.mkdir(parents=True, exist_ok=True)
    for nom in cibles:
        generer(nom)
    print("Termine. foret/feu/bol demandent de vrais enregistrements "
          "(voir assets/audio/ambiance/README.md).")


if __name__ == "__main__":
    principal()
