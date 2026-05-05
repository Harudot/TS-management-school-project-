import 'package:flutter/material.dart';

import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';

/// Top-down 2D floor plan painter:
/// - rounded rectangles for rooms (labeled with number + name)
/// - thick light-grey "hallway" bands tracing edges between non-room waypoints
/// - badged circles for stairs / elevator / entrance
/// - the computed route drawn as a vivid polyline overlay with start/end pins
class FloorPlanPainter extends CustomPainter {
  FloorPlanPainter({
    required this.routeNodes,
    required this.allNodes,
    required this.allEdges,
    required this.rooms,
    required this.viewWidth,
    required this.viewHeight,
    required this.activeIndex,
    required this.routeColor,
    required this.scheme,
  });

  final List<Waypoint> routeNodes;
  final List<Waypoint> allNodes;
  final List<GraphEdge> allEdges;
  final List<RoomDoc> rooms;
  final double viewWidth;
  final double viewHeight;
  final int activeIndex;
  final Color routeColor;
  final ColorScheme scheme;

  static const double _roomW = 140;
  static const double _roomH = 90;

  Offset _scale(double x, double y, Size size) =>
      Offset(x / viewWidth * size.width, y / viewHeight * size.height);

  Offset _scaleW(Waypoint w, Size size) => _scale(w.x, w.y, size);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = scheme.surfaceContainerLow);

    _drawHallways(canvas, size);
    _drawRooms(canvas, size);
    _drawTransitNodes(canvas, size);
    _drawRoute(canvas, size);
    _drawMarkers(canvas, size);
  }

  void _drawHallways(Canvas canvas, Size size) {
    final hallwayPaint = Paint()
      ..color = scheme.surfaceContainerHighest
      ..strokeWidth = (size.shortestSide * 0.05).clamp(18, 32)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final byId = {for (final n in allNodes) n.id: n};
    for (final e in allEdges) {
      final a = byId[e.from];
      final b = byId[e.to];
      if (a == null || b == null) continue;
      // Skip room→corridor stub: rooms get their own outline; the stub looks
      // like a finger sticking out. Draw only between transit/junction nodes.
      if (a.type == WaypointType.room || b.type == WaypointType.room) continue;
      canvas.drawLine(_scaleW(a, size), _scaleW(b, size), hallwayPaint);
    }
  }

  void _drawRooms(Canvas canvas, Size size) {
    final roomFill = Paint()..color = scheme.primaryContainer.withValues(alpha: 0.55);
    final roomBorder = Paint()
      ..color = scheme.outline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final waypointById = {for (final n in allNodes) n.id: n};
    final scaleX = size.width / viewWidth;
    final scaleY = size.height / viewHeight;
    final w = _roomW * scaleX;
    final h = _roomH * scaleY;

    for (final r in rooms) {
      final wp = waypointById[r.waypointId];
      if (wp == null) continue;
      final center = _scaleW(wp, size);
      final rect = Rect.fromCenter(center: center, width: w, height: h);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
      canvas.drawRRect(rrect, roomFill);
      canvas.drawRRect(rrect, roomBorder);

      final tp = TextPainter(
        text: TextSpan(children: [
          TextSpan(
            text: '${r.number}\n',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: r.name,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 10,
            ),
          ),
        ]),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 3,
        ellipsis: '…',
      )..layout(maxWidth: w - 12);
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawTransitNodes(Canvas canvas, Size size) {
    for (final n in allNodes) {
      if (n.type == WaypointType.room || n.type == WaypointType.junction) {
        continue;
      }
      final p = _scaleW(n, size);
      final fill = switch (n.type) {
        WaypointType.stairs => scheme.tertiaryContainer,
        WaypointType.elevator => scheme.secondaryContainer,
        WaypointType.entrance => scheme.primary,
        _ => scheme.surfaceContainerHigh,
      };
      final onFill = switch (n.type) {
        WaypointType.stairs => scheme.onTertiaryContainer,
        WaypointType.elevator => scheme.onSecondaryContainer,
        WaypointType.entrance => scheme.onPrimary,
        _ => scheme.onSurface,
      };

      canvas.drawCircle(p, 22, Paint()..color = fill);
      canvas.drawCircle(
        p,
        22,
        Paint()
          ..color = scheme.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final label = switch (n.type) {
        WaypointType.stairs => 'STAIRS',
        WaypointType.elevator => 'LIFT',
        WaypointType.entrance => 'ENTRY',
        _ => '',
      };
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: onFill,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (routeNodes.length < 2) return;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final routePaint = Paint()
      ..color = routeColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(
        _scaleW(routeNodes.first, size).dx,
        _scaleW(routeNodes.first, size).dy,
      );
    for (var i = 1; i < routeNodes.length; i++) {
      final p = _scaleW(routeNodes[i], size);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, routePaint);
  }

  void _drawMarkers(Canvas canvas, Size size) {
    if (routeNodes.isEmpty) return;
    final start = _scaleW(routeNodes.first, size);
    canvas.drawCircle(start, 11, Paint()..color = Colors.green.shade600);
    canvas.drawCircle(
      start,
      11,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (routeNodes.length >= 2) {
      final end = _scaleW(routeNodes.last, size);
      canvas.drawCircle(end, 13, Paint()..color = Colors.red.shade600);
      canvas.drawCircle(
        end,
        13,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (activeIndex >= 0 && activeIndex < routeNodes.length) {
      final a = _scaleW(routeNodes[activeIndex], size);
      canvas.drawCircle(
          a, 18, Paint()..color = routeColor.withValues(alpha: 0.35));
      canvas.drawCircle(a, 9, Paint()..color = routeColor);
      canvas.drawCircle(
        a,
        9,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloorPlanPainter old) =>
      old.routeNodes != routeNodes ||
      old.allNodes != allNodes ||
      old.allEdges != allEdges ||
      old.rooms != rooms ||
      old.activeIndex != activeIndex ||
      old.routeColor != routeColor;
}
