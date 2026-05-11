import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_list_item.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';
import 'package:side_project/feature/partners_page/domain/relation_edge.dart';

/// Карточка одной связи: краткий статус, переход к профилю контрагента, действия приёмки.
class PartnersRelationTile extends StatelessWidget {
  const PartnersRelationTile({
    super.key,
    required this.edge,
    required this.me,
    this.onAccept,
    this.onReject,
    this.onTerminate,
  });

  final RelationEdge edge;
  final String me;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTerminate;

  String _peerId() => edge.otherAccountId(me) ?? '';

  String _typeRu() => edge.relationType == 'hire' ? 'Найм' : 'Вступление';

  String _statusRu() {
    switch (edge.status) {
      case 'pending':
        return 'Ожидает';
      case 'active':
        return 'Активна';
      case 'rejected':
        return 'Отклонена';
      case 'terminated':
        return 'Завершена';
      default:
        return edge.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final peer = _peerId();
    final shortPeer = peer.length >= 8 ? '${peer.substring(0, 8)}…' : peer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_typeRu()} · ${_statusRu()}',
                          style: AppTextStyle.base(
                            15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Профиль: $shortPeer',
                          style: AppTextStyle.base(13, height: 1.3, color: AppColors.subTextColor),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: peer.isEmpty
                        ? null
                        : () => context.router.root.push(GuestProfileRoute(profileId: peer)),
                    child: Text('Открыть', style: AppTextStyle.base(14, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              if (edge.isPendingReceiver(me) && (onAccept != null || onReject != null)) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(text: 'Отклонить', onPressed: onReject, borderRadius: 12),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppOutlinedButton(text: 'Принять', onPressed: onAccept, borderRadius: 12),
                    ),
                  ],
                ),
              ],
              if (edge.status == 'active' && onTerminate != null) ...[
                const SizedBox(height: 10),
                AppListTile(
                  title: Text(
                    'Завершить связь',
                    style: AppTextStyle.base(15, fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                  onTap: () => onTerminate!(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
