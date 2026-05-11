import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/storage/prefs/profile_hire_cache_storage.dart';
import 'package:side_project/feature/partners_page/data/relations_repository.dart';
import 'package:side_project/feature/partners_page/domain/relation_edge.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile_hire/data/reposiotry/profile_hire_mine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Кнопки «Найм» / «Вступить» и ответ на заявку. Состояние связи важнее флагов профиля.
class ProfileRelationFooter extends StatefulWidget {
  const ProfileRelationFooter({super.key, required this.targetProfile});

  final ProfileModel targetProfile;

  @override
  State<ProfileRelationFooter> createState() => _ProfileRelationFooterState();
}

class _ProfileRelationFooterState extends State<ProfileRelationFooter> {
  RelationEdge? _edge;
  bool _myHiringEnabled = false;
  bool _loading = true;
  bool _busy = false;

  String? get _me => Supabase.instance.client.auth.currentUser?.id.trim();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final me = _me;
    if (me == null || me == widget.targetProfile.id) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final rel = sl<RelationsRepository>().getMyRelationWith(widget.targetProfile.id);
      final peek = sl<ProfileHireRepository>().peekGate();
      final results = await Future.wait<Object?>([rel, peek]);
      final edge = results[0] as RelationEdge?;
      final p = results[1] as ProfileHireGatePeek;
      final hire = p.stored?.hiringEnabled ?? false;
      if (!mounted) return;
      setState(() {
        _edge = edge;
        _myHiringEnabled = hire;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() fn, {String? success}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
      if (!mounted) return;
      if (success != null) {
        AppSnackBar.show(context, message: success, kind: AppSnackBarKind.success);
      }
      await _reload();
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: mapRelationsRpcError(e), kind: AppSnackBarKind.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    if (me == null || me == widget.targetProfile.id) return const SizedBox.shrink();

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    final edge = _edge;
    final target = widget.targetProfile;

    if (edge != null && edge.status == 'active') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Связь оформлена',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          AppOutlinedButton(
            text: 'Все связи',
            onPressed: _busy ? null : () => context.router.root.push(const PartnerRoute()),
            borderRadius: 12,
          ),
        ],
      );
    }

    if (edge != null && edge.status == 'pending' && edge.isPendingReceiver(me)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            edge.relationType == 'hire' ? 'Вам предложили найм' : 'Заявка на вступление в команду',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, fontWeight: FontWeight.w600, color: AppColors.textColor),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  text: 'Отклонить',
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => sl<RelationsRepository>().updateRelationStatus(
                            relationId: edge.id,
                            newStatus: 'rejected',
                          ),
                        ),
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: 'Принять',
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => sl<RelationsRepository>().updateRelationStatus(
                            relationId: edge.id,
                            newStatus: 'active',
                          ),
                          success: 'Связь подтверждена',
                        ),
                  isExpanded: true,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (edge != null && edge.status == 'pending' && edge.isPendingInitiator(me)) {
      final msg = edge.relationType == 'hire' ? 'Заявка на найм отправлена' : 'Заявка на вступление отправлена';
      return Text(
        msg,
        textAlign: TextAlign.center,
        style: AppTextStyle.base(14, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
      );
    }

    final showHire = _myHiringEnabled;
    final showJoin = target.openForMemberships;

    if (!showHire && !showJoin) return const SizedBox.shrink();

    return Row(
      children: [
        if (showHire)
          Expanded(
            child: AppButton(
              text: 'Нанять',
              isExpanded: true,
              onPressed: _busy
                  ? null
                  : () => _run(
                      () => sl<RelationsRepository>().requestRelation(targetUserId: target.id, action: 'hire'),
                      success: 'Заявка отправлена',
                    ),
            ),
          ),
        if (showHire && showJoin) const SizedBox(width: 12),
        if (showJoin)
          Expanded(
            child: AppOutlinedButton(
              text: 'Вступить',
              borderRadius: 12,
              onPressed: _busy
                  ? null
                  : () => _run(
                      () => sl<RelationsRepository>().requestRelation(targetUserId: target.id, action: 'join'),
                      success: 'Заявка отправлена',
                    ),
            ),
          ),
      ],
    );
  }
}
