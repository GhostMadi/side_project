import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_shimmer.dart';

/// Скелетон хедера профиля на время загрузки.
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              height: 128,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          3,
                          (_) => Column(
                            children: [
                              Container(
                                width: 36,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 52,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _shimBar(fullWidth: false, width: 170, height: 18, radius: 8),
                const SizedBox(height: 10),
                _shimBar(fullWidth: false, width: 120, height: 14, radius: 6),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shimBar({
    required bool fullWidth,
    double? width,
    required double height,
    required double radius,
  }) {
    final box = Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(radius)),
    );
    return fullWidth ? box : Align(alignment: Alignment.centerLeft, child: box);
  }
}
