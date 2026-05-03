import 'package:flutter/material.dart';

import 'package:ts_management/data/models/waypoint.dart';

class FloorOverlayPainter extends CustomPainter {
  FloorOverlayPainter({
    required this.routeNodes,
    required this.allNodes,
    required this.viewWidth,
    required this.viewHeight,
    required this.activeIndex,
    required this.color,
  });

  final List<Waypoint> routeNodes; // ordered nodes on the current floor
  final List<Waypoint> allNodes;   // all nodes on the current floor
  final double viewWidth;
  final double viewHeight;
  final int activeIndex;
  final Color color;

  Offset _scale(Waypoint w, Size size) {
    return Offset(
      w.x / viewWidth * size.width,
      w.y / viewHeight * size.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (routeNodes.length >= 2) {
      final path = Path()..moveTo(_scale(routeNodes.first, size).dx,
          _scale(routeNodes.first, size).dy);
      for (var i = 1; i < routeNodes.length; i++) {
        final p = _scale(routeNodes[i], size);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    // Waypoint dots
    for (final n in allNodes) {
      final p = _scale(n, size);
      final paint = Paint()..color = color.withValues(alpha: 0.25);
      canvas.drawCircle(p, 4, paint);
    }

    // Start
    if (routeNodes.isNotEmpty) {
      final start = _scale(routeNodes.first, size);
      canvas.drawCircle(start, 10, Paint()..color = Colors.green);
      canvas.drawCircle(start, 10, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    // End
    if (routeNodes.length >= 2) {
      final end = _scale(routeNodes.last, size);
      canvas.drawCircle(end, 12, Paint()..color = Colors.red);
      canvas.drawCircle(end, 12, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    // Active marker (current step on this floor)
    if (activeIndex >= 0 && activeIndex < routeNodes.length) {
      final a = _scale(routeNodes[activeIndex], size);
      canvas.drawCircle(a, 14,
          Paint()..color = color.withValues(alpha: 0.4));
      canvas.drawCircle(a, 8, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant FloorOverlayPainter old) =>
      old.routeNodes != routeNodes ||
      old.activeIndex != activeIndex ||
      old.color != color;
}
