import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

// --- МОДЕЛИ ---
class Service {
  final int id;
  final String title;
  final int duration;
  final int price;
  Service({required this.id, required this.title, required this.duration, required this.price});
}

class CartItem {
  final String workerName;
  final Service service;
  final DateTime date;
  final String startTime;
  final String endTime;

  CartItem({
    required this.workerName,
    required this.service,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}

@RoutePage()
// --- ОСНОВНОЙ ВИДЖЕТ ---
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // Данные мастеров и их "внешних" записей
  final List<Map<String, dynamic>> workers = [
    {
      'name': 'Татьяна (Nails)',
      'image': 'https://i.pravatar.cc/150?u=tanya',
      'services': [
        Service(id: 1, title: 'Маникюр', duration: 45, price: 1200),
        Service(id: 2, title: 'Педикюр', duration: 90, price: 2500),
      ],
      'booked': [
        {'start': '10:00', 'end': '10:45'},
        {'start': '13:00', 'end': '14:30'},
      ],
    },
    {
      'name': 'Дмитрий (Hair)',
      'image': 'https://i.pravatar.cc/150?u=dima',
      'services': [
        Service(id: 3, title: 'Стрижка', duration: 60, price: 1500),
        Service(id: 4, title: 'Борода', duration: 30, price: 800),
      ],
      'booked': [
        {'start': '11:00', 'end': '12:00'},
      ],
    },
  ];

  int selectedWorkerIndex = 0;
  Service? selectedService;
  DateTime selectedDate = DateTime.now();
  String? selectedStartTime;
  List<CartItem> cart = [];

  // Парсинг времени
  DateTime _parse(String t) => DateFormat("HH:mm").parse(t);
  String _format(DateTime t) => DateFormat("HH:mm").format(t);

  // ПРОВЕРКА: Занят ли клиент в это время (конфликт в корзине)
  bool _isUserBusy(String timeStr) {
    if (selectedService == null) return false;
    DateTime reqStart = _parse(timeStr);
    DateTime reqEnd = reqStart.add(Duration(minutes: selectedService!.duration));

    for (var item in cart) {
      if (item.date.day == selectedDate.day) {
        DateTime cartStart = _parse(item.startTime);
        DateTime cartEnd = _parse(item.endTime);
        if (reqStart.isBefore(cartEnd) && reqEnd.isAfter(cartStart)) return true;
      }
    }
    return false;
  }

  // ГЕНЕРАЦИЯ СЛОТОВ: С учетом длительности услуги и занятости мастера
  List<String> _generateAvailableSlots() {
    if (selectedService == null) return [];

    List<String> available = [];
    DateTime currentTime = _parse("09:00");
    DateTime endTimeLimit = _parse("20:00");
    int duration = selectedService!.duration;

    // Собираем всё, что занято у мастера
    List<Map<String, DateTime>> masterBusy = [];
    for (var b in workers[selectedWorkerIndex]['booked']) {
      masterBusy.add({'s': _parse(b['start']), 'e': _parse(b['end'])});
    }
    for (var item in cart) {
      if (item.workerName == workers[selectedWorkerIndex]['name'] && item.date.day == selectedDate.day) {
        masterBusy.add({'s': _parse(item.startTime), 'e': _parse(item.endTime)});
      }
    }

    while (currentTime.add(Duration(minutes: duration)).isBefore(endTimeLimit) ||
        currentTime.add(Duration(minutes: duration)).isAtSameMomentAs(endTimeLimit)) {
      DateTime potentialEnd = currentTime.add(Duration(minutes: duration));
      bool isOccupied = false;

      for (var busy in masterBusy) {
        if (currentTime.isBefore(busy['e']!) && potentialEnd.isAfter(busy['s']!)) {
          isOccupied = true;
          currentTime = busy['e']!; // Прыгаем в конец занятого окна
          break;
        }
      }

      if (!isOccupied) {
        available.add(_format(currentTime));
        currentTime = currentTime.add(const Duration(minutes: 15)); // Шаг поиска 15 мин
      }
    }
    return available;
  }

  void _addToCart() {
    final endTime = _format(_parse(selectedStartTime!).add(Duration(minutes: selectedService!.duration)));
    setState(() {
      cart.add(
        CartItem(
          workerName: workers[selectedWorkerIndex]['name'],
          service: selectedService!,
          date: selectedDate,
          startTime: selectedStartTime!,
          endTime: endTime,
        ),
      );
      selectedService = null;
      selectedStartTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final worker = workers[selectedWorkerIndex];
    final availableSlots = _generateAvailableSlots();
    bool userHasConflict = selectedStartTime != null && _isUserBusy(selectedStartTime!);
    const pageBg = Color(0xFFF7F9F6);
    const surface = Colors.white;
    const surfaceSoft = Color(0xFFF1F5EC);
    const borderSoft = Color(0xFFE1E7DA);
    const titleColor = Color(0xFF1A1D1E);
    const subColor = Color(0xFF6F7A6D);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: pageBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Собрать визит',
          style: AppTextStyle.base(20, color: titleColor, fontWeight: FontWeight.w800),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. ВЫБОР МАСТЕРА
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: workers.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  bool isSel = selectedWorkerIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedWorkerIndex = index;
                      selectedService = null;
                      selectedStartTime = null;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isSel ? AppColors.activeColor : surfaceSoft,
                            child: CircleAvatar(
                              radius: 27,
                              backgroundImage: NetworkImage(workers[index]['image']),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workers[index]['name'].split(' ')[0],
                            style: AppTextStyle.base(12, color: isSel ? titleColor : subColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. ВЫБОР УСЛУГИ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Выберите услугу:",
                      style: AppTextStyle.base(16, color: titleColor, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (worker['services'] as List<Service>).map((s) {
                        bool isSel = selectedService?.id == s.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            selectedService = s;
                            selectedStartTime = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFE2F4D9) : surfaceSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSel ? AppColors.btnBackground : borderSoft),
                            ),
                            child: Text(
                              "${s.title} (${s.duration}м)",
                              style: AppTextStyle.base(
                                13,
                                color: isSel ? titleColor : const Color(0xFF2E3A2D),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. ВЫБОР ВРЕМЕНИ (Динамический)
          if (selectedService != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Свободное время (${selectedService!.duration} мин):",
                  style: AppTextStyle.base(16, color: titleColor, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final slot = availableSlots[index];
                  bool isBusy = _isUserBusy(slot);
                  bool isSel = selectedStartTime == slot;

                  return GestureDetector(
                    onTap: () => setState(() => selectedStartTime = slot),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFE2F4D9) : Colors.white,
                        border: Border.all(
                          color: isBusy
                              ? Colors.amber.withOpacity(0.6)
                              : (isSel ? AppColors.btnBackground : borderSoft),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            slot,
                            style: AppTextStyle.base(13, color: isSel ? titleColor : const Color(0xFF2B332A)),
                          ),
                          if (isBusy)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Icon(Icons.person_outline, size: 10, color: Colors.amber),
                            ),
                        ],
                      ),
                    ),
                  );
                }, childCount: availableSlots.length),
              ),
            ),
          ],

          // 4. ПОДТВЕРЖДЕНИЕ В КОРЗИНУ
          if (selectedStartTime != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (userHasConflict)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          "⚠️ В это время у вас уже запланирована другая запись",
                          style: AppTextStyle.base(12, color: const Color(0xFF9C7A26)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.btnBackground,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _addToCart,
                      child: Text(
                        "Добавить в визит",
                        style: AppTextStyle.base(16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. СПИСОК КОРЗИНЫ
          if (cart.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ваш визит:",
                      style: AppTextStyle.base(18, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    const SizedBox(height: 12),
                    ...cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.service.title,
                                  style: AppTextStyle.base(
                                    15,
                                    color: titleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${item.workerName} • ${item.startTime} - ${item.endTime}",
                                  style: AppTextStyle.base(13, color: subColor),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Color(0xFF7A8475),
                                size: 22,
                              ),
                              onPressed: () => setState(() => cart.remove(item)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              color: pageBg,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnBackground,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => print("Confirming ${cart.length} items"),
                child: Text(
                  "ЗАПИСАТЬСЯ НА ВСЁ",
                  style: AppTextStyle.base(17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
    );
  }
}
