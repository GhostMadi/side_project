import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/app_svg.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/login/presentation/widget/link_button.dart';

@RoutePage() // Если нужен AutoRoute
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _loginController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final colors = AppColors;

    // 1. ПРОВАЙДЕР: Внедряем Cubit в дерево виджетов
    return BlocProvider<AuthCubit>(
      create: (context) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        // 2. LISTENER: Слушает события (навигация, ошибки)
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (user) {
              // Успешный вход -> идем на главную
              context.router.replaceAll([const HomeRoute()]);
            },
            error: (message) {
              log(message);
              // Ошибка -> показываем сообщение
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(message), backgroundColor: colors.error),
              // );
            },
            orElse: () {},
          );
        },
        // 3. BUILDER: Перерисовывает UI при загрузке
        builder: (context, state) {
          // Вычисляем, идет ли загрузка
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            // backgroundColor: colors.primary,
            // 1. SafeArea защищает от "челок" и нижних баров на телефонах
            body: SafeArea(
              // 2. Center выравнивает контент по центру экрана, если экран шире, чем maxWidth
              child: Center(
                // 3. ConstrainedBox задает жесткое ограничение ширины
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    // 4. Оптимальная ширина для форм: 500-550px.
                    // На телефонах (<500px) он займет всю ширину.
                    // На планшетах (>500px) он остановится на 500px.
                    maxWidth: 500,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMiddle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppSvg.logo),

                        SizedBox(height: AppDimensions.spaceMiddle),

                        Text(
                          'Please type your login and password \nto sign in',
                          textAlign: TextAlign.center,
                          // style: AppTextStyle.base(16, color: colors.third),
                        ),

                        SizedBox(height: AppDimensions.spaceSenior),

                        AppTextField(
                          controller: _loginController,
                          hintText: 'Login',
                        ),

                        SizedBox(height: AppDimensions.spaceMiddle),

                        AppTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                        ),

                        SizedBox(height: AppDimensions.spaceHuge),

                        AppButton(
                          text: 'Sign in',
                          isLoading: isLoading,
                          onPressed: () {
                            print("Email Login: ${_loginController.text}");
                          },
                        ),

                        SizedBox(height: AppDimensions.spaceMiddle),

                        Text(
                          'or continue with',
                          // style: AppTextStyle.base(16, color: colors.third),
                        ),

                        SizedBox(height: AppDimensions.spaceMiddle),

                        GoogleSignInButton(
                          isLoading: isLoading,
                          onPressed: () {
                            context.read<AuthCubit>().signInWithGoogle();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:side_project/core/resources/app_svg.dart';
// import 'package:side_project/core/resources/color_settings/color_extension.dart';
// import 'package:side_project/core/resources/dimension/app_dimension.dart';
// import 'package:sizer/sizer.dart';
