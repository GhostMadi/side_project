import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';

@RoutePage()
class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkerCandidate {
  const _WorkerCandidate({
    required this.id,
    required this.nick,
    required this.fullName,
    required this.speciality,
    required this.avatarUrl,
  });

  final String id;
  final String nick;
  final String fullName;
  final String speciality;
  final String avatarUrl;
}

class _WorkerService {
  const _WorkerService({
    required this.title,
    required this.minutes,
    required this.price,
  });

  final String title;
  final int minutes;
  final int price;
}

class _WorkersPageState extends State<WorkersPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<_WorkerCandidate> _pool = const [
    _WorkerCandidate(
      id: 'w_1',
      nick: 'nail_tanya',
      fullName: 'Татьяна Л.',
      speciality: 'Маникюр',
      avatarUrl: 'https://i.pravatar.cc/150?u=tanya_worker',
    ),
    _WorkerCandidate(
      id: 'w_2',
      nick: 'barber_dima',
      fullName: 'Дмитрий П.',
      speciality: 'Барбер',
      avatarUrl: 'https://i.pravatar.cc/150?u=dima_worker',
    ),
    _WorkerCandidate(
      id: 'w_3',
      nick: 'brow_aliya',
      fullName: 'Алия К.',
      speciality: 'Brow-мастер',
      avatarUrl: 'https://i.pravatar.cc/150?u=aliya_worker',
    ),
    _WorkerCandidate(
      id: 'w_4',
      nick: 'lash_sonya',
      fullName: 'Соня Р.',
      speciality: 'Лэшмейкер',
      avatarUrl: 'https://i.pravatar.cc/150?u=sonya_worker',
    ),
  ];

  final Set<String> _pendingIds = <String>{};
  /// Входящие запросы на найм: работники, которые хотят работать с салоном.
  final Set<String> _incomingHireIds = <String>{'w_4'};
  final Set<String> _hiredIds = <String>{};
  /// Салон запросил у работника какие-то конкретные услуги (корзина ожидания).
  final Map<String, List<_WorkerService>> _pendingServiceByWorker = <String, List<_WorkerService>>{};

  /// Салон принял корзину услуг работника (что попадёт в список для записи).
  final Map<String, List<_WorkerService>> _acceptedServiceByWorker = <String, List<_WorkerService>>{};
  final Map<String, List<_WorkerService>> _workerCatalog = {
    'w_1': [
      _WorkerService(title: 'Маникюр', minutes: 45, price: 1200),
      _WorkerService(title: 'Покрытие гель-лак', minutes: 75, price: 2200),
    ],
    'w_2': [
      _WorkerService(title: 'Стрижка', minutes: 60, price: 1800),
      _WorkerService(title: 'Борода', minutes: 30, price: 900),
    ],
    'w_3': [
      _WorkerService(title: 'Коррекция бровей', minutes: 40, price: 1500),
    ],
    'w_4': [
      _WorkerService(title: 'Ламинирование ресниц', minutes: 70, price: 2600),
    ],
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _sendHireRequest(_WorkerCandidate c) {
    setState(() {
      _pendingIds.add(c.id);
    });
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Запрос на найм отправлен: @${c.nick}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmAccepted(_WorkerCandidate c) {
    setState(() {
      _incomingHireIds.remove(c.id);
      _hiredIds.add(c.id);
    });
  }

  void _declineIncomingHire(_WorkerCandidate c) {
    setState(() {
      _incomingHireIds.remove(c.id);
    });
  }

  Future<void> _requestServices(_WorkerCandidate c) async {
    final catalog = _workerCatalog[c.id] ?? const <_WorkerService>[];
    if (catalog.isEmpty) return;

    final selected = <_WorkerService>{...catalog};

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Выберите услуги для запроса',
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w800, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 12),
                    ...catalog.map((s) {
                      final checked = selected.contains(s);
                      return CheckboxListTile(
                        value: checked,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          '${s.title} · ${s.minutes} мин · ${s.price} ₽',
                          style: AppTextStyle.base(14, color: AppColors.textColor, fontWeight: FontWeight.w600),
                        ),
                        onChanged: (v) {
                          setSheetState(() {
                            if (v == true) {
                              selected.add(s);
                            } else {
                              selected.remove(s);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            text: 'Отмена',
                            isExpanded: true,
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Отправить запрос',
                            isExpanded: true,
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              setState(() {
                                _pendingServiceByWorker[c.id] = selected.toList();
                              });
                              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                SnackBar(
                                  content: Text('Запрос отправлен: @${c.nick}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _acceptServiceBasket(_WorkerCandidate c) {
    final services = _pendingServiceByWorker[c.id];
    if (services == null) return;

    setState(() {
      _pendingServiceByWorker.remove(c.id);
      _acceptedServiceByWorker[c.id] = services;
    });
  }

  List<_WorkerCandidate> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _pool;
    return _pool
        .where((w) => w.nick.toLowerCase().contains(q) || w.fullName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppAppBar(
          backgroundColor: bg,
          automaticallyImplyLeading: true,
          title: Text('Работники', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            TabBar(
              labelColor: AppColors.btnBackground,
              unselectedLabelColor: AppColors.subTextColor,
              indicatorColor: AppColors.btnBackground,
              tabs: const [
                Tab(text: 'Поиск'),
                Tab(text: 'Запросы'),
                Tab(text: 'Мои сотрудники'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _searchTab(),
                  _pendingTab(),
                  _hiredTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchTab() {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMiddle,
        AppDimensions.spaceMiddle,
        AppDimensions.paddingMiddle,
        AppDimensions.spaceSenior,
      ),
      children: [
        Text(
          'Найдите человека по нику и отправьте запрос на найм.',
          style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
        ),
        SizedBox(height: AppDimensions.spaceMiddle),
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Поиск по нику: @nickname',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: AppDimensions.spaceMiddle),
        ..._filtered.map(_candidateTile),
      ],
    );
  }

  Widget _pendingTab() {
    final waitingWorkers = _pool.where((w) => _pendingServiceByWorker.containsKey(w.id)).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMiddle,
        AppDimensions.spaceMiddle,
        AppDimensions.paddingMiddle,
        AppDimensions.spaceSenior,
      ),
      children: [
        Text('ЗАПРОСЫ ОТ МЕНЯ', style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor)),
        const SizedBox(height: 8),
        ..._pendingList(),
        const SizedBox(height: 12),
        Text('ЗАПРОСЫ КО МНЕ', style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor)),
        const SizedBox(height: 8),
        ..._incomingList(),
        const SizedBox(height: 12),
        Text('КОРЗИНЫ УСЛУГ НА ПРИНЯТИЕ', style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor)),
        const SizedBox(height: 8),
        ..._serviceBasketList(waitingWorkers, waitingMode: true),
      ],
    );
  }

  Widget _hiredTab() {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMiddle,
        AppDimensions.spaceMiddle,
        AppDimensions.paddingMiddle,
        AppDimensions.spaceSenior,
      ),
      children: _hiredList(),
    );
  }

  Widget _candidateTile(_WorkerCandidate c) {
    final isPending = _pendingIds.contains(c.id);
    final isIncoming = _incomingHireIds.contains(c.id);
    final isHired = _hiredIds.contains(c.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl)),
          title: Text(c.fullName, style: AppTextStyle.base(15, fontWeight: FontWeight.w700)),
          subtitle: Text('@${c.nick} · ${c.speciality}', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
          trailing: isHired
              ? _acceptedServiceByWorker.containsKey(c.id)
                  ? const Icon(Icons.verified_rounded, color: AppColors.btnBackground)
                  : _pendingServiceByWorker.containsKey(c.id)
                      ? _miniActionButton(text: 'Ждём', outlined: true, onTap: () {})
                      : _miniActionButton(text: 'Запрос услуг', onTap: () => _requestServices(c))
              : isIncoming
                  ? _miniActionButton(text: 'Принять', onTap: () => _confirmAccepted(c))
              : isPending
                  ? _miniActionButton(text: 'Ожидает', outlined: true, onTap: () {})
                  : _miniActionButton(text: 'Нанять', onTap: () => _sendHireRequest(c)),
        ),
      ),
    );
  }

  List<Widget> _pendingList() {
    final pending = _pool.where((w) => _pendingIds.contains(w.id)).toList();
    if (pending.isEmpty) {
      return [Text('Нет запросов', style: AppTextStyle.base(13, color: AppColors.subTextColor))];
    }
    return pending.map((w) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0EBD2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: CircleAvatar(backgroundImage: NetworkImage(w.avatarUrl)),
            title: Text('@${w.nick}', style: AppTextStyle.base(15, fontWeight: FontWeight.w700)),
            subtitle: Text('Запрос отправлен', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
            trailing: _miniActionButton(text: 'Ожидает', outlined: true, onTap: () {}),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _incomingList() {
    final incoming = _pool.where((w) => _incomingHireIds.contains(w.id)).toList();
    if (incoming.isEmpty) {
      return [Text('Нет входящих запросов', style: AppTextStyle.base(13, color: AppColors.subTextColor))];
    }

    return incoming.map((w) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: CircleAvatar(backgroundImage: NetworkImage(w.avatarUrl)),
            title: Text(w.fullName, style: AppTextStyle.base(15, fontWeight: FontWeight.w700)),
            subtitle: Text('Запрос на найм: @${w.nick}', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _miniActionButton(text: 'Принять', onTap: () => _confirmAccepted(w)),
                const SizedBox(width: 8),
                _miniActionButton(text: 'Отклонить', outlined: true, onTap: () => _declineIncomingHire(w)),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _hiredList() {
    final hired = _pool.where((w) => _hiredIds.contains(w.id)).toList();
    if (hired.isEmpty) {
      return [Text('Пока никого не наняли', style: AppTextStyle.base(13, color: AppColors.subTextColor))];
    }
    return hired.map((w) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: CircleAvatar(backgroundImage: NetworkImage(w.avatarUrl)),
            title: Text(w.fullName, style: AppTextStyle.base(15, fontWeight: FontWeight.w700)),
            subtitle: Text('@${w.nick} · ${w.speciality}', style: AppTextStyle.base(13, color: AppColors.subTextColor)),
            trailing: _acceptedServiceByWorker.containsKey(w.id)
                ? const Icon(Icons.check_circle_rounded, color: AppColors.btnBackground)
                : _pendingServiceByWorker.containsKey(w.id)
                ? _miniActionButton(text: 'Принять корзину', outlined: true, onTap: () => _acceptServiceBasket(w))
                : null,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _serviceBasketList(List<_WorkerCandidate> workers, {bool waitingMode = false}) {
    if (workers.isEmpty) {
      return [Text('Пусто', style: AppTextStyle.base(13, color: AppColors.subTextColor))];
    }
    return workers.map((w) {
      final services = waitingMode
          ? (_pendingServiceByWorker[w.id] ?? const <_WorkerService>[])
          : (_acceptedServiceByWorker[w.id] ?? const <_WorkerService>[]);
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
                    CircleAvatar(radius: 16, backgroundImage: NetworkImage(w.avatarUrl)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${w.fullName} · @${w.nick}', style: AppTextStyle.base(14, fontWeight: FontWeight.w700)),
                    ),
                    if (waitingMode) _miniActionButton(text: 'Принять', onTap: () => _acceptServiceBasket(w)),
                  ],
                ),
                const SizedBox(height: 8),
                ...services.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${s.title} · ${s.minutes} мин · ${s.price} ₽',
                      style: AppTextStyle.base(13, color: AppColors.textColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _miniActionButton({
    required String text,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      width: 96,
      height: 36,
      child: Material(
        color: outlined ? Colors.white : AppColors.btnBackground,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            decoration: outlined
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.btnBackground, width: 1.4),
                  )
                : null,
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyle.base(
                13,
                fontWeight: FontWeight.w700,
                color: outlined ? AppColors.btnBackground : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
