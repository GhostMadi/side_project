import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/content_meta_block.dart';

/// Статусы [markers.status] (строка с бэка).
String markerEventStatusLabelRu(String status) {
  return switch (status) {
    'active' => 'Сейчас идёт',
    'upcoming' => 'Скоро',
    'finished' => 'Завершено',
    'cancelled' => 'Отменено',
    _ => status,
  };
}

/// Effective status based on time window (except explicit cancelled).
String markerEffectiveStatus({
  required DateTime startLocal,
  required DateTime endLocal,
  required String storedStatus,
  DateTime? nowLocal,
}) {
  final s = storedStatus.trim();
  if (s == 'cancelled') return 'cancelled';
  final now = (nowLocal ?? DateTime.now()).toLocal();
  if (now.isBefore(startLocal)) return 'upcoming';
  if (now.isAfter(endLocal)) return 'finished';
  return 'active';
}

String formatMarkerDurationCompactRu(Duration d) {
  if (d.inDays >= 1) {
    return '${d.inDays} сут.';
  }
  if (d.inHours >= 1) {
    final m = d.inMinutes.remainder(60);
    if (m == 0) {
      return '${d.inHours} ч';
    }
    return '${d.inHours} ч $m мин';
  }
  if (d.inMinutes <= 0) {
    return '—';
  }
  return '${d.inMinutes} мин';
}

/// «12 апреля · с 19:00 до 22:00 · 2 ч» — сразу читается как дата, интервал и длительность.
String formatMarkerWhenReadableRu(DateTime startLocal, DateTime endLocal) {
  final s = startLocal;
  final e = endLocal;
  final d = e.difference(s);
  final dur = formatMarkerDurationCompactRu(d);
  final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
  if (sameDay) {
    final day = DateFormat('d MMMM', 'ru').format(s);
    final t1 = DateFormat('HH:mm', 'ru').format(s);
    final t2 = DateFormat('HH:mm', 'ru').format(e);
    return '$day · с $t1 до $t2 · $dur';
  }
  return '${DateFormat("d MMM, HH:mm", "ru").format(s)} — ${DateFormat("d MMM, HH:mm", "ru").format(e)} · $dur';
}

/// Цвета чипа статуса (как мини-pill в сетке маркеров).
({Color bg, Color fg, Color border, String shortLabel}) markerEventStatusPillContext(String status) {
  return switch (status) {
    'active' => (
      bg: AppColors.primary.withValues(alpha: 0.12),
      fg: AppColors.primary,
      border: AppColors.primary.withValues(alpha: 0.25),
      shortLabel: 'Сейчас',
    ),
    'upcoming' => (
      bg: AppColors.infoSoft,
      fg: AppColors.textColor,
      border: AppColors.borderCardBlue.withValues(alpha: 0.4),
      shortLabel: 'Скоро',
    ),
    'finished' => (
      bg: AppColors.surfaceSoft,
      fg: AppColors.subTextColor,
      border: AppColors.borderSoft,
      shortLabel: 'Прошло',
    ),
    'cancelled' => (
      bg: AppColors.error.withValues(alpha: 0.1),
      fg: AppColors.error,
      border: AppColors.error.withValues(alpha: 0.2),
      shortLabel: 'Отмена',
    ),
    _ => (
      bg: AppColors.surfaceSoft,
      fg: AppColors.subTextColor,
      border: AppColors.borderSoft,
      shortLabel: status,
    ),
  };
}

/// Как рисовать блок: [card] — отдельная пилюля/карта (маркер без поста);
/// [postInline] — в ленте текста поста, в одном тоне с заголовком/описанием.
/// [ticketInline] — как в тикет-боттомшите: старт → адрес(+copy) → длительность.
enum MarkerEventDisplayStyle { card, postInline, ticketInline }

/// Карточка «Событие»: место, время (и длительность в одной строке), копирование адреса.
/// [MarkerWithoutPostPage]: [displayStyle] = [MarkerEventDisplayStyle.card];
/// [PostDetailPage] при маркере у поста: [MarkerEventDisplayStyle.postInline].
class MarkerEventMetaCard extends StatelessWidget {
  const MarkerEventMetaCard({
    super.key,
    required this.status,
    required this.eventTime,
    required this.endTime,
    this.place,
    this.emoji,
    this.showAddressCopy = true,
    this.displayStyle = MarkerEventDisplayStyle.card,
  });

  final String status;
  final DateTime eventTime;
  final DateTime endTime;
  final String? place;
  final String? emoji;

  /// [place] — текст адреса/места; при [showAddressCopy] показываем кнопку в буфер.
  final bool showAddressCopy;
  final MarkerEventDisplayStyle displayStyle;

  @override
  Widget build(BuildContext context) {
    final e = markerDisplayEmoji(emoji);
    final placeT = place?.trim();
    final startLocal = eventTime.toLocal();
    final endLocal = endTime.toLocal();
    final whenLine = formatMarkerWhenReadableRu(startLocal, endLocal);
    final effectiveStatus = markerEffectiveStatus(
      startLocal: startLocal,
      endLocal: endLocal,
      storedStatus: status,
    );
    final pill = markerEventStatusPillContext(effectiveStatus);
    if (displayStyle == MarkerEventDisplayStyle.postInline) {
      return _buildPostInline(context, placeT, whenLine, pill);
    }
    if (displayStyle == MarkerEventDisplayStyle.ticketInline) {
      return _buildTicketInline(context, placeT, startLocal, endLocal);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceSoftGreen, AppColors.pageBackground],
        ),
        border: Border.all(color: AppColors.borderCardGreen.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e, style: const TextStyle(fontSize: 28, height: 1.1)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Событие',
                          style: AppTextStyle.base(
                            13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.subTextColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: pill.bg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: pill.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text(
                            pill.shortLabel,
                            style: AppTextStyle.base(
                              12,
                              fontWeight: FontWeight.w800,
                              color: pill.fg,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Когда',
                    style: AppTextStyle.base(
                      11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.subTextColor,
                      letterSpacing: 0.35,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    whenLine,
                    style: AppTextStyle.base(
                      16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                      height: 1.4,
                    ),
                  ),
                  if (placeT != null && placeT.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Место',
                                style: AppTextStyle.base(
                                  11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.subTextColor,
                                  letterSpacing: 0.35,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                placeT,
                                style: AppTextStyle.base(
                                  15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor.withValues(alpha: 0.86),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showAddressCopy)
                          IconButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: placeT));
                              if (!context.mounted) return;
                              AppSnackBar.show(
                                context,
                                message: 'Адрес скопирован',
                                kind: AppSnackBarKind.success,
                              );
                            },
                            icon: const Icon(Icons.content_copy_rounded, size: 20),
                            color: AppColors.primary,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            tooltip: 'Скопировать адрес',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Как [EventTicketDetailsSheet] под заголовком: только **время** и **место** (статус — чип в строке времени).
  Widget _buildPostInline(
    BuildContext context,
    String? placeT,
    String whenLine,
    ({Color bg, Color fg, Color border, String shortLabel}) pill,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContentMetaRow(
          lead: Center(
            child: Icon(Icons.schedule_rounded, size: kContentMetaIcon, color: AppColors.bottomBarActiveIcon),
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(whenLine, style: contentMetaTimeTextStyle)),
              const SizedBox(width: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: pill.bg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: pill.border, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    pill.shortLabel,
                    style: AppTextStyle.base(10, fontWeight: FontWeight.w800, color: pill.fg, height: 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (placeT != null && placeT.isNotEmpty) ...[
          const SizedBox(height: 8),
          ContentMetaRow(
            lead: Center(
              child: Icon(
                Icons.place_outlined,
                size: kContentMetaIcon,
                color: AppColors.subTextColor.withValues(alpha: 0.9),
              ),
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(placeT, style: contentMetaPlaceTextStyle)),
                if (showAddressCopy)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: placeT));
                        if (!context.mounted) return;
                        AppSnackBar.show(context, message: 'Адрес скопирован', kind: AppSnackBarKind.success);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: Icon(Icons.content_copy_rounded, size: 18, color: AppColors.iconMuted),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatStartLikeTicket(DateTime startLocal) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(startLocal.year, startLocal.month, startLocal.day);
    final t = DateFormat('HH:mm', 'ru').format(startLocal);
    if (day == today) return 'Сегодня · $t';
    if (day == today.add(const Duration(days: 1))) return 'Завтра · $t';
    final d = DateFormat('d MMMM y', 'ru').format(startLocal);
    return '$d · $t';
  }

  Widget _buildTicketInline(BuildContext context, String? placeT, DateTime startLocal, DateTime endLocal) {
    final startLine = _formatStartLikeTicket(startLocal);
    final d = endLocal.difference(startLocal);
    final dur = formatMarkerDurationCompactRu(d);
    final hasDur = dur.trim().isNotEmpty && dur.trim() != '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContentMetaRow(
          lead: Center(
            child: Icon(Icons.schedule_rounded, size: kContentMetaIcon, color: AppColors.bottomBarActiveIcon),
          ),
          body: Text(startLine, style: contentMetaTimeTextStyle),
        ),
        if (placeT != null && placeT.isNotEmpty) ...[
          const SizedBox(height: 8),
          ContentMetaRow(
            lead: Center(
              child: Icon(Icons.location_on_outlined, size: kContentMetaIcon, color: AppColors.primary),
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text(placeT, style: contentMetaPlaceTextStyle)),
                if (showAddressCopy)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: placeT));
                        if (!context.mounted) return;
                        AppSnackBar.show(context, message: 'Адрес скопирован', kind: AppSnackBarKind.success);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: Icon(Icons.content_copy_rounded, size: 18, color: AppColors.iconMuted),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (hasDur) ...[
          const SizedBox(height: 8),
          ContentMetaRow(
            lead: Center(
              child: Icon(Icons.timelapse_rounded, size: kContentMetaIcon, color: AppColors.primary),
            ),
            body: Text(dur, style: contentMetaPlaceTextStyle),
          ),
        ],
      ],
    );
  }
}

String markerDisplayEmoji(String? raw) {
  final t = raw?.trim();
  return (t == null || t.isEmpty) ? '📍' : t;
}
