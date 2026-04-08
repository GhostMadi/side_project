import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return SpaceConstructorPage();
  }
}

class SpaceApp extends StatelessWidget {
  const SpaceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const SpaceConstructorPage(),
  );
}

class ZoneData {
  Offset position;
  Size size;
  bool isSelected;

  ZoneData({required this.position, required this.size, this.isSelected = false});
}

class SpaceConstructorPage extends StatefulWidget {
  const SpaceConstructorPage({super.key});
  @override
  State<SpaceConstructorPage> createState() => _SpaceConstructorPageState();
}

class _SpaceConstructorPageState extends State<SpaceConstructorPage> {
  final List<ZoneData> _zones = [];
  final TransformationController _transformationController = TransformationController();

  // Огромный размер холста
  final double worldSize = 10000.0;

  @override
  void initState() {
    super.initState();
    // Фокусируемся примерно в центре
    _transformationController.value = Matrix4.identity()
      ..translate(-worldSize / 2 + 500, -worldSize / 2 + 400);
  }

  void _addZone() {
    setState(() {
      for (var z in _zones) {
        z.isSelected = false;
      }

      // Находим центр текущего экрана пользователя
      final viewportCenter = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      final inverse = Matrix4.inverted(_transformationController.value);
      final canvasCenter = MatrixUtils.transformPoint(inverse, viewportCenter);

      _zones.add(
        ZoneData(
          position: canvasCenter - const Offset(400, 300),
          size: const Size(800, 600),
          isSelected: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0D0D0),
      body: Stack(
        children: [
          // 1. ОГРОМНОЕ ПОЛЕ
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.05,
            maxScale: 2.0,
            child: GestureDetector(
              onTap: () => setState(() {
                for (var z in _zones) {
                  z.isSelected = false;
                }
              }),
              child: Container(
                width: worldSize,
                height: worldSize,
                decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
                child: CustomPaint(
                  // Сетка рисуется через Painter для оптимизации
                  painter: GridAndZonesPainter(zones: _zones),
                ),
              ),
            ),
          ),

          // Интерактивные элементы управления (ручки) поверх холста
          ..._buildZoneControls(),

          // 2. ИНФО-ПАНЕЛЬ
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
              child: const Text(
                "РАБОЧАЯ ОБЛАСТЬ: 10,000 x 10,000",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

          // 3. HOTBAR
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Исправлено здесь
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xEE1A1A1A),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: _addZone,
                      label: const Text("СОЗДАТЬ ЗОНУ"),
                      icon: const Icon(Icons.add_box),
                      backgroundColor: Colors.blueAccent,
                    ),
                    if (_zones.any((z) => z.isSelected)) ...[
                      const SizedBox(width: 15),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 30),
                        onPressed: () => setState(() => _zones.removeWhere((z) => z.isSelected)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Создаем невидимые области для перетаскивания и изменения размера,
  // которые синхронизированы с InteractiveViewer
  List<Widget> _buildZoneControls() {
    return _zones.where((z) => z.isSelected).map((zone) {
      return AnimatedBuilder(
        animation: _transformationController,
        builder: (context, child) {
          final matrix = _transformationController.value;
          final double scale = matrix.getMaxScaleOnAxis();

          // Перевод координат холста в экранные координаты
          final screenPos = MatrixUtils.transformPoint(matrix, zone.position);
          final screenSize = zone.size * scale;

          return Stack(
            children: [
              // Перетаскивание всей зоны
              Positioned(
                left: screenPos.dx,
                top: screenPos.dy,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() => zone.position += d.delta / scale),
                  child: Container(
                    width: screenSize.width,
                    height: screenSize.height,
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Ручка изменения размера (Resize)
              Positioned(
                left: screenPos.dx + screenSize.width - 20,
                top: screenPos.dy + screenSize.height - 20,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() {
                    zone.size = Size(
                      (zone.size.width + d.delta.dx / scale).clamp(200, 5000),
                      (zone.size.height + d.delta.dy / scale).clamp(200, 5000),
                    );
                  }),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.open_in_full, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }).toList();
  }
}

// --- ОТРИСОВКА СЕТКИ И ЗОН ---
class GridAndZonesPainter extends CustomPainter {
  final List<ZoneData> zones;
  GridAndZonesPainter({required this.zones});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1.0;

    // Рисуем сетку (шаг 200)
    for (double i = 0; i <= size.width; i += 200) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i <= size.height; i += 200) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Рисуем зоны
    for (var zone in zones) {
      final rect = zone.position & zone.size;
      final zonePaint = Paint()
        ..color = zone.isSelected ? Colors.blue.withOpacity(0.15) : Colors.blue.withOpacity(0.05)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = zone.isSelected ? Colors.blue : Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = zone.isSelected ? 4 : 2;

      canvas.drawRect(rect, zonePaint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
