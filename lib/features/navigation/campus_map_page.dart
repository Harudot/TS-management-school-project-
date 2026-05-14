import 'package:flutter/widgets.dart';

import 'package:ts_management/features/navigation/map_page.dart';

/// Legacy route wrapper kept for compatibility.
/// Shows the building map list instead of the old network topology map.
class CampusMapPage extends StatelessWidget {
  const CampusMapPage({super.key});

  @override
  Widget build(BuildContext context) => const MapPage();
}
