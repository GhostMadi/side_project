import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/feature/partners_page/presentation/cubit/partners_relations_cubit.dart';
import 'package:side_project/feature/partners_page/presentation/partners_page_content.dart';

@RoutePage()
class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PartnersRelationsCubit>()..load(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          backgroundColor: Colors.white,
          title: Text('Связи', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<PartnersRelationsCubit>().load(),
          child: const PartnersPageContent(),
        ),
      ),
    );
  }
}
