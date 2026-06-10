import 'package:flutter/material.dart';

/// Un son d'ambiance du catalogue.
class SonAmbiance {
  const SonAmbiance({
    required this.id,
    required this.nom,
    required this.description,
    required this.icone,
    required this.fichier,
  });

  final String id;
  final String nom;
  final String description;
  final IconData icone;

  /// Chemin de l'asset — le fichier est fourni séparément
  /// (voir assets/audio/ambiance/README.md).
  final String fichier;
}

/// Catalogue des sons d'ambiance de Flow.
abstract final class CatalogueSons {
  static const List<SonAmbiance> tous = [
    SonAmbiance(
      id: 'pluie',
      nom: 'Pluie',
      description: 'Une pluie fine sur les feuilles',
      icone: Icons.grain_rounded,
      fichier: 'assets/audio/ambiance/pluie.mp3',
    ),
    SonAmbiance(
      id: 'vagues',
      nom: 'Vagues',
      description: 'Le ressac, lent et régulier',
      icone: Icons.waves_rounded,
      fichier: 'assets/audio/ambiance/vagues.mp3',
    ),
    SonAmbiance(
      id: 'foret',
      nom: 'Forêt',
      description: 'Oiseaux et feuillages au matin',
      icone: Icons.forest_rounded,
      fichier: 'assets/audio/ambiance/foret.mp3',
    ),
    SonAmbiance(
      id: 'ruisseau',
      nom: 'Ruisseau',
      description: 'L\'eau claire entre les pierres',
      icone: Icons.water_rounded,
      fichier: 'assets/audio/ambiance/ruisseau.mp3',
    ),
    SonAmbiance(
      id: 'vent',
      nom: 'Vent',
      description: 'Un souffle calme dans les pins',
      icone: Icons.air_rounded,
      fichier: 'assets/audio/ambiance/vent.mp3',
    ),
    SonAmbiance(
      id: 'feu',
      nom: 'Feu de bois',
      description: 'Crépitements au coin du feu',
      icone: Icons.local_fire_department_rounded,
      fichier: 'assets/audio/ambiance/feu.mp3',
    ),
    SonAmbiance(
      id: 'bol',
      nom: 'Bol tibétain',
      description: 'Résonances longues et profondes',
      icone: Icons.self_improvement_rounded,
      fichier: 'assets/audio/ambiance/bol.mp3',
    ),
  ];

  static SonAmbiance? parId(String id) {
    for (final SonAmbiance son in tous) {
      if (son.id == id) return son;
    }
    return null;
  }
}
