import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class ProfileHeaderAvatar extends StatelessWidget {
  const ProfileHeaderAvatar({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final hasImage = url != null && url.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.activeColor),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.inputBackground,
          backgroundImage: hasImage ? NetworkImage(url) : null,
          child: hasImage ? null : const Icon(Icons.person_rounded, size: 44, color: AppColors.iconMuted),
        ),
      ),
    );
  }
}

class ProfileHeaderStatItem extends StatelessWidget {
  const ProfileHeaderStatItem({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyle.base(18, color: AppColors.textColor, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.base(12, color: AppColors.subTextColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class ProfileHeaderIdentity extends StatelessWidget {
  const ProfileHeaderIdentity({
    super.key,
    required this.fullName,
    required this.username,
    required this.category,
  });

  final String? fullName;
  final String? username;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final name = fullName?.trim();
    final hasName = name != null && name.isNotEmpty;
    final nick = username?.trim();
    final hasNick = nick != null && nick.isNotEmpty;
    final cat = category?.trim();
    final hasCategory = cat != null && cat.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasName) ...[
          Text(
            name,
            style: AppTextStyle.base(18, color: AppColors.textColor, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
        ],
        if (!hasNick)
          Text(
            'пусто',
            style: AppTextStyle.base(14, color: AppColors.iconMuted, fontWeight: FontWeight.w600),
          )
        else
          Text(
            '@$nick',
            style: AppTextStyle.base(14, color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        if (hasCategory) ...[
          const SizedBox(height: 2),
          Text(
            cat,
            style: AppTextStyle.base(13, color: AppColors.subTextColor, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}
