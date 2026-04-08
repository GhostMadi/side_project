import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';

/// Список салонов/аккаунтов, которые наняли текущего работника.
/// Пока демо (локальные данные). Подключим API/статусы позже.
@RoutePage()
class EmployersPage extends StatefulWidget {
  const EmployersPage({super.key});

  @override
  State<EmployersPage> createState() => _EmployersPageState();
}

class _EmployersPageState extends State<EmployersPage> {
  final List<({String id, String name, String subtitle, String avatar})> _employers = const [
    (
      id: 'em_1',
      name: 'Lumos Coffee',
      subtitle: 'Нанял(а) вас как мастера',
      avatar: 'https://i.pravatar.cc/150?u=employer_lumos',
    ),
    (
      id: 'em_2',
      name: 'Urban Yard',
      subtitle: 'Готов(а) принимать записи на ваших услугах',
      avatar: 'https://i.pravatar.cc/150?u=employer_urban',
    ),
  ];

  final Set<String> _pendingIds = <String>{'em_1', 'em_2'};
  final Set<String> _hiredIds = <String>{};

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    const successColor = AppColors.btnBackground;
    const destructive = Color(0xFFC62828);
    final pending = _employers.where((e) => _pendingIds.contains(e.id)).toList();
    final hired = _employers.where((e) => _hiredIds.contains(e.id)).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: true,
        title: Text('Работодатели', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceMiddle,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          Text(
            'Тут отображаются работодатели и ваши запросы на найм. '
            'Нажмите на карточку — перейдёте на страницу конкретного работодателя.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),

          Text(
            'ВЫ РАБОТАЕТЕ ТУТ',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          if (hired.isEmpty)
            Text('Пока никого не наняли', style: AppTextStyle.base(14, color: AppColors.subTextColor))
          else
            ...hired.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: CircleAvatar(backgroundImage: NetworkImage(e.avatar)),
                    title: Text(e.name, style: AppTextStyle.base(15, fontWeight: FontWeight.w800)),
                    subtitle: Text(e.subtitle, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                    onTap: () => context.router.push(
                      EmployerDetailRoute(
                        employerId: e.id,
                        employerName: e.name,
                        employerAvatar: e.avatar,
                      ),
                    ),
                    trailing: _miniActionButton(
                      text: 'Уволиться',
                      bg: Colors.white,
                      fg: destructive,
                      border: destructive,
                      onTap: () {
                        setState(() {
                          _hiredIds.remove(e.id);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

          SizedBox(height: AppDimensions.spaceSenior),
          Text(
            'ВАШИ ЗАПРОСЫ',
            style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          if (pending.isEmpty)
            Text('Нет новых запросов', style: AppTextStyle.base(14, color: AppColors.subTextColor))
          else
            ...pending.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: CircleAvatar(backgroundImage: NetworkImage(e.avatar)),
                    title: Text(e.name, style: AppTextStyle.base(15, fontWeight: FontWeight.w800)),
                    subtitle: Text(e.subtitle, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                    onTap: () => context.router.push(
                      EmployerDetailRoute(
                        employerId: e.id,
                        employerName: e.name,
                        employerAvatar: e.avatar,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _miniActionButton(
                          text: 'Принять',
                          bg: successColor,
                          fg: Colors.white,
                          border: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _pendingIds.remove(e.id);
                              _hiredIds.add(e.id);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _miniActionButton(
                          text: 'Отклонить',
                          bg: Colors.white,
                          fg: destructive,
                          border: destructive,
                          onTap: () {
                            setState(() {
                              _pendingIds.remove(e.id);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniActionButton({
    required String text,
    required Color bg,
    required Color fg,
    required Color border,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 96,
      height: 36,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            decoration: border == Colors.transparent
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: border, width: 1.5),
                  ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyle.base(12, color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
