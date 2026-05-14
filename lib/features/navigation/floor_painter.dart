import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';

// ── Room type colors (exact match to campus_network_map.html) ──────────────
class _RC { final Color f,s,t; const _RC(this.f,this.s,this.t); }
const _rt = <String,_RC>{
  'class':    _RC(Color(0xFFE6F1FB),Color(0xFF185FA5),Color(0xFF0C447C)),
  'office':   _RC(Color(0xFFF1EFE8),Color(0xFF888780),Color(0xFF444441)),
  'lab':      _RC(Color(0xFFE1F5EE),Color(0xFF1D9E75),Color(0xFF085041)),
  'special':  _RC(Color(0xFFEEEDFE),Color(0xFF7F77DD),Color(0xFF3C3489)),
  'corridor': _RC(Color(0xFFFAFAF8),Color(0xFFD3D1C7),Color(0xFFB4B2A9)),
};
_RC _rc(RoomType t) => _rt[_roomTypeKey(t)] ?? _rt['office']!;
String _roomTypeKey(RoomType t) => switch(t) {
  RoomType.classroom => 'class',
  RoomType.lab => 'lab',
  RoomType.meeting => 'special',
  RoomType.cafeteria => 'special',
  RoomType.reception => 'special',
  _ => 'office',
};

class _DC { final Color f,s,t; final String l; const _DC(this.f,this.s,this.t,this.l); }
const _dt = <String,_DC>{
  'ap':     _DC(Color(0xFFE1F5EE),Color(0xFF0F6E56),Color(0xFF085041),'Access point'),
  'switch': _DC(Color(0xFFFAEEDA),Color(0xFFBA7517),Color(0xFF633806),'Switch'),
  'core':   _DC(Color(0xFFEEEDFE),Color(0xFF7F77DD),Color(0xFF3C3489),'Core switch'),
};

/// Faithful Flutter port of campus_network_map.html SVG renderer.
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
    this.pulseT = 0.0,
    this.destinationWaypointId,
  });

  final List<Waypoint> routeNodes;
  final List<Waypoint> allNodes;
  final List<GraphEdge> allEdges;
  final List<RoomDoc> rooms;
  final double viewWidth, viewHeight;
  final int activeIndex;
  final Color routeColor;
  final ColorScheme scheme;
  final double pulseT;
  final String? destinationWaypointId;

  Offset _sc(double x, double y, Size sz) =>
      Offset(x/viewWidth*sz.width, y/viewHeight*sz.height);
  Offset _sw(Waypoint w, Size sz) => _sc(w.x, w.y, sz);

  @override
  void paint(Canvas canvas, Size size) {
    _grid(canvas, size);
    _rooms(canvas, size);
    _transit(canvas, size);
    _route(canvas, size);
    _markers(canvas, size);
  }

  // ── dot grid (matches HTML pattern) ──────────────────────────────────────
  void _grid(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xFFF9F8F6));
    final p = Paint()
      ..color = const Color(0xFFD3D1C7).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    final sx = size.width/viewWidth*40, sy = size.height/viewHeight*40;
    for (var x=0.0; x<=size.width+sx; x+=sx) {
      canvas.drawLine(Offset(x,0), Offset(x,size.height), p);
    }
    for (var y=0.0; y<=size.height+sy; y+=sy) {
      canvas.drawLine(Offset(0,y), Offset(size.width,y), p);
    }
  }

  // ── rooms ─────────────────────────────────────────────────────────────────
  void _rooms(Canvas canvas, Size size) {
    final hasDest = destinationWaypointId != null;
    final byId = {for (final n in allNodes) n.id: n};
    final scX = size.width/viewWidth, scY = size.height/viewHeight;
    const rW = 130.0, rH = 92.0;

    for (final r in rooms) {
      final wp = byId[r.waypointId]; if (wp==null) continue;
      final isDest = r.waypointId == destinationWaypointId;
      final dim = hasDest && !isDest;
      final rc = _rc(r.type);
      final fillC = isDest ? const Color(0xFFB5D4F4)
                           : dim ? rc.f.withValues(alpha:0.35) : rc.f;
      final strokeC = isDest ? const Color(0xFF185FA5)
                              : dim ? rc.s.withValues(alpha:0.3) : rc.s;
      final strokeW = isDest ? 2.0 : 0.8;

      final cx = wp.x/viewWidth*size.width, cy = wp.y/viewHeight*size.height;
      final rect = Rect.fromCenter(
          center: Offset(cx,cy), width: rW*scX, height: rH*scY);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(2*scX));
      canvas.drawRRect(rr, Paint()..color = fillC);
      canvas.drawRRect(rr, Paint()
        ..color = strokeC ..style=PaintingStyle.stroke ..strokeWidth=strokeW);

      // room number
      _txt(canvas, r.number, Offset(rect.left+4*scX, rect.top+12*scY),
          fs: 8.5*scX,
          color: isDest ? const Color(0xFF0C447C) : rc.t.withValues(alpha: dim?0.4:1),
          bold: true);
      // room name
      if (rH*scY > 35) {
        final name = r.name.length>14 ? '${r.name.substring(0,13)}…' : r.name;
        _txt(canvas, name, Offset(rect.left+4*scX, rect.top+23*scY),
            fs: 7.5*scX,
            color: (isDest ? const Color(0xFF185FA5) : rc.t)
                .withValues(alpha: dim?0.35:0.85));
      }
    }
  }

  // ── transit nodes ─────────────────────────────────────────────────────────
  void _transit(Canvas canvas, Size size) {
    for (final n in allNodes) {
      if (n.type==WaypointType.room || n.type==WaypointType.junction) continue;
      final p = _sw(n, size);
      Color fill, stroke, tc;
      switch (n.type) {
        case WaypointType.stairs:
          fill=const Color(0xFFF0EDE8); stroke=const Color(0xFFB4A990); tc=const Color(0xFF444441);
        case WaypointType.elevator:
          fill=const Color(0xFFEBF3FC); stroke=const Color(0xFF185FA5); tc=const Color(0xFF185FA5);
        default:
          fill=AppTheme.primary; stroke=AppTheme.primary; tc=Colors.white;
      }
      canvas.drawCircle(p, 18, Paint()..color=fill);
      canvas.drawCircle(p, 18, Paint()..color=stroke..style=PaintingStyle.stroke..strokeWidth=1.2);
      final lbl = switch(n.type) {
        WaypointType.stairs=>'STAIR', WaypointType.elevator=>'LIFT', _=>'ENTRY'
      };
      _txt(canvas, lbl, p, fs:7, color:tc, bold:true, center:true);
    }
  }

  // ── route ─────────────────────────────────────────────────────────────────
  void _route(Canvas canvas, Size size) {
    if (routeNodes.length < 2) return;
    final pts = routeNodes.map((n)=>_sw(n,size)).toList();
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i=1; i<pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);

    canvas.drawPath(path, Paint()
      ..color=AppTheme.live.withValues(alpha:0.25)
      ..strokeWidth=18 ..style=PaintingStyle.stroke
      ..strokeCap=StrokeCap.round ..strokeJoin=StrokeJoin.round
      ..maskFilter=const MaskFilter.blur(BlurStyle.normal,8));
    canvas.drawPath(path, Paint()
      ..color=Colors.white.withValues(alpha:0.6)
      ..strokeWidth=11 ..style=PaintingStyle.stroke
      ..strokeCap=StrokeCap.round ..strokeJoin=StrokeJoin.round);
    canvas.drawPath(path, Paint()
      ..color=routeColor ..strokeWidth=6
      ..style=PaintingStyle.stroke ..strokeCap=StrokeCap.round ..strokeJoin=StrokeJoin.round);

    // chevrons
    final cp = Paint()..color=Colors.white.withValues(alpha:0.9)
      ..strokeWidth=2 ..strokeCap=StrokeCap.round ..style=PaintingStyle.stroke;
    var dist=0.0, next=60.0;
    for (var i=1; i<pts.length; i++) {
      final a=pts[i-1], b=pts[i];
      final dx=b.dx-a.dx, dy=b.dy-a.dy;
      final len=math.sqrt(dx*dx+dy*dy); if (len<1) continue;
      while (next<=dist+len) {
        final f=(next-dist)/len;
        final p=Offset(a.dx+dx*f, a.dy+dy*f);
        final ang=math.atan2(dy,dx); const s=5.0;
        canvas.drawLine(Offset(p.dx-math.cos(ang-math.pi/4)*s, p.dy-math.sin(ang-math.pi/4)*s), p, cp);
        canvas.drawLine(Offset(p.dx-math.cos(ang+math.pi/4)*s, p.dy-math.sin(ang+math.pi/4)*s), p, cp);
        next+=80;
      }
      dist+=len;
    }
  }

  // ── markers ───────────────────────────────────────────────────────────────
  void _markers(Canvas canvas, Size size) {
    if (routeNodes.isEmpty) return;
    _pin(canvas, _sw(routeNodes.first,size), AppTheme.success, 'Start');
    if (routeNodes.length>=2) {
      final end=_sw(routeNodes.last,size);
      final pr=24+6*(0.5+0.5*math.sin(pulseT*math.pi*2));
      canvas.drawCircle(end, pr, Paint()..color=routeColor.withValues(alpha:0.15));
      _pin(canvas, end, routeColor, 'Dest');
      final pos=_along(routeNodes, pulseT, size);
      canvas.drawCircle(pos, 12, Paint()..color=routeColor.withValues(alpha:0.3));
      canvas.drawCircle(pos, 6, Paint()..color=routeColor);
      canvas.drawCircle(pos, 6, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
    }
  }

  void _pin(Canvas canvas, Offset at, Color c, String label) {
    canvas.drawCircle(at, 12, Paint()..color=c);
    canvas.drawCircle(at, 12, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2.5);
    _txt(canvas, label, Offset(at.dx, at.dy-22), fs:9, color:c, bold:true, center:true);
  }

  Offset _along(List<Waypoint> nodes, double t, Size sz) {
    final pts=nodes.map((n)=>_sw(n,sz)).toList();
    var total=0.0;
    final lens=<double>[];
    for (var i=1; i<pts.length; i++) {
      final l=(pts[i]-pts[i-1]).distance; lens.add(l); total+=l;
    }
    if (total<=0) return pts.first;
    var target=total*t.clamp(0.0,1.0);
    for (var i=0; i<lens.length; i++) {
      if (target<=lens[i]) {
        return Offset.lerp(pts[i], pts[i+1], lens[i]==0?0:target/lens[i])!;
      }
      target-=lens[i];
    }
    return pts.last;
  }

  // ── text helper ───────────────────────────────────────────────────────────
  void _txt(Canvas canvas, String text, Offset pos, {
    required double fs, required Color color,
    bool bold=false, bool center=false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text:text, style:TextStyle(
        fontSize:fs, color:color,
        fontWeight: bold?FontWeight.w600:FontWeight.normal,
        fontFamily:'monospace',
      )),
      textAlign: center?TextAlign.center:TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 200);
    final dx = center ? pos.dx-tp.width/2 : pos.dx;
    final dy = center ? pos.dy-tp.height/2 : pos.dy-tp.height*0.8;
    tp.paint(canvas, Offset(dx,dy));
  }

  @override
  bool shouldRepaint(covariant FloorPlanPainter old) =>
      old.routeNodes!=routeNodes || old.allNodes!=allNodes ||
      old.rooms!=rooms || old.pulseT!=pulseT ||
      old.destinationWaypointId!=destinationWaypointId;
}
