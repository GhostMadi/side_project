import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';

@RoutePage()
class BusinessClientProfilePage extends StatelessWidget {
  const BusinessClientProfilePage({
    super.key,
    required this.clientName,
    required this.clientNick,
    required this.clientAvatar,
  });

  final String clientName;
  final String clientNick;
  final String clientAvatar;

  @override
  Widget build(BuildContext context) {
    const visits = <({String service, String price, String provider, String date})>[
      (service: 'Маникюр + покрытие', price: '2200 ₽', provider: 'Мастер: Татьяна Л.', date: '12.03.2026'),
      (service: 'Стрижка', price: '1800 ₽', provider: 'Мастер: Дмитрий П.', date: '25.02.2026'),
      (service: 'Коррекция бровей', price: '1500 ₽', provider: 'Мастер: Алия К.', date: '11.02.2026'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Карта клиента', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceJunior,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(clientAvatar)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clientName, style: AppTextStyle.base(17, fontWeight: FontWeight.w800)),
                    Text(clientNick, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          Text('ИСТОРИЯ УСЛУГ', style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor)),
          SizedBox(height: AppDimensions.spaceJunior),
          ...visits.map(_visitCard),
        ],
      ),
    );
  }

  Widget _visitCard(({String service, String price, String provider, String date}) v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(v.service, style: AppTextStyle.base(15, fontWeight: FontWeight.w700))),
                  Text(v.price, style: AppTextStyle.base(14, fontWeight: FontWeight.w800, color: AppColors.btnBackground)),
                ],
              ),
              const SizedBox(height: 5),
              Text(v.provider, style: AppTextStyle.base(13, color: AppColors.textColor)),
              Text('Дата: ${v.date}', style: AppTextStyle.base(12, color: AppColors.subTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}
