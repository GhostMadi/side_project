import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

enum IconSourceType { asset, network }

class MapMarker {
  final String id;
  final double lat;
  final double lng;
  final String iconPath;
  final IconSourceType sourceType;
  MapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    required this.iconPath,
    this.sourceType = IconSourceType.asset,
  });
}

class AppMap extends StatefulWidget {
  final List<MapMarker> markers;
  final Point initialCenter;
  final double initialZoom;
  final Function(String id)? onMarkerTap;

  const AppMap({
    super.key,
    required this.initialCenter,
    this.markers = const [],
    this.initialZoom = 14.0,
    this.onMarkerTap,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  MapboxMap? _mapboxMap;
  bool _isStyleLoaded = false;
  Timer? _debounceTimer;
  String _lastJsonState = "";

  static const double markerSize = 72.0;
  static const double collisionPadding = 12.0;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      onMapCreated: (map) => _mapboxMap = map,
      onStyleLoadedListener: (_) async {
        await _setupLayers();
        await _loadAllIcons();
      },
      onCameraChangeListener: (_) => _onCameraMove(),
      onTapListener: _handleMapTap,
    );
  }

  // 1. Быстрая загрузка иконок в память Mapbox (без кастомного рендеринга)
  Future<void> _loadAllIcons() async {
    final style = _mapboxMap?.style;
    if (style == null) return;

    for (var marker in widget.markers) {
      if (await style.hasStyleImage(marker.iconPath)) continue;
      try {
        Uint8List bytes = marker.sourceType == IconSourceType.network
            ? (await http.get(Uri.parse(marker.iconPath))).bodyBytes
            : (await rootBundle.load(marker.iconPath)).buffer.asUint8List();

        // Стилизуем одиночную картинку (рамка + скругление)
        final ui.Codec codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: 150,
          targetHeight: 150,
        );
        final ui.FrameInfo fi = await codec.getNextFrame();
        final styledImage = await _renderSingleMarker(fi.image);

        final byteData = await styledImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        await style.addStyleImage(
          marker.iconPath,
          MediaQuery.of(context).devicePixelRatio,
          MbxImage(
            width: styledImage.width,
            height: styledImage.height,
            data: byteData!.buffer.asUint8List(),
          ),
          false,
          [],
          [],
          null,
        );
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
    _updateClusters();
  }

  Future<ui.Image> _renderSingleMarker(ui.Image img) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const size = 150.0;
    final rect = const Rect.fromLTWH(0, 0, size, size);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(15));

    canvas.drawRRect(rrect.inflate(4), Paint()..color = Colors.white); // Рамка
    canvas.save();
    canvas.clipRRect(rrect);
    paintImage(canvas: canvas, rect: rect, image: img, fit: BoxFit.cover);
    canvas.restore();
    return await recorder.endRecording().toImage(size.round(), size.round());
  }

  // 2. Многослойная архитектура (GPU наложение)
  Future<void> _setupLayers() async {
    final style = _mapboxMap?.style;
    if (style == null) return;

    await style.addStyleSource(
      'cluster-source',
      jsonEncode({
        "type": "geojson",
        "data": {"type": "FeatureCollection", "features": []},
      }),
    );

    // Слои создаются от нижнего к верхнему
    await _addStackLayer(
      style,
      'layer-3',
      ['get', 'img3'],
      [-12, -16],
      -4,
    ); // Задняя
    await _addStackLayer(
      style,
      'layer-2',
      ['get', 'img2'],
      [-6, 12],
      4,
    ); // Средняя
    await _addStackLayer(
      style,
      'layer-1',
      ['get', 'img1'],
      [0, 0],
      0,
    ); // Главная

    setState(() => _isStyleLoaded = true);
  }

  Future<void> _addStackLayer(
    StyleManager style,
    String id,
    dynamic iconExpr,
    List<double> offset,
    double rotate,
  ) async {
    await style.addStyleLayer(
      jsonEncode({
        "id": id,
        "type": "symbol",
        "source": "cluster-source",
        "layout": {
          "icon-image": iconExpr,
          "icon-offset": offset,
          "icon-rotate": rotate,
          "icon-allow-overlap": true,
          "icon-ignore-placement": true,
          "icon-anchor": "center",
          "icon-size": [
            "interpolate",
            ["linear"],
            ["zoom"],
            10,
            0.35,
            14,
            0.75,
          ],
        },
        "paint": {
          "icon-opacity": [
            "case",
            ["==", iconExpr, ""],
            0,
            1,
          ],
        }, // Прячем пустые
      }),
      null,
    );
  }

  void _onCameraMove() {
    if (!_isStyleLoaded) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 32),
      () => _updateClusters(),
    );
  }

  // 3. Расчет коллизий
  void _updateClusters() async {
    if (_mapboxMap == null || !_isStyleLoaded) return;

    List<Map<String, dynamic>> points = [];
    for (var m in widget.markers) {
      final pixel = await _mapboxMap!.pixelForCoordinate(
        Point(coordinates: Position(m.lng, m.lat)),
      );
      points.add({'m': m, 'x': pixel.x, 'y': pixel.y, 'used': false});
    }

    List<Map<String, dynamic>> features = [];
    for (int i = 0; i < points.length; i++) {
      if (points[i]['used']) continue;
      points[i]['used'] = true;

      List<String> paths = [points[i]['m'].iconPath];
      Rect rectA = Rect.fromCenter(
        center: Offset(points[i]['x'], points[i]['y']),
        width: markerSize + collisionPadding,
        height: markerSize + collisionPadding,
      );

      for (int j = i + 1; j < points.length; j++) {
        if (points[j]['used']) continue;
        Rect rectB = Rect.fromCenter(
          center: Offset(points[j]['x'], points[j]['y']),
          width: markerSize + collisionPadding,
          height: markerSize + collisionPadding,
        );

        if (rectA.overlaps(rectB)) {
          points[j]['used'] = true;
          paths.add(points[j]['m'].iconPath);
          rectA = rectA.expandToInclude(rectB);
        }
      }

      features.add({
        "type": "Feature",
        "id": points[i]['m'].id,
        "geometry": {
          "type": "Point",
          "coordinates": [points[i]['m'].lng, points[i]['m'].lat],
        },
        "properties": {
          "id": points[i]['m'].id,
          "img1": paths[0],
          "img2": paths.length > 1 ? paths[1] : "",
          "img3": paths.length > 2 ? paths[2] : "",
        },
      });
    }

    final geojson = jsonEncode({
      "type": "FeatureCollection",
      "features": features,
    });
    if (_lastJsonState == geojson) return;
    _lastJsonState = geojson;

    await _mapboxMap!.style.setStyleSourceProperty(
      'cluster-source',
      'data',
      geojson,
    );
  }

  void _handleMapTap(MapContentGestureContext context) async {
    final features = await _mapboxMap?.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(context.touchPosition),
      RenderedQueryOptions(layerIds: ['layer-1']),
    );
    if (features != null && features.isNotEmpty) {
      final id = features.first?.queriedFeature.feature['id']?.toString();
      if (id != null) widget.onMarkerTap?.call(id);
    }
  }
}

extension ColorHex on Color {
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
}
