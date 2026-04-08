import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/jelly_press_controller.dart';

class AppButton extends StatefulWidget {
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.child,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
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
              color: isEnabled ? AppColors.btnBackground : AppColors.btnDisabled,
              borderRadius: BorderRadius.circular(100),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.btnBackground.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : widget.child != null
                  ? Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: widget.child)
                  : Text(
                      widget.text,
                      style: AppTextStyle.base(
                        16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? Colors.white : AppColors.btnDisabledText,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
