import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';

/// Записи бизнеса: кто записался, на кого, статус — по табам (мок).
@RoutePage()
class BusinessBookingsPage extends StatelessWidget {
  const BusinessBookingsPage({super.key});

  static const _waiting = <_BookingMock>[
    _BookingMock(
      service: 'Маникюр',
      client: '@alina_style',
      master: 'Татьяна Л.',
      when: 'Сегодня, 12:00',
      note: 'Услуга из корзины мастера',
    ),
    _BookingMock(
      service: 'Стрижка',
      client: '@marina_look',
      master: 'Дмитрий П.',
      when: 'Сегодня, 15:30',
      note: 'Услуга из корзины мастера',
    ),
  ];

  static const _noShow = <_BookingMock>[
    _BookingMock(
      service: 'Коррекция бровей',
      client: '@zhanar_a',
      master: 'Алия К.',
      when: 'Вчера, 16:00',
      note: 'Клиент не пришёл',
    ),
  ];

  static const _inProgress = <_BookingMock>[
    _BookingMock(
      service: 'Покрытие гель-лак',
      client: '@dima_o',
      master: 'Татьяна Л.',
      when: 'Сейчас',
      note: 'В кресле',
    ),
  ];

  static const _done = <_BookingMock>[
    _BookingMock(
      service: 'Ламинирование ресниц',
      client: '@lash_fan',
      master: 'Соня Р.',
      when: '24.03, 11:00',
      note: 'Услуга оказана',
    ),
    _BookingMock(
      service: 'Борода',
      client: '@barber_client',
      master: 'Дмитрий П.',
      when: '23.03, 10:30',
      note: 'Услуга оказана',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          title: Text('Записи', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.btnBackground,
            unselectedLabelColor: AppColors.subTextColor,
            indicatorColor: AppColors.btnBackground,
            labelStyle: AppTextStyle.base(13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyle.base(13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Ждём'),
              Tab(text: 'Не пришёл'),
              Tab(text: 'В процессе'),
              Tab(text: 'Сделано'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _tabBody(context, 'Ждём подтверждения или визита', _waiting),
            _tabBody(context, 'Неявка клиента', _noShow),
            _tabBody(context, 'Сейчас в работе', _inProgress),
            _tabBody(context, 'Завершённые визиты', _done),
          ],
        ),
      ),
    );
  }

  Widget _tabBody(BuildContext context, String hint, List<_BookingMock> rows) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMiddle,
        AppDimensions.spaceMiddle,
        AppDimensions.paddingMiddle,
        AppDimensions.spaceSenior,
      ),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE9F8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Кто записался → на кого', style: AppTextStyle.base(14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  'Запись у мастера; работодатель видит только услуги из поделённой корзины. $hint',
                  style: AppTextStyle.base(13, height: 1.4, color: AppColors.subTextColor),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spaceMiddle),
        if (rows.isEmpty)
          Text('Пока пусто', style: AppTextStyle.base(14, color: AppColors.subTextColor))
        else
          ...rows.map(_row),
      ],
    );
  }

  Widget _row(_BookingMock r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(r.service, style: AppTextStyle.base(16, fontWeight: FontWeight.w800))),
                  Text(r.when, style: AppTextStyle.base(12, color: AppColors.subTextColor, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Записался: ${r.client}', style: AppTextStyle.base(13, color: AppColors.textColor, fontWeight: FontWeight.w600)),
              Text('На кого: ${r.master}', style: AppTextStyle.base(13, color: AppColors.textColor)),
              const SizedBox(height: 6),
              Text(r.note, style: AppTextStyle.base(12, color: AppColors.btnBackground, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingMock {
  const _BookingMock({
    required this.service,
    required this.client,
    required this.master,
    required this.when,
    required this.note,
  });

  final String service;
  final String client;
  final String master;
  final String when;
  final String note;
}
