import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/volume.dart';

/// The picture of a milestone, in a rounded tile. Material icons where one exists; the
/// elephant, the whale and the Eiffel Tower are drawn here in the same filled style.
class MilestoneIcon extends StatelessWidget {
  const MilestoneIcon({super.key, required this.art, this.size = 52, this.reached = true, this.gold = false});

  final MilestoneArt art;
  final double size;

  /// Not reached yet: dimmed.
  final bool reached;

  /// The celebration: a warm gold frame.
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final color = gold
        ? AppColors.success
        : reached
        ? AppColors.accent
        : AppColors.textTertiary;
    final glyph = size * 0.54;

    final icon = switch (art) {
      MilestoneArt.piano => Icon(Icons.piano_rounded, size: glyph, color: color),
      MilestoneArt.car => Icon(Icons.directions_car_rounded, size: glyph, color: color),
      MilestoneArt.bus => Icon(Icons.directions_bus_rounded, size: glyph, color: color),
      MilestoneArt.truck => Icon(Icons.local_shipping_rounded, size: glyph, color: color),
      MilestoneArt.jet => Icon(Icons.flight_rounded, size: glyph, color: color),
      MilestoneArt.wheel => Icon(Icons.attractions_rounded, size: glyph, color: color),
      MilestoneArt.elephant => _Drawn(_elephant, glyph, color),
      MilestoneArt.whale => _Drawn(_whale, glyph, color),
      MilestoneArt.tower => _Drawn(_tower, glyph, color),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gold ? AppColors.success.withValues(alpha: 0.14) : AppColors.surface2,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: gold
            ? Border.all(color: AppColors.success.withValues(alpha: 0.4))
            : reached
            ? Border.all(color: AppColors.accentMid.withValues(alpha: 0.6))
            : null,
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}

class _Drawn extends StatelessWidget {
  const _Drawn(this.paint, this.size, this.color);

  final void Function(Canvas canvas, Paint fill) paint;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GlyphPainter(paint, color));
}

/// Draws on a 24 × 24 grid, like the Material icons.
class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.draw, this.color);

  final void Function(Canvas canvas, Paint fill) draw;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    // a layer, so the cut-out details (ear, eye, arch) show the tile through
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 24, 24), Paint());
    draw(canvas, Paint()..color = color);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color || old.draw != draw;
}

Paint _cut([double width = 0]) => Paint()
  ..blendMode = BlendMode.clear
  ..style = width > 0 ? PaintingStyle.stroke : PaintingStyle.fill
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

Paint _stroke(Paint fill, double width) => Paint()
  ..color = fill.color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

void _elephant(Canvas canvas, Paint fill) {
  // body, head, legs
  canvas.drawRRect(RRect.fromLTRBR(7.5, 6.5, 21.5, 16, const Radius.circular(4.5)), fill);
  canvas.drawCircle(const Offset(7, 9.5), 4.5, fill);
  canvas.drawRRect(RRect.fromLTRBR(8.5, 13, 11.5, 21, const Radius.circular(1.2)), fill);
  canvas.drawRRect(RRect.fromLTRBR(17.5, 13, 20.5, 21, const Radius.circular(1.2)), fill);
  // trunk, curling forward at the tip
  final trunk = Path()
    ..moveTo(3.6, 10.5)
    ..quadraticBezierTo(2.2, 15, 3.2, 18.6)
    ..quadraticBezierTo(3.6, 19.8, 4.8, 19.2);
  canvas.drawPath(trunk, _stroke(fill, 2.4));
  // tail
  canvas.drawLine(const Offset(21.3, 9), const Offset(22.8, 12.5), _stroke(fill, 1));
  // the ear outline and the eye, cut out
  final ear = Path()
    ..moveTo(9.2, 6.6)
    ..quadraticBezierTo(13.2, 7.4, 12.4, 12.6)
    ..quadraticBezierTo(10.8, 13.4, 9.6, 12.2);
  canvas.drawPath(ear, _cut(0.9));
  canvas.drawCircle(const Offset(5.6, 8.6), 0.75, _cut());
}

void _whale(Canvas canvas, Paint fill) {
  // a long body, tapering to the tail
  final body = Path()
    ..moveTo(1.5, 12.5)
    ..quadraticBezierTo(1.8, 8.2, 8, 8.6)
    ..quadraticBezierTo(14.5, 9.2, 19, 12)
    ..lineTo(19.6, 13.4)
    ..quadraticBezierTo(13, 16.8, 6, 16.2)
    ..quadraticBezierTo(1.4, 15.6, 1.5, 12.5)
    ..close();
  canvas.drawPath(body, fill);
  // flukes
  final flukes = Path()
    ..moveTo(18.2, 12.6)
    ..quadraticBezierTo(20.6, 10.4, 23, 9)
    ..quadraticBezierTo(22, 12.2, 21.6, 12.9)
    ..quadraticBezierTo(22.2, 14.6, 23, 17)
    ..quadraticBezierTo(20.4, 15.4, 18.2, 13.6)
    ..close();
  canvas.drawPath(flukes, fill);
  // flipper
  final flipper = Path()
    ..moveTo(7.5, 15.4)
    ..quadraticBezierTo(8.8, 18.4, 11.2, 19.2)
    ..quadraticBezierTo(10.4, 17, 10.4, 15.6)
    ..close();
  canvas.drawPath(flipper, fill);
  // eye and the line of the mouth, cut out
  canvas.drawCircle(const Offset(5, 12.2), 0.7, _cut());
  canvas.drawPath(
    Path()
      ..moveTo(2.4, 13.8)
      ..quadraticBezierTo(6, 14.6, 9.5, 13.9),
    _cut(0.7),
  );
}

void _tower(Canvas canvas, Paint fill) {
  final tower = Path()
    ..moveTo(11.4, 3.2)
    ..lineTo(12.6, 3.2)
    ..lineTo(13.5, 8.8)
    ..lineTo(15.2, 8.8)
    ..lineTo(15.2, 10.4)
    ..lineTo(14.3, 10.4)
    ..lineTo(15.6, 14.2)
    ..lineTo(17.2, 14.2)
    ..lineTo(17.2, 15.8)
    ..lineTo(16.3, 15.8)
    ..lineTo(19.2, 22)
    ..lineTo(15.6, 22)
    ..quadraticBezierTo(15.2, 18, 12, 18)
    ..quadraticBezierTo(8.8, 18, 8.4, 22)
    ..lineTo(4.8, 22)
    ..lineTo(7.7, 15.8)
    ..lineTo(6.8, 15.8)
    ..lineTo(6.8, 14.2)
    ..lineTo(8.4, 14.2)
    ..lineTo(9.7, 10.4)
    ..lineTo(8.8, 10.4)
    ..lineTo(8.8, 8.8)
    ..lineTo(10.5, 8.8)
    ..close();
  canvas.drawPath(tower, fill);
  // the spire
  canvas.drawLine(const Offset(12, 1.2), const Offset(12, 3.4), _stroke(fill, 1.1));
  // the small arch between the two platforms
  canvas.drawPath(
    Path()
      ..moveTo(10.6, 14.2)
      ..quadraticBezierTo(12, 12, 13.4, 14.2)
      ..close(),
    _cut(),
  );
}
