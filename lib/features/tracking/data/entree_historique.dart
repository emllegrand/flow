/// Une pratique enregistrée : exercice de respiration ou séance guidée.
class EntreeHistorique {
  const EntreeHistorique({
    required this.id,
    required this.type,
    required this.titre,
    required this.dureeSecondes,
    required this.date,
    this.cycles,
  });

  final String id;

  /// `respiration` ou `seance`.
  final TypePratique type;

  final String titre;
  final int dureeSecondes;
  final DateTime date;

  /// Nombre de cycles respiratoires (exercices de respiration uniquement).
  final int? cycles;

  Map<String, dynamic> versMap() => {
        'id': id,
        'type': type.name,
        'titre': titre,
        'dureeSecondes': dureeSecondes,
        'date': date.toIso8601String(),
        'cycles': cycles,
      };

  static EntreeHistorique depuisMap(Map<dynamic, dynamic> map) {
    return EntreeHistorique(
      id: map['id'] as String,
      type: TypePratique.values.asNameMap()[map['type']] ??
          TypePratique.respiration,
      titre: map['titre'] as String? ?? '',
      dureeSecondes: map['dureeSecondes'] as int? ?? 0,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      cycles: map['cycles'] as int?,
    );
  }
}

enum TypePratique { respiration, seance }
