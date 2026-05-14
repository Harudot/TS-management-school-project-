import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const CampusMapApp());

// ─── Data Models ──────────────────────────────────────────────────────────────

class _RC {
  final Color f, s, t;
  const _RC(this.f, this.s, this.t);
}

class _DC {
  final Color f, s, t;
  final String lbl;
  const _DC(this.f, this.s, this.t, this.lbl);
}

class Room {
  final String id, name, type;
  final double x, y, w, h;
  const Room(this.id, this.x, this.y, this.w, this.h, this.name, this.type);

  bool hitTest(Offset p, double sc) =>
      p.dx >= x * sc &&
      p.dx <= (x + w) * sc &&
      p.dy >= y * sc &&
      p.dy <= (y + h) * sc;
}

class Device {
  final String id, type, model, label;
  final double x, y;
  const Device(this.id, this.type, this.x, this.y, this.model, this.label);

  double get innerR => type == 'ap' ? 13.0 : 10.0;

  bool hitTest(Offset p, double sc) {
    final r = (innerR + 5) * sc;
    final dx = p.dx - x * sc, dy = p.dy - y * sc;
    return math.sqrt(dx * dx + dy * dy) <= r;
  }
}

class Uplink {
  final double x;
  final String label;
  const Uplink(this.x, this.label);
}

class BRect {
  final double x, y, w, h;
  const BRect(this.x, this.y, this.w, this.h);
}

class Floor {
  final String id, label, sub;
  final double vw, vh;
  final List<BRect> bldg;
  final List<Room> rooms;
  final List<Device> devices;
  final List<Uplink> uplinks;
  const Floor(this.id, this.label, this.sub, this.vw, this.vh,
      this.bldg, this.rooms, this.devices, this.uplinks);
}

class _Sel {
  final String kind, id;
  const _Sel(this.kind, this.id);
}

// ─── Color Constants ──────────────────────────────────────────────────────────

const _rt = {
  'class':    _RC(Color(0xFFE6F1FB), Color(0xFF185FA5), Color(0xFF0C447C)),
  'office':   _RC(Color(0xFFF1EFE8), Color(0xFF888780), Color(0xFF444441)),
  'lab':      _RC(Color(0xFFE1F5EE), Color(0xFF1D9E75), Color(0xFF085041)),
  'special':  _RC(Color(0xFFEEEDFE), Color(0xFF7F77DD), Color(0xFF3C3489)),
  'corridor': _RC(Color(0xFFFAFAF8), Color(0xFFD3D1C7), Color(0xFFB4B2A9)),
};

const _dt = {
  'ap':     _DC(Color(0xFFE1F5EE), Color(0xFF0F6E56), Color(0xFF085041), 'Access point'),
  'switch': _DC(Color(0xFFFAEEDA), Color(0xFFBA7517), Color(0xFF633806), 'Switch'),
  'core':   _DC(Color(0xFFEEEDFE), Color(0xFF7F77DD), Color(0xFF3C3489), 'Core switch'),
};

const _tl = {
  'class': 'Classroom', 'office': 'Office', 'lab': 'Laboratory',
  'special': 'Special', 'corridor': 'Corridor',
};

// ─── Floor Data ───────────────────────────────────────────────────────────────

const _floors = <Floor>[
  Floor('0', 'О давхар', 'Ground floor', 1100, 445,
    [BRect(10, 10, 260, 430), BRect(270, 10, 820, 315)],
    [
      Room('008', 10,  10,  130, 160, 'Склад-2', 'office'),
      Room('009', 10,  170, 130, 80,  'Дадлагын газар', 'lab'),
      Room('010', 10,  250, 130, 80,  'Металл судлалын лаборатори', 'lab'),
      Room('011', 10,  330, 130, 110, 'Токарын лаборатори', 'lab'),
      Room('012', 140, 330, 130, 110, 'Авто оношилгоо засварын газар', 'lab'),
      Room('006', 270, 330, 100, 110, 'Склад-1', 'office'),
      Room('007', 370, 330, 100, 110, 'Ажилчдын өрөо', 'office'),
      Room('005', 470, 330, 100, 110, 'Багш нарын өрөо', 'office'),
      Room('004', 570, 330, 100, 110, 'Мужааны өрөо', 'office'),
      Room('003', 670, 330, 120, 110, 'Хичзэлийн танхим', 'class'),
      Room('015', 270, 10,  150, 130, 'Симуляторын лаборатори', 'lab'),
      Room('016', 270, 140, 150, 80,  'Багш нарын өрөо', 'office'),
      Room('014', 420, 10,  140, 210, 'Хичзэлийн танхим', 'class'),
      Room('013', 560, 10,  140, 110, 'Багш нарын өрөо', 'office'),
      Room('017', 560, 220, 90,  80,  'ШИТ-ны өрөо', 'office'),
      Room('018', 650, 220, 80,  80,  'Ажилчдын өрөо', 'office'),
      Room('019', 730, 220, 80,  80,  'Багш нарын өрөо', 'office'),
      Room('020', 810, 220, 80,  80,  'Цахилгааны лаб-1', 'lab'),
      Room('021', 890, 220, 80,  80,  'Цахилгааны лаб-2', 'lab'),
      Room('022', 700, 10,  140, 110, 'Гидрометаллургийн лаборатори', 'lab'),
      Room('023', 840, 10,  130, 110, 'Хими, Гидравлик лаборатори', 'lab'),
      Room('024', 970, 10,  120, 110, 'Мэргэжлийн сургалтын склад', 'office'),
      Room('001', 800, 330, 150, 110, 'Виртуал лаборатори', 'lab'),
      Room('002', 950, 330, 140, 110, 'ХАБЭА-н лаборатори', 'lab'),
    ],
    [
      Device('gw01', 'ap',     155, 270, 'GWN7610',             'AP-1'),
      Device('gw02', 'ap',     345, 210, 'GWN7610',             'AP-2'),
      Device('gw03', 'ap',     895, 395, 'GWN7610',             'AP-3'),
      Device('sw01', 'switch', 390, 175, 'TPlink 28 port',      'SW-1'),
      Device('sw02', 'switch', 670, 175, 'TPlink 28 port',      'SW-2'),
      Device('sw03', 'switch', 840, 155, 'CISCO SG-350 28port', 'SW-3'),
    ],
    [Uplink(390, '110-Up'), Uplink(670, '107-Up')],
  ),

  Floor('1', '1 давхар', 'First floor', 1340, 450,
    [BRect(10, 0, 1200, 450), BRect(830, 0, 500, 290)],
    [
      Room('106', 10,   300, 100, 140, 'Хичзэлийн танхим',  'class'),
      Room('105', 110,  300, 100, 140, 'Албан өрөо',        'office'),
      Room('104', 210,  300, 100, 140, 'Хичзэлийн танхим',  'class'),
      Room('103', 310,  300, 100, 140, 'Хичзэлийн танхим',  'class'),
      Room('102', 410,  300, 100, 140, 'Хичзэлийн танхим',  'class'),
      Room('101', 510,  300, 100, 140, 'Хичзэлийн танхим',  'class'),
      Room('107', 610,  300, 80,  140, 'Албан өрөо',        'office'),
      Room('108', 690,  300, 80,  140, 'Багш нарын өрөо',   'office'),
      Room('109', 770,  300, 80,  140, 'Багш нарын өрөо',   'office'),
      Room('110', 850,  300, 80,  140, 'Албан өрөо',        'office'),
      Room('111', 930,  300, 80,  140, 'Багш нарын өрөо',   'office'),
      Room('112', 1010, 300, 70,  140, 'Албан өрөо',        'office'),
      Room('113', 1080, 300, 70,  140, 'Албан өрөо',        'office'),
      Room('114', 1150, 300, 70,  140, 'Албан өрөо',        'office'),
      Room('r23', 830,  10,  90,  80,  'Коридор',           'corridor'),
      Room('r22', 920,  10,  85,  80,  '00-н өрөо',         'office'),
      Room('r21', 1005, 10,  80,  80,  'Агаарнуулалт',      'office'),
      Room('r20', 1085, 10,  80,  80,  'Серрийн өрөо',      'office'),
      Room('r19', 1165, 10,  80,  80,  'Коридор',           'corridor'),
      Room('r18', 1245, 10,  85,  80,  'Мэдэзлэлийн тев',   'office'),
      Room('r13', 920,  90,  90,  80,  'Коридор',           'corridor'),
      Room('r14', 1010, 90,  90,  80,  'ШИТ-ний өрөо',      'office'),
      Room('r12', 1100, 90,  90,  80,  'Албан өрөо',        'office'),
      Room('r11', 1190, 90,  140, 80,  'Хоолны зал',        'special'),
      Room('r9',  830,  170, 100, 80,  'Албан өрөо',        'office'),
      Room('r10', 930,  170, 80,  80,  'СКЛАД',             'office'),
      Room('r2',  1190, 170, 140, 130, 'Номын фонд',        'special'),
      Room('r5',  1220, 300, 110, 140, 'Vip өрөо',          'special'),
    ],
    [
      Device('tp1', 'switch', 130,  280, 'TPlink 8 port',            'SW-1'),
      Device('cs1', 'switch', 880,  280, 'CISCO SG-360 28port',      'SW-2'),
      Device('tp2', 'switch', 1040, 280, 'TPlink 8 port',            'SW-3'),
      Device('cat', 'core',   1080, 240, 'Cisco Catalyst 2960 48P',  'Core'),
      Device('gw1', 'ap',     1050, 430, 'GWN7660',                  'AP-1'),
      Device('gw2', 'ap',     1120, 430, 'GWN7660',                  'AP-2'),
      Device('cs2', 'switch', 1060, 155, 'CISCO SG-350 28port',      'SW-4'),
      Device('cs3', 'switch', 1240, 265, 'CISCO SF300 24port',       'SW-5'),
      Device('gw3', 'ap',     1200, 48,  'GWN7615 026',              'AP-3'),
    ],
    [Uplink(300, 'MT-Up'), Uplink(1050, '203-Up'), Uplink(1150, 'ОБ-up')],
  ),

  Floor('2', '2 давхар', 'Second floor', 1340, 450,
    [BRect(10, 0, 1200, 450), BRect(1210, 0, 120, 450)],
    [
      Room('207', 10,   300, 100, 140, 'Захирлын өрөо',          'special'),
      Room('208', 110,  300, 100, 140, 'Албан өрөо',             'office'),
      Room('209', 210,  300, 100, 140, 'Сургалт дэд захирал',    'special'),
      Room('210', 310,  300, 90,  140, 'Албан өрөо',             'office'),
      Room('211', 400,  300, 90,  140, 'Албан өрөо',             'office'),
      Room('212', 490,  300, 90,  140, 'Багш нарын өрөо',        'office'),
      Room('213', 580,  300, 90,  140, 'Багш нарын өрөо',        'office'),
      Room('206', 670,  300, 90,  140, 'Эрдмийн зовлол',         'special'),
      Room('205', 760,  300, 90,  140, 'Албан өрөо',             'office'),
      Room('204', 850,  300, 90,  140, 'Багш нарын өрөо',        'office'),
      Room('203', 940,  300, 80,  140, 'Багш нарын өрөо',        'office'),
      Room('202', 1020, 300, 90,  140, '30-ком лаб',             'lab'),
      Room('201', 1110, 300, 100, 140, 'Фонд',                   'office'),
      Room('e7',  1210, 10,  120, 80,  'Спорт зал',              'special'),
      Room('e11', 1210, 90,  65,  80,  'Багшийн өрөо',           'office'),
      Room('e14', 1210, 170, 65,  80,  'Хүндэтгалийн танхим',    'special'),
      Room('e1',  1275, 90,  65,  360, 'Лекцийн зал',            'class'),
      Room('e15', 1110, 10,  100, 130, '(зона 15)',               'corridor'),
      Room('e9',  1110, 140, 100, 80,  'Хүвцас солих өрөо',      'office'),
    ],
    [
      Device('gw1', 'ap',     55,   280, 'GWN7615',             'AP-1'),
      Device('gw2', 'ap',     880,  430, 'GWN7660',             'AP-2'),
      Device('cat', 'core',   880,  280, 'CISCO Cat2960 48P',   'Core'),
      Device('gw3', 'ap',     1145, 95,  'GWN7615',             'AP-3'),
      Device('gw4', 'ap',     1307, 350, 'GWN7660',             'AP-4'),
      Device('gw5', 'ap',     1240, 240, 'GWN7615',             'AP-5'),
      Device('tp1', 'switch', 1165, 170, 'TPlink 16P',          'SW-1'),
      Device('tp2', 'switch', 1165, 255, 'TPlink 16P',          'SW-2'),
    ],
    [Uplink(940, '3дав Up306'), Uplink(1025, '1дав Up110'), Uplink(1110, 'Server-up')],
  ),

  Floor('3', '3 давхар', 'Third floor', 1000, 380,
    [BRect(10, 10, 780, 360), BRect(790, 10, 200, 360)],
    [
      Room('307',  150, 10,  90,  100, 'Багш нарын өрөо',      'office'),
      Room('308',  240, 10,  90,  100, 'Агаажуулалтын өрөо',   'office'),
      Room('309',  330, 10,  90,  100, 'Багш нарын өрөо',      'office'),
      Room('310',  420, 10,  90,  100, 'Багш нарын өрөо',      'office'),
      Room('311',  510, 10,  90,  100, 'Багш нарын өрөо',      'office'),
      Room('312',  600, 10,  90,  100, 'Агаажуулалтын өрөо',   'office'),
      Room('313',  690, 10,  90,  100, 'Багш нарын өрөо',      'office'),
      Room('305',  240, 250, 110, 120, 'Хичзэлийн танхим',     'class'),
      Room('304',  350, 250, 110, 120, 'Хичзэлийн танхим',     'class'),
      Room('303',  460, 250, 110, 120, 'Хичзэлийн танхим',     'class'),
      Room('302',  570, 250, 110, 120, 'Хичзэлийн танхим',     'class'),
      Room('301',  680, 250, 110, 120, 'Архив',                'office'),
      Room('306',  150, 200, 90,  170, '30-ком лаб',           'lab'),
      Room('306a', 60,  200, 90,  170, '10-ком лаб (А)',        'lab'),
      Room('306b', 10,  100, 140, 100, 'Багш нарын өрөо',      'office'),
      Room('rw',   790, 10,  200, 360, 'Багш нар зона',        'office'),
    ],
    [
      Device('lgs',  'switch', 185, 225, 'Linksys LGS28P', 'SW-1'),
      Device('tp24', 'switch', 95,  355, 'TPlink 24port',  'SW-2'),
      Device('tp8',  'switch', 545, 55,  'TPlink 8port',   'SW-3'),
      Device('gw1',  'ap',     20,  348, 'GWN7610',        'AP-1'),
      Device('gw2',  'ap',     792, 200, 'GWN7610',        'AP-2'),
    ],
    [Uplink(185, '203-up')],
  ),
];

// ─── App Root ─────────────────────────────────────────────────────────────────

class CampusMapApp extends StatelessWidget {
  const CampusMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Network Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185FA5)),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const CampusMapPage(),
    );
  }
}

// ─── Main Page ────────────────────────────────────────────────────────────────

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});
  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  String _fid = '1';
  _Sel? _sel;

  Floor get _floor => _floors.firstWhere((f) => f.id == _fid);

  void _pick(String kind, String id) {
    setState(() {
      _sel = (_sel?.id == id && _sel?.kind == kind) ? null : _Sel(kind, id);
    });
  }

  void _handleTap(Offset localPos, double scale) {
    final fl = _floor;
    for (final d in fl.devices.reversed) {
      if (d.hitTest(localPos, scale)) { _pick('d', d.id); return; }
    }
    for (final r in fl.rooms.reversed) {
      if (r.hitTest(localPos, scale)) { _pick('r', r.id); return; }
    }
    setState(() => _sel = null);
  }

  @override
  Widget build(BuildContext context) {
    final fl = _floor;
    final aps = fl.devices.where((d) => d.type == 'ap').length;
    final sws = fl.devices.where((d) => d.type != 'ap').length;
    final selRoom = (_sel?.kind == 'r')
        ? fl.rooms.cast<Room?>().firstWhere((r) => r!.id == _sel!.id, orElse: () => null)
        : null;
    final selDev = (_sel?.kind == 'd')
        ? fl.devices.cast<Device?>().firstWhere((d) => d!.id == _sel!.id, orElse: () => null)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Campus map',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A18))),
                    Text('Хичзэлийн I байр  •  tap rooms or devices',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ]),
                  const Spacer(),
                  _StatChip(value: fl.rooms.length.toString(), label: 'rooms',
                      color: const Color(0xFF666664)),
                  const SizedBox(width: 6),
                  _StatChip(value: aps.toString(), label: 'APs',
                      color: const Color(0xFF0F6E56)),
                  const SizedBox(width: 6),
                  _StatChip(value: sws.toString(), label: 'switches',
                      color: const Color(0xFF854F0B)),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E3DB)),
              const SizedBox(height: 10),

              // ── Floor tabs ──
              Row(children: [
                Wrap(spacing: 6, children: _floors.map((f) => _FloorTab(
                  label: f.label,
                  selected: f.id == _fid,
                  onTap: () => setState(() { _fid = f.id; _sel = null; }),
                )).toList()),
                const Spacer(),
                Text(fl.sub,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ]),
              const SizedBox(height: 10),

              // ── Map + panel ──
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F2EF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE5E3DB), width: 0.5),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(children: [
                          Expanded(child: _MapCanvas(
                            floor: fl,
                            sel: _sel,
                            onTap: _handleTap,
                          )),
                          const SizedBox(height: 8),
                          const Divider(height: 1, thickness: 0.5,
                              color: Color(0xFFE5E3DB)),
                          const SizedBox(height: 8),
                          const _LegendBar(),
                        ]),
                      ),
                    ),
                    if (selRoom != null || selDev != null) ...[
                      const SizedBox(width: 10),
                      _DetailPanel(
                        floor: fl,
                        room: selRoom,
                        device: selDev,
                        onDismiss: () => setState(() => _sel = null),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatChip({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFEFEEEB),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,
          color: color, height: 1.1, fontFamily: 'monospace')),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    ]),
  );
}

// ─── Floor Tab ────────────────────────────────────────────────────────────────

class _FloorTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FloorTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFDCECFD) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? const Color(0xFF378ADD) : const Color(0xFFD3D1C7),
          width: 0.5,
        ),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
        color: selected ? const Color(0xFF0C447C) : const Color(0xFF666664),
      )),
    ),
  );
}

// ─── Map Canvas ───────────────────────────────────────────────────────────────

class _MapCanvas extends StatelessWidget {
  final Floor floor;
  final _Sel? sel;
  final void Function(Offset pos, double scale) onTap;

  const _MapCanvas({required this.floor, required this.sel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final availableW = math.max(constraints.maxWidth, 480.0);
      final scale = availableW / floor.vw;
      final mapW = floor.vw * scale;
      final mapH = floor.vh * scale;

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: GestureDetector(
              onTapDown: (details) => onTap(details.localPosition, scale),
              child: CustomPaint(
                size: Size(mapW, mapH),
                painter: _FloorPainter(floor, sel, scale),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Floor Painter ────────────────────────────────────────────────────────────

class _FloorPainter extends CustomPainter {
  final Floor fl;
  final _Sel? sel;
  final double sc;

  const _FloorPainter(this.fl, this.sel, this.sc);

  @override
  bool shouldRepaint(_FloorPainter old) =>
      old.fl != fl || old.sel?.id != sel?.id || old.sel?.kind != sel?.kind ||
      old.sc != sc;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawBuildings(canvas);
    _drawUplinks(canvas);
    _drawRooms(canvas);
    _drawDevices(canvas);
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD3D1C7).withAlpha(77)
      ..strokeWidth = 0.3 * sc
      ..style = PaintingStyle.stroke;
    final path = Path();
    final step = 40.0 * sc;
    for (double x = 0; x <= size.width + step; x += step) {
      path.moveTo(x, 0); path.lineTo(x, size.height);
    }
    for (double y = 0; y <= size.height + step; y += step) {
      path.moveTo(0, y); path.lineTo(size.width, y);
    }
    canvas.drawPath(path, paint);
  }

  // ── Buildings ─────────────────────────────────────────────────────────────

  void _drawBuildings(Canvas canvas) {
    final fill  = Paint()..color = const Color(0xFFF9F8F6);
    final stroke = Paint()
      ..color = const Color(0xFFB4B2A9)
      ..strokeWidth = 0.5 * sc
      ..style = PaintingStyle.stroke;
    for (final b in fl.bldg) {
      final rr = RRect.fromRectAndRadius(
          Rect.fromLTWH(b.x * sc, b.y * sc, b.w * sc, b.h * sc),
          Radius.circular(4 * sc));
      canvas.drawRRect(rr, fill);
      canvas.drawRRect(rr, stroke);
    }
  }

  // ── Uplinks ───────────────────────────────────────────────────────────────

  void _drawUplinks(Canvas canvas) {
    final linePaint = Paint()
      ..color = const Color(0xFF378ADD).withAlpha(127)
      ..strokeWidth = 1 * sc
      ..style = PaintingStyle.stroke;
    for (final u in fl.uplinks) {
      final x = u.x * sc;
      _dashedLine(canvas, Offset(x, 0), Offset(x, fl.vh * sc), linePaint,
          5 * sc, 4 * sc);
      // label box
      const boxW = 48.0; const boxH = 15.0;
      final bl = x - boxW * sc / 2;
      final br = Rect.fromLTWH(bl, 2 * sc, boxW * sc, boxH * sc);
      final brr = RRect.fromRectAndRadius(br, Radius.circular(2 * sc));
      canvas.drawRRect(brr, Paint()..color = const Color(0xFFE6F1FB));
      canvas.drawRRect(brr, Paint()
        ..color = const Color(0xFF378ADD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * sc);
      _text(canvas, u.label,
        Offset(x, (2 + boxH / 2 + 1) * sc),
        fontSize: 7.5 * sc,
        color: const Color(0xFF0C447C),
        align: TextAlign.center,
        fontFamily: 'monospace');
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint,
      double dash, double gap) {
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len, uy = dy / len;
    var dist = 0.0;
    var draw = true;
    var cx = a.dx, cy = a.dy;
    while (dist < len) {
      final seg = draw ? dash : gap;
      final end = math.min(dist + seg, len);
      final ex = a.dx + ux * end, ey = a.dy + uy * end;
      if (draw) canvas.drawLine(Offset(cx, cy), Offset(ex, ey), paint);
      cx = ex; cy = ey; dist = end; draw = !draw;
    }
  }

  // ── Rooms ─────────────────────────────────────────────────────────────────

  void _drawRooms(Canvas canvas) {
    for (final r in fl.rooms) {
      final c = _rt[r.type] ?? _rt['office']!;
      final isSel = sel?.kind == 'r' && sel?.id == r.id;
      final rect = Rect.fromLTWH(r.x * sc, r.y * sc, r.w * sc, r.h * sc);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(2 * sc));
      canvas.drawRRect(rr,
          Paint()..color = isSel ? const Color(0xFFB5D4F4) : c.f);
      canvas.drawRRect(rr, Paint()
        ..color = isSel ? const Color(0xFF185FA5) : c.s
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isSel ? 2 : 0.8) * sc);
      // Room ID
      _text(canvas, r.id,
        Offset((r.x + 4) * sc, (r.y + 12) * sc),
        fontSize: 8.5 * sc,
        color: isSel ? const Color(0xFF0C447C) : c.t,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace');
      // Room name (only if tall enough)
      if (r.h > 35) {
        final name = r.name.length > 14
            ? '${r.name.substring(0, 13)}\u2026'
            : r.name;
        _text(canvas, name,
          Offset((r.x + 4) * sc, (r.y + 23) * sc),
          fontSize: 7.5 * sc,
          color: isSel ? const Color(0xFF185FA5) : c.t,
          alpha: (0.85 * 255).round());
      }
    }
  }

  // ── Devices ───────────────────────────────────────────────────────────────

  void _drawDevices(Canvas canvas) {
    for (final d in fl.devices) {
      final c = _dt[d.type] ?? _dt['switch']!;
      final isSel = sel?.kind == 'd' && sel?.id == d.id;
      final inner = d.innerR * sc;
      final outer = inner + 5 * sc;
      final cx = d.x * sc, cy = d.y * sc;
      final center = Offset(cx, cy);

      // Outer ring fill
      canvas.drawCircle(center, outer,
          Paint()..color = (isSel ? c.s : c.f).withAlpha(64));
      // Outer ring dashed stroke
      _dashedCircle(canvas, center, outer, Paint()
        ..color = c.s
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * sc, 3 * sc, 2 * sc);

      // Inner circle
      canvas.drawCircle(center, inner,
          Paint()..color = isSel ? c.s : c.f);
      canvas.drawCircle(center, inner, Paint()
        ..color = c.s
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isSel ? 2 : 1.2) * sc);

      // Label
      _text(canvas, d.label,
        Offset(cx, cy + 3.5 * sc),
        fontSize: 6.5 * sc,
        color: isSel ? Colors.white : c.t,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
        align: TextAlign.center);
    }
  }

  void _dashedCircle(Canvas canvas, Offset center, double radius,
      Paint paint, double dash, double gap) {
    final circumference = 2 * math.pi * radius;
    var dist = 0.0;
    var draw = true;
    while (dist < circumference) {
      final seg = draw ? dash : gap;
      final endDist = math.min(dist + seg, circumference);
      if (draw) {
        final startA = dist / radius;
        final sweepA = (endDist - dist) / radius;
        final path = Path()
          ..addArc(Rect.fromCircle(center: center, radius: radius),
              startA - math.pi / 2, sweepA);
        canvas.drawPath(path, paint);
      }
      dist = endDist;
      draw = !draw;
    }
  }

  // ── Text helper ───────────────────────────────────────────────────────────

  void _text(Canvas canvas, String text, Offset pos, {
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    String? fontFamily,
    TextAlign align = TextAlign.left,
    int alpha = 255,
  }) {
    final effectiveColor = alpha < 255
        ? color.withAlpha(alpha)
        : color;
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        fontSize: fontSize,
        color: effectiveColor,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
      )),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: 300 * sc);

    final Offset paintOffset;
    if (align == TextAlign.center) {
      // pos is the center point
      paintOffset = pos - Offset(tp.width / 2, tp.height / 2);
    } else {
      // pos is the baseline-left; approximate baseline as 80% of height
      paintOffset = Offset(pos.dx, pos.dy - tp.height * 0.8);
    }
    tp.paint(canvas, paintOffset);
  }
}

// ─── Legend Bar ───────────────────────────────────────────────────────────────

class _LegendBar extends StatelessWidget {
  const _LegendBar();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 4,
    children: [
      _chip(const Color(0xFFE6F1FB), const Color(0xFF185FA5), 'Classroom',    false),
      _chip(const Color(0xFFE1F5EE), const Color(0xFF1D9E75), 'Lab',          false),
      _chip(const Color(0xFFEEEDFE), const Color(0xFF7F77DD), 'Special',      false),
      _chip(const Color(0xFFF1EFE8), const Color(0xFF888780), 'Office',       false),
      _chip(const Color(0xFFE1F5EE), const Color(0xFF0F6E56), 'Access point', true),
      _chip(const Color(0xFFFAEEDA), const Color(0xFFBA7517), 'Switch',       true),
      _chip(const Color(0xFFEEEDFE), const Color(0xFF7F77DD), 'Core switch',  true),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 16, height: 2,
            color: const Color(0xFF378ADD).withAlpha(153)),
        const SizedBox(width: 4),
        Text('Uplink', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ]),
    ],
  );

  Widget _chip(Color fill, Color stroke, String label, bool circle) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10, height: circle ? 10 : 8,
        decoration: BoxDecoration(
          color: fill,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(2),
          border: Border.all(color: stroke, width: 1),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    ],
  );
}

// ─── Detail Panel ─────────────────────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  final Floor floor;
  final Room? room;
  final Device? device;
  final VoidCallback onDismiss;

  const _DetailPanel({
    required this.floor,
    this.room,
    this.device,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 200,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E3DB), width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (room != null) _roomBody(room!),
        if (device != null) _deviceBody(device!),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Dismiss',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF888780))),
          ),
        ),
      ],
    ),
  );

  Widget _roomBody(Room r) {
    final c = _rt[r.type] ?? _rt['office']!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ROOM', style: TextStyle(fontSize: 10, color: Colors.grey[400],
          letterSpacing: 0.5)),
      const SizedBox(height: 3),
      Text(r.id, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500,
          fontFamily: 'monospace', color: Color(0xFF1A1A18))),
      const SizedBox(height: 6),
      Text(r.name, style: const TextStyle(fontSize: 13, height: 1.4,
          color: Color(0xFF1A1A18))),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: c.f, borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.s, width: 0.5),
        ),
        child: Text(_tl[r.type] ?? r.type,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                color: c.t)),
      ),
      const SizedBox(height: 10),
      Text('${floor.label} · ${floor.sub}',
          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    ]);
  }

  Widget _deviceBody(Device d) {
    final c = _dt[d.type] ?? _dt['switch']!;
    final rows = <({String label, String value, bool mono, bool ok})>[
      (label: 'Model',  value: d.model,    mono: true,  ok: false),
      (label: 'Type',   value: c.lbl,      mono: false, ok: false),
      (label: 'Floor',  value: floor.label, mono: false, ok: false),
      (label: 'Status', value: 'Online',   mono: false, ok: true),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('NETWORK DEVICE', style: TextStyle(fontSize: 10, color: Colors.grey[400],
          letterSpacing: 0.5)),
      const SizedBox(height: 3),
      Text(d.label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A18))),
      const SizedBox(height: 10),
      ...rows.map((row) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEFEEEB), width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 6),
            Flexible(child: Text(row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: row.ok ? const Color(0xFF1D9E75) : const Color(0xFF1A1A18),
                fontFamily: row.mono ? 'monospace' : null,
              ),
            )),
          ],
        ),
      )),
    ]);
  }
}
