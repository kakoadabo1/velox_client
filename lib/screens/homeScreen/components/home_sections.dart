// ════════════════════════════════════════════════════════════════════════
//  VELOX — Sections d'accueil "food app" (promo + catégories + carrousel)
//  À placer dans : lib/screens/homeScreen/components/home_sections.dart
//
//  Insertion dans home_screen_app.dart -> _buildHomePage(...) :
//    VeloxPromoBanner(c: c, onTap: _goToRestaurants),
//    VeloxCategories(c: c, onOpen: _goToRestaurants),
//    VeloxRestaurantCarousel(c: c, onOpen: _goToRestaurants),
//
//  ⚠️ Images = placeholders (service par mot-clé). En prod, remplace par tes
//  vraies photos restaurants (Firestore/assets).
// ════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nomade_client/theme/app_colors.dart';

// ───────────────────────── BANNIÈRE PROMO ─────────────────────────
class VeloxPromoBanner extends StatelessWidget {
  const VeloxPromoBanner({super.key, required this.c, this.onTap});
  final AppColors c;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F3A1A), Color(0xFF0F1A0D)],
            ),
            border: Border.all(color: c.primary.withValues(alpha: 0.25)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                top: -14,
                child: Icon(Icons.bolt_rounded,
                    size: 120, color: c.primary.withValues(alpha: 0.14)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OFFRE DE BIENVENUE',
                      style: TextStyle(
                          color: c.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 220,
                    child: Text('−20% sur ta 1ère commande',
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 4),
                  Text('Code appliqué automatiquement au paiement',
                      style: TextStyle(
                          color: c.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Commander',
                            style: TextStyle(
                                color: c.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        const SizedBox(width: 4),
                        Icon(Icons.bolt_rounded, color: c.onPrimary, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── CATÉGORIES CLIQUABLES ─────────────────────────
class _Cat {
  final String label, query;
  const _Cat(this.label, this.query);
}

class VeloxCategories extends StatefulWidget {
  const VeloxCategories({super.key, required this.c, this.onOpen});
  final AppColors c;
  final VoidCallback? onOpen;

  @override
  State<VeloxCategories> createState() => _VeloxCategoriesState();
}

class _VeloxCategoriesState extends State<VeloxCategories> {
  int _selected = 0;

  static const _cats = <_Cat>[
    _Cat('Grill', 'grilled,chicken'),
    _Cat('Healthy', 'salad,healthy'),
    _Cat('Boulangerie', 'bread,bakery'),
    _Cat('Café', 'coffee,latte'),
    _Cat('Dessert', 'cake,dessert'),
    _Cat('Pizza', 'pizza'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Text('Catégories',
              style: GoogleFonts.spaceGrotesk(
                  color: c.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final cat = _cats[i];
              final on = i == _selected;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = i);
                  widget.onOpen?.call();
                },
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: on ? c.primary : c.outlineVariant,
                            width: on ? 2 : 1),
                        boxShadow: on
                            ? [
                                BoxShadow(
                                    color: c.primary.withValues(alpha: 0.18),
                                    blurRadius: 10,
                                    spreadRadius: 1)
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Image.network(
                          'https://loremflickr.com/120/120/${cat.query}?lock=${50 + i}',
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, ch, p) => p == null
                              ? ch
                              : Container(color: c.surfaceLow),
                          errorBuilder: (ctx, e, st) => Container(
                            color: c.surfaceLow,
                            child: Icon(Icons.restaurant_rounded,
                                color: c.onSurfaceVariant, size: 22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(cat.label,
                        style: TextStyle(
                            color: on ? c.onSurface : c.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight:
                                on ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── CARROUSEL RESTAURANTS ─────────────────────────
class _Resto {
  final String name, cuisine, time, dist, query;
  final double rating;
  const _Resto(
      this.name, this.cuisine, this.time, this.dist, this.rating, this.query);
}

class VeloxRestaurantCarousel extends StatelessWidget {
  const VeloxRestaurantCarousel({super.key, required this.c, this.onOpen});
  final AppColors c;
  final VoidCallback? onOpen;

  static const _restos = <_Resto>[
    _Resto('Chez Ayan', 'Burgers · Grill', '20–30 min', '1,2 km', 4.7,
        'burger,restaurant'),
    _Resto('Bunna Corner', 'Café · Pâtisserie', '15–25 min', '0,8 km', 4.9,
        'coffee,cafe'),
    _Resto('Pizza Palace', 'Pizza · Italien', '25–35 min', '2,0 km', 4.6,
        'pizza,restaurant'),
    _Resto('Saveurs d\'Afar', 'Traditionnel', '30–40 min', '2,5 km', 4.8,
        'rice,food'),
  ];

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
              Text('Restaurants populaires',
                  style: GoogleFonts.spaceGrotesk(
                      color: c.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
              GestureDetector(
                onTap: onOpen,
                child: Text('Voir tout',
                    style: TextStyle(
                        color: c.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _restos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _card(_restos[i], i),
          ),
        ),
      ],
    );
  }

  Widget _card(_Resto r, int i) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    'https://loremflickr.com/400/240/${r.query}?lock=${70 + i}',
                    width: 230,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, ch, p) =>
                        p == null ? ch : Container(height: 120, color: c.surfaceLow),
                    errorBuilder: (ctx, e, st) => Container(
                      height: 120,
                      color: c.surfaceLow,
                      child: Icon(Icons.storefront_rounded,
                          color: c.onSurfaceVariant, size: 30),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(r.time,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC24A), size: 14),
                      const SizedBox(width: 3),
                      Text('${r.rating}',
                          style: TextStyle(
                              color: c.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      Text('  ·  ${r.cuisine}  ·  ${r.dist}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: c.onSurfaceVariant, fontSize: 12)),
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
