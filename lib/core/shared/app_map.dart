// Карта: Yandex MapKit (плагин yandex_mapkit). Ключ API — в MainApplication.kt / AppDelegate.swift.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/service/generate_marker_.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Тип контроллера карты для колбэков ([AppMapWidget.onMapReady]).
typedef AppMapController = YandexMapController;

const _kMapIconSizeSingle = 0.5;
/// Множитель к [iconSize] для [PlacemarkIconStyle.scale] (Yandex). Меньше — мельче маркеры на карте.
const double _kYandexMarkerScaleMul = 1.8;

/// При ≥ этого числа маркеров — компактный декод bitmap и реже обновление слоя (меньше греется устройство).
const int _kManyMarkersThreshold = 36;

List<String> _normalizedPhotoUrls(MapMarker m) {
  final fromList = m.imageUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).take(4).toList();
  if (fromList.isNotEmpty) {
    return fromList;
  }
  final u = m.imageUrl?.trim();
  if (u != null && u.isNotEmpty) {
    return [u];
  }
  return const [];
}

int _mapHiddenPostsBeyondPreviews(MapMarker m, List<String> previewUrls) {
  if (m.markerPostCount <= previewUrls.length) return 0;
  return m.markerPostCount - previewUrls.length;
}

List<_DrawSpec> _buildDrawSpecs(List<MapMarker> markers) {
  final out = <_DrawSpec>[];
  final many = markers.length >= _kManyMarkersThreshold;
  for (final m in markers) {
    final urls = _normalizedPhotoUrls(m);
    final hiddenPlus = _mapHiddenPostsBeyondPreviews(m, urls);

    if (urls.isEmpty) {
      final isUser = m.isMapUserLocation;
      if (!isUser && m.markerPostCount > 1) {
        /// Несколько постов, ни у одного медиа в превью — эмодзи + счётчик.
        out.add(
          _DrawSpec(
            trackId: m.id,
            lat: m.lat,
            lng: m.lng,
            emoji: m.emoji,
            tapMarker: m,
            imageUrl: null,
            emojiOnlyLinkedPosts: m.markerPostCount,
            pinFootLine: m.pinFootLine,
            iconOffset: null,
            iconRotate: null,
            symbolSortKey: 0,
            iconSize: _kMapIconSizeSingle,
            photoStyle: m.photoStyle,
            isMapUserLocation: false,
          ),
        );
        continue;
      }
      out.add(
        _DrawSpec(
          trackId: m.id,
          lat: m.lat,
          lng: m.lng,
          emoji: m.emoji,
          tapMarker: m,
          imageUrl: null,
          pinFootLine: m.pinFootLine,
          iconOffset: null,
          iconRotate: null,
          // Снизу по z-order: визуально «под» маркерами с бэка, чтобы тап попадал в событие на той же точке.
          symbolSortKey: isUser ? -1000.0 : 0,
          iconSize: isUser ? 0.56 : _kMapIconSizeSingle,
          photoStyle: m.photoStyle,
          isMapUserLocation: isUser,
        ),
      );
      continue;
    }

    // Сетка 2–4 превью (мульти-пост).
    if (urls.length >= 2) {
      out.add(
        _DrawSpec(
          trackId: m.id,
          lat: m.lat,
          lng: m.lng,
          emoji: m.emoji,
          tapMarker: m,
          imageUrl: null,
          compositeGridUrls: urls,
          gridOverflowPlus: hiddenPlus,
          iconOffset: null,
          iconRotate: null,
          symbolSortKey: 2,
          iconSize: _kMapIconSizeSingle,
          photoStyle: MapPhotoMarkerStyle.card,
          compactDecode: many,
        ),
      );
      continue;
    }

    // Ровно одно превью-изображение.
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
          isMapUserLocation: m.isMapUserLocation,
          markerPostCount: m.markerPostCount,
          pinFootLine: m.pinFootLine,
        ),
        imageUrl: urls.first,
        singlePhotoPlusBadge: hiddenPlus,
        iconOffset: null,
        iconRotate: null,
        symbolSortKey: 1,
        iconSize: _kMapIconSizeSingle,
        photoStyle: effectiveStyle,
        compactDecode: many,
      ),
    );
  }
  return out;
}

String _drawSpecSignature(_DrawSpec s) {
  final off = s.iconOffset;
  final grid = s.compositeGridUrls?.join('~');
  final foot = s.pinFootLine ?? '';
  return '${s.trackId};${s.lat};${s.lng};${grid ?? ''};${s.gridOverflowPlus};${s.singlePhotoPlusBadge};${s.emojiOnlyLinkedPosts ?? '_'};${s.imageUrl ?? s.emoji};${off?.join(',')};${s.iconRotate};${s.symbolSortKey};${s.iconSize};${s.photoStyle.name};${s.compactDecode};${s.isMapUserLocation};f=$foot';
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

  /// Метка «моё положение» — рисуется [MarkerGeneratorService.createMapUserLocationMarker], не эмодзи.
  final bool isMapUserLocation;

  /// Сколько постов привязано к маркеру ([marker_posts]); 0 — пустой пин только с эмодзи/cover с бэка.
  final int markerPostCount;

  /// Короткая подпись над круглым пином (время / «19:00 · 3») — чтобы на карте было понятно «что за точка».
  final String? pinFootLine;

  MapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    required this.emoji,
    this.imageUrl,
    this.imageUrls = const [],
    this.metadata,
    this.photoStyle = MapPhotoMarkerStyle.card,
    this.isMapUserLocation = false,
    this.markerPostCount = 0,
    this.pinFootLine,
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
    this.emojiOnlyLinkedPosts,
    this.pinFootLine,
    this.compositeGridUrls,
    this.gridOverflowPlus = 0,
    this.singlePhotoPlusBadge = 0,
    this.iconOffset,
    this.iconRotate,
    this.symbolSortKey = 0,
    this.iconSize = _kMapIconSizeSingle,
    this.photoStyle = MapPhotoMarkerStyle.card,
    this.compactDecode = false,
    this.isMapUserLocation = false,
  });

  final String trackId;
  final double lat;
  final double lng;
  final String emoji;
  final MapMarker tapMarker;
  final String? imageUrl;
  /// >1 — дорисовать [MarkerGeneratorService.createEmojiMarkerWithLinkedPostCount].
  final int? emojiOnlyLinkedPosts;
  /// См. [MapMarker.pinFootLine] — только для эмодзи-пинов.
  final String? pinFootLine;
  final List<String>? compositeGridUrls;
  final int gridOverflowPlus;
  final int singlePhotoPlusBadge;
  final List<double>? iconOffset;
  final double? iconRotate;
  final double symbolSortKey;
  final double iconSize;
  final MapPhotoMarkerStyle photoStyle;
  final bool compactDecode;
  final bool isMapUserLocation;
}

/// Дополнительные кнопки под [+] / [−] (тот же визуальный ряд, справа по центру).
class AppMapChromeAction {
  const AppMapChromeAction({required this.icon, this.tooltip, required this.onPressed, this.iconColor});

  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  /// Если null — цвет по умолчанию для кромки карты ([AppColors.textColor]).
  final Color? iconColor;
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

  /// См. [AppMapChromeAction] — рисуются **под** зум-контролем.
  final List<AppMapChromeAction> rightColumnExtraActions;

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
    this.rightColumnExtraActions = const [],
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
      b.write('|${m.id};${m.lat};${m.lng};mpc=${m.markerPostCount};');
      b.write(m.pinFootLine ?? '');
      b.write(m.isMapUserLocation ? 'u' : 'e');
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

  static Future<({Uint8List? image, double anchorY})> _decodeMarkerImage(_DrawSpec s) async {
    if (s.isMapUserLocation) {
      final u = await MarkerGeneratorService.createMapUserLocationMarker();
      return (image: u, anchorY: 0.5);
    }
    final cu = s.compositeGridUrls;
    if (cu != null && cu.length >= 2) {
      final g = await MarkerGeneratorService.createMapMultiPostGridFromUrls(
        cu,
        overflowPlus: s.gridOverflowPlus,
        compact: s.compactDecode,
      );
      if (g != null) return (image: g, anchorY: 0.5);
    }
    final url = s.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (s.compactDecode) {
        final c = await MarkerGeneratorService.createPhotoMarkerFromUrl(
          url,
          compact: true,
          mapPlusBadge: s.singlePhotoPlusBadge,
        );
        if (c != null) return (image: c, anchorY: 0.5);
      } else {
        final Uint8List? photo = switch (s.photoStyle) {
          MapPhotoMarkerStyle.polaroid => await MarkerGeneratorService.createPolaroidPhotoMarkerFromUrl(url),
          MapPhotoMarkerStyle.card =>
            await MarkerGeneratorService.createPhotoMarkerFromUrl(
              url,
              compact: false,
              mapPlusBadge: s.singlePhotoPlusBadge,
            ),
        };
        if (photo != null) return (image: photo, anchorY: 0.5);
      }
    }

    final el = s.emojiOnlyLinkedPosts;
    if (el != null && el > 1) {
      final eb = await MarkerGeneratorService.createEmojiMarkerWithLinkedPostCount(s.emoji, linkedPostCount: el);
      if (eb != null) return await _maybePinTopFootLine(s, eb);
    }

    final plain = await MarkerGeneratorService.createEmojiMarker(s.emoji);
    return _maybePinTopFootLine(s, plain);
  }

  /// Подпись над эмодзи-пином; якорь — центр исходного круга на новой высоте bitmap.
  static Future<({Uint8List? image, double anchorY})> _maybePinTopFootLine(_DrawSpec s, Uint8List? base) async {
    final foot = s.pinFootLine?.trim();
    if (base == null) return (image: null, anchorY: 0.5);
    if (foot == null || foot.isEmpty) return (image: base, anchorY: 0.5);
    final r = await MarkerGeneratorService.composePinTopFootLine(basePng: base, footLine: foot);
    return (image: r.bytes, anchorY: r.anchorY);
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

      final decoded = await _decodeMarkerImage(s);
      if (!mounted || gen != _rebuildGeneration) return;

      final image = decoded.image;
      if (image == null) continue;

      final off = s.iconOffset;
      double ax = 0.5 + ((off != null ? off[0] : 0.0) / 200.0);
      double ay = off != null ? 0.5 + (off[1] / 200.0) : decoded.anchorY;
      // Полароид «стоит» на точке: якорь у нижней кромки, а не в центре bitmap.
      if (off == null && s.photoStyle == MapPhotoMarkerStyle.polaroid && s.iconRotate == null) {
        ax = 0.5;
        ay = 0.88;
      }

      // «Моё положение» только визуально: не участвуй в тапе по иконке (Yandex) + z ниже бэка.
      final isUser = s.isMapUserLocation;
      final icon = PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(image),
          anchor: Offset(ax.clamp(0.05, 0.95), ay.clamp(0.05, 0.95)),
          scale: (s.iconSize * scaleMul).clamp(0.24, 2.1),
          rotationType: (s.iconRotate != null && s.iconRotate!.abs() > 0.5)
              ? RotationType.rotate
              : RotationType.noRotation,
          tappableArea: isUser ? MapRect(min: Offset.zero, max: Offset.zero) : null,
        ),
      );

      built.add(
        PlacemarkMapObject(
          mapId: MapObjectId(s.trackId),
          point: Point(latitude: s.lat, longitude: s.lng),
          opacity: 1.0,
          direction: s.iconRotate ?? 0,
          zIndex: s.symbolSortKey,
          consumeTapEvents: !isUser,
          icon: icon,
          onTap: isUser
              ? null
              : (PlacemarkMapObject self, Point _) {
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

  List<Widget> _buildExtraRightChrome(Iterable<AppMapChromeAction> actions) {
    return [
      for (final a in actions) ...[
        const SizedBox(height: 8),
        Material(
          elevation: 4,
          shadowColor: AppColors.shadowDark.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: SizedBox(
              width: _mapChromeWidth,
              height: _mapChromeWidth,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  a.onPressed();
                },
                icon: Icon(a.icon, size: 24),
                tooltip: a.tooltip,
                color: a.iconColor ?? AppColors.textColor,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ],
    ];
  }

  Widget _buildZoomControls(double step) {
    final Widget? zoomBlock = widget.showZoomControls
        ? Material(
            elevation: 4,
            shadowColor: AppColors.shadowDark.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surface,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
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
                      color: AppColors.textColor,
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        unawaited(_nudgeZoom(-step));
                      },
                      icon: const Icon(Icons.remove_rounded, size: 26),
                      color: AppColors.textColor,
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : null;

    final back = widget.onMapBackPressed == null
        ? null
        : Material(
            elevation: 4,
            shadowColor: AppColors.shadowDark.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surface,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: SizedBox(
                width: _mapChromeWidth,
                height: _mapChromeWidth,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.onMapBackPressed!();
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  color: AppColors.textColor,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
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
              ..._buildExtraRightChrome(widget.rightColumnExtraActions),
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

    if (!widget.showZoomControls &&
        widget.onMapBackPressed == null &&
        widget.rightColumnExtraActions.isEmpty) {
      return map;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        map,
        if (widget.showZoomControls ||
            widget.onMapBackPressed != null ||
            widget.rightColumnExtraActions.isNotEmpty)
          RepaintBoundary(child: _buildZoomControls(widget.zoomStep)),
      ],
    );
  }
}
