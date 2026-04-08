import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';

/// Мок: клиент попадает в базу в момент записи на услугу (даже с пустыми полями и если не пришёл).
@RoutePage()
class BusinessClientsPage extends StatefulWidget {
  const BusinessClientsPage({super.key});

  @override
  State<BusinessClientsPage> createState() => _BusinessClientsPageState();
}

class _BusinessClientsPageState extends State<BusinessClientsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _statusFilter = 'all';

  static const _allClients = <_ClientEntry>[
    _ClientEntry(
      name: 'Алина С.',
      nick: '@alina_style',
      note: 'Маникюр + покрытие · предпочитает вечер',
      avatar: 'https://i.pravatar.cc/150?u=client_alina',
      statusKey: 'completed',
      partial: false,
    ),
    _ClientEntry(
      name: 'Марина К.',
      nick: '@marina_look',
      note: 'Стрижка · запись активна',
      avatar: 'https://i.pravatar.cc/150?u=client_marina',
      statusKey: 'confirmed',
      partial: false,
    ),
    _ClientEntry(
      name: 'Жанар А.',
      nick: '@zhanar_a',
      note: 'Брови — ждём визита',
      avatar: 'https://i.pravatar.cc/150?u=client_zhanar',
      statusKey: 'waiting',
      partial: false,
    ),
    _ClientEntry(
      name: 'Гость без ника',
      nick: '—',
      note: 'Только что записался · телефон не указан',
      avatar: 'https://i.pravatar.cc/150?u=guest_partial',
      statusKey: 'waiting',
      partial: true,
    ),
    _ClientEntry(
      name: 'Дмитрий О.',
      nick: '@dima_o',
      note: 'Барбер · неявка на прошлой неделе',
      avatar: 'https://i.pravatar.cc/150?u=client_dima_o',
      statusKey: 'no_show',
      partial: false,
    ),
    _ClientEntry(
      name: 'Елена В.',
      nick: '@lena_v',
      note: 'Ламинирование — отменила сама',
      avatar: 'https://i.pravatar.cc/150?u=client_lena',
      statusKey: 'declined_client',
      partial: false,
    ),
    _ClientEntry(
      name: 'Арман Т.',
      nick: '@arman_t',
      note: 'Салон отклонил перенос',
      avatar: 'https://i.pravatar.cc/150?u=client_arman',
      statusKey: 'declined_salon',
      partial: true,
    ),
    _ClientEntry(
      name: 'София М.',
      nick: '@sofia_m',
      note: 'Сейчас в кресле',
      avatar: 'https://i.pravatar.cc/150?u=client_sofia',
      statusKey: 'in_progress',
      partial: false,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = _allClients.where((c) {
      final matchStatus = _statusFilter == 'all' || c.statusKey == _statusFilter;
      final matchSearch =
          q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.nick.toLowerCase().contains(q) ||
          c.note.toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();

    final partialCount = _allClients.where((c) => c.partial).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Клиентская база', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceJunior,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          _summaryLine(partialCount),
          SizedBox(height: AppDimensions.spaceJunior),
          _logicHint(),
          SizedBox(height: AppDimensions.spaceMiddle),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Поиск',
              prefixIcon: Icon(Icons.search_rounded, size: 22, color: AppColors.subTextColor.withValues(alpha: 0.7)),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Статус',
            style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'Все'),
                _filterChip('waiting', 'Ожидает'),
                _filterChip('confirmed', 'Подтверждён'),
                _filterChip('in_progress', 'В процессе'),
                _filterChip('completed', 'Завершил'),
                _filterChip('no_show', 'Не пришёл'),
                _filterChip('declined_client', 'Отклонил клиент'),
                _filterChip('declined_salon', 'Отклонил салон'),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          AppButton(
            text: 'Рассылка',
            onPressed: () => context.router.push(const BusinessClientsBroadcastRoute()),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Клиенты · ${filtered.length}',
            style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Никого по фильтру', style: AppTextStyle.base(14, color: AppColors.subTextColor)),
              ),
            )
          else
            ...filtered.map((c) => _clientCard(context, c)),
        ],
      ),
    );
  }

  Widget _summaryLine(int partialCount) {
    return Text(
      '${_allClients.length} контактов · неполных $partialCount',
      style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
    );
  }

  Widget _logicHint() {
    return Text(
      'После записи на услугу контакт сразу попадает сюда (даже с пустыми полями). '
      'Не пришёл или отменил — карточка остаётся, меняется статус.',
      style: AppTextStyle.base(13, height: 1.45, color: AppColors.subTextColor.withValues(alpha: 0.9)),
    );
  }

  Widget _filterChip(String key, String label) {
    final on = _statusFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        label: Text(label),
        selected: on,
        onSelected: (_) => setState(() => _statusFilter = key),
        selectedColor: const Color(0xFFEEEEEE),
        checkmarkColor: AppColors.textColor,
        showCheckmark: false,
        labelStyle: AppTextStyle.base(
          12,
          fontWeight: FontWeight.w500,
          color: on ? AppColors.textColor : AppColors.subTextColor,
        ),
        side: BorderSide(color: on ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _clientCard(BuildContext context, _ClientEntry c) {
    final statusLabel = _statusLabel(c.statusKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.router.push(
            BusinessClientProfileRoute(clientName: c.name, clientNick: c.nick, clientAvatar: c.avatar),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 22, backgroundImage: NetworkImage(c.avatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(c.name, style: AppTextStyle.base(15, fontWeight: FontWeight.w600)),
                          ),
                          if (c.partial)
                            Text(
                              'неполный',
                              style: AppTextStyle.base(11, color: AppColors.subTextColor),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(c.nick, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                      const SizedBox(height: 4),
                      Text(c.note, style: AppTextStyle.base(13, color: AppColors.textColor, height: 1.25)),
                      const SizedBox(height: 4),
                      Text(statusLabel, style: AppTextStyle.base(12, color: AppColors.subTextColor)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.subTextColor.withValues(alpha: 0.45)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _statusLabel(String key) {
    switch (key) {
      case 'waiting':
        return 'Ожидает визита';
      case 'confirmed':
        return 'Подтверждён';
      case 'in_progress':
        return 'В процессе';
      case 'completed':
        return 'Завершил визит';
      case 'no_show':
        return 'Не пришёл';
      case 'declined_client':
        return 'Отклонил клиент';
      case 'declined_salon':
        return 'Отклонил салон';
      default:
        return '';
    }
  }
}

class _ClientEntry {
  const _ClientEntry({
    required this.name,
    required this.nick,
    required this.note,
    required this.avatar,
    required this.statusKey,
    required this.partial,
  });

  final String name;
  final String nick;
  final String note;
  final String avatar;
  final String statusKey;
  final bool partial;
}
