import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;

/// Préférences de l'utilisateur, persistées dans la box Hive `reglages`.
class ReglagesApp {
  const ReglagesApp({
    this.modeTheme = ThemeMode.system,
    this.haptiqueActive = true,
    this.sonsRespirationActifs = true,
    this.rappelActif = false,
    this.rappelMinutes = 20 * 60, // 20 h — un rappel du soir par défaut
  });

  /// Thème clair, sombre ou selon le système.
  final ThemeMode modeTheme;

  /// Retour haptique léger aux transitions de respiration.
  final bool haptiqueActive;

  /// Souffles et son cristallin qui accompagnent la bulle de respiration.
  final bool sonsRespirationActifs;

  /// Rappel quotidien de pratique.
  final bool rappelActif;

  /// Heure du rappel, en minutes depuis minuit.
  final int rappelMinutes;

  TimeOfDay get rappelHeure =>
      TimeOfDay(hour: rappelMinutes ~/ 60, minute: rappelMinutes % 60);

  ReglagesApp copyWith({
    ThemeMode? modeTheme,
    bool? haptiqueActive,
    bool? sonsRespirationActifs,
    bool? rappelActif,
    int? rappelMinutes,
  }) {
    return ReglagesApp(
      modeTheme: modeTheme ?? this.modeTheme,
      haptiqueActive: haptiqueActive ?? this.haptiqueActive,
      sonsRespirationActifs:
          sonsRespirationActifs ?? this.sonsRespirationActifs,
      rappelActif: rappelActif ?? this.rappelActif,
      rappelMinutes: rappelMinutes ?? this.rappelMinutes,
    );
  }

  Map<String, dynamic> versMap() => {
        'modeTheme': modeTheme.name,
        'haptiqueActive': haptiqueActive,
        'sonsRespirationActifs': sonsRespirationActifs,
        'rappelActif': rappelActif,
        'rappelMinutes': rappelMinutes,
      };

  static ReglagesApp depuisMap(Map<dynamic, dynamic> map) {
    return ReglagesApp(
      modeTheme: ThemeMode.values.asNameMap()[map['modeTheme']] ??
          ThemeMode.system,
      haptiqueActive: map['haptiqueActive'] as bool? ?? true,
      sonsRespirationActifs: map['sonsRespirationActifs'] as bool? ?? true,
      rappelActif: map['rappelActif'] as bool? ?? false,
      rappelMinutes: map['rappelMinutes'] as int? ?? 20 * 60,
    );
  }
}
