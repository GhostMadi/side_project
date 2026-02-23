import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class AppOutlinedButton extends StatefulWidget {
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.child,
  });

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton> with SingleTickerProviderStateMixin {
  late AnimationController _jellyController;
  late Animation<double> _jellyAnimation;

  @override
  void initState() {
    super.initState();
    _jellyController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _jellyAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_jellyController);
  }

  void _triggerJelly() {
    HapticFeedback.heavyImpact();

    setState(() {
      _jellyAnimation = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _jellyController, curve: Curves.elasticOut));
    });

    _jellyController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _jellyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _jellyAnimation,
      builder: (context, child) {
        final double scale = _jellyAnimation.value;
        final double vScale = 1.0 + (1.0 - scale) * 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scale, vScale, 1.0)..setEntry(3, 2, 0.001),
          child: child,
        );
      },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: GestureDetector(
          onTap: isEnabled
              ? () {
                  _triggerJelly();
                  widget.onPressed?.call();
                }
              : null,
          child: Container(
            height: 56,
            width: widget.isExpanded ? double.infinity : null,
            decoration: BoxDecoration(
              color: Colors.transparent, // Фон прозрачный
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isEnabled ? AppColors.btnBackground : AppColors.btnDisabledText,
                width: 1.5, // Тонкая рамка
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
                  : widget.child ??
                        Text(
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
