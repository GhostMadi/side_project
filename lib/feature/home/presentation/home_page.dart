import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/home/widget/ticket_bottom_sheet.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Формируем список моделей (теперь с ID и четкой структурой)
    final List<MapMarker> points = [
      MapMarker(id: "kremlin", lat: 55.7539, lng: 37.6208, emoji: "🤡"),
      MapMarker(id: "theater", lat: 55.7602, lng: 37.6186, emoji: "🎭"),
      MapMarker(id: "park", lat: 55.7286, lng: 37.6041, emoji: "🌳"),
    ];

    return Scaffold(
      body: AppMapWidget(
        markers: points, // Передаем список моделей
        initialLat: 55.7539,
        initialLng: 37.6208,
        initialZoom: 11.0,
        onMarkerTap: (marker) {
          AppBottomSheet.show(context: context, content: const EventTicketDetailsSheet());
        },
      ),
    );
  }
}
