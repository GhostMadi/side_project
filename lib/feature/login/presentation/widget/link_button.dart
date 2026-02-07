import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:side_project/core/resources/app_svg.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:sizer/sizer.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // final colors = AppColors;
    final double size = 12.w;

    return SizedBox(
      height: size,
      width: size,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          // backgroundColor: colors.primary,
          // foregroundColor: colors.third.withOpacity(0.3),
          padding: EdgeInsets.zero,
          elevation: 2,
          // shadowColor: colors.secondary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 6.w,
                width: 6.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  // valueColor: AlwaysStoppedAnimation<Color>(colors.brand),
                ),
              )
            : SvgPicture.asset(AppSvg.google, height: 7.w, width: 7.w),
      ),
    );
  }
}
