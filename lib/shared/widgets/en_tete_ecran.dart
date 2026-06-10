import 'package:flutter/material.dart';

import 'apparition.dart';

/// En-tête commun des écrans : grand titre calligraphique,
/// sous-titre discret, beaucoup d'espace.
class EnTeteEcran extends StatelessWidget {
  const EnTeteEcran({
    super.key,
    required this.titre,
    this.sousTitre,
    this.action,
  });

  final String titre;
  final String? sousTitre;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    return Apparition(
      enfant: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: typo.displaySmall),
                  if (sousTitre != null) ...[
                    const SizedBox(height: 8),
                    Text(sousTitre!, style: typo.bodyMedium),
                  ],
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
