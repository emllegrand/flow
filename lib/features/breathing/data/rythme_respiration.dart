/// Un rythme respiratoire : durée de chaque phase, en secondes.
/// Une durée nulle signifie que la phase est sautée.
class RythmeRespiration {
  const RythmeRespiration({
    required this.id,
    required this.nom,
    required this.description,
    required this.inspiration,
    required this.retentionHaute,
    required this.expiration,
    required this.retentionBasse,
  });

  final String id;
  final String nom;
  final String description;
  final double inspiration;
  final double retentionHaute;
  final double expiration;
  final double retentionBasse;

  /// Durée d'un cycle complet.
  double get dureeCycle =>
      inspiration + retentionHaute + expiration + retentionBasse;

  /// Résumé compact, ex. « 4 · 7 · 8 ».
  String get motif => [inspiration, retentionHaute, expiration, retentionBasse]
      .where((d) => d > 0)
      .map((d) => d == d.roundToDouble() ? d.toInt().toString() : '$d')
      .join(' · ');

  RythmeRespiration copyWith({
    double? inspiration,
    double? retentionHaute,
    double? expiration,
    double? retentionBasse,
  }) {
    return RythmeRespiration(
      id: id,
      nom: nom,
      description: description,
      inspiration: inspiration ?? this.inspiration,
      retentionHaute: retentionHaute ?? this.retentionHaute,
      expiration: expiration ?? this.expiration,
      retentionBasse: retentionBasse ?? this.retentionBasse,
    );
  }
}

/// Les quatre phases d'un cycle respiratoire.
enum PhaseRespiration {
  inspiration('Inspirez'),
  retentionHaute('Retenez'),
  expiration('Expirez'),
  retentionBasse('Laissez le vide');

  const PhaseRespiration(this.consigne);

  /// Consigne affichée au centre de la bulle.
  final String consigne;
}

/// Rythmes proposés par Flow.
abstract final class RythmesPredefinis {
  static const RythmeRespiration coherence = RythmeRespiration(
    id: 'coherence',
    nom: 'Cohérence cardiaque',
    description: 'Cinq secondes pour inspirer, cinq pour expirer. '
        'L\'équilibre du cœur et du souffle.',
    inspiration: 5,
    retentionHaute: 0,
    expiration: 5,
    retentionBasse: 0,
  );

  static const RythmeRespiration quatreSeptHuit = RythmeRespiration(
    id: 'quatre_sept_huit',
    nom: 'Respiration 4-7-8',
    description: 'Une longue expiration qui invite au sommeil '
        'et apaise les tensions.',
    inspiration: 4,
    retentionHaute: 7,
    expiration: 8,
    retentionBasse: 0,
  );

  static const RythmeRespiration carree = RythmeRespiration(
    id: 'carree',
    nom: 'Respiration carrée',
    description: 'Quatre temps égaux, comme les côtés d\'un carré. '
        'Stabilité et concentration.',
    inspiration: 4,
    retentionHaute: 4,
    expiration: 4,
    retentionBasse: 4,
  );

  /// Point de départ du rythme personnalisé (modifiable par l'utilisateur).
  static const RythmeRespiration personnalise = RythmeRespiration(
    id: 'personnalise',
    nom: 'Rythme personnel',
    description: 'Composez votre propre souffle, à votre mesure.',
    inspiration: 4,
    retentionHaute: 2,
    expiration: 6,
    retentionBasse: 0,
  );

  static const List<RythmeRespiration> tous = [
    coherence,
    quatreSeptHuit,
    carree,
    personnalise,
  ];

  /// Retrouve un rythme par identifiant (revient à la cohérence si inconnu).
  static RythmeRespiration parId(String id) => tous.firstWhere(
        (r) => r.id == id,
        orElse: () => coherence,
      );
}
