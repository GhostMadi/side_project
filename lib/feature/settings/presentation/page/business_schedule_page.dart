import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';

/// Настройка услуг и графика для бизнес-аккаунта (запись клиентов).
/// Данные пока только локально на экране; позже — API / репозиторий.
@RoutePage()
class BusinessSchedulePage extends StatefulWidget {
  const BusinessSchedulePage({super.key, this.showWorkers = false});

  final bool showWorkers;

  @override
  State<BusinessSchedulePage> createState() => _BusinessSchedulePageState();
}

class _EditableService {
  _EditableService({String name = '', String duration = '60', String price = ''})
    : name = TextEditingController(text: name),
      durationMin = TextEditingController(text: duration),
      price = TextEditingController(text: price);

  final TextEditingController name;
  final TextEditingController durationMin;
  final TextEditingController price;

  void dispose() {
    name.dispose();
    durationMin.dispose();
    price.dispose();
  }
}

class _WorkerMock {
  _WorkerMock({
    required this.fullName,
    required this.nick,
    required this.speciality,
    required this.avatarUrl,
    required this.services,
    required this.scheduleLines,
  });

  final String fullName;
  final String nick;
  final String speciality;
  final String avatarUrl;
  final List<String> services;
  final List<String> scheduleLines;
}

class _BusinessSchedulePageState extends State<BusinessSchedulePage> {
  final List<_EditableService> _services = [];
  late List<({String label, bool enabled, TextEditingController hours})> _weekdays;

  late final TextEditingController _lunchWindow;
  late final TextEditingController _breakBetweenMin;
  bool _lunchEnabled = true;

  // Моковые данные: показываем, как будет выглядеть “всё в одном” экране.
  final List<_WorkerMock> _workerMocks = <_WorkerMock>[
    _WorkerMock(
      fullName: 'Татьяна Л.',
      nick: '@nail_tanya',
      speciality: 'Маникюр',
      avatarUrl: 'https://i.pravatar.cc/150?u=tanya_worker',
      services: const <String>[
        'Маникюр · 45 мин · 1200 ₽',
        'Покрытие гель-лак · 75 мин · 2200 ₽',
      ],
      scheduleLines: const <String>[
        'Пн: 10:00 – 20:00',
        'Вт: 10:00 – 20:00',
        'Ср: 10:00 – 20:00',
        'Чт: 10:00 – 20:00',
        'Пт: 10:00 – 21:00',
        'Сб: 11:00 – 18:00',
      ],
    ),
    _WorkerMock(
      fullName: 'Дмитрий П.',
      nick: '@barber_dima',
      speciality: 'Барбер',
      avatarUrl: 'https://i.pravatar.cc/150?u=dima_worker',
      services: const <String>[
        'Стрижка · 60 мин · 1800 ₽',
        'Борода · 30 мин · 900 ₽',
      ],
      scheduleLines: const <String>[
        'Пн: 12:00 – 20:00',
        'Вт: 12:00 – 20:00',
        'Чт: 12:00 – 20:00',
        'Пт: 12:00 – 21:00',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _lunchWindow = TextEditingController(text: '13:00 – 14:00');
    _breakBetweenMin = TextEditingController(text: '15');
    _services.add(_EditableService(name: 'Маникюр', duration: '45', price: '1200'));
    _weekdays = <({String label, bool enabled, TextEditingController hours})>[
      (label: 'Понедельник', enabled: true, hours: TextEditingController(text: '10:00 – 20:00')),
      (label: 'Вторник', enabled: true, hours: TextEditingController(text: '10:00 – 20:00')),
      (label: 'Среда', enabled: true, hours: TextEditingController(text: '10:00 – 20:00')),
      (label: 'Четверг', enabled: true, hours: TextEditingController(text: '10:00 – 20:00')),
      (label: 'Пятница', enabled: true, hours: TextEditingController(text: '10:00 – 21:00')),
      (label: 'Суббота', enabled: true, hours: TextEditingController(text: '11:00 – 18:00')),
      (label: 'Воскресенье', enabled: false, hours: TextEditingController(text: '—')),
    ];
  }

  @override
  void dispose() {
    for (final s in _services) {
      s.dispose();
    }
    for (final d in _weekdays) {
      d.hours.dispose();
    }
    _lunchWindow.dispose();
    _breakBetweenMin.dispose();
    super.dispose();
  }

  void _addService() {
    setState(() => _services.add(_EditableService()));
  }

  void _removeService(int index) {
    final s = _services.removeAt(index);
    s.dispose();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final sectionStyle = AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.subTextColor);
    final labelStyle = AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: true,
        title: Text('График и услуги', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceJunior,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          if (widget.showWorkers) ...[
            Text(
              'Общий просмотр: личные и рабочие графики/услуги без редактирования.',
              style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
            ),
            SizedBox(height: AppDimensions.spaceMiddle),
            Text('ЛИЧНЫЕ', style: sectionStyle),
            SizedBox(height: AppDimensions.spaceJunior),
            _personalOverviewCard(),
            SizedBox(height: AppDimensions.spaceMiddle),
            Text('РАБОТНИКИ (МОК)', style: sectionStyle),
            SizedBox(height: AppDimensions.spaceJunior),
            ..._workerMocks.map(_workerCard),
          ] else ...[
            Text(
              'Клиенты видят слоты и услуги из личных настроек бизнеса: услуги, рабочие дни, обед без записи и буфер между визитами.',
              style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
            ),
            SizedBox(height: AppDimensions.spaceMiddle),
            Text('ЛИЧНЫЕ ГРАФИК И УСЛУГИ', style: sectionStyle),
            SizedBox(height: AppDimensions.spaceJunior),
            Text('УСЛУГИ', style: sectionStyle),
            SizedBox(height: AppDimensions.spaceJunior),
            ...List.generate(_services.length, (i) => _serviceCard(i, labelStyle)),
            SizedBox(height: AppDimensions.spaceJunior),
            AppOutlinedButton(text: 'Добавить услугу', onPressed: _addService),
            SizedBox(height: AppDimensions.spaceMiddle),
            Text('РАБОЧИЕ ДНИ', style: sectionStyle),
            SizedBox(height: AppDimensions.spaceJunior),
            ...List.generate(_weekdays.length, (i) => _dayTile(i, labelStyle)),
            SizedBox(height: AppDimensions.spaceMiddle),
            Text('ОБЕД И ПЕРЕРЫВЫ', style: sectionStyle),
            SizedBox(height: AppDimensions.spaceJunior),
            _pausesCard(labelStyle),
            SizedBox(height: AppDimensions.spaceHuge),
            AppButton(
              text: 'Сохранить личные настройки',
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final messenger = ScaffoldMessenger.maybeOf(context);
                await context.router.maybePop();
                messenger?.showSnackBar(
                  const SnackBar(
                    content: Text('Личные настройки сохранены (демо — подключите бэкенд)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _personalOverviewCard() {
    final localLabelStyle = AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor);
    final enabledDays = _weekdays.where((d) => d.enabled).toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF5FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE9F8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('Мой аккаунт', style: AppTextStyle.base(15, fontWeight: FontWeight.w800))),
                _tag('Личное'),
              ],
            ),
            const SizedBox(height: 10),
            Text('Услуги', style: localLabelStyle),
            const SizedBox(height: 6),
            ..._services.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _lineCard('${s.name.text} · ${s.durationMin.text} мин · ${s.price.text} ₽'),
              ),
            ),
            const SizedBox(height: 12),
            Text('График', style: localLabelStyle),
            const SizedBox(height: 6),
            ...enabledDays.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${d.label}: ${d.hours.text}', style: AppTextStyle.base(13, color: AppColors.textColor)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _lunchEnabled ? 'Обед: ${_lunchWindow.text}' : 'Обед: выключен',
              style: AppTextStyle.base(13, color: AppColors.textColor),
            ),
            Text(
              'Перерыв между услугами: ${_breakBetweenMin.text} мин',
              style: AppTextStyle.base(13, color: AppColors.textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workerCard(_WorkerMock w) {
    final localLabelStyle = AppTextStyle.base(12, fontWeight: FontWeight.w600, color: AppColors.subTextColor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF9FCF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3EBD8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: NetworkImage(w.avatarUrl)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.fullName, style: AppTextStyle.base(15, fontWeight: FontWeight.w800)),
                        Text('${w.nick} · ${w.speciality}', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                      ],
                    ),
                  ),
                  _tag('Работник'),
                ],
              ),
              const SizedBox(height: 10),
              Text('Услуги', style: localLabelStyle),
              const SizedBox(height: 6),
              ...w.services.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _lineCard(s),
                ),
              ),
              const SizedBox(height: 12),
              Text('График', style: localLabelStyle),
              const SizedBox(height: 6),
              ...w.scheduleLines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(line, style: AppTextStyle.base(13, color: AppColors.textColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2E1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyle.base(11, fontWeight: FontWeight.w700, color: AppColors.btnBackground),
      ),
    );
  }

  Widget _lineCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Text(
        text,
        style: AppTextStyle.base(13, color: AppColors.textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _serviceCard(int index, TextStyle labelStyle) {
    final s = _services[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Услуга ${index + 1}',
                      style: AppTextStyle.base(13, fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_services.length > 1)
                    IconButton(
                      onPressed: () => _removeService(index),
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Название', style: labelStyle),
              const SizedBox(height: 4),
              TextField(
                controller: s.name,
                style: AppTextStyle.base(16, color: AppColors.textColor),
                decoration: _fieldDecoration(hint: 'Например, Стрижка'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Минут', style: labelStyle),
                        const SizedBox(height: 4),
                        TextField(
                          controller: s.durationMin,
                          keyboardType: TextInputType.number,
                          style: AppTextStyle.base(16, color: AppColors.textColor),
                          decoration: _fieldDecoration(hint: '60'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Цена, ₽', style: labelStyle),
                        const SizedBox(height: 4),
                        TextField(
                          controller: s.price,
                          keyboardType: TextInputType.number,
                          style: AppTextStyle.base(16, color: AppColors.textColor),
                          decoration: _fieldDecoration(hint: '1500'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pausesCard(TextStyle labelStyle) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0EBD2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text('Обед', style: AppTextStyle.base(16, fontWeight: FontWeight.w600)),
              subtitle: Text(
                'В это время слоты не предлагаются',
                style: AppTextStyle.base(12, height: 1.3, color: AppColors.subTextColor),
              ),
              value: _lunchEnabled,
              activeThumbColor: AppColors.btnBackground,
              onChanged: (v) => setState(() => _lunchEnabled = v),
            ),
            if (_lunchEnabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Интервал обеда', style: labelStyle),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _lunchWindow,
                      style: AppTextStyle.base(15, color: AppColors.textColor),
                      decoration: _fieldDecoration(hint: '13:00 – 14:00'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Перерыв между услугами, мин', style: labelStyle),
                  const SizedBox(height: 4),
                  Text(
                    'Буфер после каждой записи до следующего слота (подготовка места, отдых).',
                    style: AppTextStyle.base(12, height: 1.35, color: AppColors.subTextColor),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _breakBetweenMin,
                    keyboardType: TextInputType.number,
                    style: AppTextStyle.base(16, color: AppColors.textColor),
                    decoration: _fieldDecoration(hint: '15'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayTile(int index, TextStyle labelStyle) {
    final d = _weekdays[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(d.label, style: AppTextStyle.base(16, fontWeight: FontWeight.w600)),
                value: d.enabled,
                activeThumbColor: AppColors.btnBackground,
                onChanged: (v) {
                  setState(() {
                    _weekdays[index] = (label: d.label, enabled: v, hours: d.hours);
                  });
                },
              ),
              if (d.enabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Часы (как показывать гостям)', style: labelStyle),
                      const SizedBox(height: 4),
                      TextField(
                        controller: d.hours,
                        style: AppTextStyle.base(15, color: AppColors.textColor),
                        decoration: _fieldDecoration(hint: '10:00 – 20:00'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.base(15, color: AppColors.textColor.withValues(alpha: 0.35)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
