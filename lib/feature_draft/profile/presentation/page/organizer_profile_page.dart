import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';

@RoutePage()
class OrganizerProfilePage extends StatelessWidget {
  final String? organizerId;

  const OrganizerProfilePage({super.key, this.organizerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: const Text('Organizer'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Text(
          organizerId != null && organizerId!.isNotEmpty
              ? 'Organizer: $organizerId'
              : 'Organizer profile (draft)',
          style: AppTextStyle.base(15, color: const Color(0xFF1A1D1E)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
