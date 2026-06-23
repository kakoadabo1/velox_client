// ════════════════════════════════════════════════════════════════════════
//  VELOX — Seeder de DÉMONSTRATION (à exécuter UNE fois, puis retirer)
//  À placer dans : lib/dev/dev_seed.dart
//
//  Crée 4 restaurants + leurs plats dans Firestore (collections
//  `restaurants` et `menuItems`). Idempotent : IDs fixes -> relancer
//  écrase au lieu de dupliquer.
//
//  ⚠️ Nécessite des règles Firestore autorisant TEMPORAIREMENT l'écriture
//  sur `restaurants` et `menuItems` (voir instructions). À reverrouiller
//  après le seed.
// ════════════════════════════════════════════════════════════════════════
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> runVeloxSeed() async {
  final db = FirebaseFirestore.instance;
  final ts = FieldValue.serverTimestamp();

  Future<void> resto(String id, Map<String, dynamic> data) {
    return db.collection('restaurants').doc(id).set({
      ...data,
      'isActive': true,
      'isOpen': true,
      'totalRevenue': 0.0,
      'createdAt': ts,
      'updatedAt': ts,
    });
  }

  Future<void> item(String id, String restaurantId, String name,
      String desc, double price, String category, String img,
      [List<Map<String, dynamic>> opts = const []]) {
    return db.collection('menuItems').doc(id).set({
      'restaurantId': restaurantId,
      'name': name,
      'description': desc,
      'price': price,
      'imageUrl': img,
      'category': category,
      'isAvailable': true,
      'preparationTime': 20,
      'discountPercentage': 0,
      'optionGroups': opts,
      'createdAt': ts,
      'updatedAt': ts,
    });
  }

  String img(String q, int lock) => 'https://loremflickr.com/600/400/$q?lock=$lock';

  // Helper pour construire un groupe de suppléments.
  Map<String, dynamic> grp(
          String name, String type, bool req, List<List<dynamic>> ch) =>
      {
        'name': name,
        'type': type,
        'required': req,
        'choices': ch.map((c) => {'name': c[0], 'price': c[1]}).toList(),
      };
  final pizzaSize = grp('Taille', 'single', true, [
    ['Moyenne', 0],
    ['Grande', 500],
  ]);
  final pizzaExtras = grp('Suppléments', 'multiple', false, [
    ['Fromage extra', 200],
    ['Champignons', 150],
    ['Olives', 100],
    ['Piment', 0],
  ]);
  final grillCuisson = grp('Cuisson', 'single', true, [
    ['À point', 0],
    ['Bien cuit', 0],
    ['Saignant', 0],
  ]);
  final grillSauces = grp('Sauces', 'multiple', false, [
    ['Harissa', 0],
    ['Ail', 100],
    ['Yaourt', 100],
  ]);
  final burgerExtras = grp('Suppléments', 'multiple', false, [
    ['Bacon', 200],
    ['Œuf', 150],
    ['Cheddar', 150],
    ['Frites', 500],
  ]);
  final drinkChoice = grp('Boisson', 'single', false, [
    ['Sans', 0],
    ['Eau', 200],
    ['Soda', 300],
  ]);

  // ───────── 1. Pizza Palace ─────────
  await resto('seed-pizzapalace', {
    'name': 'Pizza Palace',
    'address': 'Avenue 13, Djibouti-ville',
    'description': 'Pizzas au feu de bois, pâtes et plats italiens.',
    'email': 'contact@pizzapalace.dj',
    'phone': '+25377100001',
    'imageUrl': img('pizza,restaurant', 701),
    'latitude': 11.5721, 'longitude': 43.1456,
    'rating': 4.6, 'totalOrders': 120,
  });
  await item('seed-pp-1', 'seed-pizzapalace', 'Pizza Margherita',
      'Tomate, mozzarella, basilic frais', 1800, 'Pizzas', img('pizza,margherita', 711),
      [pizzaSize, pizzaExtras]);
  await item('seed-pp-2', 'seed-pizzapalace', 'Pizza Reine',
      'Jambon, champignons, mozzarella', 2000, 'Pizzas', img('pizza,ham', 712),
      [pizzaSize, pizzaExtras]);
  await item('seed-pp-3', 'seed-pizzapalace', 'Pizza 4 Fromages',
      'Mozzarella, chèvre, bleu, parmesan', 2200, 'Pizzas', img('pizza,cheese', 713),
      [pizzaSize, pizzaExtras]);
  await item('seed-pp-4', 'seed-pizzapalace', 'Tiramisu',
      'Dessert italien au café', 800, 'Desserts', img('tiramisu,dessert', 714));

  // ───────── 2. Chez Ayan ─────────
  await resto('seed-chezayan', {
    'name': 'Chez Ayan',
    'address': 'Quartier 7, Djibouti-ville',
    'description': 'Burgers gourmands et grillades maison.',
    'email': 'contact@chezayan.dj',
    'phone': '+25377100002',
    'imageUrl': img('burger,restaurant', 702),
    'latitude': 11.5890, 'longitude': 43.1480,
    'rating': 4.7, 'totalOrders': 200,
  });
  await item('seed-ca-1', 'seed-chezayan', 'Burger Velox',
      'Bœuf, cheddar, sauce maison', 1100, 'Burgers', img('burger', 721),
      [burgerExtras, drinkChoice]);
  await item('seed-ca-2', 'seed-chezayan', 'Double Bœuf',
      'Deux steaks, double fromage', 1700, 'Burgers', img('burger,double', 722),
      [burgerExtras, drinkChoice]);
  await item('seed-ca-3', 'seed-chezayan', 'Poulet Croustillant',
      'Filet de poulet pané, salade', 1300, 'Burgers', img('chicken,burger', 723),
      [burgerExtras, drinkChoice]);
  await item('seed-ca-4', 'seed-chezayan', 'Frites maison',
      'Frites fraîches et croustillantes', 500, 'Accompagnements', img('fries', 724));

  // ───────── 3. Bunna Corner ─────────
  await resto('seed-bunnacorner', {
    'name': 'Bunna Corner',
    'address': 'Place Menelik, Djibouti-ville',
    'description': 'Café de spécialité, pâtisseries et boissons fraîches.',
    'email': 'contact@bunnacorner.dj',
    'phone': '+25377100003',
    'imageUrl': img('coffee,cafe', 703),
    'latitude': 11.5950, 'longitude': 43.1400,
    'rating': 4.9, 'totalOrders': 90,
  });
  await item('seed-bc-1', 'seed-bunnacorner', 'Café + Viennoiserie',
      'Café filtre et croissant beurre', 900, 'Café', img('coffee,croissant', 731));
  await item('seed-bc-2', 'seed-bunnacorner', 'Cappuccino',
      'Espresso et mousse de lait', 600, 'Café', img('cappuccino', 732));
  await item('seed-bc-3', 'seed-bunnacorner', 'Cheesecake',
      'Part de cheesecake maison', 1000, 'Desserts', img('cheesecake', 733));
  await item('seed-bc-4', 'seed-bunnacorner', 'Jus de mangue',
      'Mangue fraîche pressée', 400, 'Boissons', img('mango,juice', 734));

  // ───────── 4. Saveurs d'Afar ─────────
  await resto('seed-afar', {
    'name': "Saveurs d'Afar",
    'address': 'Quartier 4, Djibouti-ville',
    'description': 'Cuisine traditionnelle djiboutienne.',
    'email': 'contact@saveursafar.dj',
    'phone': '+25377100004',
    'imageUrl': img('rice,food', 704),
    'latitude': 11.5800, 'longitude': 43.1500,
    'rating': 4.8, 'totalOrders': 150,
  });
  await item('seed-af-1', 'seed-afar', 'Skoudehkaris',
      'Riz épicé au mouton, plat traditionnel', 1600, 'Plats', img('rice,meat', 741));
  await item('seed-af-2', 'seed-afar', 'Riz au poisson',
      'Riz parfumé et poisson grillé', 1700, 'Plats', img('rice,fish', 742));
  await item('seed-af-3', 'seed-afar', 'Fah-fah',
      'Soupe de viande épicée', 1400, 'Plats', img('soup,meat', 743));
  await item('seed-af-4', 'seed-afar', 'Sambousa',
      'Beignets croustillants à la viande', 600, 'Entrées', img('samosa', 744));

  // ───────── 5. Le Mandeb ─────────
  await resto('seed-mandeb', {
    'name': 'Le Mandeb',
    'address': 'Bord de mer, Djibouti-ville',
    'description': 'Poissons frais et fruits de mer.',
    'email': 'contact@lemandeb.dj',
    'phone': '+25377100005',
    'imageUrl': img('seafood,fish', 705),
    'latitude': 11.6010, 'longitude': 43.1480,
    'rating': 4.5, 'totalOrders': 80,
  });
  await item('seed-md-1', 'seed-mandeb', 'Poisson grillé',
      'Poisson du jour grillé, riz', 1900, 'Plats', img('grilled,fish', 751));
  await item('seed-md-2', 'seed-mandeb', 'Crevettes sautées',
      'Crevettes à l\'ail et citron', 2300, 'Plats', img('shrimp', 752));
  await item('seed-md-3', 'seed-mandeb', 'Calamars frits',
      'Calamars croustillants, sauce', 2000, 'Entrées', img('calamari,fried', 753));
  await item('seed-md-4', 'seed-mandeb', 'Riz au poisson',
      'Riz parfumé et poisson', 1700, 'Plats', img('rice,fish', 754));

  // ───────── 6. Tadjoura Grill ─────────
  await resto('seed-tadjoura', {
    'name': 'Tadjoura Grill',
    'address': 'Quartier 5, Djibouti-ville',
    'description': 'Grillades et brochettes à la braise.',
    'email': 'contact@tadjouragrill.dj',
    'phone': '+25377100006',
    'imageUrl': img('grill,barbecue', 706),
    'latitude': 11.5700, 'longitude': 43.1420,
    'rating': 4.7, 'totalOrders': 110,
  });
  await item('seed-tg-1', 'seed-tadjoura', 'Brochettes d\'agneau',
      'Brochettes marinées à la braise', 1500, 'Grillades', img('lamb,skewer', 761),
      [grillCuisson, grillSauces]);
  await item('seed-tg-2', 'seed-tadjoura', 'Poulet grillé',
      'Demi-poulet grillé, épices', 1400, 'Grillades', img('grilled,chicken', 762),
      [grillCuisson, grillSauces]);
  await item('seed-tg-3', 'seed-tadjoura', 'Côtelettes',
      'Côtelettes d\'agneau grillées', 1800, 'Grillades', img('lamb,chops', 763),
      [grillCuisson, grillSauces]);
  await item('seed-tg-4', 'seed-tadjoura', 'Salade fraîche',
      'Crudités de saison', 700, 'Accompagnements', img('salad,fresh', 764));

  return '✅ 6 restaurants + 24 plats créés dans Firestore';
}
