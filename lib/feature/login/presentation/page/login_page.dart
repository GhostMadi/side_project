import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/app_colors.dart';
import 'package:side_project/core/resources/app_sizer.dart';
import 'package:side_project/core/resources/app_svg.dart';
import 'package:side_project/core/resources/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _loginController;
  late final TextEditingController _passwordController;

  AuthCubit get _authCubit => sl<AuthCubit>();

  @override
  void initState() {
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocConsumer<AuthCubit, AuthState>(
      bloc: _authCubit,
      listener: (context, state) {
        state.maybeWhen(
          authenticated: () {
            context.router.replaceAll([const HomeRoute()]);
          },
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizer.horizontalDef),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 2.h,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),

                    SvgPicture.asset(AppSvg.logo),
                    Text(
                      'Please type your login and password \nto sign in',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.style(15, color: appColors.third),
                    ),

                    AppTextField(
                      controller: _loginController,
                      hintText: 'Login',
                    ),
                    AppTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'forget password',
                        style: AppTextStyle.style(15, color: appColors.third),
                      ),
                    ),

                    AppButton(
                      ixExpanded: true,
                      label: 'Sign in',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
