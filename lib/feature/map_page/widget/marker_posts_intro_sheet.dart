import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/core/shared/marker_event_meta_card.dart' show formatMarkerDurationCompactRu;
import 'package:side_project/feature/map_page/data/repository/marker_post_links_repository.dart';
import 'package:side_project/feature/map_page/widget/marker_posts_list_sheet.dart';
import 'package:side_project/feature/map_page/widget/ticket_bottom_sheet.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

/// Промежуточный bottom sheet при нескольких публикациях у маркера.
///
/// Всегда показывается только через [AppBottomSheet] ([show]).
class MarkerPostsIntroSheet extends StatefulWidget {
  const MarkerPostsIntroSheet({super.key, required this.mapMarker, required this.hostContext});

  final MapMarker mapMarker;

  /// Контекст родителя ([MapPage]) после закрытия промежуточной шторки — для следующего вызова [AppBottomSheet].
  final BuildContext hostContext;

  /// Обёртка над [AppBottomSheet.show] — единственная точка входа для промежуточного списка на карте.
  static Future<void> show(BuildContext context, MapMarker marker) {
    return AppBottomSheet.show<void>(
      context: context,
      content: MarkerPostsIntroSheet(mapMarker: marker, hostContext: context),
    );
  }

  @override
  State<MarkerPostsIntroSheet> createState() => _MarkerPostsIntroSheetState();
}

class _MarkerPostsIntroSheetState extends State<MarkerPostsIntroSheet> {
  late Future<void> _load;
  Object? _err;
  List<MarkerPostLink> _links = const [];

  @override
  void initState() {
    super.initState();
    _load = _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final links = await sl<MarkerPostLinksRepository>().listPostsForMarker(widget.mapMarker.id);
      if (!mounted) return;
      setState(() => _links = links);
    } catch (e) {
      if (mounted) setState(() => _err = e);
    }
  }

  static MapMarker _markerWithPostId(MapMarker m, String postId) {
    final id = postId.trim();
    return MapMarker(
      id: m.id,
      lat: m.lat,
      lng: m.lng,
      emoji: m.emoji,
      imageUrl: m.imageUrl,
      imageUrls: m.imageUrls,
      markerPostCount: m.markerPostCount,
      pinFootLine: m.pinFootLine,
      metadata: {...?m.metadata, 'postId': id},
      photoStyle: m.photoStyle,
      isMapUserLocation: m.isMapUserLocation,
    );
  }

  static Widget _tileSubtitle(BuildContext context, PostModel post) {
    final subStyle = AppTextStyle.base(13, color: AppColors.subTextColor, fontWeight: FontWeight.w600);
    late final DateTime startLocal;
    Duration? dur;
    if (post.marker != null) {
      final w = post.resolvedMarkerEventWindow;
      startLocal = w.start.toLocal();
      dur = w.end.difference(w.start);
    } else {
      startLocal = post.createdAt.toLocal();
      dur = null;
    }
    final timeStr = DateFormat('HH:mm', 'ru').format(startLocal);
    final durLabel = dur == null || dur.inSeconds <= 0 ? '—' : formatMarkerDurationCompactRu(dur);

    final icFg = AppColors.subTextColor.withValues(alpha: 0.88);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.schedule_rounded, size: 15, color: icFg),
        const SizedBox(width: 6),
        Text(timeStr, style: subStyle),
        const SizedBox(width: 14),
        Icon(Icons.hourglass_bottom_rounded, size: 15, color: icFg),
        const SizedBox(width: 6),
        Expanded(
          child: Text(durLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: subStyle),
        ),
      ],
    );
  }

  void _showTicketForPost(String postId) {
    Navigator.of(context).pop();
    AppBottomSheet.show(
      context: widget.hostContext,
      content: EventTicketDetailsSheet(marker: _markerWithPostId(widget.mapMarker, postId)),
    );
  }

  void _showFullList() {
    Navigator.of(context).pop();
    final ctx = widget.hostContext;
    final mq = MediaQuery.of(ctx);
    final contentH = (mq.size.height * 0.76).clamp(320.0, mq.size.height * 0.92);

    AppBottomSheet.show<void>(
      context: ctx,
      contentHeight: contentH,
      contentBottomSpacing: 12,
      postFeedSurface: true,
      contentPadding: EdgeInsets.zero,
      content: MarkerPostsListSheet(mapMarker: widget.mapMarker),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done && _links.isEmpty) {
          return SizedBox(
            height: 120,
            child: Center(
              child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 28, color: AppColors.primary),
            ),
          );
        }
        if (_err != null) {
          return SizedBox(
            height: 88,
            child: Center(
              child: Text('Не удалось загрузить посты', style: AppTextStyle.base(15, color: AppColors.error)),
            ),
          );
        }
        if (_links.isEmpty) {
          return SizedBox(
            height: 72,
            child: Center(
              child: Text('Нет постов', style: AppTextStyle.base(15, color: AppColors.subTextColor)),
            ),
          );
        }

        final n = _links.length;
        final screenH = MediaQuery.sizeOf(context).height;
        final listMaxH = min(screenH * 0.52, 460.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showFullList,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Все публикации ($n)',
                  style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxH.clamp(180.0, 460.0)),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: n,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.borderSoft.withValues(alpha: 0.65)),
                itemBuilder: (context, i) {
                  final link = _links[i];
                  return FutureBuilder(
                    future: sl<PostsRepository>().getByIdWithAuthorMini(link.postId),
                    builder: (context, snap) {
                      final base = snap.data;
                      final post = base?.post ?? sl<PostsRepository>().getCachedPostById(link.postId);
                      if (post == null) {
                        if (snap.connectionState != ConnectionState.done) {
                          return SizedBox(
                            height: 52,
                            child: Center(
                              child: AppCircularProgressIndicator(
                                strokeWidth: 2,
                                dimension: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        return ListTile(
                          title: Text(
                            'Пост недоступен',
                            style: AppTextStyle.base(15, color: AppColors.subTextColor),
                          ),
                        );
                      }
                      final titleText = post.title?.trim();
                      final titleStr = (titleText != null && titleText.isNotEmpty) ? titleText : 'Публикация';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                        minVerticalPadding: 0,
                        leading: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.mapMarker.emoji,
                            style: const TextStyle(fontSize: 22, height: 1.1),
                          ),
                        ),
                        title: Text(
                          titleStr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.base(15, fontWeight: FontWeight.w700, height: 1.22),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _tileSubtitle(context, post),
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.subTextColor.withValues(alpha: 0.65),
                        ),
                        onTap: () => _showTicketForPost(link.postId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
