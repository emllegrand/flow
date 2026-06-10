import 'package:flutter/material.dart';

/// Carte douce de Flow : coins très arrondis, pas d'ombre dure,
/// réaction au toucher en fondu lent.
class CarteZen extends StatelessWidget {
  const CarteZen({
    super.key,
    required this.enfant,
    this.onTap,
    this.couleur,
    this.rembourrage = const EdgeInsets.all(24),
  });

  final Widget enfant;
  final VoidCallback? onTap;
  final Color? couleur;
  final EdgeInsetsGeometry rembourrage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final BorderRadius rayon = BorderRadius.circular(28);
    return Material(
      color: couleur ?? schema.surfaceContainerLow.withValues(alpha: 0.82),
      borderRadius: rayon,
      child: InkWell(
        onTap: onTap,
        borderRadius: rayon,
        child: Padding(padding: rembourrage, child: enfant),
      ),
    );
  }
}
