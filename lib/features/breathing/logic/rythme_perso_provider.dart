import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/stockage_service.dart';
import '../data/rythme_respiration.dart';

/// Rythme personnalisé de l'utilisateur, persisté dans les réglages.
class RythmePersoNotifier extends Notifier<RythmeRespiration> {
  static const String _cle = 'rythme_perso';

  @override
  RythmeRespiration build() {
    final dynamic brut = ref.watch(boxReglagesProvider).get(_cle);
    if (brut is Map) {
      return RythmesPredefinis.personnalise.copyWith(
        inspiration: (brut['inspiration'] as num?)?.toDouble(),
        retentionHaute: (brut['retentionHaute'] as num?)?.toDouble(),
        expiration: (brut['expiration'] as num?)?.toDouble(),
        retentionBasse: (brut['retentionBasse'] as num?)?.toDouble(),
      );
    }
    return RythmesPredefinis.personnalise;
  }

  /// Ajuste une ou plusieurs durées (les bornes sont gérées par l'UI).
  void modifier({
    double? inspiration,
    double? retentionHaute,
    double? expiration,
    double? retentionBasse,
  }) {
    state = state.copyWith(
      inspiration: inspiration,
      retentionHaute: retentionHaute,
      expiration: expiration,
      retentionBasse: retentionBasse,
    );
    ref.read(boxReglagesProvider).put(_cle, {
      'inspiration': state.inspiration,
      'retentionHaute': state.retentionHaute,
      'expiration': state.expiration,
      'retentionBasse': state.retentionBasse,
    });
  }
}

final rythmePersoProvider =
    NotifierProvider<RythmePersoNotifier, RythmeRespiration>(
  RythmePersoNotifier.new,
);
