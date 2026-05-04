import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_date_selector.dart';
import 'package:side_project/core/shared/app_duration_selector.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/service/generate_marker_.dart';
import 'package:side_project/feature/marker_create/presentation/cubit/marker_create_cubit.dart';
import 'package:side_project/feature/marker_tag/data/models/marker_models.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

@RoutePage()
class MarkerCreatePage extends StatefulWidget {
  const MarkerCreatePage({super.key});

  @override
  State<MarkerCreatePage> createState() => _MarkerCreatePageState();
}

class _MarkerCreatePageState extends State<MarkerCreatePage> {
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController();
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MarkerCreateCubit>()..start(),
      child: BlocConsumer<MarkerCreateCubit, MarkerCreateState>(
        listenWhen: (p, n) => n.maybeWhen(error: (_) => true, orElse: () => false),
        listener: (context, state) {
          state.whenOrNull(
            error: (m) => AppSnackBar.show(context, message: m, kind: AppSnackBarKind.error),
          );
        },
        builder: (context, state) {
          final stepLabel = state.maybeWhen(
            editing: (step, _, __, ___) => switch (step) {
              MarkerCreateStep.tags => '1/4',
              MarkerCreateStep.emoji => '2/4',
              MarkerCreateStep.location => '3/4',
              MarkerCreateStep.address => '4/4',
              MarkerCreateStep.done => 'Готово',
            },
            orElse: () => '',
          );

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            // Кнопки фиксируем снизу, body сам скроллится — клавиатура не должна "ломать" layout.
            resizeToAvoidBottomInset: false,
            appBar: AppAppBar(
              title: Text(stepLabel.isEmpty ? 'Создать маркер' : 'Создать маркер • $stepLabel'),
            ),
            body: SafeArea(
              child: state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (message) =>
                    _ErrorView(message: message, onRetry: () => context.read<MarkerCreateCubit>().start()),
                editing: (step, tags, draft, isSubmitting) => Column(
                  children: [
                    // // Заголовок шага
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    //   child: _StepHeader(step: step),
                    // ),

                    // Основной контент шага
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: switch (step) {
                            MarkerCreateStep.tags => _TagsStep(
                              key: const ValueKey('tags'),
                              tags: tags,
                              selectedKeys: draft.tagKeys,
                              onToggle: (k) => context.read<MarkerCreateCubit>().toggleTagKey(k),
                            ),
                            MarkerCreateStep.emoji => _EmojiStep(
                              key: const ValueKey('emoji'),
                              selected: draft.emoji,
                              onSelect: (e) => context.read<MarkerCreateCubit>().setEmoji(e),
                            ),
                            MarkerCreateStep.location => _LocationStep(
                              key: const ValueKey('location'),
                              lat: draft.lat,
                              lng: draft.lng,
                              emoji: draft.emoji,
                              onPicked: (lat, lng) =>
                                  context.read<MarkerCreateCubit>().setLocation(lat: lat, lng: lng),
                            ),
                            MarkerCreateStep.address => _AddressStep(
                              key: const ValueKey('address'),
                              controller: _address..text = (draft.address ?? _address.text),
                              onChanged: (t) => context.read<MarkerCreateCubit>().setAddress(t),
                              eventTime: draft.eventTime,
                              durationMinutes: draft.durationMinutes,
                              onEventTimeChanged: (dt) => context.read<MarkerCreateCubit>().setEventTime(dt),
                              onDurationMinutesChanged: (m) =>
                                  context.read<MarkerCreateCubit>().setDurationMinutes(m),
                            ),
                            MarkerCreateStep.done => const _DoneStep(key: ValueKey('done')),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: state.maybeWhen(
              editing: (step, _, __, isSubmitting) {
                return SafeArea(
                  top: false,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.borderSoft)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: step != MarkerCreateStep.done
                          ? Row(
                              children: [
                                Expanded(
                                  child: AppOutlinedButton(
                                    text: 'Назад',
                                    onPressed: () {
                                      final prev = switch (step) {
                                        MarkerCreateStep.tags => null,
                                        MarkerCreateStep.emoji => MarkerCreateStep.tags,
                                        MarkerCreateStep.location => MarkerCreateStep.emoji,
                                        MarkerCreateStep.address => MarkerCreateStep.location,
                                        MarkerCreateStep.done => null,
                                      };
                                      if (prev != null) context.read<MarkerCreateCubit>().setStep(prev);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppButton(
                                    text: step == MarkerCreateStep.address ? 'Создать' : 'Далее',
                                    isLoading: isSubmitting,
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            if (step == MarkerCreateStep.address) {
                                              context.read<MarkerCreateCubit>().submit();
                                              return;
                                            }
                                            final next = switch (step) {
                                              MarkerCreateStep.tags => MarkerCreateStep.emoji,
                                              MarkerCreateStep.emoji => MarkerCreateStep.location,
                                              MarkerCreateStep.location => MarkerCreateStep.address,
                                              MarkerCreateStep.address => MarkerCreateStep.done,
                                              MarkerCreateStep.done => MarkerCreateStep.done,
                                            };
                                            context.read<MarkerCreateCubit>().setStep(next);
                                          },
                                  ),
                                ),
                              ],
                            )
                          : AppButton(text: 'Готово', onPressed: () => context.router.maybePop()),
                    ),
                  ),
                );
              },
              orElse: () => null,
            ),
          );
        },
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});
  final MarkerCreateStep step;

  @override
  Widget build(BuildContext context) {
    String title = switch (step) {
      MarkerCreateStep.tags => '1/4 Теги',
      MarkerCreateStep.emoji => '2/4 Смайлик',
      MarkerCreateStep.location => '3/4 Место на карте',
      MarkerCreateStep.address => '4/4 Адрес',
      MarkerCreateStep.done => 'Готово',
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyle.base(16, fontWeight: FontWeight.w800, color: AppColors.textColor),
      ),
    );
  }
}

class _TagsStep extends StatelessWidget {
  const _TagsStep({super.key, required this.tags, required this.selectedKeys, required this.onToggle});
  final List<MarkerTagModel> tags;
  final Set<String> selectedKeys;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<MarkerTagModel>>{};
    for (final t in tags) {
      final group = t.groupTitleRu;
      (groups[group] ??= []).add(t);
    }

    return ListView(
      key: const PageStorageKey('tags_step'),
      children: [
        const SizedBox(height: 14),
        Text(
          'Выбери несколько тегов — так пользователям будет проще найти событие.',
          style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
        ),
        const SizedBox(height: 12),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Text(
              entry.key,
              style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in entry.value)
                _TagCard(
                  title: t.titleRu,
                  selected: selectedKeys.contains(t.key),
                  onTap: () => onToggle(t.key),
                ),
            ],
          ),
        ],
        const SizedBox(height: 18),
      ],
    );
  }
}

class _TagCard extends StatelessWidget {
  const _TagCard({required this.title, required this.selected, required this.onTap});
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary.withValues(alpha: 0.10) : AppColors.surface;
    final border = selected ? AppColors.primary.withValues(alpha: 0.45) : AppColors.hintCardBorder;
    final text = selected ? AppColors.primary : AppColors.textColor;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            title,
            style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: text),
          ),
        ),
      ),
    );
  }
}

class _EmojiStep extends StatelessWidget {
  const _EmojiStep({super.key, required this.selected, required this.onSelect});
  final String? selected;
  final ValueChanged<String> onSelect;

  static const _emojis = ['🎉', '☕️', '🎬', '🏋️', '🎵', '🧠', '⚽️', '🍔', '💅', '🌿', '🐶', '🕺'];

  @override
  Widget build(BuildContext context) {
    return _EmojiStepBody(selected: selected, onSelect: onSelect);
  }
}

class _EmojiStepBody extends StatefulWidget {
  const _EmojiStepBody({required this.selected, required this.onSelect});
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  State<_EmojiStepBody> createState() => _EmojiStepBodyState();
}

class _EmojiStepBodyState extends State<_EmojiStepBody> {
  late final TextEditingController _c;

  static final _emojiRuneRe = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);

  static bool _looksLikeEmoji(String grapheme) {
    if (grapheme.trim().isEmpty) return false;
    // Heuristic: most emojis live in these Unicode blocks; good enough for blocking letters/digits.
    return _emojiRuneRe.hasMatch(grapheme);
  }

  static String? _lastEmojiGrapheme(String raw) {
    String? last;
    for (final g in raw.characters) {
      if (_looksLikeEmoji(g)) last = g;
    }
    return last;
  }

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.selected ?? '');
  }

  @override
  void didUpdateWidget(covariant _EmojiStepBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.selected ?? '';
    if (_c.text != next) {
      _c.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _applySingleEmoji(String raw) {
    final lastEmoji = _lastEmojiGrapheme(raw);

    // No emoji typed: block letters/digits; keep previous selection (or clear if none).
    if (lastEmoji == null) {
      final keep = widget.selected ?? '';
      if (_c.text != keep) {
        _c.value = TextEditingValue(
          text: keep,
          selection: TextSelection.collapsed(offset: keep.length),
          composing: TextRange.empty,
        );
      }
      return;
    }

    // Enforce exactly one emoji: show the last emoji typed/pasted.
    if (_c.text != lastEmoji) {
      _c.value = TextEditingValue(
        text: lastEmoji,
        selection: TextSelection.collapsed(offset: lastEmoji.length),
        composing: TextRange.empty,
      );
    }

    if (lastEmoji != (widget.selected ?? '')) {
      widget.onSelect(lastEmoji);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),

        Text(
          'Выбери один смайлик — он будет “лицом” маркера на карте.\nМожно выбрать из списка или вставить свой с клавиатуры.',
          style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _c,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
          // Soft cap so pasted long text doesn't blow up the field;
          // we also enforce 1 grapheme in [_applySingleEmoji].
          inputFormatters: [LengthLimitingTextInputFormatter(12)],
          onChanged: _applySingleEmoji,
          decoration: InputDecoration(
            hintText: 'Вставь смайлик сюда',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.hintCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.7), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in _EmojiStep._emojis)
              _EmojiChip(emoji: e, selected: widget.selected == e, onTap: () => widget.onSelect(e)),
          ],
        ),
      ],
    );
  }
}

class _EmojiChip extends StatelessWidget {
  const _EmojiChip({required this.emoji, required this.selected, required this.onTap});
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.10) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.55) : AppColors.hintCardBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

class _LocationStep extends StatefulWidget {
  const _LocationStep({
    super.key,
    required this.lat,
    required this.lng,
    required this.emoji,
    required this.onPicked,
  });
  final double? lat;
  final double? lng;
  final String? emoji;
  final void Function(double lat, double lng) onPicked;

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  Point? _picked;
  YandexMapController? _controller;
  bool _locating = false;
  BitmapDescriptor? _pickedIcon;

  Future<void> _ensurePickedIcon() async {
    final e = widget.emoji?.trim();
    final emoji = (e != null && e.isNotEmpty) ? e : '📍';
    final bytes = await MarkerGeneratorService.createEmojiMarker(emoji);
    if (!mounted || bytes == null) return;
    setState(() => _pickedIcon = BitmapDescriptor.fromBytes(bytes));
  }

  @override
  void initState() {
    super.initState();
    final lat = widget.lat;
    final lng = widget.lng;
    if (lat != null && lng != null) {
      _picked = Point(latitude: lat, longitude: lng);
    }
    unawaited(_ensurePickedIcon());
  }

  @override
  void didUpdateWidget(covariant _LocationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.emoji ?? '').trim() != (widget.emoji ?? '').trim()) {
      unawaited(_ensurePickedIcon());
    }
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),

        Text(
          'Тапни по карте, чтобы выбрать точку. Можно приблизить место.',
          style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: AppOutlinedButton(
            text: _locating ? 'Определяем…' : 'Моё место',
            isExpanded: false,
            onPressed: _locating
                ? null
                : () async {
                    setState(() => _locating = true);
                    try {
                      if (!await Geolocator.isLocationServiceEnabled()) {
                        throw Exception('Включи геолокацию на устройстве');
                      }
                      var perm = await Geolocator.checkPermission();
                      if (perm == LocationPermission.denied) {
                        perm = await Geolocator.requestPermission();
                      }
                      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
                        throw Exception('Разреши доступ к геолокации');
                      }
                      final pos = await Geolocator.getCurrentPosition(
                        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
                      );
                      final p = Point(latitude: pos.latitude, longitude: pos.longitude);
                      setState(() => _picked = p);
                      widget.onPicked(p.latitude, p.longitude);
                      final c = _controller;
                      if (c != null) {
                        await c.moveCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(target: p, zoom: 16)),
                          animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.35),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      AppSnackBar.show(this.context, message: '$e', kind: AppSnackBarKind.error);
                    } finally {
                      if (mounted) setState(() => _locating = false);
                    }
                  },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: YandexMap(
              onMapCreated: (c) => _controller = c,
              // По условиям использования логотип должен оставаться; переносим в угол, чтобы меньше мешал.
              logoAlignment: const MapAlignment(
                horizontal: HorizontalAlignment.left,
                vertical: VerticalAlignment.top,
              ),
              onMapTap: (point) {
                setState(() => _picked = point);
                widget.onPicked(point.latitude, point.longitude);
              },
              mapObjects: [
                if (picked != null)
                  if (_pickedIcon != null)
                    PlacemarkMapObject(
                      mapId: const MapObjectId('picked_pin'),
                      point: picked,
                      opacity: 1,
                      icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                          image: _pickedIcon!,
                          // Placemark is screen-space, so it stays visible on zoom.
                          scale: 0.65,
                          anchor: const Offset(0.5, 0.5),
                        ),
                      ),
                    )
                  else ...[
                    // Fallback while bytes are loading: circles (meters-based, may scale with zoom).
                    CircleMapObject(
                      mapId: const MapObjectId('picked_outer'),
                      circle: Circle(center: picked, radius: 30),
                      fillColor: Colors.white.withValues(alpha: 0.92),
                      strokeColor: AppColors.primary,
                      strokeWidth: 5,
                    ),
                    CircleMapObject(
                      mapId: const MapObjectId('picked_inner'),
                      circle: Circle(center: picked, radius: 10),
                      fillColor: AppColors.primary,
                      strokeColor: Colors.white.withValues(alpha: 0.95),
                      strokeWidth: 3,
                    ),
                  ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (picked != null)
          Text(
            'Выбрано: ${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}',
            style: AppTextStyle.base(12, color: AppColors.subTextColor),
          ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.eventTime,
    required this.durationMinutes,
    required this.onEventTimeChanged,
    required this.onDurationMinutesChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final DateTime? eventTime;
  final int durationMinutes;
  final ValueChanged<DateTime> onEventTimeChanged;
  final ValueChanged<int> onDurationMinutesChanged;

  @override
  Widget build(BuildContext context) {
    final curEventTime = eventTime ?? DateTime.now().add(const Duration(minutes: 5));
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    const bottomBarPad = 120.0; // reserve space for fixed bottom buttons
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: bottomBarPad + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),

          Text(
            'Когда начнётся событие и сколько будет длиться (до 24 часов).',
            style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
          ),
          const SizedBox(height: 10),
          AppDateTimeSelector(
            value: curEventTime,
            min: DateTime.now().subtract(const Duration(days: 1)),
            max: DateTime.now().add(const Duration(days: 365)),
            minuteStep: 5,
            hint: 'Выбрать дату и время',
            onChanged: onEventTimeChanged,
          ),
          const SizedBox(height: 10),
          AppDurationSelector(
            minutes: durationMinutes,
            minMinutes: 15,
            maxMinutes: 24 * 60,
            stepMinutes: 15,
            onChanged: onDurationMinutesChanged,
          ),
          const SizedBox(height: 14),
          Text(
            'Адрес лучше писать коротко и читабельно.\nНапример: «Абай 10, вход со двора» или «Mega Park, 2 этаж».',
            style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Адрес...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.hintCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.7), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hintCardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Совет: добавь ориентир — «возле метро», «вход справа», «рядом с фонтаном».\n'
                'Так адрес выглядит “живым” и понятным.',
                style: AppTextStyle.base(12, color: AppColors.subTextColor, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Готово', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Маркер создан. Он появится на карте, когда будет привязан пост.',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ошибка',
              style: AppTextStyle.base(16, fontWeight: FontWeight.w800, color: AppColors.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.base(13, color: AppColors.subTextColor),
            ),
            const SizedBox(height: 12),
            AppButton(text: 'Повторить', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
