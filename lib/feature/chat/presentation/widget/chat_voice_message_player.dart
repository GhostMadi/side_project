import 'dart:async';
import 'dart:io';
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

/// Голосовое сообщение в стиле Telegram/WhatsApp: круглая кнопка play, полоса прогресса, время.
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

class _ChatVoiceMessagePlayerState extends State<ChatVoiceMessagePlayer> {
  late final AudioPlayer _player = AudioPlayer();
  File? _tempFile;
  bool _loadingSource = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
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
                  final maxSec = totalMs > 0 ? totalMs / 1000.0 : 1.0;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (_, posSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      final curSec = pos.inMilliseconds / 1000.0;
                      return SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: widget.fg.withValues(alpha: 0.88),
                          inactiveTrackColor: widget.fg.withValues(alpha: 0.28),
                          thumbColor: widget.fg.withValues(alpha: 0.98),
                        ),
                        child: Slider(
                          value: curSec.clamp(0.0, maxSec),
                          max: maxSec,
                          onChanged: _loadingSource
                              ? null
                              : (v) {
                                  unawaited(_player.seek(Duration(milliseconds: (v * 1000).round())));
                                },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 76,
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
                          if (!playing && pos == Duration.zero) {
                            return Text(
                              total.inMilliseconds > 0 ? _fmt(total) : '…',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: AppTextStyle.base(
                                12,
                                color: widget.fg.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          return Text(
                            '${_fmt(pos)} · ${_fmt(total)}',
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: AppTextStyle.base(
                              11,
                              color: widget.fg.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w500,
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
