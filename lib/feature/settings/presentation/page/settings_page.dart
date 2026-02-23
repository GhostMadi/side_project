import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // final colors = AppColors;
    return Scaffold(
      appBar: AppAppBar(
        automaticallyImplyLeading: true,
        title: Text('Settings', style: AppTextStyle.base(19)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),
        children: [
          SizedBox(height: AppDimensions.spaceMiddle),

          Text('General', style: AppTextStyle.base(18, fontWeight: FontWeight.w400)),

          // AppListTile(
          //   title: Text(
          //     'Change Language',
          //     style: AppTextStyle.base(16, weight: FontWeight.w500),
          //   ),
          //   leading: Icon(AppIcons.language.icon, color: colors.secondary),
          //   onTap: () {
          //     sl<AuthCubit>().signOut();
          //   },
          // ),
          // AppListTile(
          //   title: Text(
          //     'Change Theme',
          //     style: AppTextStyle.base(16, weight: FontWeight.w500),
          //   ),
          //   leading: Icon(AppIcons.theme.icon, color: colors.secondary),
          //   onTap: () {},
          // ),
          // SizedBox(height: AppDimensions.spaceMiddle),
          // Text(
          //   'Business',
          //   style: AppTextStyle.base(18, weight: FontWeight.w400),
          // ),
          // AppListTile(
          //   title: Text(
          //     'Add business',
          //     style: AppTextStyle.base(16, weight: FontWeight.w500),
          //   ),
          //   leading: Icon(AppIcons.addShop.icon, color: colors.secondary),
          //   onTap: () {
          //     context.router.push(BusinessRequestsRoute());
          //   },
          // ),
        ],
      ),
    );
  }
}
