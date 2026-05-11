import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/feature/partners_page/domain/relation_edge.dart';
import 'package:side_project/feature/partners_page/presentation/cubit/partners_relations_cubit.dart';
import 'package:side_project/feature/partners_page/widgets/partners_relation_tile.dart';
import 'package:side_project/feature/partners_page/widgets/partners_section_header.dart';

class PartnersPageContent extends StatelessWidget {
  const PartnersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartnersRelationsCubit, PartnersRelationsState>(
      listener: (context, state) {
        state.whenOrNull(error: (msg) {
          AppSnackBar.show(context, message: msg, kind: AppSnackBarKind.error);
        });
      },
      builder: (context, state) {
        return state.when(
          loading: () => const Center(
            child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 32, color: AppColors.primary),
          ),
          error: (msg) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(msg, textAlign: TextAlign.center, style: AppTextStyle.base(15, color: AppColors.error)),
            ),
          ),
          loaded: (viewerId, hireIn, hireOut, joinIn, joinOut, active) {
            final cubit = context.read<PartnersRelationsCubit>();

            Widget tileForIncoming(RelationEdge e) {
              return PartnersRelationTile(
                edge: e,
                me: viewerId,
                onAccept: () async {
                  final err = await cubit.accept(e.id);
                  if (context.mounted && err != null) {
                    AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                  }
                },
                onReject: () async {
                  final err = await cubit.reject(e.id);
                  if (context.mounted && err != null) {
                    AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                  }
                },
              );
            }

            Widget tileForOutgoing(RelationEdge e) {
              return PartnersRelationTile(edge: e, me: viewerId);
            }

            Widget tileForActive(RelationEdge e) {
              return PartnersRelationTile(
                edge: e,
                me: viewerId,
                onTerminate: () async {
                  final err = await cubit.terminate(e.id);
                  if (context.mounted && err != null) {
                    AppSnackBar.show(context, message: err, kind: AppSnackBarKind.error);
                  }
                },
              );
            }

            final slivers = <Widget>[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    'Заявки и активные связи (найм и вступление в команду).',
                    style: TextStyle(fontSize: 14, height: 1.35, color: AppColors.subTextColor),
                  ),
                ),
              ),
            ];

            void pushSection(String title, List<RelationEdge> edges, Widget Function(RelationEdge) tileBuilder) {
              if (edges.isEmpty) return;
              slivers.add(SliverToBoxAdapter(child: PartnersSectionHeader(title: title)));
              for (final e in edges) {
                slivers.add(SliverToBoxAdapter(child: tileBuilder(e)));
              }
            }

            pushSection('Активные', active, tileForActive);
            pushSection('Найм — входящие', hireIn, tileForIncoming);
            pushSection('Найм — исходящие', hireOut, tileForOutgoing);
            pushSection('Вступление — входящие', joinIn, tileForIncoming);
            pushSection('Вступление — исходящие', joinOut, tileForOutgoing);

            if (slivers.length == 1) {
              slivers.add(
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Пока нет заявок и связей.',
                      style: TextStyle(fontSize: 15, color: AppColors.subTextColor),
                    ),
                  ),
                ),
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: slivers,
            );
          },
        );
      },
    );
  }
}
