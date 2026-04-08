import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/jelly_press_controller.dart';

class AppOutlinedButton extends StatefulWidget {
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final double? borderRadius;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.child,
    this.borderRadius,
  });

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton> with SingleTickerProviderStateMixin {
  late final JellyPressController _jelly;

  @override
  void initState() {
    super.initState();
    _jelly = JellyPressController(vsync: this, onAnimationSwap: () => setState(() {}));
  }

  @override
  void dispose() {
    _jelly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _jelly.scaleAnimation,
      builder: (context, child) {
        final s = _jelly.scaleAnimation.value;
        final vScale = 1.0 + (1.0 - s) * 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(s, vScale, 1.0)..setEntry(3, 2, 0.001),
          child: child,
        );
      },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: GestureDetector(
          onTap: isEnabled
              ? () {
                  _jelly.trigger();
                  widget.onPressed?.call();
                }
              : null,
          child: Container(
            height: 56,
            width: widget.isExpanded ? double.infinity : null,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 100),
              border: Border.all(
                color: isEnabled ? AppColors.btnBackground : AppColors.btnDisabledText,
                width: 1.5,
              ),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.btnBackground),
                      ),
                    )
                  : widget.child != null
                  ? Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: widget.child)
                  : Text(
                      widget.text,
                      style: AppTextStyle.base(
                        16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? AppColors.btnBackground : AppColors.btnDisabledText,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
