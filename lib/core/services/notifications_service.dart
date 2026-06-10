import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Rappels de pratique : une notification locale douce, chaque jour
/// à l'heure choisie. Programmation inexacte (pas de permission
/// « alarme exacte » nécessaire — quelques minutes près suffisent
/// pour une invitation à respirer).
class NotificationsService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _idRappel = 1;

  static const AndroidNotificationDetails _details =
      AndroidNotificationDetails(
    'rappel_pratique',
    'Rappels de pratique',
    channelDescription: 'Invitation quotidienne à prendre un moment de calme',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: false,
    styleInformation: BigTextStyleInformation(''),
  );

  /// Initialise le plugin et les fuseaux horaires.
  Future<void> initialiser() async {
    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo fuseau = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(fuseau.identifier));
    } catch (_) {
      // Fuseau introuvable : on reste sur le fuseau par défaut (UTC),
      // le rappel restera fonctionnel mais possiblement décalé.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Demande la permission de notifier (Android 13+). Renvoie `true`
  /// si la permission est accordée.
  Future<bool> demanderPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? accorde = await android?.requestNotificationsPermission();
    return accorde ?? false;
  }

  /// Programme le rappel quotidien à l'heure donnée.
  Future<void> programmerRappelQuotidien(TimeOfDay heure) async {
    await annulerRappel();
    final tz.TZDateTime maintenant = tz.TZDateTime.now(tz.local);
    tz.TZDateTime prochain = tz.TZDateTime(
      tz.local,
      maintenant.year,
      maintenant.month,
      maintenant.day,
      heure.hour,
      heure.minute,
    );
    if (prochain.isBefore(maintenant)) {
      prochain = prochain.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _idRappel,
      title: 'Un moment pour vous',
      body: 'Quelques respirations suffisent à retrouver le calme.',
      scheduledDate: prochain,
      notificationDetails: const NotificationDetails(android: _details),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Annule le rappel quotidien.
  Future<void> annulerRappel() => _plugin.cancel(id: _idRappel);
}

/// Service de notifications global, injecté depuis `main`.
final notificationsProvider = Provider<NotificationsService>(
  (ref) => throw UnimplementedError('Injecté au démarrage dans main.dart'),
);
