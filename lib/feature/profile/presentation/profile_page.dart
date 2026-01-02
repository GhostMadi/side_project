import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.red),
          // GestureDetector(
          //   onTap: () {
          //     sl<AuthCubit>().signOut();
          //     context.router.replaceAll([const HomeRoute()]);
          //   },
          //   child: Text('logout'),
          // ),
        ],
      ),
    );
  }
}
