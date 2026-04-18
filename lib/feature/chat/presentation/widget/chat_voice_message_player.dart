import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';

/// Один активный плеер в чате — при запуске другого предыдущий ставится на паузу.
final class ChatVoicePlaybackHub {
  ChatVoicePlaybackHub._();
  static final ChatVoicePlaybackHub instance = ChatVoicePlaybackHub._();

  AudioPlayer? _active;

  Future<void> activate(AudioPlayer player) async {
    if (_active != null && !identical(_active, player)) {
      try {
        await _active!.pause();
        await _active!.seek(Duration.zero);
      } catch (_) {}
    }
    _active = player;
  }

  void deactivate(AudioPlayer player) {
    if (identical(_active, player)) _active = null;
  }
}

/// Голосовое сообщение в стиле WhatsApp: play, дорожка из полосок (waveform), время справа с отступом.
class ChatVoiceMessagePlayer extends StatefulWidget {
  const ChatVoiceMessagePlayer({
    super.key,
    this.networkUrl,
    this.memoryBytes,
    required this.mimeType,
    required this.fg,
    this.durationMsHint,
  }) : assert(
          (networkUrl != null && memoryBytes == null) || (networkUrl == null && memoryBytes != null),
        );

  final String? networkUrl;
  final Uint8List? memoryBytes;
  final String mimeType;
  final Color fg;

  /// [ChatMessageAttachmentModel.duration_ms] с бэка, если есть.
  final int? durationMsHint;

  @override
  State<ChatVoiceMessagePlayer> createState() => _ChatVoiceMessagePlayerState();
}

class _VoiceWaveformPainter extends CustomPainter {
  _VoiceWaveformPainter({
    required this.heights,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.gap,
    required this.maxBarHeight,
  });

  final List<double> heights;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double gap;
  final double maxBarHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final n = heights.length;
    if (n == 0 || size.width <= 0) return;
    final totalGap = gap * (n - 1);
    final barW = max(1.2, (size.width - totalGap) / n);
    final cy = size.height / 2;
    var x = 0.0;
    for (var i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      final fill = t <= progress;
      final h = heights[i].clamp(0.08, 1.0) * maxBarHeight;
      final paint = Paint()
        ..color = fill ? activeColor : inactiveColor
        ..strokeCap = StrokeCap.round;
      final top = cy - h / 2;
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, h),
        Radius.circular(barW / 2),
      );
      canvas.drawRRect(rr, paint);
      x += barW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.heights != heights ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

class _ChatVoiceMessagePlayerState extends State<ChatVoiceMessagePlayer> {
  late final AudioPlayer _player = AudioPlayer();
  File? _tempFile;
  bool _loadingSource = true;
  bool _failed = false;
  late final List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    final seed = widget.networkUrl?.hashCode ?? widget.memoryBytes?.hashCode ?? 0;
    final rnd = Random(seed ^ 0x51a7beef);
    _barHeights = List.generate(44, (_) => 0.22 + rnd.nextDouble() * 0.78);
    unawaited(_bindSource());
  }

  Future<void> _bindSource() async {
    try {
      if (widget.networkUrl != null) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.networkUrl!)));
      } else {
        final dir = await getTemporaryDirectory();
        final ext = _tempExtension(widget.mimeType);
        _tempFile = File('${dir.path}/chat_voice_${hashCode}_${widget.memoryBytes!.length}$ext');
        await _tempFile!.writeAsBytes(widget.memoryBytes!, flush: true);
        await _player.setAudioSource(AudioSource.file(_tempFile!.path));
      }
      if (mounted) {
        setState(() => _loadingSource = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingSource = false;
          _failed = true;
        });
      }
    }
  }

  static String _tempExtension(String mime) {
    final m = mime.toLowerCase();
    if (m.contains('mpeg') || m.contains('mp3')) return '.mp3';
    if (m.contains('wav')) return '.wav';
    if (m.contains('ogg')) return '.ogg';
    return '.m4a';
  }

  @override
  void dispose() {
    ChatVoicePlaybackHub.instance.deactivate(_player);
    unawaited(_player.dispose());
    try {
      final f = _tempFile;
      if (f != null && f.existsSync()) f.deleteSync();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_loadingSource || _failed) return;
    final playing = _player.playerState.playing;
    if (playing) {
      await _player.pause();
    } else {
      await ChatVoicePlaybackHub.instance.activate(_player);
      await _player.play();
    }
    if (mounted) setState(() {});
  }

  void _seekFromLocalX(double dx, double width) {
    if (_loadingSource || _failed || width <= 0) return;
    final r = (dx / width).clamp(0.0, 1.0);
    unawaited(_seekProgress(r));
  }

  Future<void> _seekProgress(double r) async {
    var ms = _player.duration?.inMilliseconds ?? 0;
    if (ms <= 0 && widget.durationMsHint != null) {
      ms = widget.durationMsHint!;
    }
    if (ms <= 0) return;
    await _player.seek(Duration(milliseconds: (r * ms).round()));
  }

  static String _fmt(Duration d) {
    final totalSec = d.inSeconds;
    final m = totalSec ~/ 60;
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'Не удалось воспроизвести аудио',
          style: AppTextStyle.base(13, color: widget.fg.withValues(alpha: 0.85)),
        ),
      );
    }

    final hint = widget.durationMsHint != null ? Duration(milliseconds: widget.durationMsHint!) : null;
    final activeWave = widget.fg.withValues(alpha: 0.92);
    final inactiveWave = widget.fg.withValues(alpha: 0.32);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
      child: SizedBox(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: Material(
                color: widget.fg.withValues(alpha: 0.2),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _loadingSource ? null : _togglePlay,
                  child: Center(
                    child: _loadingSource
                        ? AppCircularProgressIndicator(
                            dimension: 22,
                            strokeWidth: 2,
                            color: widget.fg.withValues(alpha: 0.95),
                          )
                        : StreamBuilder<PlayerState>(
                            stream: _player.playerStateStream,
                            builder: (_, snap) {
                              final playing = snap.data?.playing ?? false;
                              return Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: widget.fg.withValues(alpha: 0.96),
                                size: 27,
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _player.durationStream.map((d) => d ?? Duration.zero),
                initialData: hint ?? Duration.zero,
                builder: (_, durSnap) {
                  final dur = durSnap.data ?? Duration.zero;
                  final totalMs = dur.inMilliseconds > 0 ? dur.inMilliseconds : (hint?.inMilliseconds ?? 0);
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (_, posSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      final progress = totalMs > 0 ? (pos.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0;
                      return LayoutBuilder(
                        builder: (_, bc) {
                          final w = bc.maxWidth;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (d) => _seekFromLocalX(d.localPosition.dx, w),
                            onHorizontalDragUpdate: (d) => _seekFromLocalX(d.localPosition.dx, w),
                            child: SizedBox(
                              height: 34,
                              width: w,
                              child: CustomPaint(
                                painter: _VoiceWaveformPainter(
                                  heights: _barHeights,
                                  progress: progress,
                                  activeColor: activeWave,
                                  inactiveColor: inactiveWave,
                                  gap: 2,
                                  maxBarHeight: 28,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 48,
              child: StreamBuilder<Duration>(
                stream: _player.durationStream.map((d) => d ?? Duration.zero),
                initialData: hint ?? Duration.zero,
                builder: (_, durSnap) {
                  final dur = durSnap.data ?? Duration.zero;
                  final total = dur.inMilliseconds > 0 ? dur : (hint ?? Duration.zero);
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (_, posSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      return StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (_, ps) {
                          final playing = ps.data?.playing ?? false;
                          final text = (!playing && pos == Duration.zero)
                              ? (total.inMilliseconds > 0 ? _fmt(total) : '…')
                              : '${_fmt(pos)} / ${_fmt(total)}';
                          return Text(
                            text,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: AppTextStyle.base(
                              !playing && pos == Duration.zero ? 12 : 11,
                              color: widget.fg.withValues(alpha: !playing && pos == Duration.zero ? 0.78 : 0.72),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
