import 'dart:convert';
import 'package:flutter/widgets.dart';

/// Retourne le bon ImageProvider pour un avatar :
/// - data URI base64 (photo stockée dans Firestore) → MemoryImage
/// - URL http(s) → NetworkImage
/// - sinon (null/vide/illisible) → null (avatar par défaut)
ImageProvider? avatarProvider(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('data:image')) {
    final comma = url.indexOf(',');
    if (comma == -1) return null;
    try {
      return MemoryImage(base64Decode(url.substring(comma + 1)));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(url);
}
