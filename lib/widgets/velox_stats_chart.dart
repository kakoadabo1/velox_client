// ════════════════════════════════════════════════════════════════════════
//  VELOX — Graphique de statistiques (barres animées, sans dépendance)
//  À placer dans : lib/widgets/velox_stats_chart.dart
// ════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nomade_client/theme/app_colors.dart';

class StatBar {
  final String label;
  final double value;
  final String display;
  const StatBar(this.label, this.value, this.display);
}

class VeloxStatsChart extends StatefulWidget {
  const VeloxStatsChart({super.key, required this.c, required this.bars});
  final AppColors c;
  final List<StatBar> bars;

  @override
  State<VeloxStatsChart> createState() => _VeloxStatsChartState();
}

class _VeloxStatsChartState extends State<VeloxStatsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final maxV = widget.bars
        .map((b) => b.value)
        .fold<double>(0, (a, b) => b > a ? b : a);
    final denom = maxV <= 0 ? 1.0 : maxV;
    const chartH = 120.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          decoration: BoxDecoration(
            color: c.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: SizedBox(
            height: chartH + 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.bars.map((b) {
                final raw = (b.value / denom) * chartH * t;
                final h = raw < 5 ? 5.0 : raw;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        b.display,
                        style: GoogleFonts.spaceGrotesk(
                          color: c.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              c.primary,
                              c.primary.withValues(alpha: 0.30),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                            bottom: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: c.onSurfaceVariant,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
