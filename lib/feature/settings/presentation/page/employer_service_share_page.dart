import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';

class _MyService {
  const _MyService({required this.id, required this.title, required this.minutes, required this.price});

  final String id;
  final String title;
  final int minutes;
  final int price;
}

/// Канонические направления для отчётов (как на экране «Услуги для аналитики»).
class _AnalyticsLine {
  const _AnalyticsLine({required this.id, required this.title, required this.subtitle});

  final String id;
  final String title;
  final String subtitle;
}

@RoutePage()
class EmployerServiceSharePage extends StatefulWidget {
  const EmployerServiceSharePage({
    super.key,
    required this.employerId,
    required this.employerName,
  });

  final String employerId;
  final String employerName;

  @override
  State<EmployerServiceSharePage> createState() => _EmployerServiceSharePageState();
}

class _EmployerServiceSharePageState extends State<EmployerServiceSharePage> {
  // Демо: “мои” услуги работника (как источник).
  final List<_MyService> _myServices = const [
    _MyService(id: 's1', title: 'Маникюр', minutes: 45, price: 1200),
    _MyService(id: 's2', title: 'Покрытие гель-лак', minutes: 75, price: 2200),
    _MyService(id: 's3', title: 'Снятие покрытия', minutes: 20, price: 700),
    _MyService(id: 's4', title: 'Дизайн ногтей', minutes: 30, price: 900),
  ];

  final List<_MyService> _basket = [];

  static const List<_AnalyticsLine> _analyticsLines = [
    _AnalyticsLine(id: 'a1', title: 'Маникюр', subtitle: 'Ногти · руки'),
    _AnalyticsLine(id: 'a2', title: 'Педикюр', subtitle: 'Ногти · стопы'),
    _AnalyticsLine(id: 'a3', title: 'Брови', subtitle: 'Лицо'),
  ];

  /// id услуги мастера → id канона аналитики (одна услуга — одна группа).
  final Map<String, String> _serviceToAnalytics = {};

  void _addToBasket(_MyService s) {
    if (_basket.any((x) => x.id == s.id)) return;
    setState(() => _basket.add(s));
  }

  void _removeFromBasket(_MyService s) {
    setState(() {
      _basket.removeWhere((x) => x.id == s.id);
      _serviceToAnalytics.remove(s.id);
    });
  }

  void _bindBasketItemToAnalytics(_MyService basketItem, String analyticsId) {
    if (!_basket.any((x) => x.id == basketItem.id)) return;
    setState(() => _serviceToAnalytics[basketItem.id] = analyticsId);
  }

  void _clearAnalyticsBinding(String serviceId) {
    setState(() => _serviceToAnalytics.remove(serviceId));
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final sectionStyle = AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: true,
        title: Text('Выберите услуги для работодателя', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
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
            'Работодатель: ${widget.employerName}. Перетащите услуги в корзину — вы делитесь не всеми, а только выбранными.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),

          Text('МОИ УСЛУГИ (DRAG)', style: sectionStyle),
          const SizedBox(height: 8),
          _servicesSource(),
          SizedBox(height: AppDimensions.spaceMiddle),

          Text('УСЛУГИ ДЛЯ АНАЛИТИКИ (DRAG)', style: sectionStyle),
          const SizedBox(height: 8),
          Text(
            'После того как услуга в корзине, перетащите сюда подходящее направление и отпустите на строке этой услуги в корзине.',
            style: AppTextStyle.base(13, height: 1.35, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 10),
          _analyticsSourceStrip(),
          SizedBox(height: AppDimensions.spaceMiddle),

          Text('КОРЗИНА ДЛЯ ЭТОГО РАБОТОДАТЕЛЯ', style: sectionStyle),
          const SizedBox(height: 8),
          _basketTarget(),
          SizedBox(height: AppDimensions.spaceHuge),

          AppButton(
            text: 'Отправить корзину',
            onPressed: () async {
              AppSnackBar.show(
                context,
                message:
                    'Корзина отправлена: ${_basket.length} услуг, привязок к аналитике: ${_serviceToAnalytics.length} (демо)',
                kind: AppSnackBarKind.success,
              );
              await context.router.maybePop();
            },
          ),
        ],
      ),
    );
  }

  Widget _servicesSource() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _myServices.map((s) {
        final inBasket = _basket.any((x) => x.id == s.id);
        final chip = _serviceChip(s, inBasket: inBasket);
        return Draggable<_MyService>(
          data: s,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.95, child: chip),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: chip),
          child: chip,
        );
      }).toList(),
    );
  }

  Widget _serviceChip(_MyService s, {required bool inBasket}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inBasket ? const Color(0xFFF8FAF5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: inBasket ? const Color(0xFFE0EBD2) : const Color(0xFFE8E8E8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator_rounded, size: 20, color: AppColors.subTextColor.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              s.title,
              style: AppTextStyle.base(14, fontWeight: FontWeight.w700, color: AppColors.textColor),
            ),
            const SizedBox(width: 10),
            Text(
              '${s.minutes}м · ${s.price}₽',
              style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor),
            ),
          ],
        ),
      ),
    );
  }

  String? _analyticsTitleForService(String serviceId) {
    final aid = _serviceToAnalytics[serviceId];
    if (aid == null) return null;
    for (final l in _analyticsLines) {
      if (l.id == aid) return l.title;
    }
    return null;
  }

  Widget _analyticsSourceStrip() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _analyticsLines.map(_analyticsDraggableChip).toList(),
    );
  }

  Widget _analyticsDraggableChip(_AnalyticsLine line) {
    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8DDF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 18, color: AppColors.btnBackground.withValues(alpha: 0.9)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(line.title, style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.textColor)),
                Text(line.subtitle, style: AppTextStyle.base(11, color: AppColors.subTextColor)),
              ],
            ),
            const SizedBox(width: 6),
            Icon(Icons.drag_indicator_rounded, size: 18, color: AppColors.subTextColor.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
    return Draggable<_AnalyticsLine>(
      data: line,
      feedback: Material(
        color: Colors.transparent,
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        child: Opacity(opacity: 0.92, child: chip),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }

  Widget _basketTarget() {
    return DragTarget<_MyService>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _addToBasket(d.data),
      builder: (context, candidates, rejected) {
        final isHover = candidates.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: isHover ? const Color(0xFFEFF8E7) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isHover ? AppColors.btnBackground : const Color(0xFFE8E8E8), width: 1.4),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: SizedBox(
              height: _basket.isEmpty
                  ? 220
                  : (96 * _basket.length + 48).clamp(200, 520).toDouble(),
              child: _basket.isEmpty ? _emptyBasketHint() : _basketList(),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyBasketHint() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Перетащите сюда',
          style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.textColor),
        ),
        const SizedBox(height: 6),
        Text(
          'Выберите услуги слева и перетащите в корзину.\nПорядок в корзине можно менять. Затем перетащите направление аналитики на строку услуги.',
          style: AppTextStyle.base(13, height: 1.35, color: AppColors.subTextColor),
        ),
      ],
    );
  }

  Widget _basketList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _basket.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _basket.removeAt(oldIndex);
          _basket.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final s = _basket[index];
        final analyticsTitle = _analyticsTitleForService(s.id);
        return DragTarget<_AnalyticsLine>(
          key: ValueKey('basket_${s.id}'),
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (d) => _bindBasketItemToAnalytics(s, d.data.id),
          builder: (context, candidates, rejected) {
            final hover = candidates.isNotEmpty;
            return Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: hover ? const Color(0xFFEFF8E7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hover ? AppColors.btnBackground : const Color(0xFFE8E8E8),
                    width: hover ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle_rounded, color: AppColors.subTextColor),
                  ),
                  title: Text(s.title, style: AppTextStyle.base(14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${s.minutes} минут · ${s.price} ₽',
                        style: AppTextStyle.base(13, color: AppColors.subTextColor),
                      ),
                      const SizedBox(height: 4),
                      if (analyticsTitle != null)
                        Row(
                          children: [
                            Icon(Icons.insights_outlined, size: 14, color: AppColors.btnBackground.withValues(alpha: 0.85)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Аналитика: $analyticsTitle',
                                style: AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.btnBackground),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Снять привязку',
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.close_rounded, size: 18, color: AppColors.subTextColor.withValues(alpha: 0.7)),
                              onPressed: () => _clearAnalyticsBinding(s.id),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Перетащите сюда направление из блока выше',
                          style: AppTextStyle.base(12, height: 1.2, color: AppColors.subTextColor.withValues(alpha: 0.85)),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Убрать из корзины',
                    icon: Icon(Icons.close_rounded, color: AppColors.subTextColor.withValues(alpha: 0.75)),
                    onPressed: () => _removeFromBasket(s),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

