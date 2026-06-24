import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/low_data_notifier.dart';

/// Image réseau qui se transforme en simple placeholder léger
/// quand le mode faible data est activé (aucun téléchargement).
class VeloxNetworkImage extends ConsumerWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const VeloxNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowData = ref.watch(lowDataModeProvider);
    if (lowData) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF2A2A2A),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: Color(0xFF6A6A6A), size: 30),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFF2A2A2A),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            color: Color(0xFF6A6A6A), size: 28),
      ),
    );
  }
}
