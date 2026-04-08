import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';

@RoutePage()
class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: const Text('My appointments'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Text(
          'No appointments yet.',
          style: AppTextStyle.base(15, color: const Color(0xFF6A6A6A)),
        ),
      ),
    );
  }
}
