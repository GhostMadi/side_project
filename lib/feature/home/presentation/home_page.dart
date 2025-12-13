import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/shared/app_list_item.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          AppTile(
            leadingIcon: Icons.abc_outlined,
            trailingIcon: Icons.ac_unit_outlined,
            title: 'asdasd',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
