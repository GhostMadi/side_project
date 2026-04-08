import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/map_page/presentation/almaty_demo_markers.dart';

/// Результат выбора точки на карте (центр видимой области = метка).
class PostPickedLocation {
  const PostPickedLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Полноэкранный выбор места: [AppMapWidget] + фиксированная метка в центре.
class PostLocationPickPage extends StatefulWidget {
  const PostLocationPickPage({super.key, this.initialLatitude, this.initialLongitude});

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<PostLocationPickPage> createState() => _PostLocationPickPageState();
}

class _PostLocationPickPageState extends State<PostLocationPickPage> {
  AppMapController? _map;

  double get _startLat => widget.initialLatitude ?? almatyCenterLat;

  double get _startLng => widget.initialLongitude ?? almatyCenterLng;

  Future<void> _confirm() async {
    final map = _map;
    if (map == null) {
      return;
    }
    try {
      final pos = await map.getCameraPosition();
      final lat = pos.target.latitude;
      final lng = pos.target.longitude;
      if (!mounted) {
        return;
      }
      HapticFeedback.lightImpact();
      Navigator.of(context).pop(PostPickedLocation(latitude: lat, longitude: lng));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppMapWidget(
            markers: const [],
            initialLat: _startLat,
            initialLng: _startLng,
            initialZoom: 14,
            showZoomControls: true,
            enable3DView: false,
            initialPitch: 0,
            initialBearing: 0,
            onMapReady: (m) => _map = m,
          ),
          const IgnorePointer(child: Center(child: _CenterPin())),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(AppIcons.back.icon, color: AppColors.textColor),
                    ),
                    Expanded(
                      child: Text(
                        'Место на карте',
                        style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text(
                    'Сдвиньте карту так, чтобы метка указывала на нужную точку.',
                    style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Сохранить точку',
                      style: AppTextStyle.base(16, color: AppColors.textInverse, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          size: 52,
          color: AppColors.primary,
          shadows: const [Shadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        Transform.translate(
          offset: const Offset(0, -10),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.shadowDark.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
