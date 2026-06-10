import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/mixeur_audio.dart';
import 'core/services/notifications_service.dart';
import 'core/services/stockage_service.dart';
import 'core/theme/theme_flow.dart';
import 'features/home/presentation/ecran_principal.dart';
import 'features/settings/logic/reglages_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // L'interface s'étend sous les barres système, pour un fond continu.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Services initialisés avant le premier rendu : stockage, dates
  // en français, audio en arrière-plan, notifications.
  await StockageService.initialiser();
  await initializeDateFormatting('fr_FR');
  final MixeurAudioHandler mixeur = await initialiserAudio();
  final NotificationsService notifications = NotificationsService();
  await notifications.initialiser();

  runApp(
    ProviderScope(
      overrides: [
        mixeurAudioProvider.overrideWithValue(mixeur),
        notificationsProvider.overrideWithValue(notifications),
      ],
      child: const AppFlow(),
    ),
  );
}

/// Racine de l'application : thèmes clair/sombre et écran principal.
class AppFlow extends ConsumerWidget {
  const AppFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode =
        ref.watch(reglagesProvider.select((r) => r.modeTheme));

    return MaterialApp(
      title: 'Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeFlow.clair(),
      darkTheme: ThemeFlow.sombre(),
      themeMode: mode,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const EcranPrincipal(),
    );
  }
}
