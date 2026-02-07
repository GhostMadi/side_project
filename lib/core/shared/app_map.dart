import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:side_project/core/shared/service/generate_marker_.dart';

class MapMarker {
  final String id;
  final double lat;
  final double lng;
  final String emoji;
  final Map<String, dynamic>? metadata; // Для любых доп. данных

  MapMarker({required this.id, required this.lat, required this.lng, required this.emoji, this.metadata});
}

class AppMapWidget extends StatefulWidget {
  final List<MapMarker> markers;
  final void Function(MapMarker marker)? onMarkerTap;
  final double initialLat;
  final double initialLng;
  final double initialZoom;

  const AppMapWidget({
    super.key,
    required this.markers,
    this.onMarkerTap,
    this.initialLat = 55.7558,
    this.initialLng = 37.6173,
    this.initialZoom = 12.0,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> implements OnPointAnnotationClickListener {
  PointAnnotationManager? _annotationManager;
  MapboxMap? _mapboxMap;

  // Используем кэш ID, так как это самый стабильный способ в текущем SDK
  final Map<String, MapMarker> _mapboxIdToMarker = {};

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    HapticFeedback.lightImpact();

    // Мгновенно находим наш маркер по внутреннему ID Mapbox
    final marker = _mapboxIdToMarker[annotation.id];
    if (marker != null) {
      widget.onMarkerTap?.call(marker);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    mapboxMap.annotations.createPointAnnotationManager().then((manager) {
      if (!mounted) return;
      _annotationManager = manager;

      // Регистрируем слушатель
      manager.addOnPointAnnotationClickListener(this);
      _syncMarkers();
    });
  }

  Future<void> _syncMarkers() async {
    final manager = _annotationManager;
    if (manager == null || !mounted) return;

    await manager.deleteAll();
    _mapboxIdToMarker.clear();

    final List<PointAnnotationOptions> options = await Future.wait(
      widget.markers.map((m) async {
        final Uint8List? imageBytes = await MarkerGeneratorService.createEmojiMarker(m.emoji);

        return PointAnnotationOptions(
          geometry: Point(coordinates: Position(m.lng, m.lat)),
          image: imageBytes,
          iconSize: 0.5,
          iconAnchor: IconAnchor.CENTER,
        );
      }),
    );

    if (mounted) {
      // Создаем аннотации и сохраняем их ID для связи
      final annotations = await manager.createMulti(options);

      for (int i = 0; i < annotations.length; i++) {
        final ann = annotations[i];
        if (ann != null) {
          _mapboxIdToMarker[ann.id] = widget.markers[i];
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.markers != oldWidget.markers) {
      _syncMarkers();
    }
  }

  @override
  void dispose() {
    // Исправленное название метода удаления слушателя
    _annotationManager?.deleteAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey("mapbox_map_core"),
      onMapCreated: _onMapCreated,
      styleUri: MapboxStyles.MAPBOX_STREETS,
      textureView: true,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(widget.initialLng, widget.initialLat)),
        zoom: widget.initialZoom,
      ),
      mapOptions: MapOptions(pixelRatio: MediaQuery.of(context).devicePixelRatio),
    );
  }
}
