import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persistance locale avec Hive.
///
/// Deux boxes :
///  - `reglages`   : préférences (thème, haptique, rappels, volumes…)
///  - `historique` : entrées de pratique (respiration, séances)
///
/// Les données sont stockées en `Map` JSON — pas d'adaptateurs générés,
/// la structure reste simple et lisible.
abstract final class StockageService {
  static const String boxReglages = 'reglages';
  static const String boxHistorique = 'historique';

  /// À appeler avant `runApp`.
  static Future<void> initialiser() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(boxReglages);
    await Hive.openBox<dynamic>(boxHistorique);
  }
}

/// Box des réglages, ouverte au démarrage.
final boxReglagesProvider = Provider<Box<dynamic>>(
  (ref) => Hive.box<dynamic>(StockageService.boxReglages),
);

/// Box de l'historique de pratique, ouverte au démarrage.
final boxHistoriqueProvider = Provider<Box<dynamic>>(
  (ref) => Hive.box<dynamic>(StockageService.boxHistorique),
);
