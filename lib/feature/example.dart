import 'dart:math' as math;

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

class MultiLevelVenuePage extends StatefulWidget {
  const MultiLevelVenuePage({super.key});

  @override
  State<MultiLevelVenuePage> createState() => _MultiLevelVenuePageState();
}

class _MultiLevelVenuePageState extends State<MultiLevelVenuePage> {
  int activeFloor = 1;
  List<String> selectedItems = [];

  void _onItemTap(String id) {
    setState(() {
      selectedItems.contains(id) ? selectedItems.remove(id) : selectedItems.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Complex Space Planner", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFloorSelector(),
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(1000),
              minScale: 0.1,
              maxScale: 2.0,
              child: _buildCanvas(),
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }

  // Переключатель этажей
  Widget _buildFloorSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [1, 2]
            .map(
              (f) => GestureDetector(
                onTap: () => setState(() => activeFloor = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: activeFloor == f ? Colors.blueAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Этаж $f",
                    style: TextStyle(color: activeFloor == f ? Colors.white : Colors.white54),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      width: 1200,
      height: 1200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(children: activeFloor == 1 ? _buildCinemaFloor() : _buildCafeFloor()),
    );
  }

  // --- ЭТАЖ 1: КИНОТЕАТР ---
  List<Widget> _buildCinemaFloor() {
    return [
      // Стены зала
      _buildWall(0, 300, 10, 600), // Левая
      _buildWall(1190, 300, 10, 600), // Правая
      // Экран
      Positioned(
        top: 100,
        left: 400,
        child: Container(
          width: 400,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
            ],
          ),
        ),
      ),
      // Сетка кресел
      Positioned(top: 250, left: 350, child: _buildCinemaGrid(8, 12)),
    ];
  }

  // --- ЭТАЖ 2: КАФЕ (СТОЛЫ, СТЕНЫ) ---
  List<Widget> _buildCafeFloor() {
    return [
      // Внешние стены кафе
      _buildWall(200, 200, 800, 10), // Верхняя
      _buildWall(200, 200, 10, 500), // Левая
      _buildWall(500, 200, 10, 200), // Внутренняя перегородка
      // Барная стойка
      Positioned(
        top: 300,
        left: 250,
        child: Container(
          width: 200,
          height: 40,
          color: Colors.brown[700],
          child: const Center(
            child: Text("BAR", style: TextStyle(color: Colors.white24)),
          ),
        ),
      ),
      // Группа столов
      _buildTable(id: "T1", x: 600, y: 350, seats: 4),
      _buildTable(id: "T2", x: 850, y: 350, seats: 6),
      _buildTable(id: "T3", x: 600, y: 550, seats: 2),
      _buildTable(id: "T4", x: 850, y: 550, seats: 8),
    ];
  }

  // --- УНИВЕРСАЛЬНЫЕ КОМПОНЕНТЫ ---

  Widget _buildWall(double x, double y, double w, double h) {
    return Positioned(
      left: x,
      top: y,
      child: Container(width: w, height: h, color: Colors.white24),
    );
  }

  Widget _buildTable({required String id, required double x, required double y, int seats = 4}) {
    return Positioned(
      left: x,
      top: y,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Стол
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle),
            child: Center(
              child: Text(id, style: const TextStyle(color: Colors.white38)),
            ),
          ),
          // Стулья вокруг стола по формуле круга
          ...List.generate(seats, (i) {
            double angle = (2 * math.pi / seats) * i;
            return Transform.translate(
              offset: Offset(math.cos(angle) * 50, math.sin(angle) * 50),
              child: _buildSeatItem("$id-S$i"),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCinemaGrid(int rows, int cols) {
    return Column(
      children: List.generate(
        rows,
        (r) => Row(children: List.generate(cols, (c) => _buildSeatItem("R$r-C$c"))),
      ),
    );
  }

  Widget _buildSeatItem(String id) {
    bool isSelected = selectedItems.contains(id);
    return GestureDetector(
      onTap: () => _onItemTap(id),
      child: Container(
        margin: const EdgeInsets.all(3),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              "Выбрано: ${selectedItems.length}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {},
              child: const Text("Продолжить", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return VenueConstructorApp();
  }
}

// --- МОДЕЛИ ДАННЫХ ---
enum SeatStatus { available, selected, occupied, gap }

class SeatModel {
  final String rowName;
  final int seatNumber;
  SeatStatus status;

  SeatModel({required this.rowName, required this.seatNumber, this.status = SeatStatus.available});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatModel &&
          runtimeType == other.runtimeType &&
          rowName == other.rowName &&
          seatNumber == other.seatNumber;

  @override
  int get hashCode => rowName.hashCode ^ seatNumber.hashCode;
}

// --- ВИДЖЕТ СХЕМЫ (С сохранением состояния камеры) ---
class UniversalHallWidget extends StatefulWidget {
  final Map<String, dynamic> hallData;
  final List<String> selectedSeats;
  final Function(String) onSeatTap;

  const UniversalHallWidget({
    super.key,
    required this.hallData,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  State<UniversalHallWidget> createState() => _UniversalHallWidgetState();
}

class _UniversalHallWidgetState extends State<UniversalHallWidget> {
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _controller.value = Matrix4.identity()..translate(-600.0, -100.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List zones = widget.hallData['zones'];

    return InteractiveViewer(
      transformationController: _controller,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.1,
      maxScale: 1.5,
      child: Container(
        width: 2000,
        height: 1800,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(top: 50, left: 800, child: _buildStage()),
            ...zones.map((zone) => _buildDynamicZone(zone)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicZone(Map<String, dynamic> zone) {
    return Positioned(
      left: 1000 + (zone['position']['x'] as double) - 150,
      top: zone['position']['y'] as double,
      child: Transform.rotate(
        angle: (zone['rotation'] ?? 0.0) as double,
        child: GestureDetector(
          onTap: () => widget.onSeatTap("${zone['id']}_0_0"),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(zone['rows'].length, (rIndex) {
                var row = zone['rows'][rIndex];
                return Transform.translate(
                  offset: Offset((row['offset'] ?? 0.0) as double, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(row['seatCount'], (sIndex) {
                        String seatId = "${zone['id']}_${row['rowId']}_$sIndex";
                        return _SeatButton(
                          color: Color(int.parse(zone['color'])),
                          isSelected: widget.selectedSeats.contains(seatId),
                          onTap: () => widget.onSeatTap(seatId),
                        );
                      }),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Text(
                zone['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage() => Container(
    width: 400,
    height: 40,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
    child: const Center(child: Text("Сцена")),
  );
}

class _SeatButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _SeatButton({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// // --- Основной экран ---
// class DynamicSeatPlanScreen extends StatefulWidget {
//   const DynamicSeatPlanScreen({super.key});

//   @override
//   _DynamicSeatPlanScreenState createState() => _DynamicSeatPlanScreenState();
// }

// class _DynamicSeatPlanScreenState extends State<DynamicSeatPlanScreen> {
//   late List<RowModel> hallConfiguration;
//   List<SeatModel> selectedSeats = [];

//   @override
//   void initState() {
//     super.initState();
//     _generateMockHall();
//   }

//   void _generateMockHall() {
//     hallConfiguration = [
//       _createRow("A", 20, gaps: [5, 15]), // Проходы после 5 и 15 места
//       _createRow("B", 20, gaps: [5, 15]),
//       _createRow("C", 24, gaps: [6, 18]),
//       _createRow("D", 24, gaps: [6, 18]),
//       _createRow("E", 14, gaps: [7]), // Узкий ряд с проходом по центру
//       _createRow("VIP", 8, isVip: true), // Ряд без проходов, VIP
//     ];
//   }

//   RowModel _createRow(String name, int count, {List<int>? gaps, bool isVip = false}) {
//     List<SeatModel> rowSeats = [];
//     for (int i = 1; i <= count; i++) {
//       rowSeats.add(SeatModel(rowName: name, seatNumber: i));
//       if (gaps != null && gaps.contains(i)) {
//         rowSeats.add(SeatModel(rowName: name, seatNumber: 0, status: SeatStatus.gap));
//       }
//     }
//     return RowModel(rowName: name, seats: rowSeats);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1014),
//       body: Stack(
//         children: [
//           // Основной контент
//           Column(
//             children: [
//               const SizedBox(height: 60),
//               _buildScreenCurve(), // Красивый экран со свечением

//               Expanded(
//                 child: InteractiveViewer(
//                   constrained: false,
//                   boundaryMargin: const EdgeInsets.all(150),
//                   minScale: 0.1,
//                   maxScale: 2.0,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//                     child: Column(children: hallConfiguration.map((row) => _buildRow(row)).toList()),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 120), // Место под нижнюю панель
//             ],
//           ),

//           // Glassmorphism панель покупки
//           Positioned(bottom: 0, left: 0, right: 0, child: _buildGlassPurchasePanel()),
//         ],
//       ),
//     );
//   }

//   Widget _buildRow(RowModel rowData) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _rowLabel(rowData.rowName),
//           ...rowData.seats.map((seat) => _buildSeat(seat)),
//           _rowLabel(rowData.rowName),
//         ],
//       ),
//     );
//   }

//   Widget _rowLabel(String name) => SizedBox(
//     width: 30,
//     child: Text(
//       name,
//       style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, fontWeight: FontWeight.bold),
//     ),
//   );

//   Widget _buildSeat(SeatModel seat) {
//     if (seat.status == SeatStatus.gap) return const SizedBox(width: 16);

//     bool isSelected = selectedSeats.contains(seat);
//     bool isOccupied = (seat.seatNumber % 9 == 0); // Просто для примера занятых мест

//     return GestureDetector(
//       onTap: isOccupied
//           ? null
//           : () {
//               setState(() {
//                 isSelected ? selectedSeats.remove(seat) : selectedSeats.add(seat);
//               });
//             },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         margin: const EdgeInsets.symmetric(horizontal: 3),
//         width: 26,
//         height: 28,
//         decoration: BoxDecoration(
//           color: isOccupied ? Colors.white10 : (isSelected ? Colors.cyanAccent : Colors.white24),
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(4)),
//           boxShadow: isSelected
//               ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)]
//               : [],
//         ),
//         child: Center(
//           child: Text(
//             "${seat.seatNumber}",
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: isSelected ? Colors.black : Colors.white38,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildScreenCurve() {
//     return Column(
//       children: [
//         Container(
//           width: 280,
//           height: 4,
//           decoration: BoxDecoration(
//             color: Colors.cyanAccent,
//             boxShadow: [
//               BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 25, spreadRadius: 8),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           "STAGE / SCREEN",
//           style: TextStyle(color: Colors.cyanAccent, fontSize: 10, letterSpacing: 5),
//         ),
//       ],
//     );
//   }

//   Widget _buildGlassPurchasePanel() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.05),
//             border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Выбрано: ${selectedSeats.length}", style: const TextStyle(color: Colors.white70)),
//                   Text(
//                     "\$${selectedSeats.length * 12.5}",
//                     style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               ElevatedButton(
//                 onPressed: selectedSeats.isEmpty ? null : () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.cyanAccent,
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text("КУПИТЬ", style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// --- МОДЕЛИ ДАННЫХ ---

enum ObjectType { zone, table, wall, stage }

class HallObject {
  final String id;
  final String name;
  final ObjectType type;
  final Offset position;
  final double rotation; // в радианах
  final int floor;
  final dynamic data; // Специфичные данные для каждого типа

  HallObject({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.rotation = 0,
    required this.floor,
    this.data,
  });
}

// --- ОСНОВНАЯ СТРАНИЦА ---

class AdvancedHallPage extends StatefulWidget {
  const AdvancedHallPage({super.key});

  @override
  State<AdvancedHallPage> createState() => _AdvancedHallPageState();
}

class _AdvancedHallPageState extends State<AdvancedHallPage> {
  int currentFloor = 1;
  List<String> selectedSeats = [];
  final TransformationController _transformationController = TransformationController();

  // Имитация базы данных объектов
  late List<HallObject> hallObjects;

  @override
  void initState() {
    super.initState();
    _setupMockData();
    // Начальный зум
    _transformationController.value = Matrix4.identity()
      ..translate(-200.0, 0.0)
      ..scale(0.8);
  }

  void _setupMockData() {
    hallObjects = [
      // ЭТАЖ 1: Сцена и Партер
      HallObject(
        id: 'stage_1',
        name: 'Главная сцена',
        type: ObjectType.stage,
        position: const Offset(800, 100),
        floor: 1,
        data: {"width": 400.0, "height": 60.0},
      ),
      HallObject(
        id: 'wall_left',
        name: 'Стена левая',
        type: ObjectType.wall,
        position: const Offset(550, 100),
        floor: 1,
        data: {"width": 10.0, "height": 600.0},
      ),
      HallObject(
        id: 'main_zone',
        name: 'Партер',
        type: ObjectType.zone,
        position: const Offset(800, 250),
        floor: 1,
        data: {"rows": 6, "seatsPerRow": 12, "color": Colors.orangeAccent},
      ),
      // ЭТАЖ 2: VIP Столы и Бар
      HallObject(
        id: 'vip_table_1',
        name: 'VIP 1',
        type: ObjectType.table,
        position: const Offset(700, 400),
        floor: 2,
        data: {"seatCount": 6, "radius": 40.0, "color": Colors.purpleAccent},
      ),
      HallObject(
        id: 'vip_table_2',
        name: 'VIP 2',
        type: ObjectType.table,
        position: const Offset(900, 400),
        floor: 2,
        data: {"seatCount": 8, "radius": 50.0, "color": Colors.purpleAccent},
      ),
    ];
  }

  void toggleSeat(String id) {
    setState(() {
      selectedSeats.contains(id) ? selectedSeats.remove(id) : selectedSeats.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактор пространства"), actions: [_buildFloorPicker()]),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(1000),
            minScale: 0.1,
            maxScale: 2.0,
            child: Container(
              width: 2000,
              height: 2000,
              color: Colors.grey[50],
              child: Stack(
                children: hallObjects
                    .where((obj) => obj.floor == currentFloor)
                    .map((obj) => _buildObject(obj))
                    .toList(),
              ),
            ),
          ),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  // --- ГЕНЕРАТОР ВИДЖЕТОВ ---

  Widget _buildObject(HallObject obj) {
    return Positioned(
      left: obj.position.dx,
      top: obj.position.dy,
      child: Transform.rotate(angle: obj.rotation, child: _mapObjectToWidget(obj)),
    );
  }

  Widget _mapObjectToWidget(HallObject obj) {
    switch (obj.type) {
      case ObjectType.stage:
        return Container(
          width: obj.data['width'],
          height: obj.data['height'],
          decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
          child: const Center(
            child: Text("СЦЕНА", style: TextStyle(color: Colors.white)),
          ),
        );

      case ObjectType.wall:
        return Container(width: obj.data['width'], height: obj.data['height'], color: Colors.black26);

      case ObjectType.zone:
        return Column(
          children: [
            ...List.generate(
              obj.data['rows'],
              (r) => Row(
                children: List.generate(obj.data['seatsPerRow'], (s) {
                  String id = "${obj.id}_${r}_$s";
                  return _Seat(
                    isSelected: selectedSeats.contains(id),
                    color: obj.data['color'],
                    onTap: () => toggleSeat(id),
                  );
                }),
              ),
            ),
            Text(obj.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        );

      case ObjectType.table:
        return SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Сам стол
              CircleAvatar(
                radius: obj.data['radius'],
                backgroundColor: Colors.brown[300],
                child: Text(obj.name, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              // Стулья вокруг
              ...List.generate(obj.data['seatCount'], (i) {
                double angle = (2 * math.pi / obj.data['seatCount']) * i;
                double dist = obj.data['radius'] + 15;
                return Transform.translate(
                  offset: Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                  child: _Seat(
                    isSelected: selectedSeats.contains("${obj.id}_$i"),
                    color: obj.data['color'],
                    onTap: () => toggleSeat("${obj.id}_$i"),
                  ),
                );
              }),
            ],
          ),
        );
    }
  }

  Widget _buildFloorPicker() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [1, 2]
            .map(
              (f) => ChoiceChip(
                label: Text("$f Этаж"),
                selected: currentFloor == f,
                onSelected: (_) => setState(() => currentFloor = f),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoPanel() {
    if (selectedSeats.isEmpty) return const SizedBox();
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                "Выбрано объектов: ${selectedSeats.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton(onPressed: () {}, child: const Text("Забронировать")),
            ],
          ),
        ),
      ),
    );
  }
}

class _Seat extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _Seat({required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : color.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.deepOrange : color, width: 2),
        ),
      ),
    );
  }
}

class CinemaUiPage extends StatefulWidget {
  const CinemaUiPage({super.key});

  @override
  State<CinemaUiPage> createState() => _CinemaUiPageState();
}

class _CinemaUiPageState extends State<CinemaUiPage> {
  List<String> selectedSeats = [];

  // Пример данных зала
  final List<List<int>> seatLayout = [
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0], // 0 - проход, 1 - обычное
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 2, 2, 0, 0, 2, 2, 0, 0], // 2 - VIP (диваны)
  ];

  void _onSeatTap(String id) {
    setState(() {
      selectedSeats.contains(id) ? selectedSeats.remove(id) : selectedSeats.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Глубокий черный
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white),
        title: const Column(
          children: [
            Text(
              "Дюна: Часть вторая",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("14 марта, 19:30 • Зал 4", style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          _buildScreen(), // Экран с подсветкой
          const SizedBox(height: 60),
          Expanded(child: InteractiveViewer(minScale: 0.5, maxScale: 2.0, child: _buildSeatingPlan())),
          _buildLegend(),
          _buildCheckoutPanel(),
        ],
      ),
    );
  }

  // Виджет Экрана
  Widget _buildScreen() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text("ЭКРАН", style: TextStyle(color: Colors.white24, letterSpacing: 8, fontSize: 10)),
      ],
    );
  }

  // Сетка мест
  Widget _buildSeatingPlan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(seatLayout.length, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(seatLayout[rowIndex].length, (colIndex) {
              int type = seatLayout[rowIndex][colIndex];
              if (type == 0) return const SizedBox(width: 35);

              String seatId = "$rowIndex-$colIndex";
              bool isSelected = selectedSeats.contains(seatId);
              bool isVip = type == 2;

              return GestureDetector(
                onTap: () => _onSeatTap(seatId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: isVip ? 70 : 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blueAccent
                        : (isVip ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white30
                          : (isVip ? Colors.amber.withOpacity(0.4) : Colors.white10),
                      width: 1,
                    ),
                  ),
                  child: isVip ? const Icon(Icons.king_bed, size: 16, color: Colors.amber) : null,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem("Свободно", const Color(0xFF1A1A1A)),
          const SizedBox(width: 20),
          _legendItem("Выбрано", Colors.blueAccent),
          const SizedBox(width: 20),
          _legendItem("VIP", const Color(0xFF2A2A2A), borderColor: Colors.amber),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor ?? Colors.transparent),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Итого", style: TextStyle(color: Colors.white54)),
                Text(
                  "${selectedSeats.length * 2500} ₸",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: selectedSeats.isEmpty ? null : () {},
                child: const Text("Купить билеты", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VenueConstructorApp extends StatefulWidget {
  const VenueConstructorApp({super.key});

  @override
  State<VenueConstructorApp> createState() => _VenueConstructorAppState();
}

class _VenueConstructorAppState extends State<VenueConstructorApp> {
  int activeFloor = 1;
  final Set<String> selectedIds = {};

  // Пример цен
  final Map<String, double> prices = {'seat': 500, 'vip': 2000, 'table': 1500};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Глубокий темный
      body: Stack(
        children: [
          // 1. Основной холст с зумом
          InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(1500),
            minScale: 0.1,
            maxScale: 2.0,
            child: _buildVenueCanvas(),
          ),

          // 2. Верхняя панель управления
          _buildTopPanel(),

          // 3. Боковой легенда-информатор
          _buildLegend(),

          // 4. Нижний чек-аут
          _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildVenueCanvas() {
    return Container(
      width: 2000,
      height: 2000,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        image: DecorationImage(
          image: NetworkImage(
            'https://www.transparenttextures.com/patterns/carbon-fibre.png',
          ), // Текстура пола
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ),
      ),
      child: Stack(children: activeFloor == 1 ? _buildFirstFloor() : _buildSecondFloor()),
    );
  }

  // --- СЛОЙ ЭТАЖ 1: КИНОКОНЦЕРТНЫЙ ЗАЛ ---
  List<Widget> _buildFirstFloor() {
    return [
      // Стены здания
      _Wall(x: 400, y: 100, w: 1200, h: 20, label: "Outer Wall"),
      _Wall(x: 400, y: 100, w: 20, h: 800, label: ''),
      _Wall(x: 1580, y: 100, w: 20, h: 800, label: ''),

      // Сцена / Экран с неоновым свечением
      Positioned(
        top: 150,
        left: 600,
        child: Container(
          width: 800,
          height: 15,
          decoration: BoxDecoration(
            color: Colors.cyanAccent,
            boxShadow: [
              BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: const Center(
            child: Text("SCREEN / STAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      ),

      // Ряды кресел (Сектор А)
      Positioned(top: 300, left: 550, child: _buildSeatingBlock("A", 10, 16)),

      // VIP Зоны по бокам
      _buildVipBox("VIP 1", 450, 400),
      _buildVipBox("VIP 2", 1450, 400),
    ];
  }

  // --- СЛОЙ ЭТАЖ 2: ЛАУНЖ-БАР И КЛУБ ---
  List<Widget> _buildSecondFloor() {
    return [
      // Стены
      _Wall(x: 300, y: 100, w: 1400, h: 15, label: ''),

      // Барная стойка (Интерьерный объект)
      _buildBarCounter(700, 200),

      // Танцпол
      Positioned(
        top: 400,
        left: 700,
        child: Container(
          width: 600,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
            gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.1)]),
          ),
          child: const Center(
            child: Text("DANCE FLOOR", style: TextStyle(color: Colors.white24)),
          ),
        ),
      ),

      // Столики для продажи
      _buildTableGroup("T1", 400, 300, 4),
      _buildTableGroup("T2", 400, 500, 6),
      _buildTableGroup("T3", 1400, 300, 4),
      _buildTableGroup("T4", 1400, 500, 8),
    ];
  }

  // --- КОМПОНЕНТЫ КОНСТРУКТОРА ---

  Widget _buildSeatingBlock(String sector, int rows, int cols) {
    return Column(
      children: List.generate(
        rows,
        (r) => Row(
          children: List.generate(cols, (c) {
            String id = "$sector-R$r-C$c";
            return _InteractivePoint(
              id: id,
              isSelected: selectedIds.contains(id),
              onTap: () => _toggleSelection(id),
              color: Colors.blueGrey,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTableGroup(String id, double x, double y, int seats) {
    return Positioned(
      left: x,
      top: y,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Стол (Визуал)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.brown[800],
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5)],
            ),
            child: Center(
              child: Text(id, style: const TextStyle(fontSize: 10, color: Colors.white60)),
            ),
          ),
          // Места вокруг стола (Продажа)
          ...List.generate(seats, (i) {
            double angle = (2 * math.pi / seats) * i;
            String sId = "$id-S$i";
            return Transform.translate(
              offset: Offset(math.cos(angle) * 45, math.sin(angle) * 45),
              child: _InteractivePoint(
                id: sId,
                isSelected: selectedIds.contains(sId),
                onTap: () => _toggleSelection(sId),
                color: Colors.orangeAccent,
                size: 18,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBarCounter(double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: Column(
        children: [
          Container(
            width: 600,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text("MAIN BAR", style: TextStyle(color: Colors.white38)),
            ),
          ),
          const SizedBox(height: 5),
          // Места у бара
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              15,
              (i) => _InteractivePoint(
                id: "Bar-$i",
                isSelected: selectedIds.contains("Bar-$i"),
                onTap: () => _toggleSelection("Bar-$i"),
                color: Colors.amber,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipBox(String name, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
          color: Colors.amber.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(name, style: const TextStyle(color: Colors.amber, fontSize: 10)),
            _InteractivePoint(
              id: name,
              isSelected: selectedIds.contains(name),
              onTap: () => _toggleSelection(name),
              color: Colors.amber,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  // --- ЛОГИКА ---
  void _toggleSelection(String id) {
    setState(() {
      if (!selectedIds.remove(id)) selectedIds.add(id);
    });
  }

  // --- ИНТЕРФЕЙС УПРАВЛЕНИЯ ---
  Widget _buildTopPanel() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(30)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [1, 2]
                .map(
                  (f) => GestureDetector(
                    onTap: () => setState(() => activeFloor = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: activeFloor == f ? Colors.blueAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text("Этаж $f", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      right: 20,
      top: 100,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: Colors.blueGrey, text: "Стандарт"),
            _LegendItem(color: Colors.orangeAccent, text: "За столиком"),
            _LegendItem(color: Colors.amber, text: "VIP"),
            _LegendItem(color: Colors.cyanAccent, text: "Сцена / Бар"),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ВЫБРАНО: ${selectedIds.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "ИТОГО: \$${selectedIds.length * 500}",
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "ОФОРМИТЬ",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Вспомогательные микро-виджеты
class _Wall extends StatelessWidget {
  final double x, y, w, h;
  final String label;
  const _Wall({required this.x, required this.y, required this.w, required this.h, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
        ),
      ),
    );
  }
}

class _InteractivePoint extends StatelessWidget {
  final String id;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _InteractivePoint({
    required this.id,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(size / 4),
          border: Border.all(color: isSelected ? Colors.white : color, width: 1.5),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.greenAccent, blurRadius: 10)] : null,
        ),
        child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
