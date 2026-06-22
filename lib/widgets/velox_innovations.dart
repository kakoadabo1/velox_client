// ════════════════════════════════════════════════════════════════════════════
//  VELOX — Composants innovants (drop-in)
//  À placer dans : lib/widgets/velox_innovations.dart  (app Client)
//
//  Tous ces widgets prennent ta palette `AppColors c` en paramètre, donc
//  l'intégration est triviale dans tes écrans :
//
//    final c = ref.watch(themeNotifierProvider).isDarkMode
//        ? AppColors.dark : AppColors.light;
//
//    SearchRadar(c: c, label: 'Recherche d\'un chauffeur…')
//    VeloxTimeline(c: c, activeIndex: idx, steps: VeloxSteps.taxi)
//    RouteMapCard(c: c, progress: 0.6)            // 0 = départ, 1 = arrivée
//    PrepRing(c: c, progress: prep)               // 0..1
//
//  Aucune dépendance externe : Flutter pur.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nomade_client/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  1) SEARCH RADAR — pulse de recherche de chauffeur/coursier
// ─────────────────────────────────────────────────────────────────────────────
class SearchRadar extends StatefulWidget {
  const SearchRadar({
    super.key,
    required this.c,
    this.label = 'Recherche en cours…',
    this.icon = '🚕',
    this.size = 150,
  });
  final AppColors c;
  final String label;
  final String icon;
  final double size;

  @override
  State<SearchRadar> createState() => _SearchRadarState();
}

class _SearchRadarState extends State<SearchRadar>
    with TickerProviderStateMixin {
  late final AnimationController _rings =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();
  late final AnimationController _sweep =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
        ..repeat();

  @override
  void dispose() {
    _rings.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_rings, _sweep]),
            builder: (_, __) => CustomPaint(
              painter: _RadarPainter(
                progress: _rings.value,
                sweep: _sweep.value,
                color: c.primary,
              ),
              child: Center(
                child: Container(
                  width: widget.size * 0.34,
                  height: widget.size * 0.34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.primary,
                    boxShadow: [
                      BoxShadow(
                          color: c.primary.withValues(alpha: 0.6),
                          blurRadius: 24,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Center(
                      child: Text(widget.icon,
                          style: const TextStyle(fontSize: 22))),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.label,
            style: TextStyle(
                color: c.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(
      {required this.progress, required this.sweep, required this.color});
  final double progress; // 0..1 boucle
  final double sweep; // 0..1 boucle
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;

    // anneaux qui s'étendent (3 décalés)
    for (int i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      final r = maxR * (0.2 + 0.8 * t);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: (1 - t) * 0.5);
      canvas.drawCircle(center, r, paint);
    }

    // balayage conique
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 3,
        colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: maxR));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweep * 2 * math.pi);
    canvas.drawCircle(Offset.zero, maxR, sweepPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.progress != progress || old.sweep != sweep;
}

// ─────────────────────────────────────────────────────────────────────────────
//  2) VELOX TIMELINE — stepper animé (course / livraison)
// ─────────────────────────────────────────────────────────────────────────────
class VeloxStep {
  final String label;
  final String? sub;
  const VeloxStep(this.label, [this.sub]);
}

/// Listes prêtes à l'emploi, alignées sur les statuts réels.
class VeloxSteps {
  static const taxi = <VeloxStep>[
    VeloxStep('Accepté', 'Chauffeur assigné'),
    VeloxStep('En approche', 'Vient au point de départ'),
    VeloxStep('Arrivé', 'Au point de rendez-vous'),
    VeloxStep('En route', 'Course démarrée'),
    VeloxStep('Terminé', 'Destination atteinte'),
  ];

  static const food = <VeloxStep>[
    VeloxStep('Confirmée', 'Restaurant a accepté'),
    VeloxStep('En préparation', 'Votre repas se prépare'),
    VeloxStep('Prête', 'Le coursier récupère'),
    VeloxStep('En livraison', 'En route vers vous'),
    VeloxStep('Livrée', 'Bon appétit'),
  ];

  /// Mappe un statut Firestore -> index de la timeline.
  static int taxiIndex(String s) => const {
        'accepted': 0,
        'arriving': 1,
        'arrived': 2,
        'started': 3,
        'completed': 4,
      }[s] ??
      0;

  static int foodIndex(String s) => const {
        'confirmed': 0,
        'accepted': 0,
        'preparing': 1,
        'ready': 2,
        'delivering': 3,
        'completed': 4,
      }[s] ??
      0;
}

class VeloxTimeline extends StatefulWidget {
  const VeloxTimeline({
    super.key,
    required this.c,
    required this.steps,
    required this.activeIndex,
  });
  final AppColors c;
  final List<VeloxStep> steps;
  final int activeIndex;

  @override
  State<VeloxTimeline> createState() => _VeloxTimelineState();
}

class _VeloxTimelineState extends State<VeloxTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.steps.length; i++)
          _row(c, i, widget.steps[i], last: i == widget.steps.length - 1),
      ],
    );
  }

  Widget _row(AppColors c, int i, VeloxStep s, {required bool last}) {
    final done = i < widget.activeIndex;
    final active = i == widget.activeIndex;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final glow = active ? (4 + 6 * _pulse.value) : 0.0;
                  return Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (done || active) ? c.primary : c.bg,
                      border: Border.all(
                          color: (done || active)
                              ? c.primary
                              : c.outlineVariant,
                          width: 2),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: c.primary.withValues(alpha: 0.25),
                                  blurRadius: glow,
                                  spreadRadius: glow / 2),
                            ]
                          : null,
                    ),
                    child: done
                        ? Icon(Icons.check, size: 14, color: c.onPrimary)
                        : null,
                  );
                },
              ),
              if (!last)
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
          Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 18, top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.label,
                    style: TextStyle(
                        color: i > widget.activeIndex
                            ? c.onSurfaceVariant.withValues(alpha: 0.6)
                            : c.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                if (s.sub != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(s.sub!,
                        style: TextStyle(
                            color: c.onSurfaceVariant, fontSize: 11)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3) ROUTE MAP CARD — carte stylisée + tracé animé + marqueur véhicule
//     `progress` 0..1 (anime-le selon le statut de la course)
// ─────────────────────────────────────────────────────────────────────────────
class RouteMapCard extends StatelessWidget {
  const RouteMapCard({
    super.key,
    required this.c,
    required this.progress,
    this.height = 220,
    this.marker = '🚕',
  });
  final AppColors c;
  final double progress;
  final double height;
  final String marker;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeInOut,
        builder: (_, p, __) => SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _MapPainter(c: c, progress: p, marker: marker),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.c, required this.progress, required this.marker});
  final AppColors c;
  final double progress;
  final String marker;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // fond
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF12110F));

    // routes
    final road = Paint()
      ..color = const Color(0xFF2B2826)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10, h * 0.5), Offset(w + 10, h * 0.5), road);
    canvas.drawLine(Offset(w * 0.55, -10), Offset(w * 0.55, h + 10), road);
    final road2 = Paint()
      ..color = const Color(0xFF242220)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.25, -10), Offset(w * 0.25, h + 10), road2);
    canvas.drawLine(Offset(-10, h * 0.78), Offset(w + 10, h * 0.78), road2);

    // tracé (bezier)
    final path = Path()
      ..moveTo(w * 0.16, h * 0.82)
      ..cubicTo(w * 0.30, h * 0.72, w * 0.34, h * 0.46, w * 0.52, h * 0.46)
      ..cubicTo(w * 0.72, h * 0.46, w * 0.78, h * 0.24, w * 0.86, h * 0.18);

    // tracé fond
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF2C2C2C));

    // tracé progressif
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [const Color(0xFF5B6CFF), c.primary],
          ).createShader(Offset.zero & size));

    // points départ / arrivée
    final start = metric.getTangentForOffset(0)!.position;
    final end = metric.getTangentForOffset(metric.length)!.position;
    canvas.drawCircle(start, 7, Paint()..color = const Color(0xFF5B6CFF));
    canvas.drawCircle(end, 7, Paint()..color = c.primary);

    // marqueur véhicule
    final pos =
        metric.getTangentForOffset(metric.length * progress)?.position ?? start;
    canvas.drawCircle(
        pos,
        13,
        Paint()
          ..color = c.primary
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5));
    final tp = TextPainter(
      text: TextSpan(text: marker, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  4) PREP RING — préparation en cuisine (anneau circulaire + %), pour le food
// ─────────────────────────────────────────────────────────────────────────────
class PrepRing extends StatelessWidget {
  const PrepRing({
    super.key,
    required this.c,
    required this.progress,
    this.icon = '🍳',
    this.size = 150,
  });
  final AppColors c;
  final double progress; // 0..1
  final String icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 500),
      builder: (_, p, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
              progress: p, track: c.outlineVariant, color: c.primary),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 40)),
                Text('${(p * 100).round()}%',
                    style: TextStyle(
                        color: c.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(
      {required this.progress, required this.track, required this.color});
  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 6;
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
