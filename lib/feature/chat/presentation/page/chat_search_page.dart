import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';

@RoutePage()
class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  late final TextEditingController _c;
  Timer? _d;
  bool _loading = false;
  Object? _error;
  var _results = <({String conversationId, String text, String senderUsername})>[];

  @override
  void initState() {
    super.initState();
    _c = TextEditingController();
  }

  @override
  void dispose() {
    _d?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _d?.cancel();
    final q = v.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    _d = Timer(const Duration(milliseconds: 320), () => unawaited(_run(q)));
  }

  Future<void> _run(String q) async {
    try {
      final repo = sl<ChatRepository>();
      final list = await repo.searchMessages(query: q, limit: 50);
      if (!mounted) return;
      setState(() {
        _results = [
          for (final e in list)
            (
              conversationId: e.conversationId,
              text: e.message.message.text ?? '',
              senderUsername: e.message.sender.username ?? 'noName',
            ),
        ];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppAppBar(
        automaticallyImplyLeading: true,
        title: Text('Поиск', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: TextField(
              controller: _c,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Поиск по сообщениям',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_error != null) {
                  return Center(
                    child: Text(
                      'Ошибка: $_error',
                      style: AppTextStyle.base(14, color: AppColors.subTextColor),
                    ),
                  );
                }
                if (_loading) {
                  return const Center(child: AppCircularProgressIndicator());
                }
                if (_results.isEmpty) {
                  return Center(
                    child: Text(
                      'Введите запрос',
                      style: AppTextStyle.base(14, color: AppColors.subTextColor),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border.withValues(alpha: 0.55)),
                  itemBuilder: (context, i) {
                    final r = _results[i];
                    return ListTile(
                      title: Text(r.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('@${r.senderUsername}'),
                      onTap: () => context.router.push(ChatThreadRoute(conversationId: r.conversationId)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
