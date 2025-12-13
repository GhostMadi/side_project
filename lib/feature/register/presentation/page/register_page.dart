import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/extensions/context_extension.dart';
import 'package:side_project/core/resources/app_sizer.dart';
import 'package:side_project/core/resources/app_text_style.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final cubit = sl<AuthCubit>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizer.horizontalDef),
          child: SingleChildScrollView(
            child: Column(
              spacing: 2.h,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15.h),
                Text(
                  'Create Account',
                  style: AppTextStyle.style(22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Please choose character or image for avatar anf fill\n Nick name',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style(14, color: colorScheme.onPrimary),
                ),
                Container(
                  width: 30.h,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    border: Border.all(color: colorScheme.secondary, width: 1),
                  ),
                  child: Icon(Icons.person_pin_rounded),
                ),

                AppTextField(hintText: 'Nick name'),

                SizedBox(
                  width: context.width,
                  child: ElevatedButton(
                    onPressed: () async {
                      await cubit.signUp(
                        email: 'tokhtarbayev.mady@gmail.com',
                        password: '123123',
                      );
                    },
                    child: Text('Create account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
