import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/services/stockage_service.dart';
import '../data/entree_historique.dart';

/// Historique de pratique, trié du plus récent au plus ancien,
/// persisté dans la box Hive `historique`.
class HistoriqueNotifier extends Notifier<List<EntreeHistorique>> {
  @override
  List<EntreeHistorique> build() {
    final Box<dynamic> box = ref.watch(boxHistoriqueProvider);
    final List<EntreeHistorique> entrees = box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(EntreeHistorique.depuisMap)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entrees;
  }

  /// Enregistre une pratique terminée. L'état est mis à jour avant
  /// l'écriture disque (pas d'écart asynchrone avant `state`).
  Future<void> ajouter(EntreeHistorique entree) async {
    state = [entree, ...state];
    await ref.read(boxHistoriqueProvider).put(entree.id, entree.versMap());
  }

  /// Efface tout l'historique (action volontaire depuis les réglages).
  Future<void> toutEffacer() async {
    await ref.read(boxHistoriqueProvider).clear();
    state = const [];
  }
}

final historiqueProvider =
    NotifierProvider<HistoriqueNotifier, List<EntreeHistorique>>(
  HistoriqueNotifier.new,
);
