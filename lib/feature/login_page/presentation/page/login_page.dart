import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_text_button.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/login_page/presentation/widget/login_google_sign_in_button.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToApp() {
    HapticFeedback.lightImpact();
    context.router.replaceAll([const ApplicationRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, next) => next.maybeMap(
        authenticated: (_) => true,
        error: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.whenOrNull(
          authenticated: (_) =>
              context.router.replaceAll([const ApplicationRoute()]),
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        final googleLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradientTopSoftGreen,
                  AppColors.gradientBottomWhite,
                ],
                stops: [0.0, 0.45],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.paddingMiddle,
                      24,
                      AppDimensions.paddingMiddle,
                      28 + bottomInset + keyboardInset,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - keyboardInset)
                            .clamp(0.0, double.infinity),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.btnBackground.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: AppColors.shadowDark.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.hintCardBorder,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    22,
                                    26,
                                    22,
                                    22,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Почта',
                                        style: AppTextStyle.base(
                                          13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AppTextField(
                                        controller: _emailController,
                                        hintText: 'you@example.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autocorrect: false,
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        'Пароль',
                                        style: AppTextStyle.base(
                                          13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AppTextField(
                                        controller: _passwordController,
                                        hintText: 'Введите пароль',
                                        obscureText: _obscurePassword,
                                        autocorrect: false,
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          tooltip: _obscurePassword
                                              ? 'Показать'
                                              : 'Скрыть',
                                          icon: Icon(
                                            _obscurePassword
                                                ? AppIcons.visibility.icon
                                                : AppIcons.visibilityOff.icon,
                                            size: 22,
                                            color: AppColors.subTextColor
                                                .withValues(alpha: 0.75),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: AppTextButton(
                                          text: 'Забыли пароль?',
                                          onPressed: () {},
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AppButton(
                                        text: 'Войти',
                                        onPressed: _goToApp,
                                      ),
                                      const SizedBox(height: 22),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.subTextColor
                                                  .withValues(alpha: 0.2),
                                              height: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            child: Text(
                                              'или',
                                              style: AppTextStyle.base(
                                                13,
                                                color: AppColors.subTextColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.subTextColor
                                                  .withValues(alpha: 0.2),
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Center(
                                        child: LoginGoogleSignInButton(
                                          isLoading: googleLoading,
                                          onPressed: () => context
                                              .read<AuthCubit>()
                                              .signInWithGoogle(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
