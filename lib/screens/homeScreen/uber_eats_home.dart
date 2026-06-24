import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomade_client/theme/app_colors.dart';
import 'package:nomade_client/widgets/velox_network_image.dart';

/// Page d'accueil façon Uber Eats (barre d'adresse, recherche, catégories,
/// filtres, cartes restos et plats), branchée sur le thème VELOX et le panier.
class UberEatsHome extends ConsumerWidget {
  final AppColors c;
  final String firstName;
  final bool locationOff;
  final VoidCallback onRequestLocation;
  final VoidCallback onOpenRestaurants;
  final void Function(String category) onOpenCategory;
  final VoidCallback onGoTaxi;
  final VoidCallback onOpenProfile;
  final Widget? servicesSection;
  final Widget? statsSection;
  final void Function(
    String name,
    int price,
    String resto,
    String restaurantId,
    String imageUrl,
    String description,
  ) onAddDish;

  const UberEatsHome({
    super.key,
    required this.c,
    required this.firstName,
    required this.locationOff,
    required this.onRequestLocation,
    required this.onOpenRestaurants,
    required this.onOpenCategory,
    required this.onGoTaxi,
    required this.onOpenProfile,
    required this.onAddDish,
    this.servicesSection,
    this.statsSection,
  });

  static String _u(String id) =>
      'https://images.unsplash.com/photo-$id?w=400&q=70&auto=format&fit=crop';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(),
          _searchBar(),
          if (locationOff) _locationBanner(),
          const SizedBox(height: 6),
          _categories(),
          _promo(),
          if (servicesSection != null) servicesSection!,
          if (statsSection != null) statsSection!,
          _sectionHeader('Populaires près de chez vous'),
          _restaurantRail(),
          _sectionHeader('Tendances à Djibouti'),
          ..._dishes.asMap().entries.map((e) => _dishRow(e.value, e.key)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Barre d'adresse + avatar ───────────────────────────────────
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Image.asset('assets/images/logo-velox1.png', height: 40),
          const Spacer(),
          GestureDetector(
            onTap: onOpenProfile,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceHigh,
                border: Border.all(
                    color: c.primary.withValues(alpha: 0.4), width: 2),
              ),
              child: Icon(Icons.person, color: c.primary, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recherche ──────────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GestureDetector(
        onTap: onOpenRestaurants,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.surfaceLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: c.onSurfaceVariant, size: 22),
              const SizedBox(width: 10),
              Text(
                'Plat, restaurant, cuisine…',
                style: TextStyle(color: c.onSurfaceVariant, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bandeau localisation (si GPS coupé) ────────────────────────
  Widget _locationBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5B800),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active ta localisation',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                  'Pour une livraison précise et sans confusion.',
                  style:
                      TextStyle(color: Colors.black87, fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onRequestLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Partager la position',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.warning_amber_rounded,
              color: Colors.white, size: 58),
        ],
      ),
    );
  }

  // ── Catégories (pastilles horizontales) ────────────────────────
  Widget _categories() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          return GestureDetector(
            onTap: () => onOpenCategory(cat.label),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: c.surfaceLow,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: c.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: VeloxNetworkImage(_u(cat.imageId),
                      width: 60, height: 60),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                      color: c.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Filtres (chips horizontales) ───────────────────────────────
  // ── Bannière promo ─────────────────────────────────────────────
  Widget _promo() {
    return GestureDetector(
      onTap: onOpenRestaurants,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [c.primary, c.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Livraison offerte',
                      style: TextStyle(
                          color: c.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Sur ta première commande VELOX',
                      style: TextStyle(
                          color: c.onPrimary.withValues(alpha: 0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.delivery_dining,
                color: c.onPrimary.withValues(alpha: 0.9), size: 56),
          ],
        ),
      ),
    );
  }

  // ── En-tête de section ─────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  color: c.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          GestureDetector(
            onTap: onOpenRestaurants,
            child: Text('Voir tout',
                style: TextStyle(
                    color: c.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Carrousel de restos (grandes cartes) ───────────────────────
  Widget _restaurantRail() {
    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _dishes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final d = _dishes[i];
          return GestureDetector(
            onTap: onOpenRestaurants,
            child: SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: VeloxNetworkImage(
                          _u(d.imageId),
                          width: 260,
                          height: 150,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Livraison offerte',
                              style: TextStyle(
                                  color: c.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(d.resto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.surfaceLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: c.primary, size: 13),
                            const SizedBox(width: 2),
                            Text(d.rating.toString(),
                                style: TextStyle(
                                    color: c.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${d.minutes} min · ${d.fee == 0 ? "Gratuit" : "${d.fee} FDJ"}',
                          style: TextStyle(
                              color: c.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Ligne plat façon Uber Eats (image + infos + bouton +) ──────
  Widget _dishRow(_UDish d, int i) {
    final priceInt = d.price;
    return GestureDetector(
      onTap: () => onAddDish(d.name, priceInt, d.resto, d.restaurantId,
          _u(d.imageId), d.desc),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VeloxNetworkImage(
                _u(d.imageId),
                width: 92,
                height: 92,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(d.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onSurfaceVariant,
                          fontSize: 12.5,
                          height: 1.3)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('$priceInt FDJ',
                          style: TextStyle(
                              color: c.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 10),
                      Icon(Icons.star, color: c.primary, size: 13),
                      const SizedBox(width: 2),
                      Text(d.rating.toString(),
                          style: TextStyle(
                              color: c.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_rounded, color: c.onPrimary, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carte taxi (bonus, on garde le service VTC) ────────────────
  Widget _taxiCard() {
    return GestureDetector(
      onTap: onGoTaxi,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.surfaceLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.local_taxi_rounded, color: c.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Besoin d\'une course ?',
                      style: TextStyle(
                          color: c.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Réserve un taxi VELOX en quelques secondes',
                      style: TextStyle(
                          color: c.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: c.onSurfaceVariant, size: 16),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DONNÉES
// ═══════════════════════════════════════════════════════════════

class _Cat {
  final String imageId;
  final String label;
  const _Cat(this.imageId, this.label);
}

const _cats = [
  _Cat('1513104890138-7c749659a591', 'Pizza'),
  _Cat('1599974579688-8dbdd335c77f', 'Tacos'),
  _Cat('1568901346375-23c9450c58cd', 'Burgers'),
  _Cat('1630877265928-abc0c39186aa', 'Healthy'),
  _Cat('1626700051175-6818013e1d4f', 'Grillades'),
  _Cat('1716956755600-4d32af2b8f87', 'Boissons'),
];

class _UDish {
  final String name;
  final String resto;
  final int price;
  final double rating;
  final String imageId;
  final String restaurantId;
  final String desc;
  final int minutes;
  final int fee;
  const _UDish(this.name, this.resto, this.price, this.rating, this.imageId,
      this.restaurantId, this.desc, this.minutes, this.fee);
}

const _dishes = [
  _UDish('Pizza Margherita', 'Pizza Palace', 1800, 4.7, '1513104890138-7c749659a591',
      'seed-pizzapalace', 'Tomate, mozzarella et basilic frais', 25, 0),
  _UDish('Tacos Poulet', 'Tacos City', 1200, 4.6, '1599974579688-8dbdd335c77f',
      'seed-chezayan', 'Poulet grillé, légumes et sauce maison', 20, 300),
  _UDish('Wrap Falafel', 'Healthy Corner', 1000, 4.8, '1562059390-a761a084768e',
      'seed-bunnacorner', 'Falafel, crudités et sauce tahini', 30, 0),
  _UDish('Burrito Bœuf', 'Mexico Djib', 1500, 4.5, '1731090389603-d63060ee08a6', 'seed-tadjoura',
      'Bœuf épicé, riz, haricots et fromage', 35, 400),
  _UDish('Skoudehkaris', 'Saveurs d\'Afar', 1600, 4.9, '1626700051175-6818013e1d4f', 'seed-afar',
      'Riz épicé traditionnel mijoté au bœuf', 30, 200),
  _UDish('Jus de mangue', 'Fruity', 400, 4.6, '1716956755600-4d32af2b8f87', 'seed-mandeb',
      'Jus de mangue fraîchement pressé', 15, 0),
];
