import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomade_client/theme/app_colors.dart';
import 'package:nomade_client/providers/all_providers.dart';
import 'package:nomade_client/widgets/velox_network_image.dart';
import 'package:nomade_client/models/restaurant.dart';
import 'package:nomade_client/models/menu_item.dart';
import 'package:nomade_client/screens/food/addToOrder/add_to_order_screen.dart';

/// Écran de restaurants SIMULÉS (données locales) avec de vraies photos de
/// plats exactes (CDN Unsplash). Filtrable par catégorie. Aucun appel réseau
/// Firestore : tout est local pour la démo. Le tap sur un plat ouvre
/// AddToOrderScreen avec un Restaurant/MenuItem construit à la volée.
class RestaurantsBrowseScreen extends ConsumerWidget {
  final String? category;
  const RestaurantsBrowseScreen({super.key, this.category});

  static String _u(String id) =>
      'https://images.unsplash.com/photo-$id?w=600&q=70&auto=format&fit=crop';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider).isDarkMode;
    final c = isDark ? AppColors.dark : AppColors.light;

    final cat = category;
    final filtered = (cat == null)
        ? _restos
        : _restos
            .where((r) => r.tags.any((t) => t.toLowerCase() == cat.toLowerCase()))
            .toList();
    final shown = filtered.isEmpty ? _restos : filtered;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          cat ?? 'Restaurants',
          style: TextStyle(
            color: c.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: shown.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (_, i) => _restoCard(context, c, shown[i]),
      ),
    );
  }

  // ── Carte restaurant (header + liste de plats) ────────────────────────────
  Widget _restoCard(BuildContext context, AppColors c, _Resto r) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Stack(
            children: [
              VeloxNetworkImage(_u(r.headerId),
                  width: double.infinity, height: 140),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: c.onPrimary, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        r.rating.toStringAsFixed(1),
                        style: TextStyle(
                            color: c.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: TextStyle(
                      color: c.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 17),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        color: c.onSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text('${r.minutes} min',
                        style: TextStyle(
                            color: c.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(width: 12),
                    Icon(Icons.pedal_bike_rounded,
                        color: c.onSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text(r.fee == 0 ? 'Gratuit' : '${r.fee} FDJ',
                        style: TextStyle(
                            color: r.fee == 0 ? c.primary : c.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // plats
          ...r.dishes.map((d) => _dishRow(context, c, r, d)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _dishRow(BuildContext context, AppColors c, _Resto r, _RDish d) {
    return InkWell(
      onTap: () => _openDish(context, r, d),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VeloxNetworkImage(_u(d.imageId), width: 72, height: 72),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      style: TextStyle(
                          color: c.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(d.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${d.price} FDJ',
                      style: TextStyle(
                          color: c.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration:
                  BoxDecoration(color: c.primary, shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: c.onPrimary, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  void _openDish(BuildContext context, _Resto r, _RDish d) {
    final now = DateTime.now();
    final restaurant = Restaurant(
      id: r.id,
      name: r.name,
      address: 'Djibouti-ville',
      description: '',
      email: '',
      phone: '',
      imageUrl: _u(r.headerId),
      latitude: 11.5721,
      longitude: 43.1456,
      createdAt: now,
    );
    final menuItem = MenuItem(
      id: 'demo-${d.name}',
      restaurantId: r.id,
      name: d.name,
      description: d.desc,
      price: d.price.toDouble(),
      imageUrl: _u(d.imageId),
      category: 'Plats',
      createdAt: now,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddToOrderScreen(menuItem: menuItem, restaurant: restaurant),
      ),
    );
  }
}

// ── Données simulées (images Unsplash exactes par plat) ─────────────────────
class _RDish {
  final String name;
  final int price;
  final String imageId;
  final String desc;
  const _RDish(this.name, this.price, this.imageId, this.desc);
}

class _Resto {
  final String id;
  final String name;
  final String headerId;
  final double rating;
  final int minutes;
  final int fee;
  final List<String> tags;
  final List<_RDish> dishes;
  const _Resto(this.id, this.name, this.headerId, this.rating, this.minutes,
      this.fee, this.tags, this.dishes);
}

// IDs photo confirmés (chaque image correspond au plat exact)
const _pizza = '1513104890138-7c749659a591';
const _pizza2 = '1565299624946-b28f40a0ae38';
const _tacos = '1599974579688-8dbdd335c77f';
const _tacos2 = '1624300629298-e9de39c13be5';
const _burger = '1568901346375-23c9450c58cd';
const _burger2 = '1586190848861-99aa4a171e90';
const _burrito = '1731090389603-d63060ee08a6';
const _rice = '1626700051175-6818013e1d4f';
const _wrap = '1562059390-a761a084768e';
const _salad = '1630877265928-abc0c39186aa';
const _mango = '1716956755600-4d32af2b8f87';

const _restos = [
  _Resto(
    'sim-pizzapalace',
    'Pizza Palace',
    _pizza,
    4.7,
    25,
    0,
    ['Pizza'],
    [
      _RDish('Pizza Margherita', 1800, _pizza,
          'Tomate, mozzarella et basilic frais'),
      _RDish('Pizza Reine', 2000, _pizza2,
          'Jambon, champignons et mozzarella'),
      _RDish('Salade César', 1200, _salad,
          'Salade, poulet grillé, parmesan et croûtons'),
    ],
  ),
  _Resto(
    'sim-tacoscity',
    'Tacos City',
    _tacos,
    4.6,
    20,
    300,
    ['Tacos'],
    [
      _RDish('Tacos Poulet', 1200, _tacos,
          'Poulet grillé, légumes et sauce maison'),
      _RDish('Tacos Bœuf', 1300, _tacos2,
          'Bœuf épicé, oignons et coriandre'),
      _RDish('Burrito Bœuf', 1500, _burrito,
          'Bœuf épicé, riz, haricots et fromage'),
    ],
  ),
  _Resto(
    'sim-burgerhouse',
    'Burger House',
    _burger,
    4.5,
    30,
    400,
    ['Burgers'],
    [
      _RDish('Cheeseburger', 1500, _burger,
          'Steak, cheddar, salade et tomate'),
      _RDish('Double Burger', 2200, _burger2,
          'Double steak, double fromage, sauce maison'),
      _RDish('Wrap Poulet', 1100, _wrap,
          'Poulet pané, crudités et sauce'),
    ],
  ),
  _Resto(
    'sim-healthycorner',
    'Healthy Corner',
    _salad,
    4.8,
    25,
    0,
    ['Healthy', 'Boissons'],
    [
      _RDish('Buddha Bowl', 1600, _salad,
          'Quinoa, avocat, pois chiches et légumes'),
      _RDish('Wrap Falafel', 1000, _wrap,
          'Falafel, crudités et sauce tahini'),
      _RDish('Jus de mangue', 400, _mango,
          'Jus de mangue fraîchement pressé'),
    ],
  ),
  _Resto(
    'sim-saveursafar',
    "Saveurs d'Afar",
    _rice,
    4.9,
    30,
    200,
    ['Grillades', 'Boissons'],
    [
      _RDish('Skoudehkaris', 1600, _rice,
          'Riz épicé traditionnel mijoté au bœuf'),
      _RDish('Grillades mixtes', 2500, _tacos2,
          'Assortiment de viandes grillées et riz'),
      _RDish('Jus de mangue', 400, _mango,
          'Jus de mangue fraîchement pressé'),
    ],
  ),
];
