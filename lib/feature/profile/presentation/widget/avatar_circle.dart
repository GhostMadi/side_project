import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/user/cubit/user_cubit.dart';
import 'package:sizer/sizer.dart';

class ProfileCircleAvatar extends StatelessWidget {
  const ProfileCircleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final double size = 20.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: sl<UserCubit>().currentUser?.avatarUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: colors.fourth,
                  child: Icon(AppIcons.user.icon, color: colors.secondary),
                ),
              ),
            ),
          ),

          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.brand,
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.add, size: 14, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
