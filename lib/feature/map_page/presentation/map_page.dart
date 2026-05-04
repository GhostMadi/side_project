import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/core/shared/app_pill_navigation_bar.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/feature/map_page/presentation/almaty_demo_markers.dart';
import 'package:side_project/feature/map_page/presentation/cubit/map_filters_cubit.dart';
import 'package:side_project/feature/map_page/presentation/cubit/map_markers_cubit.dart';
import 'package:side_project/feature/map_page/widget/map_filter_bottom_sheet.dart';
import 'package:side_project/feature/map_page/widget/marker_posts_intro_sheet.dart';
import 'package:side_project/feature/map_page/widget/ticket_bottom_sheet.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Метка «моё положение» (отдельно от событий; [MapMarker.isMapUserLocation]).
const String kMapUserLocationMarkerId = 'map_user_location';

@RoutePage()
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MapFiltersCubit>()),
        BlocProvider(
          create: (context) {
            final c = sl<MapMarkersCubit>();
            c.load(context.read<MapFiltersCubit>().state);
            return c;
          },
        ),
      ],
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  AppMapController? _map;

  /// Кэш последнего удачного GPS (кнопка «моё положение»).
  (double, double)? _lastUserGps;

  /// Гео попытка завершена — можно смотреть маркеры на фолбэк.
  bool _geoResolved = false;

  /// Камеру к пользователю/первому пину уже подогнали.
  bool _initialTargetApplied = false;

  Future<void> _onMapReady(AppMapController c) async {
    _map = c;
    await _runInitialMapTarget();
  }

  /// Сначала геолокация + зум, иначе — первый маркер, когда появятся в кубите.
  Future<void> _runInitialMapTarget() async {
    if (!mounted || _initialTargetApplied) return;
    final ctrl = _map;
    if (ctrl == null) return;

    final u = await _tryUserLatLng();
    if (!mounted) return;
    setState(() => _geoResolved = true);

    if (u != null) {
      await _moveCameraTo(ctrl, u.$1, u.$2, 14);
      if (mounted) setState(() => _initialTargetApplied = true);
      return;
    }

    if (_tryMoveToFirstMarker(ctrl)) {
      if (mounted) setState(() => _initialTargetApplied = true);
      return;
    }
    if (!mounted) return;
    final list = context.read<MapMarkersCubit>().state.maybeWhen(
      loaded: (l) => l,
      orElse: () => <MapMarker>[],
    );
    if (list.isEmpty) {
      setState(() => _initialTargetApplied = true);
    }
  }

  Future<(double, double)?> _tryUserLatLng() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return null;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      final t = (pos.latitude, pos.longitude);
      if (mounted) {
        setState(() => _lastUserGps = t);
      } else {
        _lastUserGps = t;
      }
      return t;
    } catch (_) {
      return null;
    }
  }

  bool _tryMoveToFirstMarker(AppMapController c) {
    if (!mounted) return false;
    final list = context.read<MapMarkersCubit>().state.maybeWhen(
      loaded: (l) => l,
      orElse: () => <MapMarker>[],
    );
    if (list.isEmpty) return false;
    unawaited(_moveCameraTo(c, list.first.lat, list.first.lng, 12.5));
    return true;
  }

  static Future<void> _moveCameraTo(AppMapController c, double lat, double lng, double zoom) async {
    try {
      await c.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: lat, longitude: lng),
            zoom: zoom,
            azimuth: 0,
            tilt: 0,
          ),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.45),
      );
    } catch (_) {}
  }

  /// Центр карты на текущем GPS; метка «моё положение» обновляется вместе с [ _lastUserGps ].
  Future<void> _onMyLocation() async {
    final c = _map;
    if (c == null) return;
    (double, double)? p = _lastUserGps;
    p ??= await _tryUserLatLng();
    if (!mounted) return;
    if (p == null) {
      AppSnackBar.show(
        context,
        message: 'Не удалось определить положение. Включи геолокацию и разрешения.',
        kind: AppSnackBarKind.error,
      );
      return;
    }
    unawaited(_moveCameraTo(c, p.$1, p.$2, 16.0));
  }

  void _onMarkersLoadedForFallback(List<MapMarker> markers) {
    if (_initialTargetApplied || !_geoResolved) return;
    final c = _map;
    if (c == null) return;
    if (markers.isEmpty) {
      setState(() => _initialTargetApplied = true);
      return;
    }
    unawaited(_moveCameraTo(c, markers.first.lat, markers.first.lng, 12.5));
    if (mounted) setState(() => _initialTargetApplied = true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    const barH = 64.0;
    const gap = 10.0;

    return BlocListener<MapFiltersCubit, MapFiltersState>(
      listenWhen: (a, b) => a != b,
      listener: (context, s) {
        context.read<MapMarkersCubit>().load(s);
      },
      child: BlocListener<MapMarkersCubit, MapMarkersState>(
        listenWhen: (a, b) => b.maybeWhen(loaded: (_) => true, orElse: () => false),
        listener: (context, s) {
          s.mapOrNull(
            loaded: (L) {
              if (!_geoResolved) return;
              if (_initialTargetApplied) return;
              _onMarkersLoadedForFallback(L.markers);
            },
          );
        },
        child: BlocListener<MapMarkersCubit, MapMarkersState>(
          listenWhen: (a, b) => b.maybeWhen(error: (_) => true, orElse: () => false),
          listener: (context, state) {
            state.whenOrNull(
              error: (m) => AppSnackBar.show(context, message: m, kind: AppSnackBarKind.error),
            );
          },
          child: BlocBuilder<MapMarkersCubit, MapMarkersState>(
            builder: (context, mState) {
              final points = mState.maybeWhen(loaded: (l) => l, orElse: () => <MapMarker>[]);
              final loading = mState.maybeWhen(loading: () => true, orElse: () => false);
              final merged = List<MapMarker>.from(points);
              if (_lastUserGps != null) {
                final g = _lastUserGps!;
                merged.add(
                  MapMarker(
                    id: kMapUserLocationMarkerId,
                    lat: g.$1,
                    lng: g.$2,
                    emoji: '·',
                    markerPostCount: 0,
                    isMapUserLocation: true,
                    metadata: const {'title': 'Ты здесь'},
                  ),
                );
              }

              return Stack(
                children: [
                  AppMapWidget(
                    key: const ValueKey('app_map'),
                    markers: merged,
                    initialLat: almatyCenterLat,
                    initialLng: almatyCenterLng,
                    initialZoom: 10.5,
                    onMapReady: _onMapReady,
                    rightColumnExtraActions: [
                      AppMapChromeAction(
                        icon: Icons.my_location_rounded,
                        iconColor: AppColors.primary,
                        tooltip: 'Моё положение',
                        onPressed: () {
                          unawaited(_onMyLocation());
                        },
                      ),
                    ],
                    onMarkerTap: (marker) {
                      if (marker.isMapUserLocation) return;
                      if (marker.markerPostCount > 1) {
                        MarkerPostsIntroSheet.show(context, marker);
                        return;
                      }
                      AppBottomSheet.show(
                        context: context,
                        content: EventTicketDetailsSheet(marker: marker),
                      );
                    },
                  ),
                  if (loading)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 56,
                      child: Center(
                        child: Card(
                          color: AppColors.pageBackground,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppCircularProgressIndicator(
                                  strokeWidth: 2,
                                  dimension: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Загрузка…',
                                  style: AppTextStyle.base(
                                    14,
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    bottom: bottomPad + barH + gap,
                    child: AppPillBarIconAction(
                      icon: Icons.tune_rounded,
                      size: 40,
                      tooltip: 'Фильтр',
                      onPressed: () {
                        final f = context.read<MapFiltersCubit>();
                        final s = f.state;
                        MapFilterBottomSheet.show(
                          context,
                          initialAtTime: s.atTime,
                          initialTagKeys: s.selectedTagKeys,
                          onApply: (at, tagKeys) {
                            f.replaceAll(atTime: at, tagKeys: tagKeys);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
