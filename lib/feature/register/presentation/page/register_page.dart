import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AuthCubit cubit;
  @override
  void initState() {
    cubit = sl<AuthCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors;
    return Scaffold(
      appBar: AppAppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(),
          child: SingleChildScrollView(
            child: Column(
              spacing: 2.h,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15.h),
                Text(
                  'Create Account',
                  // style: AppTextStyle.style(22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Please choose character or image for avatar anf fill\n Nick name',
                  textAlign: TextAlign.center,
                  // style: AppTextStyle.style(15, color: appColors.secondary),
                ),
                Container(
                  width: 30.h,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all( width: 1),
                  ),
                  child: Icon(Icons.person_pin_rounded),
                ),
                AppTextField(hintText: 'Nick name'),
                // AppButton(
                //   fullWidth: true,
                //   onPressed: () async {
                //     cubit.signUp(
                //       email: 'tokhtarbayali@gmail.com',
                //       password: '123123',
                //     );
                //   },
                //   label: 'Create account',
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
