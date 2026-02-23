import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_button.dart';

class EventTicketDetailsSheet extends StatelessWidget {
  const EventTicketDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Шапка профиля
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightGreen.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://img.freepik.com/premium-psd/music-concert-flyer-template-design_452208-1420.jpg?semt=ais_hybrid&w=740',
                ),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ClubBlaBlabar',
                    style: AppTextStyle.base(15, fontWeight: FontWeight.w600, color: AppColors.textColor),
                  ),
                  Text(
                    'Astana, Kz',
                    style: AppTextStyle.base(13, fontWeight: FontWeight.w400, color: AppColors.subTextColor),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Изображение концерта
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              'https://img.freepik.com/free-psd/music-band-festival-template_23-2151624456.jpg?semt=ais_hybrid&w=740&q=80',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 3. Текстовый блок
        Text(
          'FRIDAY PARTY',
          style: AppTextStyle.base(24, fontWeight: FontWeight.w800, color: AppColors.textColor),
        ),
        Text('12.09.2026 - 18:30', style: AppTextStyle.base(14, color: AppColors.subTextColor)),
        const SizedBox(height: 12),

        Text(
          'Бронирование и покупка билетов на самолет онлайн. · Сравнения цен на билеты. Спецпредложения. Выбор пользователей. Авиабилеты по всему миру. Безопасная онлайн оплата',
          textAlign: TextAlign.center,
          style: AppTextStyle.base(13, height: 1.5, color: AppColors.textColor.withOpacity(0.8)),
        ),
        const SizedBox(height: 24),

        // 4. Кнопки действий
        Row(
          children: [
            Expanded(
              flex: 4,
              child: AppButton(text: 'Перейти в чат', onPressed: () => log('Chat pressed')),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: AppButton(
                text: '',
                // Используем иконку билета через AppIcons
                child: Icon(AppIcons.ticket.icon, color: AppColors.btnText),
                onPressed: () => context.router.push(TicketViewRoute()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
