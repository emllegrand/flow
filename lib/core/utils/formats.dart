/// Petits utilitaires de formatage, en français.
library;

/// Formate une durée en secondes vers « 12 min » ou « 1 h 05 ».
String formatMinutes(int secondes) {
  final int minutes = secondes ~/ 60;
  if (minutes < 1) return '${secondes}s';
  if (minutes < 60) return '$minutes min';
  final int heures = minutes ~/ 60;
  final int reste = minutes % 60;
  return reste == 0 ? '$heures h' : '$heures h ${reste.toString().padLeft(2, '0')}';
}

/// Formate une durée en secondes vers un chronomètre « 4:05 ».
String formatChrono(int secondes) {
  final int minutes = secondes ~/ 60;
  final int reste = secondes % 60;
  return '$minutes:${reste.toString().padLeft(2, '0')}';
}

/// Salutation selon l'heure de la journée.
String salutationDuMoment(DateTime maintenant) {
  final int heure = maintenant.hour;
  if (heure < 5) return 'Douce nuit';
  if (heure < 12) return 'Bonjour';
  if (heure < 18) return 'Bel après-midi';
  return 'Bonsoir';
}

/// Phrase d'invitation selon l'heure, pour l'écran d'accueil.
String invitationDuMoment(DateTime maintenant) {
  final int heure = maintenant.hour;
  if (heure < 5) return 'Le calme de la nuit vous accompagne.';
  if (heure < 9) return 'Commencez la journée en douceur.';
  if (heure < 12) return 'Prenez un instant pour respirer.';
  if (heure < 18) return 'Une pause, simplement.';
  if (heure < 22) return 'Laissez la journée se déposer.';
  return 'Préparez-vous à une nuit paisible.';
}

/// Tronque une date à son jour (minuit).
DateTime jourDe(DateTime date) => DateTime(date.year, date.month, date.day);
