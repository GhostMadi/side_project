import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('asd')],
      ),
    );
  }
}
