import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';

@RoutePage()
class BusinessClientsBroadcastPage extends StatefulWidget {
  const BusinessClientsBroadcastPage({super.key});

  @override
  State<BusinessClientsBroadcastPage> createState() => _BusinessClientsBroadcastPageState();
}

class _BusinessClientsBroadcastPageState extends State<BusinessClientsBroadcastPage> {
  String _gender = 'all';
  RangeValues _ageRange = const RangeValues(18, 45);
  String _lastVisit = 'all';
  /// Статус записи / визита для рассылки (мок-фильтр).
  String _visitStatus = 'all';

  final TextEditingController _messageCtrl = TextEditingController(
    text: 'Здравствуйте! Для вас есть специальное предложение на услуги.',
  );

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  int _mockRecipientCount() {
    var base = 128;
    if (_gender == 'female') {
      base = 86;
    }
    if (_gender == 'male') {
      base = 42;
    }
    if (_lastVisit == '30') {
      base = (base * 0.45).round();
    }
    if (_lastVisit == '90') {
      base = (base * 0.72).round();
    }
    if (_lastVisit == 'old') {
      base = (base * 0.28).round();
    }
    switch (_visitStatus) {
      case 'waiting':
        return (base * 0.22).clamp(1, 999).toInt();
      case 'confirmed':
        return (base * 0.18).clamp(1, 999).toInt();
      case 'in_progress':
        return (base * 0.05).clamp(1, 999).toInt();
      case 'completed':
        return (base * 0.55).clamp(1, 999).toInt();
      case 'no_show':
        return (base * 0.12).clamp(1, 999).toInt();
      case 'declined_client':
        return (base * 0.08).clamp(1, 999).toInt();
      case 'declined_salon':
        return (base * 0.06).clamp(1, 999).toInt();
      default:
        return base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _mockRecipientCount();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Множественная рассылка', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
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
            'Фильтруйте аудиторию по полу, возрасту, дате визита и статусу записи.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Статус записи / визита',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _visitChip('all', 'Все'),
              _visitChip('waiting', 'Ожидает'),
              _visitChip('confirmed', 'Подтверждён'),
              _visitChip('in_progress', 'В процессе'),
              _visitChip('completed', 'Завершил визит'),
              _visitChip('no_show', 'Не пришёл'),
              _visitChip('declined_client', 'Отклонил клиент'),
              _visitChip('declined_salon', 'Отклонил салон'),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text('Пол', style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: AppColors.subTextColor)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _genderChip('all', 'Все'),
              _genderChip('female', 'Только девушки'),
              _genderChip('male', 'Только мужчины'),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text(
            'Возраст: ${_ageRange.start.round()}-${_ageRange.end.round()}',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: AppColors.subTextColor),
          ),
          RangeSlider(
            values: _ageRange,
            min: 16,
            max: 70,
            activeColor: AppColors.btnBackground,
            divisions: 54,
            labels: RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}'),
            onChanged: (v) => setState(() => _ageRange = v),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          Text('Последний визит', style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: AppColors.subTextColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _lastVisit,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Все клиенты')),
              DropdownMenuItem(value: '30', child: Text('Были за последние 30 дней')),
              DropdownMenuItem(value: '90', child: Text('Были за последние 90 дней')),
              DropdownMenuItem(value: 'old', child: Text('Не были более 90 дней')),
            ],
            onChanged: (v) => setState(() => _lastVisit = v ?? 'all'),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text('Текст рассылки', style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: AppColors.subTextColor)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Введите текст для клиентов',
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3F9EC), Color(0xFFEAF2E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCEE4B2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.send_rounded, color: AppColors.btnBackground, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Мок: получателей примерно $count (с учётом статуса записи и остальных фильтров)',
                      style: AppTextStyle.base(13, height: 1.35, color: AppColors.textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceHuge),
          AppButton(
            text: 'Отправить рассылку',
            onPressed: () {
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                SnackBar(
                  content: Text('Мок: рассылка на ~$count контактов'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _genderChip(String value, String text) {
    final selected = _gender == value;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF2E1) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFFCEE4B2) : const Color(0xFFE8E8E8)),
        ),
        child: Text(
          text,
          style: AppTextStyle.base(
            13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.btnBackground : AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _visitChip(String value, String text) {
    final selected = _visitStatus == value;
    return FilterChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => setState(() => _visitStatus = value),
      selectedColor: const Color(0xFFEAF2E1),
      checkmarkColor: AppColors.btnBackground,
      labelStyle: AppTextStyle.base(
        12,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.btnBackground : AppColors.textColor,
      ),
      side: BorderSide(color: selected ? const Color(0xFFCEE4B2) : const Color(0xFFE0E0E0)),
    );
  }
}
