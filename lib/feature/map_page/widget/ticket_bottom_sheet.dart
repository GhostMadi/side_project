import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/map_page/model/event_pin_preview.dart';

/// Обзор события с карты: организатор, обложка, дата, тексты, переход в чат.
class EventTicketDetailsSheet extends StatelessWidget {
  const EventTicketDetailsSheet({super.key, required this.marker});

  final MapMarker marker;

  @override
  Widget build(BuildContext context) {
    final preview = EventPinPreview.fromMapMarker(marker);

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
                    _OrganizerAvatar(url: preview.organizerAvatarUrl, fallbackEmoji: marker.emoji),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preview.organizerName,
                            style: AppTextStyle.base(
                              16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preview.organizerCity,
                            style: AppTextStyle.base(
                              13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.subTextColor,
                            ),
                          ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = w * 9 / 16;
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: h,
                  width: w,
                  child: preview.coverImageUrls.isEmpty
                      ? _CoverFallback(emoji: marker.emoji)
                      : _EventPhotoCarousel(urls: preview.coverImageUrls, emoji: marker.emoji),
                ),
              );
            },
          ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place_outlined, size: 18, color: AppColors.subTextColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    preview.venueLabel,
                    style: AppTextStyle.base(13, height: 1.35, color: AppColors.subTextColor),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            preview.subtitle,
            style: AppTextStyle.base(
              15,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            preview.description,
            style: AppTextStyle.base(14, height: 1.5, color: AppColors.textColor.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Перейти в чат',
            onPressed: () {
              HapticFeedback.mediumImpact();
              final messenger = ScaffoldMessenger.maybeOf(context);
              Navigator.of(context).maybePop();
              messenger?.showSnackBar(
                const SnackBar(
                  content: Text('Чат с заведением — подключите экран чата'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrganizerAvatar extends StatelessWidget {
  const _OrganizerAvatar({this.url, required this.fallbackEmoji});

  final String? url;
  final String fallbackEmoji;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
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

  Widget _emojiCircle(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bottomBarSegment,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.25)),
      ),
      child: Text(fallbackEmoji, style: const TextStyle(fontSize: 26)),
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
