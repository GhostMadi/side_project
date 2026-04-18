import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/feature/profile_page/presentation/page/guest_profile_page.dart';

/// Alias-страница гостевого профиля с нужным названием.
///
/// Внутри переиспользует `GuestProfilePage`.
@RoutePage()
class ProfileForGuestPage extends StatelessWidget {
  const ProfileForGuestPage({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    return GuestProfilePage(profileId: profileId);
  }
}

