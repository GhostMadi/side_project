import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:side_project/core/resources/app_svg.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:sizer/sizer.dart';

class LoginGoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginGoogleSignInButton({super.key, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final double size = 12.w;

    return SizedBox(
      height: size,
      width: size,
      child: Material(
        color: AppColors.surface,
        elevation: 1.5,
        shadowColor: AppColors.shadowDark.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed();
                },
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 6.w,
                    width: 6.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.btnBackground),
                    ),
                  )
                : SvgPicture.asset(AppSvg.google, height: 7.w, width: 7.w),
          ),
        ),
      ),
    );
  }
}
