import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/media_widget.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';
import 'package:side_project/feature/map_page/model/event_pin_preview.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

/// Обзор события с карты: подгружает пост по [marker.id] → [posts.marker_id], иначе данные из метки.
class EventTicketDetailsSheet extends StatefulWidget {
  const EventTicketDetailsSheet({super.key, required this.marker});

  final MapMarker marker;

  @override
  State<EventTicketDetailsSheet> createState() => _EventTicketDetailsSheetState();
}

class _EventTicketDetailsSheetState extends State<EventTicketDetailsSheet> {
  bool _loading = true;
  EventPinPreview? _preview;

  EventPinPreview _mergeMarkerAndPostPreview({
    required EventPinPreview markerPreview,
    required EventPinPreview postPreview,
  }) {
    return EventPinPreview(
      organizerId: postPreview.organizerId,
      organizerName: postPreview.organizerName,
      organizerUsername: postPreview.organizerUsername,
      organizerFullName: postPreview.organizerFullName,
      organizerCity: postPreview.organizerCity,
      organizerAvatarUrl: postPreview.organizerAvatarUrl,
      // Title must come only from Post. If Post title is empty -> show nothing (no marker fallback).
      title: postPreview.title,
      description: postPreview.description.trim().isNotEmpty
          ? postPreview.description
          : markerPreview.description,
      startsAt: markerPreview.startsAt,
      venueLabel: markerPreview.venueLabel,
      address: markerPreview.address,
      durationLabel: markerPreview.durationLabel,
      coverImageUrls: postPreview.coverImageUrls.isNotEmpty
          ? postPreview.coverImageUrls
          : markerPreview.coverImageUrls,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = widget.marker;
    if (m.isMapUserLocation) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _preview = EventPinPreview.fromMapMarker(m);
      });
      return;
    }

    final posts = sl<PostsRepository>();
    try {
      final meta = m.metadata ?? const <String, dynamic>{};
      final postId = (meta['postId'] is String) ? (meta['postId'] as String).trim() : '';
      final markerPreview = EventPinPreview.fromMapMarker(m);

      // 1) Мгновенный превью-кадр из markers (title/short/cover) уже есть в `meta`.
      if (mounted) {
        setState(() {
          _preview = markerPreview;
          _loading = false;
        });
      }

      // 2) Тяжёлый слой: пост по post_id (из RPC). Если нет postId — fallback.
      if (postId.isEmpty) return;

      final cached = posts.getCachedPostById(postId);
      if (cached != null) {
        final mini = await sl<ProfileMiniCacheStorage>().read(cached.userId);
        if (!mounted) return;
        final postPreview = EventPinPreview.fromPostModel(
          cached,
          authorUsername: mini?.username,
          authorAvatarUrl: mini?.avatarUrl,
        );
        setState(() {
          _preview = _mergeMarkerAndPostPreview(markerPreview: markerPreview, postPreview: postPreview);
        });
        return;
      }

      final byId = await posts.getByIdWithAuthorMini(postId);
      if (!mounted) return;
      if (byId == null) return;
      final postPreview = EventPinPreview.fromPostModel(
        byId.post,
        authorUsername: byId.username,
        authorFullName: byId.fullName,
        authorAvatarUrl: byId.avatarUrl,
      );
      setState(() {
        _preview = _mergeMarkerAndPostPreview(markerPreview: markerPreview, postPreview: postPreview);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _preview = EventPinPreview.fromMapMarker(m);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          ),
        ),
      );
    }

    final preview = _preview ?? EventPinPreview.fromMapMarker(widget.marker);
    final username = preview.organizerUsername?.trim();
    final hasUsername = username != null && username.isNotEmpty;
    final fullName = preview.organizerFullName?.trim();
    final hasFullName = fullName != null && fullName.isNotEmpty;
    final fallbackNick = preview.organizerName.trim();
    final nicknameLine = hasUsername
        ? username
        : ((fallbackNick.isNotEmpty && fallbackNick != 'Автор') ? fallbackNick : '');
    final hasNicknameLine = nicknameLine.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                final router = context.router.root;
                final id = preview.organizerId;
                Navigator.of(context).maybePop();
                router.push(OrganizerProfileRoute(organizerId: id));
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _OrganizerAvatar(
                      size: 52,
                      url: preview.organizerAvatarUrl,
                      fallbackEmoji: widget.marker.emoji,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasNicknameLine)
                            Text(
                              nicknameLine,
                              style: AppTextStyle.base(
                                16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColor,
                              ),
                            ),
                          if (hasFullName) ...[
                            const SizedBox(height: 2),
                            Text(
                              fullName,
                              style: AppTextStyle.base(
                                13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: preview.coverImageUrls.isEmpty
                ? _CoverFallback(emoji: widget.marker.emoji)
                : _AdaptiveEventPhotoCarousel(urls: preview.coverImageUrls, emoji: widget.marker.emoji),
          ),
          if (preview.title.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              preview.title,
              style: AppTextStyle.base(
                22,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
          ] else
            const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: AppColors.bottomBarActiveIcon),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  preview.formattedDateTime,
                  style: AppTextStyle.base(14, fontWeight: FontWeight.w600, color: AppColors.textColor),
                ),
              ),
            ],
          ),
          if (preview.venueLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Icon(Icons.radio_button_on_sharp, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    preview.venueLabel,
                    style: AppTextStyle.base(
                      13,
                      height: 1.35,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (preview.durationLabel != null && preview.durationLabel!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Icon(Icons.timelapse_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    preview.durationLabel!,
                    style: AppTextStyle.base(
                      13,
                      height: 1.35,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (preview.address != null && preview.address!.trim().isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    preview.address!,
                    style: AppTextStyle.base(
                      13,
                      height: 1.35,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.subTextColor.withValues(alpha: 0.8),
                  ),
                  tooltip: 'Копировать адрес',
                  onPressed: () {
                    final text = preview.address!.trim();
                    if (text.isEmpty) return;
                    Clipboard.setData(ClipboardData(text: text));
                    AppSnackBar.show(context, message: 'Скопировано', kind: AppSnackBarKind.info);
                  },
                ),
              ],
            ),
          ],

          if (preview.description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              preview.description,
              style: AppTextStyle.base(14, height: 1.5, color: AppColors.textColor.withValues(alpha: 0.85)),
            ),
          ],
          const SizedBox(height: 10),
          // AppButton(
          //   text: 'Перейти в чат',
          //   onPressed: () {
          //     HapticFeedback.mediumImpact();
          //     AppSnackBar.show(
          //       context,
          //       message: 'Чат с заведением — подключите экран чата',
          //       kind: AppSnackBarKind.info,
          //     );
          //     Navigator.of(context).maybePop();
          //   },
          // ),
        ],
      ),
    );
  }
}

class _OrganizerAvatar extends StatelessWidget {
  const _OrganizerAvatar({this.url, required this.fallbackEmoji, this.size = 40});

  final String? url;
  final String fallbackEmoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _emojiCircle(size),
        ),
      );
    }
    return _emojiCircle(size);
  }

  Widget _emojiCircle(double s) {
    return Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bottomBarSegment,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.25)),
      ),
      child: Text(fallbackEmoji, style: TextStyle(fontSize: (s * 0.58).clamp(16, 24))),
    );
  }
}

class _EventPhotoCarousel extends StatefulWidget {
  const _EventPhotoCarousel({required this.urls, required this.emoji});

  final List<String> urls;
  final String emoji;

  @override
  State<_EventPhotoCarousel> createState() => _EventPhotoCarouselState();
}

class _AdaptiveEventPhotoCarousel extends StatefulWidget {
  const _AdaptiveEventPhotoCarousel({required this.urls, required this.emoji});

  final List<String> urls;
  final String emoji;

  @override
  State<_AdaptiveEventPhotoCarousel> createState() => _AdaptiveEventPhotoCarouselState();
}

class _AdaptiveEventPhotoCarouselState extends State<_AdaptiveEventPhotoCarousel> {
  late final PageController _controller;
  int _page = 0;

  static const _ratioMin = 0.55;
  static const _ratioMax = 1.6;
  static final _aspectRe = RegExp(r'__ar-(\d+)x(\d+)', caseSensitive: false);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _ratioFromUrl(String url) {
    if (url.isEmpty) return null;
    final u = Uri.tryParse(url);
    final path = (u?.path ?? url).toLowerCase();
    final m = _aspectRe.firstMatch(path);
    if (m == null) return null;
    final w = int.tryParse(m.group(1) ?? '');
    final h = int.tryParse(m.group(2) ?? '');
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / h;
  }

  BoxFit _fitForUrl(String url) {
    final r = _ratioFromUrl(url);
    if (r != null && r < 1.0) return BoxFit.contain;
    return BoxFit.cover;
  }

  String _activeUrl() {
    final urls = widget.urls;
    if (urls.isEmpty) return '';
    final i = _page.clamp(0, urls.length - 1);
    return urls[i].trim();
  }

  @override
  Widget build(BuildContext context) {
    final activeUrl = _activeUrl();
    final aspectRatio = (_ratioFromUrl(activeUrl) ?? (16 / 9)).clamp(_ratioMin, _ratioMax);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = (w / aspectRatio).clamp(w * 0.50, w * 2.0);
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            height: h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: widget.urls.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final url = widget.urls[index].trim();
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            fullscreenDialog: true,
                            builder: (ctx) => _EventImageViewerPage(
                              urls: widget.urls,
                              initialIndex: index,
                              emoji: widget.emoji,
                            ),
                          ),
                        );
                      },
                      child: MediaWidget.previewTile(
                        url: url,
                        fit: _fitForUrl(url),
                        fadeDuration: const Duration(milliseconds: 160),
                        placeholder: _CoverFallback(emoji: widget.emoji),
                        errorWidget: _CoverFallback(emoji: widget.emoji),
                        showPlayBadge: true,
                      ),
                    );
                  },
                ),
                if (widget.urls.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.urls.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _page == i ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white.withValues(alpha: _page == i ? 0.95 : 0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventPhotoCarouselState extends State<_EventPhotoCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (ctx) =>
                        _EventImageViewerPage(urls: widget.urls, initialIndex: index, emoji: widget.emoji),
                  ),
                );
              },
              child: Image.network(
                widget.urls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _CoverFallback(emoji: widget.emoji),
              ),
            );
          },
        ),
        if (widget.urls.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.urls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _page == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withValues(alpha: _page == i ? 0.95 : 0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EventImageViewerPage extends StatefulWidget {
  const _EventImageViewerPage({required this.urls, required this.initialIndex, required this.emoji});

  final List<String> urls;
  final int initialIndex;
  final String emoji;

  @override
  State<_EventImageViewerPage> createState() => _EventImageViewerPageState();
}

class _EventImageViewerPageState extends State<_EventImageViewerPage> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    final max = widget.urls.length - 1;
    _index = widget.initialIndex.clamp(0, max < 0 ? 0 : max);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  widget.urls[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Text(widget.emoji, style: const TextStyle(fontSize: 72, color: Colors.white38)),
                ),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.urls.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _index == i ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withValues(alpha: _index == i ? 0.95 : 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bottomBarSegment,
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 64)),
    );
  }
}
