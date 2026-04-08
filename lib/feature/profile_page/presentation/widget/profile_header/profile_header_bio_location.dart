import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Сворачиваемое био: локальный [ValueNotifier], без [setState].
class ProfileHeaderExpandableBio extends StatefulWidget {
  const ProfileHeaderExpandableBio({super.key, required this.text});

  final String text;

  @override
  State<ProfileHeaderExpandableBio> createState() => _ProfileHeaderExpandableBioState();
}

class _ProfileHeaderExpandableBioState extends State<ProfileHeaderExpandableBio> {
  late final ValueNotifier<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = ValueNotifier(false);
  }

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bio = widget.text;
    return ValueListenableBuilder<bool>(
      valueListenable: _expanded,
      builder: (context, expanded, _) {
        return GestureDetector(
          onTap: () => _expanded.value = !expanded,
          child: RichText(
            text: TextSpan(
              style: AppTextStyle.base(14, color: AppColors.textColor, height: 1.4),
              children: [
                TextSpan(text: bio.length > 90 && !expanded ? '${bio.substring(0, 90)}...' : bio),
                if (bio.length > 90 && !expanded)
                  TextSpan(
                    text: ' еще',
                    style: AppTextStyle.base(14, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileHeaderLocationRow extends StatelessWidget {
  const ProfileHeaderLocationRow({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: AppTextStyle.base(12, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
