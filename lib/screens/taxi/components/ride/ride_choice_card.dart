import 'package:flutter/material.dart';
import 'package:nomade_client/models/ride_choice.dart';
import 'package:nomade_client/theme/app_colors.dart';

/// Carte de choix de véhicule — PNG conservé, bordure premium + pastille check.
class RideChoiceCard extends StatelessWidget {
  const RideChoiceCard({
    super.key,
    required this.ride,
    required this.onTap,
    required this.c,
    this.distance = 0.0,
    this.isSelected = false,
  });

  final RideChoice ride;
  final double distance; // 0 si pas de destination (affiche le prix de base)
  final VoidCallback onTap;
  final bool isSelected;
  final AppColors c;

  String get _image {
    switch (ride.type) {
      case RideType.comfort:
        return 'assets/vehicule/taxi-A.png';
      case RideType.standard:
        return 'assets/vehicule/taxi-B.png';
      default:
        return 'assets/vehicule/taxi-A.png';
    }
  }

  bool get _popular => ride.type == RideType.comfort;

  @override
  Widget build(BuildContext context) {
    final price = distance > 0 ? ride.calculatePrice(distance) : ride.basePrice;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
        decoration: BoxDecoration(
          color: isSelected ? c.primary.withValues(alpha: 0.12) : c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? c.primary
                : c.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bandeau "Populaire" (Confort) — réserve la même hauteur ailleurs
                if (_popular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Populaire',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: c.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 23),

                // Image PNG du véhicule
                SizedBox(
                  height: 46,
                  child: Image.asset(
                    _image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.local_taxi_rounded,
                      size: 34,
                      color: isSelected ? c.primary : c.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nom
                Text(
                  ride.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: c.onSurface,
                  ),
                ),
                const SizedBox(height: 3),

                // ETA + places
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: c.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      ride.estimatedArrivalTime ?? '—',
                      style:
                          TextStyle(fontSize: 11, color: c.onSurfaceVariant),
                    ),
                    const SizedBox(width: 7),
                    Icon(Icons.person_rounded,
                        size: 11, color: c.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      '${ride.seats}',
                      style:
                          TextStyle(fontSize: 11, color: c.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 7),

                // Prix
                Text(
                  '${price.toStringAsFixed(0)} FDJ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? c.primary : c.onSurface,
                  ),
                ),
              ],
            ),

            // Innovation : pastille check quand sélectionné
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 15, color: c.onPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
