import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final _ctrl = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_processing) return;
    final raw = cap.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _processing = true;
    final id = _extractBuildingId(raw);
    final building = await ref.read(buildingsRepositoryProvider).get(id);
    if (!mounted) return;
    if (building == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unknown building: $id')),
      );
      _processing = false;
      return;
    }
    context.push('/building/$id');
    Future.delayed(const Duration(seconds: 1), () => _processing = false);
  }

  String _extractBuildingId(String raw) {
    if (raw.startsWith('campus://')) {
      return raw.substring('campus://'.length).split('/').first;
    }
    return raw.trim();
  }

  Future<void> _openDemoBuilding() async {
    const demoId = 'main';
    final repo = ref.read(buildingsRepositoryProvider);
    try {
      final existing = await repo.get(demoId);
      if (existing == null) {
        await repo.upsert(Building(
          id: demoId,
          name: 'Main Campus Building',
          address: 'Erdenet Institute of Technology, Erdenet, Mongolia',
          floorCount: 3,
          companies: ['Computer Science', 'Engineering', 'Administration'],
        ));
      }
      if (!mounted) return;
      context.push('/building/$demoId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demo failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(controller: _ctrl, onDetect: _onDetect),
        const _ScannerOverlay(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scan QR',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          Text('Point at the building QR code',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => _ctrl.toggleTorch(),
                      icon: const Icon(Icons.flashlight_on_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openDemoBuilding,
                  icon: const Icon(Icons.bug_report_rounded),
                  label: const Text('Demo: open Main Campus Building'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _CutoutPainter(),
    );
  }
}

class _CutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hole = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black54);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const len = 28.0;
    void corner(Offset o, double dx, double dy) {
      canvas.drawLine(o, Offset(o.dx + len * dx, o.dy), paint);
      canvas.drawLine(o, Offset(o.dx, o.dy + len * dy), paint);
    }

    corner(hole.topLeft, 1, 1);
    corner(hole.topRight, -1, 1);
    corner(hole.bottomLeft, 1, -1);
    corner(hole.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
