import 'dart:io';

import 'package:flow/core/theme/theme_flow.dart';
import 'package:flow/features/home/presentation/ecran_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Test de fumée : l'écran principal se construit, les cinq onglets
/// sont là et la navigation fonctionne.
void main() {
  setUpAll(() async {
    // Pas de réseau dans les tests : Google Fonts retombe sur les
    // polices de substitution.
    GoogleFonts.config.allowRuntimeFetching = false;
    final Directory dossier = Directory.systemTemp.createTempSync('flow_ui');
    Hive.init(dossier.path);
    await Hive.openBox<dynamic>('reglages');
    await Hive.openBox<dynamic>('historique');
    await initializeDateFormatting('fr_FR');
  });

  testWidgets('l\'écran principal affiche les cinq onglets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeFlow.clair(),
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const EcranPrincipal(),
        ),
      ),
    );
    // Les apparitions sont lentes : on laisse le temps aux fondus.
    await tester.pump(const Duration(seconds: 3));

    // Chaque libellé d'onglet est présent (les écrans restant montés
    // dans la pile fondue, certains textes existent aussi en titre).
    expect(find.text('Accueil'), findsAtLeastNWidgets(1));
    expect(find.text('Respirer'), findsAtLeastNWidgets(1));
    expect(find.text('Séances'), findsAtLeastNWidgets(1));
    expect(find.text('Sons'), findsAtLeastNWidgets(1));
    expect(find.text('Suivi'), findsAtLeastNWidgets(1));

    // Navigation vers l'onglet Respirer (le libellé de la barre basse
    // est le dernier dans l'arbre).
    await tester.tap(find.text('Respirer').last);
    await tester.pump(const Duration(seconds: 2));
    // Les rythmes proposés sont visibles en tête de liste.
    expect(find.text('Cohérence cardiaque'), findsWidgets);
    expect(find.text('Respiration 4-7-8'), findsWidgets);
  });
}
