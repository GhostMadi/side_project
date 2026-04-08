import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';

class _AnalyticsServiceItem {
  _AnalyticsServiceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String id;
  String title;
  String subtitle;
  String description;
}

/// Канонический список услуг аккаунта для аналитики (мок — только на экране).
@RoutePage()
class BusinessAnalyticsServicesPage extends StatefulWidget {
  const BusinessAnalyticsServicesPage({super.key});

  @override
  State<BusinessAnalyticsServicesPage> createState() => _BusinessAnalyticsServicesPageState();
}

class _BusinessAnalyticsServicesPageState extends State<BusinessAnalyticsServicesPage> {
  late final List<_AnalyticsServiceItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      _AnalyticsServiceItem(
        id: '1',
        title: 'Маникюр',
        subtitle: 'Ногти · руки',
        description: 'Все виды маникюра и покрытий для отчётов и записи.',
      ),
      _AnalyticsServiceItem(
        id: '2',
        title: 'Педикюр',
        subtitle: 'Ногти · стопы',
        description: 'Педикюр и уход за стопами.',
      ),
      _AnalyticsServiceItem(
        id: '3',
        title: 'Брови',
        subtitle: 'Лицо',
        description: 'Коррекция, окрашивание, ламинирование бровей.',
      ),
    ];
  }

  void _remove(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
  }

  Future<void> _add() async {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Новая услуга', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleCtrl,
                  decoration: const InputDecoration(labelText: 'Подзаголовок'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Добавить', style: TextStyle(color: AppColors.btnBackground, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    // Считываем до dispose: после pop диалог ещё может держать TextField один кадр.
    final title = titleCtrl.text.trim();
    final subtitle = subtitleCtrl.text.trim();
    final description = descCtrl.text.trim();

    void disposeCtrls() {
      titleCtrl.dispose();
      subtitleCtrl.dispose();
      descCtrl.dispose();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => disposeCtrls());

    if (!mounted) return;

    if (ok == true && title.isNotEmpty) {
      setState(() {
        _items.add(
          _AnalyticsServiceItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            subtitle: subtitle,
            description: description,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Услуги для аналитики', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
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
            'Общие направления для отчётов. Мастера могут называть услуги по-своему — здесь задаётся, к какой группе относить цифры.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          AppOutlinedButton(text: 'Добавить услугу', onPressed: _add),
          SizedBox(height: AppDimensions.spaceMiddle),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Список пуст', style: AppTextStyle.base(14, color: AppColors.subTextColor)),
              ),
            )
          else
            ..._items.map(_row),
        ],
      ),
    );
  }

  Widget _row(_AnalyticsServiceItem e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: AppTextStyle.base(16, fontWeight: FontWeight.w700)),
                    if (e.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(e.subtitle, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                    ],
                    if (e.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(e.description, style: AppTextStyle.base(13, height: 1.35, color: AppColors.textColor)),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                onPressed: () => _remove(e.id),
                tooltip: 'Удалить',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
