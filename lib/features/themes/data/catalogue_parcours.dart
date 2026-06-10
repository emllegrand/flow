import 'package:flutter/material.dart';

import '../../../core/theme/palette_flow.dart';

/// Type d'une étape de parcours.
enum TypeEtape { respiration, seance, sons }

/// Une étape d'un parcours : renvoie vers un exercice de respiration,
/// une séance guidée ou un mélange de sons d'ambiance.
class EtapeParcours {
  const EtapeParcours.respiration({
    required this.libelle,
    required this.rythmeId,
    required this.dureeMinutes,
  })  : type = TypeEtape.respiration,
        seanceId = null,
        sonsIds = const [];

  const EtapeParcours.seance({
    required this.libelle,
    required this.seanceId,
  })  : type = TypeEtape.seance,
        rythmeId = null,
        dureeMinutes = null,
        sonsIds = const [];

  const EtapeParcours.sons({
    required this.libelle,
    required this.sonsIds,
  })  : type = TypeEtape.sons,
        rythmeId = null,
        seanceId = null,
        dureeMinutes = null;

  final TypeEtape type;
  final String libelle;
  final String? rythmeId;
  final int? dureeMinutes;
  final String? seanceId;
  final List<String> sonsIds;
}

/// Un parcours par besoin : un chemin tout tracé pour un moment précis.
class ParcoursBesoin {
  const ParcoursBesoin({
    required this.id,
    required this.nom,
    required this.invitation,
    required this.description,
    required this.icone,
    required this.couleur,
    required this.etapes,
  });

  final String id;
  final String nom;

  /// Phrase courte affichée sous le nom.
  final String invitation;

  final String description;
  final IconData icone;

  /// Teinte d'accent de la carte (toujours douce).
  final Color couleur;

  final List<EtapeParcours> etapes;
}

/// Les parcours proposés par Flow.
abstract final class CatalogueParcours {
  static const List<ParcoursBesoin> tous = [
    ParcoursBesoin(
      id: 'stress_examen',
      nom: 'Avant un examen',
      invitation: 'Retrouver ses moyens, posément.',
      description: 'Quand l\'échéance approche, le souffle est votre '
          'meilleur allié : un exercice court, une pause guidée, '
          'et la forêt en toile de fond.',
      icone: Icons.spa_rounded,
      couleur: PaletteFlow.mousse,
      etapes: [
        EtapeParcours.respiration(
          libelle: 'Respiration carrée — 3 minutes',
          rythmeId: 'carree',
          dureeMinutes: 3,
        ),
        EtapeParcours.seance(
          libelle: 'Pause express',
          seanceId: 'pause_express',
        ),
        EtapeParcours.sons(
          libelle: 'La forêt en fond sonore',
          sonsIds: ['foret'],
        ),
      ],
    ),
    ParcoursBesoin(
      id: 'sommeil',
      nom: 'Vers le sommeil',
      invitation: 'Laisser la journée se déposer.',
      description: 'Une respiration qui allonge l\'expiration, une voix '
          'qui accompagne vers la nuit, et la pluie pour bercer le tout.',
      icone: Icons.nightlight_round,
      couleur: PaletteFlow.indigo,
      etapes: [
        EtapeParcours.respiration(
          libelle: 'Respiration 4-7-8 — 5 minutes',
          rythmeId: 'quatre_sept_huit',
          dureeMinutes: 5,
        ),
        EtapeParcours.seance(
          libelle: 'Vers un sommeil profond',
          seanceId: 'sommeil_profond',
        ),
        EtapeParcours.sons(
          libelle: 'La pluie pour la nuit',
          sonsIds: ['pluie'],
        ),
      ],
    ),
    ParcoursBesoin(
      id: 'concentration',
      nom: 'Concentration',
      invitation: 'Rassembler l\'attention.',
      description: 'Stabiliser le souffle, poser l\'esprit, puis '
          'travailler porté par le murmure d\'un ruisseau.',
      icone: Icons.center_focus_weak_rounded,
      couleur: PaletteFlow.mousseSombre,
      etapes: [
        EtapeParcours.respiration(
          libelle: 'Cohérence cardiaque — 5 minutes',
          rythmeId: 'coherence',
          dureeMinutes: 5,
        ),
        EtapeParcours.seance(
          libelle: 'Concentration calme',
          seanceId: 'concentration_calme',
        ),
        EtapeParcours.sons(
          libelle: 'Un ruisseau pour travailler',
          sonsIds: ['ruisseau'],
        ),
      ],
    ),
    ParcoursBesoin(
      id: 'anxiete',
      nom: 'Apaiser l\'anxiété',
      invitation: 'Un refuge quand tout s\'accélère.',
      description: 'Ralentir le souffle pour ralentir le mental, '
          's\'appuyer sur une voix calme, et sur la respiration '
          'régulière des vagues.',
      icone: Icons.favorite_border_rounded,
      couleur: PaletteFlow.terracotta,
      etapes: [
        EtapeParcours.respiration(
          libelle: 'Cohérence cardiaque — 5 minutes',
          rythmeId: 'coherence',
          dureeMinutes: 5,
        ),
        EtapeParcours.seance(
          libelle: 'Apaiser l\'anxiété',
          seanceId: 'apaiser_anxiete',
        ),
        EtapeParcours.sons(
          libelle: 'Les vagues, lentes et sûres',
          sonsIds: ['vagues'],
        ),
      ],
    ),
    ParcoursBesoin(
      id: 'reveil',
      nom: 'Réveil en douceur',
      invitation: 'Commencer sans se presser.',
      description: 'Trois minutes de souffle pour éveiller le corps, '
          'un ancrage guidé, et les oiseaux de la forêt au matin.',
      icone: Icons.wb_twilight_rounded,
      couleur: PaletteFlow.terracottaClair,
      etapes: [
        EtapeParcours.respiration(
          libelle: 'Cohérence cardiaque — 3 minutes',
          rythmeId: 'coherence',
          dureeMinutes: 3,
        ),
        EtapeParcours.seance(
          libelle: 'Ancrage du matin',
          seanceId: 'ancrage_matin',
        ),
        EtapeParcours.sons(
          libelle: 'La forêt au lever du jour',
          sonsIds: ['foret'],
        ),
      ],
    ),
  ];

  static ParcoursBesoin? parId(String id) {
    for (final ParcoursBesoin parcours in tous) {
      if (parcours.id == id) return parcours;
    }
    return null;
  }
}
