// ════════════════════════════════════════════════════════════════════════════
//  VELOX — Section "Populaire à Djibouti" (drop-in)
//  À placer dans : lib/screens/homeScreen/components/djibouti_dishes.dart
//
//  Insertion dans home_screen_app.dart -> _buildHomePage(...), ex. juste après
//  _buildLoyaltyCard(c) :
//
//      DjiboutiDishes(c: c),
//
//  (importer : import 'components/djibouti_dishes.dart';)
//
//  ⚠️ Les images sont chargées depuis un service de photos par mot-clé
//  (placeholder réaliste). Pour la prod, remplace les `image` par tes vraies
//  photos (assets locaux ou URLs Firestore de tes restaurants).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nomade_client/theme/app_colors.dart';

class _Dish {
  final String name, resto, price, query, restaurantId;
  final double rating;
  const _Dish(this.name, this.resto, this.price, this.rating, this.query,
      this.restaurantId);
}

class DjiboutiDishes extends StatelessWidget {
  const DjiboutiDishes({super.key, required this.c, this.onOpenResto, this.onAdd});
  final AppColors c;
  // Ouvre la fiche du restaurant seedé correspondant au plat.
  final void Function(String restaurantId)? onOpenResto;
  // (nom, prix DJF, restaurant, restaurantId, imageUrl)
  final void Function(String name, int price, String restaurant,
      String restaurantId, String imageUrl)? onAdd;

  static const _dishes = <_Dish>[
    _Dish('Pizza Margherita', 'Pizza Palace', '1 800', 4.7, 'pizza', 'seed-pizzapalace'),
    _Dish('Tacos Poulet', 'Tacos City', '1 200', 4.6, 'tacos,food', 'seed-ayan'),
    _Dish('Wrap Falafel', 'Healthy Corner', '1 000', 4.8, 'wrap,sandwich', 'seed-bunna'),
    _Dish('Burrito Bœuf', 'Mexico Djib', '1 500', 4.5, 'burrito', 'seed-tadjoura'),
    _Dish('Skoudehkaris', 'Saveurs d\'Afar', '1 600', 4.9, 'rice,meat', 'seed-afar'),
    _Dish('Jus de mangue', 'Fruity', '400', 4.6, 'mango,juice', 'seed-mandeb'),
  ];

  String _img(String q, int lock) =>
      'https://loremflickr.com/320/240/$q?lock=$lock';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Populaire à Djibouti',
                  style: GoogleFonts.spaceGrotesk(
                      color: c.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
              Text('Voir tout',
                  style: TextStyle(
                      color: c.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _dishes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _card(_dishes[i], i),
          ),
        ),
      ],
    );
  }

  Widget _card(_Dish d, int i) {
    return GestureDetector(
      onTap: () => onOpenResto?.call(d.restaurantId),
      child: Container(
        width: 168,
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                _img(d.query, 10 + i),
                width: 168,
                height: 110,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, prog) => prog == null
                    ? child
                    : Container(
                        width: 168,
                        height: 110,
                        color: c.surfaceLow,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: c.primary),
                          ),
                        ),
                      ),
                errorBuilder: (ctx, err, st) => Container(
                  width: 168,
                  height: 110,
                  color: c.surfaceLow,
                  child: Icon(Icons.restaurant_rounded,
                      color: c.onSurfaceVariant, size: 30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC24A), size: 14),
                      const SizedBox(width: 3),
                      Text('${d.rating}',
                          style: TextStyle(
                              color: c.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text('  ·  ${d.resto}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: c.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${d.price} DJF',
                          style: GoogleFonts.spaceGrotesk(
                              color: c.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      GestureDetector(
                        onTap: () => onAdd?.call(
                          d.name,
                          int.tryParse(d.price.replaceAll(' ', '')) ?? 1000,
                          d.resto,
                          d.restaurantId,
                          _img(d.query, 700),
                        ),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add_rounded,
                              color: c.onPrimary, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
