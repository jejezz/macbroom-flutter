import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../core/format.dart';
import '../theme/broom_theme.dart';

/// Full-page overlay shown while a clean is running: a spinning glow ring,
/// a progress bar (indeterminate when [total] is 0) and bytes removed so far.
class CleaningOverlay extends StatefulWidget {
  const CleaningOverlay({super.key, required this.done, required this.total, required this.bytes});
  final int done;
  final int total;
  final int bytes;

  @override
  State<CleaningOverlay> createState() => _CleaningOverlayState();
}

class _CleaningOverlayState extends State<CleaningOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final determinate = widget.total > 0;
    final ratio = determinate ? (widget.done / widget.total).clamp(0.0, 1.0) : null;
    return AbsorbPointer(
      child: Container(
        color: Broom.bg0.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(alignment: Alignment.center, children: [
                  RotationTransition(
                    turns: c,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [Broom.violet.withValues(alpha: 0), Broom.pink, Broom.violet.withValues(alpha: 0)]),
                        boxShadow: Broom.glow(Broom.pink, blur: 40, alpha: 0.5),
                      ),
                    ),
                  ),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Broom.bg0),
                  ),
                  AnimatedBuilder(
                    animation: c,
                    builder: (_, child) => Transform.scale(scale: 1 + 0.12 * sin(c.value * 2 * pi), child: child),
                    child: const Icon(CupertinoIcons.sparkles, size: 38, color: Broom.pink),
                  ),
                ]),
              ),
              const SizedBox(height: 26),
              const Text('Cleaning…', style: Broom.h1),
              const SizedBox(height: 6),
              Text(determinate ? '${widget.done} / ${widget.total} items · ${formatBytes(widget.bytes)} freed' : 'Working…', style: Broom.caption),
              const SizedBox(height: 18),
              SizedBox(
                width: 280,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(children: [
                    Container(color: Broom.glass),
                    if (ratio != null)
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(decoration: const BoxDecoration(gradient: Broom.accentGradient)),
                      )
                    else
                      AnimatedBuilder(
                        animation: c,
                        builder: (_, _) => Align(
                          alignment: Alignment(-1 + 2 * c.value, 0),
                          child: FractionallySizedBox(widthFactor: 0.3, child: Container(decoration: const BoxDecoration(gradient: Broom.accentGradient))),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
