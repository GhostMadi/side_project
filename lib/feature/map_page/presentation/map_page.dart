import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/map_page/presentation/almaty_demo_markers.dart';
import 'package:side_project/feature/map_page/widget/ticket_bottom_sheet.dart';

@RoutePage()
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MapMarker> points = almatyDemoMarkers();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AppMapWidget(
        markers: points,
        initialLat: almatyCenterLat,
        initialLng: almatyCenterLng,
        initialZoom: 10.5,
        onMarkerTap: (marker) {
          AppBottomSheet.show(
            context: context,
            content: EventTicketDetailsSheet(marker: marker),
          );
        },
      ),
    );
  }
}
