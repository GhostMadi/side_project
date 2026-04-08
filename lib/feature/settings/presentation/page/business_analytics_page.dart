import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';

/// Строка отчёта по канонической услуге аналитики (как на экране «Услуги для аналитики»).
class _AnalyticsServiceRow {
  const _AnalyticsServiceRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bookingsByPeriod,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;

  /// [день, неделя, месяц] — мок-записей по группе
  final List<int> bookingsByPeriod;
}

/// Сводная аналитика бизнеса. Мок — без бэкенда.
@RoutePage()
class BusinessAnalyticsPage extends StatefulWidget {
  const BusinessAnalyticsPage({super.key});

  @override
  State<BusinessAnalyticsPage> createState() => _BusinessAnalyticsPageState();
}

class _BusinessAnalyticsPageState extends State<BusinessAnalyticsPage> {
  int _periodIndex = 1; // 0 день, 1 неделя, 2 месяц

  static const _periodLabels = ['День', 'Неделя', 'Месяц'];

  /// Мок-цифры по периоду [день, неделя, месяц]
  static const _bookings = [12, 47, 186];
  static const _confirmed = [9, 38, 152];
  static const _noShow = [1, 4, 11];
  static const _cancelled = [2, 5, 23];
  static const _newClients = [3, 14, 48];

  /// Топ по конкретным услугам (как называют у мастеров / в записи).
  static const _topServices = [
    ('Маникюр + покрытие', 42),
    ('Стрижка', 31),
    ('Коррекция бровей', 18),
    ('Ламинирование ресниц', 14),
  ];

  late final List<_AnalyticsServiceRow> _analyticsServiceRows;

  @override
  void initState() {
    super.initState();
    _analyticsServiceRows = [
      const _AnalyticsServiceRow(
        id: '1',
        title: 'Маникюр',
        subtitle: 'Ногти · руки',
        description: 'Все виды маникюра и покрытий для отчётов и записи.',
        bookingsByPeriod: [5, 18, 72],
      ),
      const _AnalyticsServiceRow(
        id: '2',
        title: 'Педикюр',
        subtitle: 'Ногти · стопы',
        description: 'Педикюр и уход за стопами.',
        bookingsByPeriod: [3, 12, 44],
      ),
      const _AnalyticsServiceRow(
        id: '3',
        title: 'Брови',
        subtitle: 'Лицо',
        description: 'Коррекция, окрашивание, ламинирование бровей.',
        bookingsByPeriod: [2, 9, 31],
      ),
    ];
  }

  static const _topMasters = [('Татьяна Л.', 52), ('Дмитрий П.', 41), ('Алия К.', 28), ('Соня Р.', 22)];

  @override
  Widget build(BuildContext context) {
    final i = _periodIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Аналитика', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceJunior,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          Text(
            'Сводка по записям и клиентам. Цифры для демо.',
            style: AppTextStyle.base(13, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Row(
            children: List.generate(3, (index) {
              final on = _periodIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _periodIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: on ? const Color(0xFFF5F5F5) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: on ? const Color(0xFFBDBDBD) : const Color(0xFFEEEEEE)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _periodLabels[index],
                          style: AppTextStyle.base(
                            13,
                            fontWeight: FontWeight.w600,
                            color: on ? AppColors.textColor : AppColors.subTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          _kpiGrid([
            ('Записей', '${_bookings[i]}'),
            ('Подтверждено', '${_confirmed[i]}'),
            ('Не пришли', '${_noShow[i]}'),
            ('Отмены', '${_cancelled[i]}'),
          ]),
          SizedBox(height: AppDimensions.spaceJunior),
          _kpiWide('Новых в клиентской базе', '${_newClients[i]}'),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Воронка (мок)',
            style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          _funnelBar('Заявка', 100, AppColors.subTextColor.withValues(alpha: 0.35)),
          const SizedBox(height: 6),
          _funnelBar('Подтверждена', 78, AppColors.subTextColor.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          _funnelBar('Визит состоялся', 64, AppColors.btnBackground.withValues(alpha: 0.55)),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Топ услуг',
            style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          ..._topServices.map((e) => _rankRow(e.$1, e.$2)),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Услуги аналитики',
            style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Те же группы, что в «Услуги для аналитики». Цифры и порядок в отчёте — для демо; порядок строк меняйте за ручку.',
            style: AppTextStyle.base(12, height: 1.35, color: AppColors.subTextColor.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 10),
          _analyticsServicesReorderableBlock(i),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Топ мастеров',
            style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          ..._topMasters.map((e) => _rankRow(e.$1, e.$2)),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'После подключения бэкенда здесь будут реальные агрегаты по событиям записи.',
            style: AppTextStyle.base(12, height: 1.35, color: AppColors.subTextColor.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _kpiGrid(List<(String, String)> items) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: items.map((e) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.$1, style: AppTextStyle.base(12, color: AppColors.subTextColor)),
              const SizedBox(height: 4),
              Text(
                e.$2,
                style: AppTextStyle.base(22, fontWeight: FontWeight.w800, color: AppColors.textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _kpiWide(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
          Text(value, style: AppTextStyle.base(18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _funnelBar(String label, int percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyle.base(12, color: AppColors.textColor)),
            Text(
              '$percent%',
              style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFEEEEEE),
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _rankRow(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyle.base(14, fontWeight: FontWeight.w500)),
          ),
          Text(
            '$count',
            style: AppTextStyle.base(14, fontWeight: FontWeight.w700, color: AppColors.subTextColor),
          ),
        ],
      ),
    );
  }

  /// Карточка в духе чипов аналитики на экране выбора услуг работодателю.
  Widget _analyticsServicesReorderableBlock(int periodIndex) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _analyticsServiceRows.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final x = _analyticsServiceRows.removeAt(oldIndex);
              _analyticsServiceRows.insert(newIndex, x);
            });
          },
          itemBuilder: (context, index) {
            final e = _analyticsServiceRows[index];
            final count = e.bookingsByPeriod[periodIndex.clamp(0, 2)];
            return Padding(
              key: ValueKey('analytics_row_${e.id}'),
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC8DDF5).withValues(alpha: 0.65)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, right: 8),
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: AppColors.subTextColor.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.analytics_outlined,
                        size: 20,
                        color: AppColors.btnBackground.withValues(alpha: 0.88),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: AppTextStyle.base(
                                15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textColor,
                              ),
                            ),
                            if (e.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(e.subtitle, style: AppTextStyle.base(12, color: AppColors.subTextColor)),
                            ],
                            if (e.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                e.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.base(
                                  12,
                                  height: 1.3,
                                  color: AppColors.textColor.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$count',
                            style: AppTextStyle.base(
                              18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text('записей', style: AppTextStyle.base(11, color: AppColors.subTextColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
