# -*- coding: utf-8 -*-
"""Génère les voix des séances guidées de Flow (edge-tts + ffmpeg).

Chaque texte de tools/voix/textes/<nom>.txt est synthétisé paragraphe
par paragraphe (voix neurale Microsoft, gratuite, débit ralenti), puis
assemblé avec des silences entre les instructions. La durée des silences
est calibrée pour approcher la durée cible de la séance, telle
qu'annoncée dans le catalogue de l'application — une méditation guidée
laisse respirer entre deux consignes.

Usage :
    pip install edge-tts            # + ffmpeg dans le PATH
    python tools/generer_voix.py                  # toutes les séances
    python tools/generer_voix.py sommeil_profond  # une seule
    python tools/generer_voix.py --voix fr-FR-HenriNeural

Voix françaises : python -m edge_tts --list-voices  (filtrer fr-FR)
"""

import argparse
import asyncio
import subprocess
import sys
import tempfile
from pathlib import Path

import edge_tts

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_TEXTES = RACINE / "tools" / "voix" / "textes"
DOSSIER_SORTIE = RACINE / "assets" / "audio" / "sessions"

VOIX_PAR_DEFAUT = "fr-FR-DeniseNeural"
DEBIT_PAR_DEFAUT = "-18%"   # plus lent que la parole normale : ton méditatif
HAUTEUR_PAR_DEFAUT = "-4Hz"  # voix légèrement plus grave, plus posée

# Durées cibles (minutes) — doivent suivre lib/features/sessions/data/catalogue_seances.dart
DUREES_CIBLES_MIN = {
    "pause_express": 3,
    "respiration_decouverte": 5,
    "ancrage_matin": 10,
    "concentration_calme": 10,
    "lacher_prise": 12,
    "scan_corporel": 15,
    "apaiser_anxiete": 15,
    "sommeil_profond": 20,
}

SILENCE_MINI_S = 2.5    # respiration minimale entre deux consignes
SILENCE_MAXI_S = 45.0   # même pour le sommeil, on ne dépasse pas
SILENCE_DEBUT_S = 2.0   # arrivée en douceur
SILENCE_FIN_S = 4.0     # sortie en douceur


def duree_de(fichier: Path) -> float:
    """Durée d'un fichier audio en secondes (via ffprobe)."""
    resultat = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=noprint_wrappers=1:nokey=1", str(fichier)],
        capture_output=True, text=True, check=True,
    )
    return float(resultat.stdout.strip())


def fabriquer_silence(dossier: Path, nom: str, secondes: float) -> Path:
    """Crée un MP3 de silence aux mêmes paramètres que la voix edge-tts."""
    sortie = dossier / f"{nom}.mp3"
    subprocess.run(
        ["ffmpeg", "-y", "-v", "error",
         "-f", "lavfi", "-i", "anullsrc=r=24000:cl=mono",
         "-t", f"{secondes:.2f}", "-c:a", "libmp3lame", "-b:a", "48k",
         str(sortie)],
        check=True,
    )
    return sortie


async def generer(nom: str, voix: str, debit: str, hauteur: str) -> None:
    texte = (DOSSIER_TEXTES / f"{nom}.txt").read_text(encoding="utf-8")
    paragraphes = [p.strip() for p in texte.split("\n\n") if p.strip()]
    cible_s = DUREES_CIBLES_MIN.get(nom, 5) * 60

    with tempfile.TemporaryDirectory(prefix=f"flow_{nom}_") as tmp:
        dossier = Path(tmp)

        # 1. Une piste de voix par paragraphe.
        segments = []
        for i, paragraphe in enumerate(paragraphes):
            segment = dossier / f"voix_{i:03d}.mp3"
            await edge_tts.Communicate(
                paragraphe, voix, rate=debit, pitch=hauteur
            ).save(str(segment))
            segments.append(segment)

        # 2. Silence entre les consignes, calibré sur la durée cible.
        duree_parole = sum(duree_de(s) for s in segments)
        nb_espaces = max(len(segments) - 1, 1)
        reste = cible_s - duree_parole - SILENCE_DEBUT_S - SILENCE_FIN_S
        pause_s = max(SILENCE_MINI_S, min(SILENCE_MAXI_S, reste / nb_espaces))

        silence_debut = fabriquer_silence(dossier, "debut", SILENCE_DEBUT_S)
        silence_pause = fabriquer_silence(dossier, "pause", pause_s)
        silence_fin = fabriquer_silence(dossier, "fin", SILENCE_FIN_S)

        # 3. Assemblage, avec réencodage : garantit des timestamps
        # propres (la recherche ±15 s du lecteur en dépend).
        morceaux = [silence_debut]
        for i, segment in enumerate(segments):
            morceaux.append(segment)
            morceaux.append(silence_fin if i == len(segments) - 1 else silence_pause)

        liste = dossier / "liste.txt"
        liste.write_text(
            "".join(f"file '{m.as_posix()}'\n" for m in morceaux),
            encoding="utf-8",
        )
        sortie = DOSSIER_SORTIE / f"{nom}.mp3"
        subprocess.run(
            ["ffmpeg", "-y", "-v", "error", "-f", "concat", "-safe", "0",
             "-i", str(liste), "-c:a", "libmp3lame", "-b:a", "48k",
             "-ar", "24000", str(sortie)],
            check=True,
        )

    duree = duree_de(sortie)
    print(f"  ok  {nom:26s} {int(duree // 60)} min {int(duree % 60):02d} s "
          f"(cible {cible_s // 60:.0f} min, pauses {pause_s:.0f} s)")


async def principal() -> None:
    analyseur = argparse.ArgumentParser(description=__doc__)
    analyseur.add_argument("seances", nargs="*", help="noms des séances (défaut : toutes)")
    analyseur.add_argument("--voix", default=VOIX_PAR_DEFAUT)
    analyseur.add_argument("--debit", default=DEBIT_PAR_DEFAUT)
    analyseur.add_argument("--hauteur", default=HAUTEUR_PAR_DEFAUT)
    options = analyseur.parse_args()

    disponibles = sorted(p.stem for p in DOSSIER_TEXTES.glob("*.txt"))
    cibles = options.seances or disponibles
    inconnues = [n for n in cibles if n not in disponibles]
    if inconnues:
        sys.exit(f"Textes introuvables : {', '.join(inconnues)} "
                 f"(disponibles : {', '.join(disponibles)})")

    DOSSIER_SORTIE.mkdir(parents=True, exist_ok=True)
    print(f"Voix {options.voix}, debit {options.debit}, hauteur {options.hauteur}")
    for nom in cibles:
        await generer(nom, options.voix, options.debit, options.hauteur)
    print("Termine. Relancez `flutter run` pour embarquer les nouveaux assets.")


if __name__ == "__main__":
    asyncio.run(principal())
