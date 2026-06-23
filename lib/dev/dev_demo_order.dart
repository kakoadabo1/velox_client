// ════════════════════════════════════════════════════════════════════════
//  VELOX — Création d'une COMMANDE DE DÉMO (outil de démo)
//  À placer dans : lib/dev/dev_demo_order.dart
//
//  Crée une commande valide (statut 'pending') que le DemoSimulator fait
//  ensuite défiler automatiquement (confirmée → préparation → ... → livrée).
//  Renvoie l'orderId pour ouvrir l'écran de suivi.
// ════════════════════════════════════════════════════════════════════════
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> createDemoOrder({
  required String name,
  required int price,
  String restaurant = 'Resto démo',
  String restaurantId = 'seed-demo',
  String imageUrl = '',
  String category = 'Plats',
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final db = FirebaseFirestore.instance;
  final ts = FieldValue.serverTimestamp();
  const deliveryFee = 200;

  final item = {
    'menuId': 'demo-$name',
    'name': name,
    'description': 'Article de démo',
    'imageUrl': imageUrl,
    'category': category,
    'basePrice': price,
    'quantity': 1,
    'extras': <Map<String, dynamic>>[],
    'sauces': <Map<String, dynamic>>[],
    'extrasTotal': 0,
    'saucesTotal': 0,
    'unitPrice': price,
    'totalPrice': price,
  };

  final ref = await db.collection('orders').add({
    'userId': user.uid,
    'restaurantId': restaurantId,
    'restaurantName': restaurant,
    'restaurantImageUrl': imageUrl,
    'customerName': user.displayName ?? 'Client',
    'customerPhone': user.phoneNumber ?? '',
    'items': [item],
    'itemCount': 1,
    'subtotal': price,
    'deliveryFee': deliveryFee,
    'pointsUsed': 0,
    'discount': 0,
    'total': price + deliveryFee,
    'status': 'pending',
    'paymentMethod': 'cash',
    'deliveryAddress': 'Djibouti-ville (démo)',
    'deliveryLocation': const GeoPoint(11.5950, 43.1400),
    'createdAt': ts,
    'updatedAt': ts,
  });

  return ref.id;
}
