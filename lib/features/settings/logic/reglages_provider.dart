import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/services/notifications_service.dart';
import '../../../core/services/stockage_service.dart';
import '../data/reglages_app.dart';

/// Source de vérité des préférences. Chaque modification est
/// immédiatement persistée dans Hive et, pour les rappels,
/// répercutée sur les notifications programmées.
class ReglagesNotifier extends Notifier<ReglagesApp> {
  static const String _cle = 'reglages_app';

  @override
  ReglagesApp build() {
    final Box<dynamic> box = ref.watch(boxReglagesProvider);
    final dynamic brut = box.get(_cle);
    if (brut is Map) return ReglagesApp.depuisMap(brut);
    return const ReglagesApp();
  }

  void _appliquer(ReglagesApp nouveau) {
    state = nouveau;
    ref.read(boxReglagesProvider).put(_cle, nouveau.versMap());
  }

  void changerTheme(ThemeMode mode) =>
      _appliquer(state.copyWith(modeTheme: mode));

  void changerHaptique(bool active) =>
      _appliquer(state.copyWith(haptiqueActive: active));

  /// Active ou coupe le rappel quotidien. Demande la permission si besoin ;
  /// renvoie `false` si elle est refusée (le rappel reste inactif).
  Future<bool> changerRappel(bool actif) async {
    final NotificationsService notifications = ref.read(notificationsProvider);
    if (actif) {
      final bool permission = await notifications.demanderPermission();
      if (!permission) {
        _appliquer(state.copyWith(rappelActif: false));
        return false;
      }
      _appliquer(state.copyWith(rappelActif: true));
      await notifications.programmerRappelQuotidien(state.rappelHeure);
      return true;
    }
    _appliquer(state.copyWith(rappelActif: false));
    await notifications.annulerRappel();
    return true;
  }

  /// Change l'heure du rappel et reprogramme si le rappel est actif.
  Future<void> changerHeureRappel(TimeOfDay heure) async {
    _appliquer(
      state.copyWith(rappelMinutes: heure.hour * 60 + heure.minute),
    );
    if (state.rappelActif) {
      await ref.read(notificationsProvider).programmerRappelQuotidien(heure);
    }
  }
}

final reglagesProvider = NotifierProvider<ReglagesNotifier, ReglagesApp>(
  ReglagesNotifier.new,
);
