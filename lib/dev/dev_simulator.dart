// ════════════════════════════════════════════════════════════════════════
//  VELOX — Simulateur de DÉMO (mode test sans vrais chauffeurs/restaurants)
//  À placer dans : lib/dev/dev_simulator.dart
//
//  Joue le rôle du chauffeur ET du restaurant : dès que tu crées une course
//  ou une commande, il fait défiler automatiquement TOUS les statuts, pour
//  que tu voies tout le parcours de suivi côté Client.
//
//  Course   : requested → accepted → arriving → arrived → started → completed
//  Commande : pending → confirmed → preparing → ready → delivering → completed
//
//  Démarré depuis l'accueil (DemoSimulator.instance.ensureStarted()).
//  ⚠️ OUTIL DE DÉMO : à retirer (ou ne pas démarrer) pour la vraie prod,
//  où ce sont l'app Partenaire et les restaurants qui font évoluer les statuts.
// ════════════════════════════════════════════════════════════════════════
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DemoSimulator {
  DemoSimulator._();
  static final DemoSimulator instance = DemoSimulator._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Set<String> _handled = {};
  StreamSubscription? _ridesSub;
  StreamSubscription? _ordersSub;
  bool _started = false;

  /// Démarre l'écoute une seule fois (idempotent).
  void ensureStarted() {
    if (_started) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _started = true;
    debugPrint('🎬 [DemoSimulator] démarré pour $uid');

    // Courses : on filtre le statut en mémoire (pas d'index composite requis).
    _ridesSub = _db
        .collection('taxiRides')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      for (final doc in snap.docs) {
        final status = (doc.data()['status'] ?? '') as String;
        if (status == 'requested' && _handled.add('ride_${doc.id}')) {
          _runRide(doc.id);
        }
      }
    });

    // Commandes
    _ordersSub = _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      for (final doc in snap.docs) {
        final status = (doc.data()['status'] ?? '') as String;
        if (status == 'pending' && _handled.add('order_${doc.id}')) {
          _runOrder(doc.id);
        }
      }
    });
  }

  Future<void> _wait(int s) => Future.delayed(Duration(seconds: s));

  Future<void> _runRide(String id) async {
    final ref = _db.collection('taxiRides').doc(id);
    debugPrint('🚖 [DemoSimulator] course $id : démarrage du scénario');
    try {
      await _wait(3);
      await ref.update({
        'status': 'accepted',
        'driverId': 'demo-driver',
        'driverName': 'Mohamed (démo)',
        'driverPhone': '+25377123456',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      await _wait(4);
      await ref.update({'status': 'arriving'});
      await _wait(4);
      await ref.update({
        'status': 'arrived',
        'arrivedAt': FieldValue.serverTimestamp(),
      });
      await _wait(3);
      await ref.update({
        'status': 'started',
        'startedAt': FieldValue.serverTimestamp(),
      });
      await _wait(6);
      await ref.update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [DemoSimulator] course $id terminée');
    } catch (e) {
      debugPrint('⚠️ [DemoSimulator] course $id: $e');
    }
  }

  Future<void> _runOrder(String id) async {
    final ref = _db.collection('orders').doc(id);
    debugPrint('🍔 [DemoSimulator] commande $id : démarrage du scénario');
    try {
      await _wait(3);
      await ref.update({'status': 'confirmed'});
      await _wait(4);
      await ref.update({'status': 'preparing'});
      await _wait(5);
      await ref.update({
        'status': 'ready',
        'readyAt': FieldValue.serverTimestamp(),
      });
      await _wait(3);
      // Le livreur de démo = l'uid du client, pour pouvoir écrire
      // livreurs/{uid} (autorisé par les règles : owner).
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await ref.update({
        'status': 'delivering',
        'deliveryDriverId': uid,
        'deliveryDriverName': 'Idriss (démo)',
        'deliveryDriverPhone': '+25377123456',
      });
      // Simule le déplacement GPS du livreur (visible sur la carte de suivi).
      if (uid != null) {
        await _animateLivreur(uid);
      } else {
        await _wait(6);
      }
      await ref.update({
        'status': 'completed',
        'deliveredAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [DemoSimulator] commande $id terminée');
    } catch (e) {
      debugPrint('⚠️ [DemoSimulator] commande $id: $e');
    }
  }

  /// Fait bouger la position du livreur (livreurs/{uid}.currentLocation)
  /// du restaurant vers le client, pour la carte de suivi.
  Future<void> _animateLivreur(String uid) async {
    final ref = _db.collection('livreurs').doc(uid);
    const startLat = 11.5800, startLng = 43.1480; // resto (démo)
    const endLat = 11.5950, endLng = 43.1400;     // client (démo)
    const steps = 8;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      await ref.set({
        'currentLocation':
            GeoPoint(startLat + (endLat - startLat) * t,
                     startLng + (endLng - startLng) * t),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _wait(2);
    }
  }

  void stop() {
    _ridesSub?.cancel();
    _ordersSub?.cancel();
    _started = false;
  }
}
