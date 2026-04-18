import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_media_gallery_item.dart';
import 'package:video_player/video_player.dart';

/// Скругление превью в ленте — совпадает с сеткой чата (`ClipRRect` 10).
const double kAppMediaGalleryThumbHeroRadius = 10;

/// Полноэкранный просмотр списка медиа (свайп между кадрами). Открывать через [show].
abstract final class AppMediaGalleryViewer {
  AppMediaGalleryViewer._();

  /// Последний переданный в [show] rect превью (глобальные координаты), для отладки / будущих переходов.
  static Rect? lastOpenedThumbnailRect;

  /// Для пары Hero на превью и в [show]: дуговая траектория, как в Material.
  static CreateRectTween get heroRectTween => (Rect? begin, Rect? end) {
    if (begin == null || end == null) return RectTween(begin: begin, end: end);
    return MaterialRectArcTween(begin: begin, end: end);
  };

  /// [thumbnailRect] — глобальный rect превью в ленте (для Hero / будущих кастомных переходов).
  static Future<void> show(
    BuildContext context, {
    required List<AppMediaGalleryItem> items,
    int initialIndex = 0,
    List<String?>? heroTags,
    Rect? thumbnailRect,
  }) {
    if (items.isEmpty) return Future.value();
    assert(heroTags == null || heroTags.length == items.length, 'heroTags must match items length');
    final i = initialIndex.clamp(0, items.length - 1);
    lastOpenedThumbnailRect = thumbnailRect;
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: 'AppMediaGalleryViewer'),
        fullscreenDialog: true,
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            _GalleryViewerScaffold(items: items, initialIndex: i, heroTags: heroTags),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) => child,
      ),
    );
  }
}

/// Передаёт коэффициент затемнения (0…1) для фона/AppBar при свайпе — чат проступает сквозь слой.
class _GalleryBackdropFade extends InheritedWidget {
  const _GalleryBackdropFade({required this.dim, required super.child});

  /// Непрозрачность чёрного слоя (1 = как раньше, к 0 — виден экран под маршрутом).
  final double dim;

  static double of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_GalleryBackdropFade>();
    return scope?.dim ?? 1;
  }

  @override
  bool updateShouldNotify(covariant _GalleryBackdropFade oldWidget) => oldWidget.dim != dim;
}

/// Свайп вверх/вниз: 1:1 с пальцем; масштаб ↓ до ~0.82; фон связан со свайпом и с [ModalRoute.animation] (открытие 0→1, закрытие Hero).
/// Закрытие свайпом → сразу [Navigator.pop]: Hero возвращает картинку в превью в сообщении (без выезда за экран).
class _SwipeDismissGalleryShell extends StatefulWidget {
  const _SwipeDismissGalleryShell({required this.child, required this.onDismiss});

  final Widget child;
  final VoidCallback onDismiss;

  @override
  State<_SwipeDismissGalleryShell> createState() => _SwipeDismissGalleryShellState();
}

class _SwipeDismissGalleryShellState extends State<_SwipeDismissGalleryShell> with TickerProviderStateMixin {
  double _dragY = 0;

  late final AnimationController _snapCtrl;
  Animation<double> _snapMotion = const AlwaysStoppedAnimation<double>(0);

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        if (_snapCtrl.isAnimating) {
          setState(() => _dragY = _snapMotion.value);
        }
      });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  double _clampDrag(double y, double h) {
    if (h <= 0) return y;
    final limit = h * 0.42;
    return y.clamp(-limit, limit);
  }

  /// Альфа затемнения только от свайпа (без учёта входа маршрута): 1 → почти прозрачный при большом сдвиге.
  double _swipeBackdropAlpha(double h) {
    if (h <= 0) return 1;
    final t = (_dragY.abs() / (h * 0.42)).clamp(0.0, 1.0);
    return lerpDouble(1, 0.06, Curves.easeOut.transform(t))!.clamp(0.0, 1.0);
  }

  /// При открытии маршрута 0→1: затемнение нарастает поверх чата; при pop — синхронно гаснет вместе с Hero.
  double _routeEnterFactor(BuildContext context) {
    final route = ModalRoute.of(context);
    final a = route?.animation;
    if (a != null) return a.value;
    return route?.isCurrent == true ? 1.0 : 0.0;
  }

  double _effectiveBackdropAlpha(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final swipe = _swipeBackdropAlpha(h);
    final routeT = _routeEnterFactor(context);
    return (swipe * routeT).clamp(0.0, 1.0);
  }

  /// Чем дальше тянем, тем меньше масштаб (~1 → ~0.82).
  double _dragScale(double h) {
    if (h <= 0) return 1;
    final t = (_dragY.abs() / (h * 0.38)).clamp(0.0, 1.0);
    return lerpDouble(1.0, 0.82, Curves.easeOut.transform(t))!;
  }

  void _stopSnapAndSync() {
    if (!_snapCtrl.isAnimating) return;
    final v = _snapMotion.value;
    _snapCtrl.stop();
    _snapCtrl.reset();
    _dragY = v;
  }

  void _snapBack() {
    final start = _dragY;
    _snapMotion = Tween<double>(
      begin: start,
      end: 0,
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));
    _snapCtrl.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => _dragY = 0);
      _snapCtrl.reset();
    });
  }

  void _onVerticalDragStart(DragStartDetails _) {
    _stopSnapAndSync();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final h = MediaQuery.sizeOf(context).height;
    setState(() {
      _dragY = _clampDrag(_dragY + details.delta.dy, h);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final h = MediaQuery.sizeOf(context).height;
    final threshold = h * 0.16;
    final vy = details.velocity.pixelsPerSecond.dy;

    final flingDismiss = vy.abs() > 1150;
    final distanceDismiss = _dragY.abs() > threshold;
    final shouldDismiss = distanceDismiss || flingDismiss;

    if (shouldDismiss) {
      widget.onDismiss();
      return;
    }
    _snapBack();
  }

  @override
  Widget build(BuildContext context) {
    final busySnap = _snapCtrl.isAnimating;
    final h = MediaQuery.sizeOf(context).height;
    final dim = _effectiveBackdropAlpha(context);
    final scale = _dragScale(h);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          onVerticalDragCancel: busySnap ? null : _snapBack,
          child: Transform.translate(
            offset: Offset(0, _dragY),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: RepaintBoundary(
                child: _GalleryBackdropFade(dim: dim, child: widget.child),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GalleryViewerScaffold extends StatefulWidget {
  const _GalleryViewerScaffold({required this.items, required this.initialIndex, this.heroTags});

  final List<AppMediaGalleryItem> items;
  final int initialIndex;
  final List<String?>? heroTags;

  @override
  State<_GalleryViewerScaffold> createState() => _GalleryViewerScaffoldState();
}

class _GalleryViewerScaffoldState extends State<_GalleryViewerScaffold> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;

    return _SwipeDismissGalleryShell(
      onDismiss: () => Navigator.of(context).maybePop(),
      child: Builder(
        builder: (innerContext) {
          final dim = _GalleryBackdropFade.of(innerContext);
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.black.withValues(alpha: dim),
              foregroundColor: AppColors.textInverse,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                '${_index + 1} / $n',
                style: AppTextStyle.base(16, color: AppColors.textInverse, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            body: PageView.builder(
              controller: _pageController,
              itemCount: n,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final item = widget.items[i];
                final heroTag = widget.heroTags != null ? widget.heroTags![i] : null;
                return item.isVideo
                    ? _GalleryVideoPage(url: item.url)
                    : _GalleryImagePage(url: item.url, heroTag: heroTag);
              },
            ),
          );
        },
      ),
    );
  }
}

class _GalleryImagePage extends StatefulWidget {
  const _GalleryImagePage({required this.url, this.heroTag});

  final String url;
  final String? heroTag;

  @override
  State<_GalleryImagePage> createState() => _GalleryImagePageState();
}

class _GalleryImagePageState extends State<_GalleryImagePage> {
  final TransformationController _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransformChanged);
    _transform.dispose();
    super.dispose();
  }

  void _onTransformChanged() => setState(() {});

  /// Без масштаба отключаем pan — вертикальный свайп уходит на закрытие галереи.
  bool get _zoomed {
    final m = _transform.value.storage;
    final sx = math.sqrt(m[0] * m[0] + m[4] * m[4]);
    final sy = math.sqrt(m[1] * m[1] + m[5] * m[5]);
    return math.max(sx, sy) > 1.03;
  }

  static Widget _networkImage({
    required String url,
    required BoxFit fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, Object)? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: Duration.zero,
      placeholder:
          placeholder ??
          (_, __) => const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
            ),
          ),
      errorWidget:
          errorWidget ??
          (_, __, ___) => Center(
            child: Text(
              'Не удалось загрузить',
              style: AppTextStyle.base(14, color: AppColors.textInverse.withValues(alpha: 0.85)),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image = _networkImage(url: widget.url, fit: BoxFit.contain);
    if (widget.heroTag != null) {
      image = Hero(
        tag: widget.heroTag!,
        createRectTween: AppMediaGalleryViewer.heroRectTween,
        flightShuttleBuilder: (flightContext, animation, flightDirection, _, __) {
          final push = flightDirection == HeroFlightDirection.push;
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(animation.value);
              final radius = push
                  ? lerpDouble(kAppMediaGalleryThumbHeroRadius, 0, t)!
                  : lerpDouble(0, kAppMediaGalleryThumbHeroRadius, t)!;
              final scale = push ? lerpDouble(0.96, 1.0, t)! : lerpDouble(1.0, 0.96, t)!;
              return Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Material(
                    color: Colors.black,
                    child: _networkImage(
                      url: widget.url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: Colors.black,
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Material(type: MaterialType.transparency, child: image),
      );
    }
    return InteractiveViewer(
      transformationController: _transform,
      panEnabled: _zoomed,
      minScale: 1,
      maxScale: 4,
      child: Center(child: image),
    );
  }
}

class _GalleryVideoPage extends StatefulWidget {
  const _GalleryVideoPage({required this.url});

  final String url;

  @override
  State<_GalleryVideoPage> createState() => _GalleryVideoPageState();
}

class _GalleryVideoPageState extends State<_GalleryVideoPage> {
  VideoPlayerController? _controller;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _busy = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Видео недоступно',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.textInverse.withValues(alpha: 0.85)),
          ),
        ),
      );
    }
    final c = _controller!;
    return GestureDetector(
      onTap: _togglePlay,
      child: Center(
        child: AspectRatio(
          aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(c),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: c,
                builder: (context, value, _) {
                  if (value.isPlaying) return const SizedBox.shrink();
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 56,
                      color: AppColors.textInverse.withValues(alpha: 0.95),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
