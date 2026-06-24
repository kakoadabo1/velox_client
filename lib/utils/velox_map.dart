import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import '../providers/low_data_notifier.dart';

/// Couche de tuiles VELOX (Voyager), optimisée.
/// En mode faible data : renvoie une liste vide → aucune tuile téléchargée
/// (la carte affiche juste le fond + marqueurs + tracé).
List<Widget> veloxBaseLayers(WidgetRef ref) {
  final lowData = ref.watch(lowDataModeProvider);
  if (lowData) return const [];
  return [
    TileLayer(
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      subdomains: const ['a', 'b', 'c', 'd'],
      userAgentPackageName: 'dj.velox.client',
      keepBuffer: 6,
      panBuffer: 2,
      tileDisplay: const TileDisplay.instantaneous(),
    ),
  ];
}
