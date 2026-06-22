import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth-firebase/auth/sign_in_screen.dart';
import 'package:nomade_client/providers/theme_notifier.dart';
import 'package:nomade_client/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late final AnimationController _tl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  // Flottement des emojis du slide 1 (effet "ça bouge")
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _tl.dispose();
    _pulse.dispose();
    _float.dispose();
    super.dispose();
  }

  void _goAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _next() {
    if (_page == 0) {
      _pageCtrl.animateToPage(1,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      _goAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeNotifierProvider).isDarkMode;
    final c = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  if (i == 1) _tl.forward(from: 0);
                },
                children: [
                  _slideOne(c),
                  _slideTwo(c),
                ],
              ),
            ),
            _footer(c),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── SLIDE 1 : Food + Taxi ─────────────────────────
  Widget _slideOne(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _duoTile(c, '🛵', 'FOOD', c.primary, 0),
              const SizedBox(width: 16),
              _duoTile(c, '🚕', 'TAXI', const Color(0xFF9FB0FF), math.pi),
            ],
          ),
          const SizedBox(height: 34),
          _badge(c, 'VELOX · DJIBOUTI'),
          const SizedBox(height: 14),
          Text(
            'Tout Djibouti,\nlivré en un éclair',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: c.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tes repas et tes courses, ou un taxi fiable — VELOX réunit '
            'la livraison et la course dans une seule app.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.onSurfaceVariant, fontSize: 14.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _duoTile(AppColors c, String emo, String label, Color accent, double phase) {
    return Container(
      width: 130,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: c.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.14), c.surfaceLow],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (_, child) {
              final t = math.sin(_float.value * 2 * math.pi + phase);
              return Transform.translate(
                offset: Offset(0, t * 7),
                child: Transform.rotate(angle: t * 0.10, child: child),
              );
            },
            child: Text(emo, style: const TextStyle(fontSize: 50)),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  color: accent, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
        ],
      ),
    );
  }

  // ────────────────────── SLIDE 2 : suivi animé ──────────────────────
  Widget _slideTwo(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeline(c),
          const SizedBox(height: 26),
          _badge(c, 'SUIVI EN TEMPS RÉEL'),
          const SizedBox(height: 14),
          Text(
            'Suis ta commande,\nétape par étape',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: c.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'De la cuisine à ta porte : reçois une alerte à chaque étape, '
            'jusqu\'à la livraison.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.onSurfaceVariant, fontSize: 14.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  static const _steps = [
    ['Commande reçue', 'Le restaurant confirme ta commande'],
    ['Préparation en cours', 'Ton repas se prépare en cuisine'],
    ['Livreur en route', 'Ton coursier arrive vers toi'],
    ['Livreur arrivé', 'Retrouve-le devant chez toi'],
    ['Commande livrée', 'Bon appétit !'],
  ];

  Widget _timeline(AppColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.outlineVariant),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_tl, _pulse]),
        builder: (_, __) {
          return Column(
            children: List.generate(_steps.length, (i) {
              final threshold = i * 0.18;
              final reveal = ((_tl.value - threshold) / 0.16).clamp(0.0, 1.0);
              final done = _tl.value >= threshold + 0.12;
              final isLast = i == _steps.length - 1;
              return _step(c, i, reveal, done, isLast);
            }),
          );
        },
      ),
    );
  }

  Widget _step(AppColors c, int i, double reveal, bool done, bool isLast) {
    final lbl = _steps[i];
    final celebrate = isLast && done;
    final pulse = celebrate ? (1 + 0.08 * _pulse.value) : 1.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Transform.scale(
                scale:
                    Curves.elasticOut.transform(reveal.clamp(0.0, 1.0)) * pulse,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? c.primary : c.bg,
                    border: Border.all(
                        color: done ? c.primary : c.outlineVariant, width: 2),
                    boxShadow: celebrate
                        ? [
                            BoxShadow(
                                color: c.primary.withValues(alpha: 0.5),
                                blurRadius: 14,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                  child: Icon(
                    isLast ? Icons.celebration_rounded : Icons.check_rounded,
                    size: 16,
                    color: done ? c.onPrimary : Colors.transparent,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: done ? c.primary : c.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Opacity(
            opacity: reveal,
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lbl[0],
                      style: TextStyle(
                          color: c.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  Text(lbl[1],
                      style: TextStyle(color: c.onSurfaceVariant, fontSize: 11.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── pied de page ─────────────────────────────
  Widget _footer(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final on = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: on ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: on ? c.primary : c.outlineVariant,
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _goAuth,
                child: Text('Passer',
                    style: TextStyle(
                        color: c.onSurfaceVariant, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  minimumSize: const Size(150, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _page == 0 ? 'Suivant  →' : 'Démarrer  ⚡',
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(AppColors c, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(t,
          style: TextStyle(
              color: c.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}
