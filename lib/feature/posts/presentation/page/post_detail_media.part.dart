part of 'post_detail_page.dart';

class _AdaptiveMediaPager extends StatefulWidget {
  const _AdaptiveMediaPager({
    required this.urls,
    required this.pageIndex,
    required this.onPageChanged,
    required this.pageController,
    required this.heroPostId,
    required this.aspectRatio,
    required this.onLike,
    required this.onDislike,
  });

  final List<String> urls;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final PageController pageController;
  final String heroPostId;
  final double aspectRatio;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  @override
  State<_AdaptiveMediaPager> createState() => _AdaptiveMediaPagerState();
}

class _AdaptiveMediaPagerState extends State<_AdaptiveMediaPager> {
  late int _currentIndex;
  int _tapCount = 0;
  Timer? _tapTimer;
  _BurstKind? _burst;
  Timer? _burstTimer;

  static const _ratioMin = 0.55;
  static const _ratioMax = 1.6;
  static final _aspectRe = RegExp(r'__ar-(\d+)x(\d+)', caseSensitive: false);
  static const _tapWindow = Duration(milliseconds: 320);
  static const _burstDuration = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.pageIndex;
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _burstTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AdaptiveMediaPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _currentIndex = widget.pageIndex;
    }
  }

  void _registerTap() {
    _tapCount += 1;
    _tapTimer?.cancel();
    _tapTimer = Timer(_tapWindow, () {
      final c = _tapCount;
      _tapCount = 0;
      if (!mounted) return;
      if (c >= 3) {
        _triggerDislikeBurst();
        widget.onDislike();
        return;
      }
      if (c == 2) {
        _triggerLikeBurst();
        widget.onLike();
      }
    });
  }

  void _triggerLikeBurst() {
    _burstTimer?.cancel();
    setState(() => _burst = _BurstKind.like);
    _burstTimer = Timer(_burstDuration, () {
      if (!mounted) return;
      setState(() => _burst = null);
    });
  }

  void _triggerDislikeBurst() {
    _burstTimer?.cancel();
    setState(() => _burst = _BurstKind.dislike);
    _burstTimer = Timer(_burstDuration, () {
      if (!mounted) return;
      setState(() => _burst = null);
    });
  }

  String _activeUrl(List<String> urls, {int? pageIndex}) {
    if (urls.isEmpty) return '';
    final i = (pageIndex ?? _currentIndex).clamp(0, urls.length - 1);
    return urls[i];
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

  /// Вертикальные кадры (9×16 и т.д.): [BoxFit.cover] режет бока при малейшем
  /// расхождении контейнера и реального соотношения — показываем целиком по ширине.
  BoxFit _boxFitForStillUrl(String url) {
    final r = _ratioFromUrl(url);
    if (r != null && r < 1.0) return BoxFit.contain;
    return BoxFit.cover;
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    final activeUrl = _activeUrl(urls);
    final aspectRatio = (_ratioFromUrl(activeUrl) ?? widget.aspectRatio).clamp(_ratioMin, _ratioMax);

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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _registerTap,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: widget.pageController,
                    onPageChanged: (i) {
                      setState(() => _currentIndex = i);
                      widget.onPageChanged(i);
                      assert(() {
                        final u = _activeUrl(widget.urls);
                        final r = _ratioFromUrl(u);
                        debugPrint('PostDetail pager: index=$i url=${u.split('/').last} ratio=$r');
                        return true;
                      }());
                    },
                    itemCount: urls.isEmpty ? 1 : urls.length,
                    itemBuilder: (context, i) {
                      final url = urls.isEmpty ? '' : urls[i];
                      if (url.isEmpty) {
                        return const PostMediaFramePlaceholder(shimmer: true);
                      }
                      if (MediaService.isVideo(url)) {
                        return _NetworkVideoFrame(
                          url: url,
                          shimmerPlaceholder: const PostMediaFramePlaceholder(shimmer: true),
                        );
                      }
                      final imageFit = _boxFitForStillUrl(url);
                      final img = AppProgressiveNetworkImage(
                        imageUrl: url,
                        fit: imageFit,
                        fadeInDuration: Duration.zero,
                        backgroundColor: AppColors.surfaceSoft,
                      );
                      if (i != 0) return img;
                      return buildPostHero(postId: widget.heroPostId, child: img);
                    },
                  ),
                  IgnorePointer(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 140),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _burst == null
                            ? const SizedBox.shrink()
                            : _InstaBurst(key: ValueKey(_burst), kind: _burst!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NetworkVideoFrame extends StatefulWidget {
  const _NetworkVideoFrame({required this.url, required this.shimmerPlaceholder});

  final String url;
  final Widget shimmerPlaceholder;

  @override
  State<_NetworkVideoFrame> createState() => _NetworkVideoFrameState();
}

class _NetworkVideoFrameState extends State<_NetworkVideoFrame> {
  VideoPlayerController? _c;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void didUpdateWidget(covariant _NetworkVideoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      unawaited(_init());
    }
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prev = _c;
    _c = null;
    await prev?.dispose();

    try {
      final uri = Uri.parse(widget.url);
      final c = VideoPlayerController.networkUrl(uri);
      _c = c;
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return widget.shimmerPlaceholder;

    final c = _c;
    if (_error != null || c == null || !c.value.isInitialized) {
      return ColoredBox(
        color: AppColors.surfaceSoft,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 44,
                  color: AppColors.subTextColor.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 10),
                Text(
                  'Не удалось загрузить видео',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.base(14, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: _init, child: const Text('Повторить')),
              ],
            ),
          ),
        ),
      );
    }

    final sz = c.value.size;
    final videoPortrait = sz.width > 0 && sz.height > 0 && sz.width < sz.height;
    final videoFit = videoPortrait ? BoxFit.contain : BoxFit.cover;

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: videoFit,
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(width: sz.width, height: sz.height, child: VideoPlayer(c)),
        ),
        if (c.value.isBuffering)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.08),
            child: const Center(child: PostMediaFramePlaceholder(shimmer: true)),
          ),
      ],
    );
  }
}

enum _BurstKind { like, dislike }

class _InstaBurst extends StatefulWidget {
  const _InstaBurst({super.key, required this.kind});
  final _BurstKind kind;

  @override
  State<_InstaBurst> createState() => _InstaBurstState();
}

class _InstaBurstState extends State<_InstaBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
    ]).animate(_c);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.25, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.kind == _BurstKind.like ? Icons.favorite : Icons.thumb_down;
    final color = widget.kind == _BurstKind.like ? AppColors.error : AppColors.textInverse;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Icon(
              icon,
              size: 110,
              color: color,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  color: AppColors.black.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

