import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_shimmer.dart';

/// Простой шиммер для горизонтального стрипа кластеров (как карточки в профиле).
class ClustersStripShimmer extends StatelessWidget {
  const ClustersStripShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: List.generate(
            itemCount,
            (i) => Padding(
              padding: EdgeInsets.only(right: i == itemCount - 1 ? 0 : 12),
              child: const _ClusterCardShim(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClusterCardShim extends StatelessWidget {
  const _ClusterCardShim();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 212,
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.white.withValues(alpha: 0.9),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Box(width: 64, height: 64, radius: 14),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(width: double.infinity, height: 14, radius: 6),
                SizedBox(height: 8),
                _Box(width: 120, height: 12, radius: 6),
                SizedBox(height: 10),
                _Box(width: 80, height: 12, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.radius});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.isFinite ? width : null,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

