import 'dart:async';
import 'dart:io';
import 'dart:ui' show lerpDouble;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_text_field.dart';
import 'package:side_project/feature/chat/domain/chat_attachment_rules.dart';
import 'package:side_project/feature/chat/domain/chat_outgoing_attachment.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_thread_cubit.dart';

const double _kComposerActionSize = 52;

/// Пиковый scale кнопки микрофона в режиме записи — слот должен быть не меньше `size * scale` + запас под тень.
const double _kRecordingMicButtonMaxScale = 1.15;

/// Единая длительность переходов панели.
const Duration _kUiAnim = Duration(milliseconds: 180);

/// Мгновенная отдача при касании микрофона (короткая и заметная).
const Duration _kMicPressAnim = Duration(milliseconds: 38);

/// Короткая отдача у кнопок «+» / отправить.
const Duration _kPressAnim = Duration(milliseconds: 90);

/// Пульсация точки записи.
const Duration _kPulseDotDuration = Duration(milliseconds: 780);

/// Свайп влево накопленный dx ниже порога — при отпускании отмена вместо отправки.
const double _kSwipeCancelThreshold = -72;

/// Ширина «зоны отмены» по dx (положительное число): от 0 до этого смещения растёт индикатор и краснеет обводка.
double get _kSwipeCancelZoneAbs => (_kSwipeCancelThreshold * 0.55).abs();

/// Плавная смена подсказки при пересечении режима отмены.
const Duration _kRecordingHintCrossFade = Duration(milliseconds: 165);

/// Радиус поля ввода в композере (= AppTextField radius).
const double _kComposerFieldRadius = 30;

/// Свайп: сырой dx копится без жёсткого потолка; визуальный сдвиг усиливается в коде.
const double _kSwipeVisualClamp = -150;

/// Анимация «уезжает при отмене» (закрытие голосовой полосы).
const Duration _kRecordingDismissAnim = Duration(milliseconds: 240);

/// Три зоны: [ файлы ] [ текст | запись ] [ действие ].
/// Микрофон: касание → запись; отпускание → отправка аудио.
class ChatThreadComposerBar extends StatefulWidget {
  const ChatThreadComposerBar({
    super.key,
    required this.controller,
    required this.conversationId,
    required this.showAttachmentChooser,
  });

  final TextEditingController controller;
  final String conversationId;

  final Future<void> Function() showAttachmentChooser;

  @override
  State<ChatThreadComposerBar> createState() => ChatThreadComposerBarState();
}

class _Draft {
  _Draft({required this.bytes, required this.filename, required this.mime});

  final Uint8List bytes;
  final String filename;
  final String mime;
}

class ChatThreadComposerBarState extends State<ChatThreadComposerBar> with TickerProviderStateMixin {
  final List<_Draft> _drafts = [];

  final FocusNode _focus = FocusNode();
  final AudioRecorder _recorder = AudioRecorder();

  bool _recording = false;
  bool _recordStarting = false;
  bool _recordClosing = false;
  String? _recordPath;
  int _recordElapsedSec = 0;
  Timer? _recordTick;

  late AnimationController _micSendCtrl;
  late AnimationController _recordingVisualCtrl;
  late AnimationController _recordDismissCtrl;
  AnimationController? _pulseDotCtrl;

  /// Палец на зоне микрофона (до отпускания).
  bool _micFingerDown = false;

  /// Горизонтальный свайп во время записи (влево < 0). Listenable — надёжная перерисовка при движении пальца.
  final ValueNotifier<double> _slideCancel = ValueNotifier<double>(0);

  /// Чтобы хаптик при входе в зону отмены сработал один раз, пока палец не вернётся из зоны.
  bool _cancelZoneHapticLatched = false;

  /// Сразу при касании микрофона — «вдавливание» (короткая анимация).
  late AnimationController _micSquashCtrl;

  bool get _wantSend => widget.controller.text.trim().isNotEmpty || _drafts.isNotEmpty;

  Future<void> _toast(String msg) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> pickGalleryAfterSheet() => _pickGallery();

  Future<void> pickDocumentsAfterSheet() => _pickDocuments();

  Future<void> pickCameraAfterSheet() async {
    final remaining = ChatAttachmentRules.maxCount - _drafts.length;
    if (remaining <= 0) {
      await _toast('Не больше ${ChatAttachmentRules.maxCount} файлов');
      return;
    }
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final mime = ChatAttachmentRules.inferMime(x.name, x.mimeType);
    final err = ChatAttachmentRules.validateByteSize(bytes.length);
    if (err != null) {
      await _toast('$err (${x.name})');
      return;
    }
    if (!ChatAttachmentRules.isAllowedMime(mime)) {
      await _toast('Неподдерживаемый тип: ${x.name}');
      return;
    }
    setState(() {
      _drafts.add(_Draft(bytes: bytes, filename: x.name, mime: mime));
    });
    _syncMicSend();
  }

  Future<void> _pickGallery() async {
    final remaining = ChatAttachmentRules.maxCount - _drafts.length;
    if (remaining <= 0) {
      await _toast('Не больше ${ChatAttachmentRules.maxCount} файлов');
      return;
    }
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(limit: remaining);
    if (files.isEmpty) return;

    for (final x in files) {
      final bytes = await x.readAsBytes();
      final mime = ChatAttachmentRules.inferMime(x.name, x.mimeType);
      final err = ChatAttachmentRules.validateByteSize(bytes.length);
      if (err != null) {
        await _toast('$err (${x.name})');
        continue;
      }
      if (!ChatAttachmentRules.isAllowedMime(mime)) {
        await _toast('Неподдерживаемый тип: ${x.name}');
        continue;
      }
      setState(() {
        _drafts.add(_Draft(bytes: bytes, filename: x.name, mime: mime));
      });
      _syncMicSend();
    }
  }

  Future<void> _pickDocuments() async {
    final remaining = ChatAttachmentRules.maxCount - _drafts.length;
    if (remaining <= 0) {
      await _toast('Не больше ${ChatAttachmentRules.maxCount} файлов');
      return;
    }
    final res = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any, withData: true);
    if (res == null || res.files.isEmpty) return;

    var added = 0;
    for (final f in res.files) {
      if (added >= remaining) break;
      Uint8List? bytes = f.bytes;
      final path = f.path;
      bytes ??= (path != null && path.isNotEmpty) ? await XFile(path).readAsBytes() : null;
      if (bytes == null) {
        await _toast('Не удалось прочитать файл');
        continue;
      }
      final name = (f.name.isNotEmpty) ? f.name : 'file';
      final mime = ChatAttachmentRules.inferMime(name, null);
      final err = ChatAttachmentRules.validateByteSize(bytes.length);
      if (err != null) {
        await _toast('$err ($name)');
        continue;
      }
      if (!ChatAttachmentRules.isAllowedMime(mime)) {
        await _toast('Неподдерживаемый тип: $name');
        continue;
      }
      final safeBytes = bytes;
      setState(() {
        _drafts.add(_Draft(bytes: safeBytes, filename: name, mime: mime));
      });
      _syncMicSend();
      added++;
    }
  }

  Future<void> _openAttachmentsPanel() async {
    if (_recording) return;
    await widget.showAttachmentChooser();
  }

  Future<void> _send() async {
    final text = widget.controller.text.trim();
    final hasMedia = _drafts.isNotEmpty;

    try {
      final thread = context.read<ChatThreadCubit>();

      if (hasMedia) {
        final parts = _drafts
            .map((d) => ChatOutgoingAttachment(bytes: d.bytes, filename: d.filename, mimeType: d.mime))
            .toList(growable: false);
        final caption = text.isNotEmpty ? text : null;
        widget.controller.clear();
        setState(() => _drafts.clear());
        await thread.optimisticSendAttachments(outgoing: parts, caption: caption);
        return;
      }
      if (text.isEmpty) return;
      await thread.optimisticSendText(text);
      widget.controller.clear();
    } catch (e) {
      await _toast('$e');
    }
  }

  Future<void> _onSendTapped() async {
    if (!_wantSend || _recording) return;
    await _send();
  }

  void _onMicPointerDown() {
    if (_wantSend || _recording || _recordStarting || _recordClosing) return;
    _micFingerDown = true;
    _micSquashCtrl.value = 1.0;
    unawaited(_beginRecording());
  }

  /// Один Listener на правый слот (микрофон → запись), чтобы при rebuild не терялся палец.
  void _onRightSlotPointerDown() {
    if (_recording) {
      _micSquashCtrl.value = 1.0;
      return;
    }
    _onMicPointerDown();
  }

  void _onRightSlotPointerUp() {
    if (_recording) {
      _micSquashCtrl.reverse();
      _micFingerDown = false;
      final cancelSwipe = _slideCancel.value <= _kSwipeCancelThreshold;
      if (cancelSwipe) {
        unawaited(_cancelRecording());
      } else {
        unawaited(_stopRecordingAndSend());
      }
      return;
    }

    _micFingerDown = false;
    _micSquashCtrl.reverse();
  }

  void _onRecordingSlideMove(PointerMoveEvent e) {
    if (!_recording || _recordClosing) return;
    _slideCancel.value += e.delta.dx;
    final v = _slideCancel.value;
    final inCancelZone = v <= _kSwipeCancelThreshold * 0.55;
    if (inCancelZone && !_cancelZoneHapticLatched) {
      _cancelZoneHapticLatched = true;
      HapticFeedback.selectionClick();
    } else if (!inCancelZone && _cancelZoneHapticLatched) {
      _cancelZoneHapticLatched = false;
    }
  }

  void _onRightSlotPointerMove(PointerMoveEvent e) {
    if (_recording) _onRecordingSlideMove(e);
  }

  void _onRightSlotPointerCancel() {
    if (_recording) {
      _micSquashCtrl.reverse();
      unawaited(_cancelRecording());
      return;
    }
    _micFingerDown = false;
    _micSquashCtrl.reverse();
  }

  Future<void> _beginRecording() async {
    if (_recordStarting || _wantSend || _recording || _recordClosing) return;
    _recordStarting = true;
    try {
      final ok = await _recorder.hasPermission();
      if (!ok) {
        await _toast('Нет доступа к микрофону');
        _micSquashCtrl.reverse();
        return;
      }
      if (!mounted || !_micFingerDown) {
        _micSquashCtrl.reverse();
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      try {
        await _recorder.start(RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      } catch (_) {
        try {
          await _recorder.start(const RecordConfig(), path: path);
        } catch (e) {
          await _toast('Не удалось начать запись: $e');
          _micSquashCtrl.reverse();
          return;
        }
      }

      if (!mounted || !_micFingerDown) {
        try {
          await _recorder.cancel();
        } catch (_) {}
        try {
          final drop = File(path);
          if (await drop.exists()) await drop.delete();
        } catch (_) {}
        _micSquashCtrl.reverse();
        return;
      }

      final pulse = AnimationController(vsync: this, duration: _kPulseDotDuration)..repeat(reverse: true);
      _pulseDotCtrl?.dispose();
      _pulseDotCtrl = pulse;

      _recordTick?.cancel();
      _recordElapsedSec = 0;
      _recordTick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordElapsedSec++);
      });

      setState(() {
        _recording = true;
        _recordPath = path;
      });
      _slideCancel.value = 0;
      _cancelZoneHapticLatched = false;
      _micSquashCtrl.value = 0;
      await _recordingVisualCtrl.forward(from: 0);
      if (mounted) HapticFeedback.lightImpact();
    } finally {
      _recordStarting = false;
    }
  }

  Future<void> _finishRecording({required bool cancel}) async {
    if (!_recording || _recordClosing) return;
    _recordClosing = true;
    _recordTick?.cancel();
    final pulse = _pulseDotCtrl;
    pulse?.dispose();
    _pulseDotCtrl = null;

    final path = _recordPath;

    setState(() {
      _recording = false;
      _recordPath = null;
      _recordElapsedSec = 0;
    });
    _slideCancel.value = 0;
    _cancelZoneHapticLatched = false;
    _recordingVisualCtrl.value = 0;
    _micSquashCtrl.reset();
    _syncMicSend();

    try {
      if (cancel) {
        try {
          await _recorder.cancel();
        } catch (_) {
          // Плагин может кинуть, если файл уже удалён или запись не стартовала — для отмены не показываем ошибку.
        }
        if (path != null) {
          try {
            final f = File(path);
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }
        return;
      }
      final out = await _recorder.stop();
      final usePath = out ?? path;
      if (usePath == null) return;
      final file = File(usePath);
      if (!await file.exists()) return;
      final bytes = await file.readAsBytes();
      final err = ChatAttachmentRules.validateByteSize(bytes.length);
      if (err != null) {
        await _toast(err);
        await file.delete();
        return;
      }
      final mime = ChatAttachmentRules.inferMime('voice.m4a', 'audio/mp4');
      _recordClosing = false;
      _micFingerDown = false;

      if (!mounted) return;
      final thread = context.read<ChatThreadCubit>();
      await thread.optimisticSendAttachments(
        outgoing: [ChatOutgoingAttachment(bytes: bytes, filename: 'voice.m4a', mimeType: mime)],
        caption: null,
      );
      try {
        await file.delete();
      } catch (_) {}
    } catch (e) {
      await _toast('$e');
    } finally {
      _recordClosing = false;
      _micFingerDown = false;
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_recording) return;
    await _recordingVisualCtrl.reverse();
    await _finishRecording(cancel: false);
  }

  Future<void> _cancelRecording() async {
    if (!_recording || _recordClosing) return;
    _micFingerDown = false;
    try {
      if (mounted) HapticFeedback.mediumImpact();
      _slideCancel.value = 0;
      _cancelZoneHapticLatched = false;
      await _recordDismissCtrl.forward(from: 0);
      await _recordingVisualCtrl.reverse();
      await _finishRecording(cancel: true);
    } finally {
      if (mounted) _recordDismissCtrl.reset();
    }
  }

  void _onTextChanged() {
    _syncMicSend();
    setState(() {});
  }

  void _syncMicSend() {
    if (_recording) return;
    if (_wantSend) {
      _micSendCtrl.forward();
    } else {
      _micSendCtrl.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _micSendCtrl = AnimationController(vsync: this, duration: _kUiAnim);
    _micSendCtrl.value = _wantSend ? 1.0 : 0.0;
    _recordingVisualCtrl = AnimationController(vsync: this, duration: _kUiAnim);
    _recordDismissCtrl = AnimationController(vsync: this, duration: _kRecordingDismissAnim);
    _micSquashCtrl = AnimationController(vsync: this, duration: _kMicPressAnim);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focus.dispose();
    _slideCancel.dispose();
    _recordTick?.cancel();
    _micSendCtrl.dispose();
    _recordingVisualCtrl.dispose();
    _recordDismissCtrl.dispose();
    _micSquashCtrl.dispose();
    _pulseDotCtrl?.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  String _formatRecTime() {
    final s = _recordElapsedSec;
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  Widget _buildMicSendStack() {
    return AnimatedBuilder(
      animation: _micSendCtrl,
      builder: (context, _) {
        final t = _micSendCtrl.value.clamp(0.0, 1.0);
        final micOpacity = (1.0 - t).clamp(0.0, 1.0);
        final micScale = lerpDouble(1.0, 0.9, t) ?? 1.0;
        final micDy = lerpDouble(0.0, -3.0, t) ?? 0.0;

        final sendOpacity = t.clamp(0.0, 1.0);
        final sendScale = lerpDouble(0.9, 1.0, t) ?? 1.0;
        final sendDy = lerpDouble(3.0, 0.0, t) ?? 0.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: Colors.black26,
              child: const SizedBox.expand(),
            ),
            IgnorePointer(
              ignoring: t >= 0.5,
              child: Opacity(
                opacity: micOpacity,
                child: Transform.translate(
                  offset: Offset(0, micDy),
                  child: Transform.scale(
                    scale: micScale,
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: t < 0.5,
              child: Opacity(
                opacity: sendOpacity,
                child: Transform.translate(
                  offset: Offset(0, sendDy),
                  child: Transform.scale(
                    scale: sendScale,
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordingButtonVisual() {
    return AnimatedBuilder(
      animation: _recordingVisualCtrl,
      builder: (context, _) {
        final g = Curves.easeOutCubic.transform(_recordingVisualCtrl.value);
        final scale = lerpDouble(1.0, _kRecordingMicButtonMaxScale, g) ?? 1.0;
        final bg = Color.lerp(AppColors.primary, Colors.redAccent, g) ?? Colors.redAccent;
        return Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: SizedBox(
            width: _kComposerActionSize,
            height: _kComposerActionSize,
            child: Material(
              color: bg,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: Colors.black26,
              child: const Center(child: Icon(Icons.mic_rounded, color: Colors.white, size: 26)),
            ),
          ),
        );
      },
    );
  }

  /// Правая кнопка: удержание микрофона / отправка текста / отпускание завершает голос.
  Widget _buildRightAction() {
    if (_wantSend) {
      return _PressScaleButton(
        onPressed: () => unawaited(_onSendTapped()),
        child: SizedBox(
          width: _kComposerActionSize,
          height: _kComposerActionSize,
          child: _buildMicSendStack(),
        ),
      );
    }

    final slot = _recording ? _kComposerActionSize * _kRecordingMicButtonMaxScale + 6 : _kComposerActionSize;
    return SizedBox(
      width: slot,
      height: slot,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _onRightSlotPointerDown(),
        onPointerMove: _onRightSlotPointerMove,
        onPointerUp: (_) => _onRightSlotPointerUp(),
        onPointerCancel: (_) => _onRightSlotPointerCancel(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_micSquashCtrl, _micSendCtrl, _recordingVisualCtrl]),
          builder: (context, _) {
            final squash = lerpDouble(1.0, 0.80, Curves.easeOut.transform(_micSquashCtrl.value)) ?? 1.0;
            final inner = _recording ? _buildRecordingButtonVisual() : _buildMicSendStack();
            return Transform.scale(scale: squash, alignment: Alignment.center, child: inner);
          },
        ),
      ),
    );
  }

  Widget _buildRecordingCenterZone() {
    final pulse = _pulseDotCtrl;
    return ValueListenableBuilder<double>(
      valueListenable: _slideCancel,
      builder: (context, slideDx, _) {
        final cancelHint = slideDx <= _kSwipeCancelThreshold * 0.55;
        final cancelT = ((-slideDx) / _kSwipeCancelZoneAbs).clamp(0.0, 1.0);
        final easedT = Curves.easeOutCubic.transform(cancelT);
        final borderColor = Color.lerp(AppColors.inputBorder, AppColors.error, easedT)!;
        final borderW = lerpDouble(1.0, 1.65, easedT)!;
        final arrowOpacity = (0.12 + 0.88 * easedT).clamp(0.0, 1.0);
        final arrowColor = Color.lerp(AppColors.subTextColor, AppColors.error, easedT)!;
        final chevronDx = lerpDouble(0, -5, easedT)!;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(_kComposerFieldRadius),
            border: Border.all(color: borderColor, width: borderW),
            boxShadow: easedT > 0.06
                ? [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.06 + 0.12 * easedT),
                      blurRadius: 5 + 5 * easedT,
                      offset: Offset(-1.5 * easedT, 0),
                    ),
                  ]
                : null,
          ),
          padding: AppTextField.defaultContentPadding,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(chevronDx, 0),
                      child: Opacity(
                        opacity: arrowOpacity,
                        child: Icon(Icons.arrow_back_rounded, size: 18, color: arrowColor),
                      ),
                    ),
                  ),
                ),
              ),
              if (pulse != null)
                AnimatedBuilder(
                  animation: pulse,
                  builder: (_, __) {
                    final v = Curves.easeInOut.transform(pulse.value);
                    final ps = lerpDouble(1.0, 1.15, v) ?? 1.0;
                    final po = lerpDouble(1.0, 0.65, v) ?? 1.0;
                    return Transform.scale(
                      scale: ps,
                      child: Opacity(
                        opacity: po.clamp(0.0, 1.0),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                ),
              const SizedBox(width: 10),
              Text(
                _formatRecTime(),
                style: AppTextStyle.base(
                  16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                  height: 1.25,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: _kRecordingHintCrossFade,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    cancelHint ? 'Отпустите для отмены' : 'Влево — отмена · отпустите — отправить',
                    key: ValueKey<bool>(cancelHint),
                    style: AppTextStyle.base(
                      16,
                      color: AppColors.subTextColor.withValues(alpha: 0.72),
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Свайп влево: вся полоса (поле записи + кнопка микрофона) едет вместе; при отмене — «уезжает и гаснет».
  Widget _wrapRecordingSwipeMotion({required Widget child}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_recordDismissCtrl, _slideCancel]),
      builder: (context, _) {
        final dismissT = Curves.easeInCubic.transform(_recordDismissCtrl.value);
        final dismissShift = lerpDouble(0, -220, dismissT) ?? 0;
        final raw = _slideCancel.value;
        final fingerShift = (raw * 1.48).clamp(_kSwipeVisualClamp, 0.0);
        final totalX = fingerShift + dismissShift;

        // Мягче, чем резкий clamp — полоса не «дымит» на мелком движении.
        final swipeFade = (1.0 + raw / 195.0).clamp(0.62, 1.0);
        final dismissFade = lerpDouble(1, 0, dismissT) ?? 1;
        final opacity = (swipeFade * dismissFade).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(totalX, 0), child: child),
        );
      },
    );
  }

  Widget _buildCenterZone() {
    if (_recording) {
      return _buildRecordingCenterZone();
    }
    return AppTextField(
      hintText: 'Сообщение…',
      focusNode: _focus,
      radius: 30,
      controller: widget.controller,
      minLines: 1,
      maxLines: 5,
    );
  }

  Widget _buildToolbarRow() {
    if (_recording) {
      return RepaintBoundary(
        child: _wrapRecordingSwipeMotion(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: _onRecordingSlideMove,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: _kUiAnim,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) {
                      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(key: const ValueKey('rec'), child: _buildCenterZone()),
                  ),
                ),
                const SizedBox(width: 10),
                _buildRightAction(),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PressScaleButton(
          minScale: 0.88,
          duration: _kMicPressAnim,
          onPressed: () => unawaited(_openAttachmentsPanel()),
          child: SizedBox(
            width: _kComposerActionSize,
            height: _kComposerActionSize,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: Colors.black26,
              clipBehavior: Clip.none,
              child: const Center(child: Icon(Icons.attach_file_rounded, color: Colors.white, size: 28)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: _kUiAnim,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            transitionBuilder: (child, anim) {
              final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(key: ValueKey<bool>(_recording), child: _buildCenterZone()),
          ),
        ),
        const SizedBox(width: 10),
        _buildRightAction(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: Material(
        elevation: 14,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        color: Colors.transparent,
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_drafts.isNotEmpty && !_recording) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                child: _AttachmentStrip(
                  drafts: _drafts,
                  onRemove: (i) {
                    setState(() => _drafts.removeAt(i));
                    _syncMicSend();
                  },
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.only(bottom: _focus.hasFocus && !_recording ? 2 : 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: _buildToolbarRow(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scale 1 → [minScale] при тапе (короткая отдача, затем действие).
class _PressScaleButton extends StatefulWidget {
  const _PressScaleButton({
    required this.child,
    required this.onPressed,
    this.minScale = 0.92,
    this.duration,
  });

  final Widget child;
  final VoidCallback onPressed;

  /// Меньше значение — заметнее «вдавливание» (например кнопка «+»).
  final double minScale;

  /// По умолчанию [_kPressAnim]; для «+» можно короче ([_kMicPressAnim]).
  final Duration? duration;

  @override
  State<_PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<_PressScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration ?? _kPressAnim);
  }

  @override
  void didUpdateWidget(_PressScaleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _ctrl.duration = widget.duration ?? _kPressAnim;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _cancel() {
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final s = lerpDouble(1.0, widget.minScale, Curves.easeOut.transform(_ctrl.value)) ?? 1.0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _ctrl.forward(),
          onTap: () {
            _ctrl.reverse();
            widget.onPressed();
          },
          onTapCancel: () => _cancel(),
          child: Transform.scale(scale: s, alignment: Alignment.center, child: widget.child),
        );
      },
    );
  }
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({required this.drafts, required this.onRemove});

  final List<_Draft> drafts;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(top: 8, left: 2, right: 4),
          itemCount: drafts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final d = drafts[i];
            final isImg = ChatAttachmentRules.isImageMime(d.mime);
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: AppColors.inputBackground,
                    child: isImg
                        ? Image.memory(d.bytes, fit: BoxFit.cover)
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file_rounded,
                                    color: AppColors.primary.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    d.filename,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.base(10, color: AppColors.subTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.62),
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.35),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => onRemove(i),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.close_rounded, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
