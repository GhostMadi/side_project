import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';
import 'package:side_project/feature/post_create_page/presentation/widget/post_reorder_bottom_sheet.dart';
import 'package:side_project/feature/post_create_page/presentation/widget/post_reorder_card.dart';

/// Фильтр источника на шаге галереи: всё / только фото / только видео / избранное.
enum _GalleryMediaFilter {
  all,
  photos,
  videos,
  favorites;

  String get label => switch (this) {
    _GalleryMediaFilter.all => 'Всё',
    _GalleryMediaFilter.photos => 'Фото',
    _GalleryMediaFilter.videos => 'Видео',
    _GalleryMediaFilter.favorites => 'Избранное',
  };
}

/// Верх — превью выбранного, низ — сетка галереи (фото и видео), мультивыбор.
class PostCreateGalleryStep extends StatefulWidget {
  const PostCreateGalleryStep({
    super.key,
    this.maxSelection = 10,
    this.allowVideo = true,
    required this.onContinue,
    this.onSelectionCountChanged,
  });

  final int maxSelection;
  /// Если `false`, в сетке и выборе участвуют только фото.
  final bool allowVideo;
  final void Function(List<PostCreateSlot> slots) onContinue;
  final ValueChanged<int>? onSelectionCountChanged;

  @override
  State<PostCreateGalleryStep> createState() => PostCreateGalleryStepState();
}

class PostCreateGalleryStepState extends State<PostCreateGalleryStep> {
  final PageController _previewPageCtrl = PageController();

  /// Текущая страница превью (для точек и после переупорядочивания).
  int _previewPageIndex = 0;

  PermissionState? _permission;
  bool _loadingPaths = true;
  bool _filterReloading = false;
  String? _loadError;

  _GalleryMediaFilter _mediaFilter = _GalleryMediaFilter.all;

  AssetPathEntity? _album;
  final List<AssetEntity> _gridAssets = [];
  int _page = 0;
  static const int _pageSize = 60;
  bool _loadingMore = false;
  bool _hasMore = true;

  /// Порядок выбора как в Instagram.
  final List<AssetEntity> _selected = [];

  /// Есть ли выбранные материалы (для кнопки «Далее» в AppBar).
  bool get hasSelection => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (!widget.allowVideo) {
      _mediaFilter = _GalleryMediaFilter.photos;
    }
    _bootstrap();
  }

  List<_GalleryMediaFilter> get _visibleMediaFilters {
    if (widget.allowVideo) {
      return _GalleryMediaFilter.values.toList(growable: false);
    }
    return [
      _GalleryMediaFilter.all,
      _GalleryMediaFilter.photos,
      _GalleryMediaFilter.favorites,
    ];
  }

  @override
  void dispose() {
    _previewPageCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    setState(() => _permission = ps);
    if (!ps.isAuth) {
      setState(() => _loadingPaths = false);
      return;
    }
    await _loadAlbumAndFirstPage(fromFilterChip: false);
  }

  Future<AssetPathEntity?> _pickFavoritesAlbum() async {
    final favFilter = AdvancedCustomFilter()
        .addWhereCondition(
          ColumnWhereCondition(
            column: CustomColumns.base.isFavorite,
            operator: '==',
            value: '1',
          ),
        )
        .addOrderBy(column: CustomColumns.base.createDate, isAsc: false);

    var paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.common,
      filterOption: favFilter,
    );
    if (paths.isNotEmpty) {
      return paths.first;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      paths = await PhotoManager.getAssetPathList(
        onlyAll: false,
        type: RequestType.common,
        filterOption: FilterOptionGroup(),
      );
      for (final p in paths) {
        if (p.albumTypeEx?.darwin?.subtype ==
            PMDarwinAssetCollectionSubtype.smartAlbumFavorites) {
          return p;
        }
      }
    }

    paths = await PhotoManager.getAssetPathList(
      onlyAll: false,
      type: RequestType.common,
      filterOption: FilterOptionGroup(),
    );
    for (final p in paths) {
      final n = p.name.toLowerCase();
      if (n.contains('favorite') ||
          n.contains('favourite') ||
          n.contains('избранн')) {
        return p;
      }
    }
    return null;
  }

  Future<AssetPathEntity?> _pickAlbumForFilter(_GalleryMediaFilter f) async {
    switch (f) {
      case _GalleryMediaFilter.all:
        final paths = await PhotoManager.getAssetPathList(
          onlyAll: true,
          type: widget.allowVideo ? RequestType.common : RequestType.image,
        );
        return paths.isEmpty ? null : paths.first;
      case _GalleryMediaFilter.photos:
        final paths = await PhotoManager.getAssetPathList(
          onlyAll: true,
          type: RequestType.image,
        );
        return paths.isEmpty ? null : paths.first;
      case _GalleryMediaFilter.videos:
        final paths = await PhotoManager.getAssetPathList(
          onlyAll: true,
          type: RequestType.video,
        );
        return paths.isEmpty ? null : paths.first;
      case _GalleryMediaFilter.favorites:
        return _pickFavoritesAlbum();
    }
  }

  Future<void> _loadAlbumAndFirstPage({required bool fromFilterChip}) async {
    if (!fromFilterChip) {
      setState(() {
        _loadingPaths = true;
        _loadError = null;
      });
    } else {
      setState(() {
        _filterReloading = true;
        _loadError = null;
      });
    }
    try {
      final album = await _pickAlbumForFilter(_mediaFilter);
      if (!mounted) {
        return;
      }
      if (album == null) {
        setState(() {
          _album = null;
          _page = 0;
          _gridAssets.clear();
          _hasMore = false;
          _loadingPaths = false;
          _filterReloading = false;
          if (_mediaFilter != _GalleryMediaFilter.favorites) {
            _loadError = 'Альбомы не найдены';
          } else {
            _loadError = null;
          }
        });
        return;
      }
      setState(() {
        _album = album;
        _page = 0;
        _gridAssets.clear();
        _hasMore = true;
        _loadError = null;
      });
      await _fetchPage(reset: true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = '$e';
          _loadingPaths = false;
          _filterReloading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingPaths = false;
          _filterReloading = false;
        });
      }
    }
  }

  void _onMediaFilterSelected(_GalleryMediaFilter f) {
    if (f == _mediaFilter) {
      return;
    }
    setState(() {
      _mediaFilter = f;
      _selected.clear();
      _previewPageIndex = 0;
    });
    widget.onSelectionCountChanged?.call(0);
    _loadAlbumAndFirstPage(fromFilterChip: true);
  }

  Future<void> _fetchPage({required bool reset}) async {
    final album = _album;
    if (album == null) {
      return;
    }
    if (_loadingMore) {
      return;
    }
    _loadingMore = true;
    try {
      final list = await album.getAssetListPaged(page: _page, size: _pageSize);
      if (!mounted) {
        return;
      }
      setState(() {
        if (reset) {
          _gridAssets.clear();
        }
        _gridAssets.addAll(list);
        _hasMore = list.length >= _pageSize;
        _page++;
        _loadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = '$e';
          _loadingMore = false;
        });
      }
    }
  }

  void _toggle(AssetEntity e) {
    if (!widget.allowVideo && e.type == AssetType.video) {
      return;
    }
    final i = _selected.indexWhere((x) => x.id == e.id);
    setState(() {
      if (i >= 0) {
        _selected.removeAt(i);
        if (_selected.isEmpty) {
          _previewPageIndex = 0;
        } else if (_previewPageIndex >= _selected.length) {
          _previewPageIndex = _selected.length - 1;
        }
      } else if (_selected.length < widget.maxSelection) {
        _selected.add(e);
        _previewPageIndex = _selected.length - 1;
      } else {
        // Лимит уже набран: новый тап заменяет самый ранний выбор (для max=1 — просто смена фото).
        _selected.removeAt(0);
        _selected.add(e);
        _previewPageIndex = _selected.length - 1;
      }
    });
    widget.onSelectionCountChanged?.call(_selected.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selected.isEmpty) {
        return;
      }
      if (!_previewPageCtrl.hasClients) {
        return;
      }
      _previewPageCtrl.jumpToPage(_previewPageIndex);
    });
  }

  void _onReorderSelected(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final anchorId = _selected[_previewPageIndex].id;
    setState(() {
      final item = _selected.removeAt(oldIndex);
      _selected.insert(newIndex, item);
      final ni = _selected.indexWhere((x) => x.id == anchorId);
      _previewPageIndex = ni < 0 ? 0 : ni;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _previewPageCtrl.hasClients) {
        _previewPageCtrl.jumpToPage(_previewPageIndex);
      }
    });
  }

  Future<void> _openReorderSelectedSheet() async {
    await showPostReorderBottomSheet(
      context: context,
      variant: PostReorderSheetVariant.gallery,
      itemCount: _selected.length,
      onReorder: _onReorderSelected,
      itemBuilder: (context, index) {
        final asset = _selected[index];
        return postReorderListRow(
          key: ValueKey(asset.id),
          variant: PostReorderSheetVariant.gallery,
          index: index,
          itemCount: _selected.length,
          card: PostReorderCard.gallery(
            index: index,
            mediaLabel: asset.type == AssetType.video ? 'Видео' : 'Фото',
            thumbnail: FutureBuilder<Uint8List?>(
              future: asset.thumbnailDataWithSize(
                const ThumbnailSize(128, 128),
                quality: 72,
              ),
              builder: (context, snap) {
                if (snap.data == null) {
                  return ColoredBox(
                    color: AppColors.inputBackground,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  );
                }
                return Image.memory(
                  snap.data!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.low,
                );
              },
            ),
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.drag_handle_rounded),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSelected(AssetEntity e) => _selected.any((x) => x.id == e.id);

  int _selectedOrder(AssetEntity e) {
    final i = _selected.indexWhere((x) => x.id == e.id);
    return i < 0 ? 0 : i + 1;
  }

  Future<void> _onContinue() async {
    if (_selected.isEmpty) {
      if (mounted) {
        widget.onContinue([]);
      }
      return;
    }
    final slots = <PostCreateSlot>[];
    for (final e in _selected) {
      final f = await e.originFile;
      if (f == null) {
        continue;
      }
      slots.add(
        PostCreateSlot(originalFile: f, isVideo: e.type == AssetType.video),
      );
    }
    if (slots.isEmpty || !mounted) {
      return;
    }
    widget.onContinue(slots);
  }

  /// Вызывается из AppBar родителя (кнопка «Далее»).
  Future<void> continueWithSelection() => _onContinue();

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (_permission != null && !_permission!.isAuth) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Нужен доступ к фото и видео, чтобы выбрать материалы для поста.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.base(
                      15,
                      color: AppColors.subTextColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    text: 'Разрешить в настройках',
                    onPressed: () => PhotoManager.openSetting(),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Запросить снова',
                    onPressed: () async {
                      await _bootstrap();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_loadingPaths && _gridAssets.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.subTextColor),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildTopPreview(),
              ),
            ),
          ),
        ),
        _buildMediaFilterBar(),
        Expanded(flex: 13, child: _buildGrid()),
        if (_selected.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 10 + bottomInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowDark.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      '${_selected.length} из ${widget.maxSelection}',
                      style: AppTextStyle.base(
                        13,
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                if (_selected.length > 1) ...[
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _openReorderSelectedSheet,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      'Порядок',
                      style: AppTextStyle.base(13, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          SizedBox(height: 10 + bottomInset),
      ],
    );
  }

  Widget _buildTopPreview() {
    if (_selected.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Выберите фото или видео в сетке ниже',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(
              15,
              color: AppColors.subTextColor,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _previewPageCtrl,
          itemCount: _selected.length,
          onPageChanged: (i) {
            setState(() {
              _previewPageIndex = i;
            });
          },
          itemBuilder: (context, index) {
        final e = _selected[index];
        return FutureBuilder<Uint8List?>(
          future: e.thumbnailDataWithSize(
            const ThumbnailSize(1200, 1200),
            quality: 90,
          ),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              );
            }
            final data = snap.data;
            if (data == null) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.iconMuted,
                  size: 48,
                ),
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(data, fit: BoxFit.contain, gaplessPlayback: true),
                if (e.type == AssetType.video)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(e.videoDuration),
                            style: AppTextStyle.base(
                              13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
        ),
        if (_selected.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_selected.length, (j) {
                final active = j == _previewPageIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaFilterBar() {
    return SizedBox(
      height: 44,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          itemCount: _visibleMediaFilters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final f = _visibleMediaFilters[i];
            final sel = f == _mediaFilter;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onMediaFilterSelected(f),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.16)
                        : AppColors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border.withValues(alpha: 0.55),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    f.label,
                    style: AppTextStyle.base(
                      13,
                      color: sel
                          ? AppColors.primary
                          : AppColors.postEditorOnSurfaceMuted,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_album == null) {
      if (_mediaFilter == _GalleryMediaFilter.favorites) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Нет избранных фото и видео. Отметьте материалы как избранные в приложении «Фото».',
              textAlign: TextAlign.center,
              style: AppTextStyle.base(
                14,
                color: AppColors.subTextColor,
                height: 1.35,
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels > n.metrics.maxScrollExtent - 480 &&
                _hasMore &&
                !_loadingMore) {
              _fetchPage(reset: false);
            }
            return false;
          },
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1,
            ),
            itemCount: _gridAssets.length + (_loadingMore && _hasMore ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= _gridAssets.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final e = _gridAssets[i];
              final sel = _isSelected(e);
              return GestureDetector(
                onTap: () => _toggle(e),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FutureBuilder<Uint8List?>(
                        future: e.thumbnailDataWithSize(
                          const ThumbnailSize(200, 200),
                          quality: 80,
                        ),
                        builder: (context, snap) {
                          if (snap.data == null) {
                            return ColoredBox(color: AppColors.inputBackground);
                          }
                          return Image.memory(
                            snap.data!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          );
                        },
                      ),
                      if (e.type == AssetType.video)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatDuration(e.videoDuration),
                              style: AppTextStyle.base(
                                10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (sel)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.5,
                            ),
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowDark.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${_selectedOrder(e)}',
                                  style: AppTextStyle.base(
                                    11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
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
          ),
        ),
        if (_filterReloading)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.surfaceSoft.withValues(alpha: 0.88),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
