import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/local_cache.dart';

/// Mode faible data : désactive les tuiles de carte et allège les images.
class LowDataNotifier extends StateNotifier<bool> {
  LowDataNotifier() : super(false) {
    state = LocalCache.getLowData();
  }

  Future<void> toggle() async {
    state = !state;
    await LocalCache.saveLowData(state);
    debugPrint('🔋 [LowData] ${state ? "ON" : "OFF"}');
  }

  Future<void> set(bool value) async {
    state = value;
    await LocalCache.saveLowData(value);
  }
}

final lowDataModeProvider =
    StateNotifierProvider<LowDataNotifier, bool>((ref) => LowDataNotifier());
