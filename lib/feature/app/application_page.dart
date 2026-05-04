import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/app/widget/app_bottom_bar.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_conversations_list_cubit.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_repository.dart';

@RoutePage()
class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(sl<BusinessProfileRepository>().warmCacheFromRemoteBestEffort());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatConversationsListCubit>()..load(),
      child: AutoTabsRouter(
        routes: const [MapRoute(), ChatListRoute(), ProfileRoute()],
        builder: (context, child) {
          return Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: child,
            bottomNavigationBar: Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              color: Colors.transparent,
              child: const AppBottomBar(),
            ),
          );
        },
      ),
    );
  }
}
