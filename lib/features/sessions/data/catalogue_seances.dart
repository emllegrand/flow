/// Objectifs des séances guidées (et des parcours).
enum ObjectifSeance {
  decouverte('Découverte'),
  stress('Stress'),
  sommeil('Sommeil'),
  concentration('Concentration'),
  anxiete('Anxiété'),
  reveil('Réveil doux');

  const ObjectifSeance(this.libelle);

  final String libelle;
}

/// Une séance guidée du catalogue.
class SeanceGuidee {
  const SeanceGuidee({
    required this.id,
    required this.titre,
    required this.description,
    required this.objectif,
    required this.dureeMinutes,
    required this.fichier,
  });

  final String id;
  final String titre;
  final String description;
  final ObjectifSeance objectif;

  /// Durée indicative affichée dans la bibliothèque ; la durée réelle
  /// vient du fichier audio une fois chargé.
  final int dureeMinutes;

  /// Chemin de l'asset — le fichier voix est fourni séparément
  /// (voir assets/audio/sessions/README.md).
  final String fichier;
}

/// Bibliothèque des séances guidées de Flow.
abstract final class CatalogueSeances {
  static const List<SeanceGuidee> toutes = [
    SeanceGuidee(
      id: 'pause_express',
      titre: 'Pause express',
      description: 'Quatre minutes pour déposer ce qui pèse, '
          'où que vous soyez.',
      objectif: ObjectifSeance.stress,
      dureeMinutes: 4,
      fichier: 'assets/audio/sessions/pause_express.mp3',
    ),
    SeanceGuidee(
      id: 'respiration_decouverte',
      titre: 'Découvrir sa respiration',
      description: 'Une première rencontre avec votre souffle, '
          'simplement, sans rien attendre.',
      objectif: ObjectifSeance.decouverte,
      dureeMinutes: 5,
      fichier: 'assets/audio/sessions/respiration_decouverte.mp3',
    ),
    SeanceGuidee(
      id: 'ancrage_matin',
      titre: 'Ancrage du matin',
      description: 'Poser le corps et l\'esprit avant que la journée '
          'ne commence.',
      objectif: ObjectifSeance.reveil,
      dureeMinutes: 10,
      fichier: 'assets/audio/sessions/ancrage_matin.mp3',
    ),
    SeanceGuidee(
      id: 'concentration_calme',
      titre: 'Concentration calme',
      description: 'Rassembler l\'attention, doucement, '
          'comme on rassemble de l\'eau.',
      objectif: ObjectifSeance.concentration,
      dureeMinutes: 10,
      fichier: 'assets/audio/sessions/concentration_calme.mp3',
    ),
    SeanceGuidee(
      id: 'lacher_prise',
      titre: 'Lâcher-prise',
      description: 'Relâcher une à une les tensions que la journée '
          'a déposées.',
      objectif: ObjectifSeance.stress,
      dureeMinutes: 12,
      fichier: 'assets/audio/sessions/lacher_prise.mp3',
    ),
    SeanceGuidee(
      id: 'scan_corporel',
      titre: 'Scan corporel',
      description: 'Parcourir le corps de la tête aux pieds, '
          'avec une attention bienveillante.',
      objectif: ObjectifSeance.decouverte,
      dureeMinutes: 15,
      fichier: 'assets/audio/sessions/scan_corporel.mp3',
    ),
    SeanceGuidee(
      id: 'apaiser_anxiete',
      titre: 'Apaiser l\'anxiété',
      description: 'Un refuge calme quand le mental s\'emballe.',
      objectif: ObjectifSeance.anxiete,
      dureeMinutes: 15,
      fichier: 'assets/audio/sessions/apaiser_anxiete.mp3',
    ),
    SeanceGuidee(
      id: 'sommeil_profond',
      titre: 'Vers un sommeil profond',
      description: 'Se laisser glisser vers la nuit, '
          'sans chercher à s\'endormir.',
      objectif: ObjectifSeance.sommeil,
      dureeMinutes: 20,
      fichier: 'assets/audio/sessions/sommeil_profond.mp3',
    ),
  ];

  static SeanceGuidee? parId(String id) {
    for (final SeanceGuidee seance in toutes) {
      if (seance.id == id) return seance;
    }
    return null;
  }
}
