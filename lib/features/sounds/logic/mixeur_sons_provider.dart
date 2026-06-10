import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/mixeur_audio.dart';
import '../../../core/services/stockage_service.dart';
import '../data/catalogue_sons.dart';

/// État d'une piste d'ambiance dans le mixeur.
class PisteAmbiance {
  const PisteAmbiance({
    this.active = false,
    this.volume = 0.7,
    this.disponible = true,
  });

  final bool active;

  /// Volume propre à cette piste (0.0 à 1.0), indépendant des autres.
  final double volume;

  /// `false` si le fichier audio est absent des assets.
  final bool disponible;

  PisteAmbiance copyWith({bool? active, double? volume, bool? disponible}) {
    return PisteAmbiance(
      active: active ?? this.active,
      volume: volume ?? this.volume,
      disponible: disponible ?? this.disponible,
    );
  }
}

/// Mixeur des sons d'ambiance : chaque son se joue, se coupe et se dose
/// indépendamment ; plusieurs sons se superposent librement.
/// Les volumes choisis sont mémorisés entre les sessions.
class MixeurSonsNotifier extends Notifier<Map<String, PisteAmbiance>> {
  static const String _cleVolumes = 'volumes_ambiance';

  @override
  Map<String, PisteAmbiance> build() {
    final dynamic volumes = ref.read(boxReglagesProvider).get(_cleVolumes);
    return {
      for (final son in CatalogueSons.tous)
        son.id: PisteAmbiance(
          volume: volumes is Map
              ? ((volumes[son.id] as num?)?.toDouble() ?? 0.7)
              : 0.7,
        ),
    };
  }

  /// Active ou coupe un son. Si le fichier est absent, la piste est
  /// marquée indisponible et l'interface l'indique calmement.
  Future<void> basculer(String id) async {
    final SonAmbiance? son = CatalogueSons.parId(id);
    final PisteAmbiance? piste = state[id];
    if (son == null || piste == null) return;

    final MixeurAudioHandler mixeur = ref.read(mixeurAudioProvider);
    if (piste.active) {
      await mixeur.desactiverAmbiance(id);
      state = {...state, id: piste.copyWith(active: false)};
    } else {
      final bool ok =
          await mixeur.activerAmbiance(id, son.fichier, volume: piste.volume);
      state = {
        ...state,
        id: piste.copyWith(active: ok, disponible: ok),
      };
    }
  }

  /// Règle le volume d'une piste (et le mémorise).
  Future<void> reglerVolume(String id, double volume) async {
    final PisteAmbiance? piste = state[id];
    if (piste == null) return;
    state = {...state, id: piste.copyWith(volume: volume)};
    await ref.read(mixeurAudioProvider).reglerVolumeAmbiance(id, volume);
    ref.read(boxReglagesProvider).put(_cleVolumes, {
      for (final entree in state.entries) entree.key: entree.value.volume,
    });
  }

  /// Coupe toutes les ambiances d'un geste.
  Future<void> toutCouper() async {
    await ref.read(mixeurAudioProvider).arreterAmbiances();
    state = {
      for (final entree in state.entries)
        entree.key: entree.value.copyWith(active: false),
    };
  }

  /// Nombre de pistes actuellement actives.
  int get nombreActives => state.values.where((p) => p.active).length;
}

final mixeurSonsProvider =
    NotifierProvider<MixeurSonsNotifier, Map<String, PisteAmbiance>>(
  MixeurSonsNotifier.new,
);
