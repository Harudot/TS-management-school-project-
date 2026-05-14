import 'dart:async';
import 'package:flutter/material.dart';

/// One clickable area on a floor‑plan.
class Hotspot {
  /// Rectangle expressed in the original image pixel coordinates.
  final Rect rect;
  final String label;
  final VoidCallback onTap;

  const Hotspot({required this.rect, required this.label, required this.onTap});
}

/// Widget that displays a floor‑plan image and a set of tappable hotspots.
///
/// * `imageAsset` – path to the PNG in `assets/`.
/// * `hotspots` – list of clickable rectangles.
/// * `startPoint` – optional marker (e.g. the building entry).
class FloorMapWidget extends StatelessWidget {
  final String imageAsset;
  final List<Hotspot> hotspots;
  final Offset? startPoint;

  const FloorMapWidget({
    super.key,
    required this.imageAsset,
    required this.hotspots,
    this.startPoint,
  });

  @override
  Widget build(BuildContext context) {
    // Load the image to know its natural size.
    return FutureBuilder<Size>(
      future: _imageSize(context, imageAsset),
      builder: (c, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final Size imgSize = snapshot.data!;

        // Build hotspot widgets positioned relative to the image size.
        final List<Widget> hotspotWidgets = hotspots.map((hs) {
          final double left = hs.rect.left / imgSize.width * imgSize.width;
          final double top = hs.rect.top / imgSize.height * imgSize.height;
          final double width = hs.rect.width / imgSize.width * imgSize.width;
          final double height = hs.rect.height / imgSize.height * imgSize.height;

          return Positioned(
            left: left,
            top: top,
            width: width,
            height: height,
            child: GestureDetector(
              onTap: hs.onTap,
              child: Container(
                color: Colors.transparent,
                // Uncomment for debugging bounds:
                // decoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 1)),
              ),
            ),
          );
        }).toList();

        // Optional entry marker.
        if (startPoint != null) {
          hotspotWidgets.add(
            Positioned(
              left: startPoint!.dx,
              top: startPoint!.dy,
              child: const Icon(Icons.location_on, color: Colors.blue, size: 28),
            ),
          );
        }

        return InteractiveViewer(
          constrained: false,
          child: Stack(
            children: [
              Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Text('Map image not found', style: TextStyle(color: Colors.red)),
                ),
              ),
              ...hotspotWidgets,
            ],
          ),
        );
      },
    );
  }

  // Helper to read image dimensions.
  Future<Size> _imageSize(BuildContext ctx, String asset) async {
    final ImageProvider provider = AssetImage(asset);
    final Completer<Size> completer = Completer<Size>();
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
    }));
    return completer.future;
  }
}
