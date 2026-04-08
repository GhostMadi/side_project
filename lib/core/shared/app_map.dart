// Карта: Yandex MapKit (плагин yandex_mapkit). Ключ API — в MainApplication.kt / AppDelegate.swift.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/shared/service/generate_marker_.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Тип контроллера карты для колбэков ([AppMapWidget.onMapReady]).
typedef AppMapController = YandexMapController;

const _kMapIconSizeSingle = 0.5;
const _kMapIconSizeScatter = 0.36;

/// Множитель к [iconSize] для [PlacemarkIconStyle.scale] (Yandex). Меньше — мельче маркеры на карте.
const double _kYandexMarkerScaleMul = 1.8;

const int _kCylinderMaxHalfWidth = 2;
const double _kCylinderAngleStepRad = 0.30;
const double _kCylinderRadiusY = 20.0;
const double _kCylinderDepthX = 12.5;
const double _kCylinderTiltDegPerSlot = 6.2;
const double _kCylinderCenterMagnification = 1.2;
const int _kCylinderVirtualUrlRepeatCount = 3;

/// При ≥ этого числа маркеров — компактный декод bitmap и реже обновление слоя (меньше греется устройство).
const int _kManyMarkersThreshold = 36;

List<String> _normalizedPhotoUrls(MapMarker m) {
  final fromList = m.imageUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (fromList.isNotEmpty) {
    return fromList;
  }
  final u = m.imageUrl?.trim();
  if (u != null && u.isNotEmpty) {
    return [u];
  }
  return const [];
}

int _wrapGalleryIndex(int i, int n) => ((i % n) + n) % n;

({double dx, double dy, double rotate, double iconSize, double opacity, double symbolSortKey})
_cylinderReelSlotLayout(int slot, int halfWidth, MapPhotoMarkerStyle style) {
  assert(halfWidth >= 1);
  assert(slot.abs() <= halfWidth);
  final theta = slot * _kCylinderAngleStepRad;
  final dy = _kCylinderRadiusY * math.sin(theta);
  final dx = _kCylinderDepthX * (1.0 - math.cos(theta)) * (slot >= 0 ? 1.0 : -1.0);
  final rotate = -slot * _kCylinderTiltDegPerSlot;
  final depthScale = math.cos(theta).clamp(0.40, 1.0);
  final base = switch (style) {
    MapPhotoMarkerStyle.polaroid => 0.56,
    MapPhotoMarkerStyle.card => _kMapIconSizeScatter * 1.12,
  };
  final iconSize = base * _kCylinderCenterMagnification * depthScale;
  final edge = halfWidth <= 0 ? 0.0 : slot.abs() / halfWidth;
  final opacity = (1.0 - edge * 0.62).clamp(0.30, 1.0);
  final symbolSortKey = 200.0 + (halfWidth - slot.abs()) * 40.0;
  return (dx: dx, dy: dy, rotate: rotate, iconSize: iconSize, opacity: opacity, symbolSortKey: symbolSortKey);
}

List<_DrawSpec> _buildDrawSpecs(List<MapMarker> markers) {
  final out = <_DrawSpec>[];
  final many = markers.length >= _kManyMarkersThreshold;
  for (final m in markers) {
    final urls = _normalizedPhotoUrls(m);
    if (urls.isEmpty) {
      out.add(
        _DrawSpec(
          trackId: m.id,
          lat: m.lat,
          lng: m.lng,
          emoji: m.emoji,
          tapMarker: m,
          imageUrl: null,
          iconOffset: null,
          iconRotate: null,
          symbolSortKey: 0,
          iconSize: _kMapIconSizeSingle,
          photoStyle: m.photoStyle,
        ),
      );
      continue;
    }
    // Одна картинка — всегда один плакемарк: и card, и polaroid (без тяжёлого цилиндра polaroid).
    if (urls.length == 1) {
      final effectiveStyle = many ? MapPhotoMarkerStyle.card : m.photoStyle;
      out.add(
        _DrawSpec(
          trackId: m.id,
          lat: m.lat,
          lng: m.lng,
          emoji: m.emoji,
          tapMarker: MapMarker(
            id: m.id,
            lat: m.lat,
            lng: m.lng,
            emoji: m.emoji,
            imageUrl: urls.first,
            metadata: {...?m.metadata, 'photoGallery': urls, 'photoGalleryIndex': 0},
            photoStyle: effectiveStyle,
          ),
          imageUrl: urls.first,
          iconOffset: null,
          iconRotate: null,
          symbolSortKey: 0,
          iconSize: _kMapIconSizeSingle,
          photoStyle: effectiveStyle,
          compactDecode: many,
        ),
      );
      continue;
    }

    final galleryUrls = urls;
    final layoutUrls = urls.length == 1
        ? List<String>.generate(_kCylinderVirtualUrlRepeatCount, (_) => urls.first)
        : urls;
    final n = layoutUrls.length;
    final halfW = math.min(_kCylinderMaxHalfWidth, math.max(1, n - 1));
    final centerIdx = n ~/ 2;
    for (var s = -halfW; s <= halfW; s++) {
      final imageIdx = _wrapGalleryIndex(centerIdx + s, n);
      final url = layoutUrls[imageIdx];
      final cyl = _cylinderReelSlotLayout(s, halfW, m.photoStyle);
      final tapGalleryIndex = galleryUrls.length == 1 ? 0 : imageIdx;
      out.add(
        _DrawSpec(
          trackId: '${m.id}__cyl_$s',
          lat: m.lat,
          lng: m.lng,
          emoji: m.emoji,
          tapMarker: MapMarker(
            id: m.id,
            lat: m.lat,
            lng: m.lng,
            emoji: m.emoji,
            imageUrl: url,
            metadata: {...?m.metadata, 'photoGallery': galleryUrls, 'photoGalleryIndex': tapGalleryIndex},
            photoStyle: m.photoStyle,
          ),
          imageUrl: url,
          iconOffset: [cyl.dx, cyl.dy],
          iconRotate: cyl.rotate,
          symbolSortKey: cyl.symbolSortKey,
          iconSize: cyl.iconSize,
          iconOpacity: cyl.opacity,
          photoStyle: m.photoStyle,
        ),
      );
    }
  }
  return out;
}

String _drawSpecSignature(_DrawSpec s) {
  final off = s.iconOffset;
  return '${s.trackId};${s.lat};${s.lng};${s.imageUrl ?? s.emoji};${off?.join(',')};${s.iconRotate};${s.symbolSortKey};${s.iconSize};${s.iconOpacity};${s.photoStyle.name};${s.compactDecode}';
}

enum MapPhotoMarkerStyle { card, polaroid }

class MapMarker {
  final String id;
  final double lat;
  final double lng;
  final String emoji;
  final String? imageUrl;
  final List<String> imageUrls;
  final Map<String, dynamic>? metadata;
  final MapPhotoMarkerStyle photoStyle;

  MapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    required this.emoji,
    this.imageUrl,
    this.imageUrls = const [],
    this.metadata,
    this.photoStyle = MapPhotoMarkerStyle.card,
  });
}

class _DrawSpec {
  _DrawSpec({
    required this.trackId,
    required this.lat,
    required this.lng,
    required this.emoji,
    required this.tapMarker,
    this.imageUrl,
    this.iconOffset,
    this.iconRotate,
    this.symbolSortKey = 0,
    this.iconSize = _kMapIconSizeSingle,
    this.iconOpacity = 1.0,
    this.photoStyle = MapPhotoMarkerStyle.card,
    this.compactDecode = false,
  });

  final String trackId;
  final double lat;
  final double lng;
  final String emoji;
  final MapMarker tapMarker;
  final String? imageUrl;
  final List<double>? iconOffset;
  final double? iconRotate;
  final double symbolSortKey;
  final double iconSize;
  final double iconOpacity;
  final MapPhotoMarkerStyle photoStyle;
  final bool compactDecode;
}

class AppMapWidget extends StatefulWidget {
  final List<MapMarker> markers;
  final void Function(MapMarker marker)? onMarkerTap;
  final double initialLat;
  final double initialLng;
  final double initialZoom;
  final bool showZoomControls;
  final double zoomStep;

  /// JSON стиля MapKit (см. Yandex MapKit style API). Пустая строка сбрасывает стиль.
  final String? mapStyleJson;

  final bool enable3DView;
  final double initialPitch;
  final double initialBearing;

  final void Function(AppMapController controller)? onMapReady;
  final VoidCallback? onMapBackPressed;
  final bool deferMarkerSyncUntilMapIdle;

  const AppMapWidget({
    super.key,
    required this.markers,
    this.onMarkerTap,
    this.initialLat = 55.7558,
    this.initialLng = 37.6173,
    this.initialZoom = 12.0,
    this.showZoomControls = true,
    this.zoomStep = 1.0,
    this.mapStyleJson,
    this.enable3DView = true,
    this.initialPitch = 52.0,
    this.initialBearing = 0.0,
    this.onMapReady,
    this.onMapBackPressed,
    this.deferMarkerSyncUntilMapIdle = false,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  YandexMapController? _controller;
  List<MapObject> _mapObjects = const [];

  int _rebuildGeneration = 0;
  String _lastDataSignature = '';

  bool _mapCameraMovingForMarkers = false;
  bool _pendingMarkerResyncAfterIdle = false;
  bool _markerLayerPrimed = false;
  bool _initialCameraApplied = false;

  static const double _minZoom = 0.0;
  static const double _maxZoom = 21.0;

  static String _dataSignature(List<MapMarker> markers) {
    final specs = _buildDrawSpecs(markers);
    final parts = specs.map(_drawSpecSignature).toList()..sort();
    return parts.join('|');
  }

  /// Дешёвое сравнение списка маркеров без построения draw-specs (родитель часто даёт новый [List] при каждом build).
  static String _quickMarkerListSignature(List<MapMarker> markers) {
    if (markers.isEmpty) return '0';
    final b = StringBuffer()..write(markers.length);
    for (final m in markers) {
      b.write('|${m.id};${m.lat};${m.lng};');
      final u = m.imageUrl?.trim();
      if (u != null && u.isNotEmpty) b.write(u);
      for (final x in m.imageUrls) {
        b.write(',');
        b.write(x);
      }
    }
    return b.toString();
  }

  Future<void> _nudgeZoom(double delta) async {
    final c = _controller;
    if (c == null || !mounted) return;
    try {
      final pos = await c.getCameraPosition();
      final z = (pos.zoom + delta).clamp(_minZoom, _maxZoom);
      if ((z - pos.zoom).abs() < 1e-6) return;
      await c.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: pos.target, zoom: z, azimuth: pos.azimuth, tilt: pos.tilt),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.22),
      );
    } catch (_) {}
  }

  static Future<Uint8List?> _decodeMarkerImage(_DrawSpec s) async {
    final url = s.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (s.compactDecode) {
        final c = await MarkerGeneratorService.createPhotoMarkerFromUrl(url, compact: true);
        if (c != null) return c;
      } else {
        final Uint8List? photo = switch (s.photoStyle) {
          MapPhotoMarkerStyle.polaroid => await MarkerGeneratorService.createPolaroidPhotoMarkerFromUrl(url),
          MapPhotoMarkerStyle.card => await MarkerGeneratorService.createPhotoMarkerFromUrl(url),
        };
        if (photo != null) return photo;
      }
    }
    return MarkerGeneratorService.createEmojiMarker(s.emoji);
  }

  Future<void> _syncMarkers() async {
    if (!mounted) return;

    final gen = ++_rebuildGeneration;

    final sig = _dataSignature(widget.markers);
    if (sig == _lastDataSignature) {
      _markerLayerPrimed = true;
      return;
    }

    final specs = _buildDrawSpecs(widget.markers);
    if (specs.isEmpty) {
      if (!mounted || gen != _rebuildGeneration) return;
      setState(() {
        _mapObjects = const [];
        _lastDataSignature = sig;
        _markerLayerPrimed = true;
      });
      return;
    }

    final built = <MapObject>[];
    final totalSpecs = specs.length;
    final markerCount = widget.markers.length;
    final heavyCluster = markerCount >= _kManyMarkersThreshold;
    final scaleMul = markerCount >= 52 ? 1.36 : (heavyCluster ? 1.5 : _kYandexMarkerScaleMul);
    final flushStride = totalSpecs > 40 ? 12 : (totalSpecs > 18 ? 6 : 2);

    for (var i = 0; i < totalSpecs; i++) {
      final s = specs[i];
      if (!mounted || gen != _rebuildGeneration) return;

      final Uint8List? image = await _decodeMarkerImage(s);
      if (!mounted || gen != _rebuildGeneration) return;

      if (image == null) continue;

      final off = s.iconOffset;
      double ax = 0.5 + ((off != null ? off[0] : 0.0) / 200.0);
      double ay = 0.5 + ((off != null ? off[1] : 0.0) / 200.0);
      // Полароид «стоит» на точке: якорь у нижней кромки, а не в центре bitmap.
      if (off == null && s.photoStyle == MapPhotoMarkerStyle.polaroid && s.iconRotate == null) {
        ax = 0.5;
        ay = 0.88;
      }

      final icon = PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(image),
          anchor: Offset(ax.clamp(0.05, 0.95), ay.clamp(0.05, 0.95)),
          scale: (s.iconSize * scaleMul).clamp(0.24, 2.1),
          rotationType: (s.iconRotate != null && s.iconRotate!.abs() > 0.5)
              ? RotationType.rotate
              : RotationType.noRotation,
        ),
      );

      built.add(
        PlacemarkMapObject(
          mapId: MapObjectId(s.trackId),
          point: Point(latitude: s.lat, longitude: s.lng),
          opacity: s.iconOpacity,
          direction: s.iconRotate ?? 0,
          zIndex: s.symbolSortKey,
          consumeTapEvents: true,
          icon: icon,
          onTap: (PlacemarkMapObject self, Point _) {
            HapticFeedback.selectionClick();
            widget.onMarkerTap?.call(s.tapMarker);
          },
        ),
      );

      // Показываем маркеры по мере готовности; при большом числе точек реже дергаем setState / native слой.
      final n = built.length;
      final isLastSpec = i == totalSpecs - 1;
      final flush = isLastSpec || n <= 4 || n % flushStride == 0;
      if (flush) {
        if (!mounted || gen != _rebuildGeneration) return;
        setState(() => _mapObjects = List<MapObject>.from(built));
      }
      await Future<void>.delayed(Duration.zero);
      if (!mounted || gen != _rebuildGeneration) return;
    }

    if (!mounted || gen != _rebuildGeneration) return;
    // Догоняем, если остался нечётный хвост без flush (например 7 из 10 уже с flush на 6, нужен 7).
    if (built.length != _mapObjects.length) {
      setState(() => _mapObjects = List<MapObject>.from(built));
    }
    _lastDataSignature = sig;
    _markerLayerPrimed = true;
  }

  Future<void> _onYandexMapCreated(YandexMapController controller) async {
    _controller = controller;

    if (!_initialCameraApplied) {
      _initialCameraApplied = true;
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: widget.initialLat, longitude: widget.initialLng),
            zoom: widget.initialZoom,
            azimuth: widget.initialBearing,
            tilt: widget.enable3DView ? widget.initialPitch : 0.0,
          ),
        ),
      );
    }

    final style = widget.mapStyleJson;
    if (style != null && style.isNotEmpty) {
      await controller.setMapStyle(style);
    }

    widget.onMapReady?.call(controller);

    _lastDataSignature = '';
    unawaited(_syncMarkers());
  }

  void _onCameraPositionChanged(CameraPosition position, CameraUpdateReason reason, bool finished) {
    if (!widget.deferMarkerSyncUntilMapIdle) return;
    if (!_markerLayerPrimed) return;

    if (!finished) {
      // Только флаг: раньше здесь инкрементили generation и помечали «нужен resync», из‑за чего после каждого зума вызывался полный [_syncMarkers] и карта лагала.
      _mapCameraMovingForMarkers = true;
      return;
    }

    _mapCameraMovingForMarkers = false;
    if (!_pendingMarkerResyncAfterIdle) return;
    _pendingMarkerResyncAfterIdle = false;
    _lastDataSignature = '';
    unawaited(_syncMarkers());
  }

  @override
  void didUpdateWidget(covariant AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_quickMarkerListSignature(widget.markers) != _quickMarkerListSignature(oldWidget.markers)) {
      if (widget.deferMarkerSyncUntilMapIdle && _mapCameraMovingForMarkers) {
        _rebuildGeneration++;
        _pendingMarkerResyncAfterIdle = true;
      } else {
        _lastDataSignature = '';
        unawaited(_syncMarkers());
      }
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  static const double _mapChromeWidth = 48;

  Widget _buildZoomControls(double step) {
    final Widget? zoomBlock = widget.showZoomControls
        ? Material(
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: _mapChromeWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      unawaited(_nudgeZoom(step));
                    },
                    icon: const Icon(Icons.add_rounded, size: 26),
                    color: const Color(0xFF1A1D1E),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.08)),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      unawaited(_nudgeZoom(-step));
                    },
                    icon: const Icon(Icons.remove_rounded, size: 26),
                    color: const Color(0xFF1A1D1E),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          )
        : null;

    final back = widget.onMapBackPressed == null
        ? null
        : Material(
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: SizedBox(
              width: _mapChromeWidth,
              height: _mapChromeWidth,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  widget.onMapBackPressed!();
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                color: const Color(0xFF1A1D1E),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          );

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (back != null) ...[back, if (zoomBlock != null) const SizedBox(height: 10)],
              if (zoomBlock != null) zoomBlock,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Логотип MapKit по условиям использования должен оставаться на карте; через API можно только сменить угол (по умолчанию — правый нижний).
    final map = YandexMap(
      key: const ValueKey('yandex_map_core_v1'),
      onMapCreated: _onYandexMapCreated,
      onCameraPositionChanged: widget.deferMarkerSyncUntilMapIdle ? _onCameraPositionChanged : null,
      mapObjects: _mapObjects,
      mapType: MapType.vector,
      mode2DEnabled: !widget.enable3DView,
      tiltGesturesEnabled: widget.enable3DView,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      logoAlignment: const MapAlignment(
        horizontal: HorizontalAlignment.left,
        vertical: VerticalAlignment.top,
      ),
    );

    if (!widget.showZoomControls && widget.onMapBackPressed == null) {
      return map;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        map,
        if (widget.showZoomControls || widget.onMapBackPressed != null)
          RepaintBoundary(child: _buildZoomControls(widget.zoomStep)),
      ],
    );
  }
}
