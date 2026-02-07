import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/feature/example.dart';

@RoutePage()
class AdminEditorPage extends StatefulWidget {
  const AdminEditorPage({super.key});

  @override
  State<AdminEditorPage> createState() => _AdminEditorPageState();
}

class _AdminEditorPageState extends State<AdminEditorPage> {
  Map<String, dynamic> editingHall = {"hallName": "New Venue", "zones": []};
  int? selectedZoneIndex;
  final bool _isPanelHovered = false; // Для эффекта прозрачности

  void _addNewZone() {
    setState(() {
      final newId = "zone_${DateTime.now().millisecondsSinceEpoch}";
      editingHall['zones'].add({
        "id": newId,
        "name": "Секция ${editingHall['zones'].length + 1}",
        "price": "0",
        "color": "0xFFE0E0E0",
        "position": {"x": 0.0, "y": 300.0},
        "rotation": 0.0,
        "rows": [
          {"rowId": "1", "seatCount": 10, "offset": 0.0},
        ],
      });
      selectedZoneIndex = editingHall['zones'].length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. СХЕМА НА ВЕСЬ ЭКРАН
          Positioned.fill(
            child: UniversalHallWidget(
              hallData: editingHall,
              selectedSeats: const [],
              onSeatTap: (id) {
                final zoneId = id.split('_').first;
                setState(() {
                  selectedZoneIndex = editingHall['zones'].indexWhere((z) => z['id'] == zoneId);
                });
              },
            ),
          ),

          // 2. ВЕРХНИЕ ИНСТРУМЕНТЫ (Компактные)
          _buildMinimalTopBar(),

          // 3. ПЛАВАЮЩИЙ ИНСПЕКТОР (Умный дизайн)
          if (selectedZoneIndex != null) _buildFloatingInspector(),
        ],
      ),
    );
  }

  Widget _buildMinimalTopBar() {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionBtn(Icons.add_location_alt, "Добавить", _addNewZone),
          _actionBtn(Icons.save_outlined, "Save JSON", () => print(editingHall)),
        ],
      ),
    );
  }

  Widget _buildFloatingInspector() {
    var zone = editingHall['zones'][selectedZoneIndex!];
    return AdminVenueEditor();
    // return Positioned(
    //   right: 20,
    //   top: 120,
    //   child: MouseRegion(
    //     onEnter: (_) => setState(() => _isPanelHovered = true),
    //     onExit: (_) => setState(() => _isPanelHovered = false),
    //     child: AnimatedOpacity(
    //       duration: const Duration(milliseconds: 300),
    //       opacity: _isPanelHovered ? 1.0 : 0.6, // Панель затухает, когда не нужна
    //       child: Container(
    //         width: 280,
    //         constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(20),
    //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
    //           border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
    //         ),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             _inspectorHeader(zone),
    //             Flexible(
    //               child: ListView(
    //                 shrinkWrap: true,
    //                 padding: const EdgeInsets.all(16),
    //                 children: [
    //                   _compactInput("Название", zone['name'], (v) => zone['name'] = v),
    //                   const SizedBox(height: 15),
    //                   _tinyLabel("ПОЗИЦИЯ (X / Y / УГОЛ)"),
    //                   _controlRow([
    //                     _numInp("X", zone['position']['x'], (v) => zone['position']['x'] = v),
    //                     _numInp("Y", zone['position']['y'], (v) => zone['position']['y'] = v),
    //                     _numInp("°", zone['rotation'], (v) => zone['rotation'] = v),
    //                   ]),
    //                   const SizedBox(height: 15),
    //                   _tinyLabel("РЯДЫ"),
    //                   ...List.generate(zone['rows'].length, (i) => _rowItem(zone, i)),
    //                   const SizedBox(height: 10),
    //                   TextButton.icon(
    //                     onPressed: () => setState(
    //                       () => zone['rows'].add({
    //                         "rowId": "${zone['rows'].length + 1}",
    //                         "seatCount": 10,
    //                         "offset": 0.0,
    //                       }),
    //                     ),
    //                     icon: const Icon(Icons.add, size: 16),
    //                     label: const Text("Добавить ряд", style: TextStyle(fontSize: 12)),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  // --- МИНИ-ВИДЖЕТЫ ДЛЯ UX ---

  Widget _inspectorHeader(Map zone) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.blueAccent.withOpacity(0.05),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "EDIT ZONE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueAccent),
        ),
        GestureDetector(
          onTap: () => setState(() => selectedZoneIndex = null),
          child: const Icon(Icons.close, size: 18),
        ),
      ],
    ),
  );

  Widget _controlRow(List<Widget> children) => Row(
    children: children
        .map(
          (w) => Expanded(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: w),
          ),
        )
        .toList(),
  );

  Widget _numInp(String label, dynamic val, Function(double) onCh) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      TextField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11),
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
        onChanged: (v) => setState(() => onCh(double.tryParse(v) ?? 0.0)),
      ),
    ],
  );

  Widget _rowItem(Map zone, int index) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        Text("R${index + 1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const Spacer(),
        _tinyInp(
          "${zone['rows'][index]['seatCount']}",
          (v) => zone['rows'][index]['seatCount'] = int.tryParse(v) ?? 0,
        ),
        IconButton(
          onPressed: () => setState(() => zone['rows'].removeAt(index)),
          icon: const Icon(Icons.remove_circle_outline, size: 14, color: Colors.red),
        ),
      ],
    ),
  );

  Widget _tinyInp(String val, Function(String) onCh) => SizedBox(
    width: 40,
    child: TextField(
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10),
      decoration: const InputDecoration(isDense: true),
      onChanged: onCh,
    ),
  );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label, style: const TextStyle(fontSize: 12)),
    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );

  Widget _compactInput(String label, String val, Function(String) onCh) => TextField(
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontSize: 11)),
    style: const TextStyle(fontSize: 13),
    onChanged: onCh,
  );

  Widget _tinyLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
    ),
  );
}

// --- МОДЕЛИ ДАННЫХ ---
enum ElementType { wall, table, seatBlock, bar }

class EditorElement {
  String id;
  ElementType type;
  Offset position;
  double width;
  double height;
  int property; // Кол-во мест для стола или рядов для блока кресел

  EditorElement({
    required this.id,
    required this.type,
    required this.position,
    this.width = 100,
    this.height = 20,
    this.property = 4,
  });
}

class AdminVenueEditor extends StatefulWidget {
  const AdminVenueEditor({super.key});

  @override
  State<AdminVenueEditor> createState() => _AdminVenueEditorState();
}

class _AdminVenueEditorState extends State<AdminVenueEditor> {
  List<EditorElement> canvasElements = [];
  EditorElement? selectedElement;
  bool isGridEnabled = true;
  double gridSize = 20.0;

  void _addElement(ElementType type) {
    setState(() {
      final newEl = EditorElement(
        id: "ID-${DateTime.now().millisecondsSinceEpoch}",
        type: type,
        position: const Offset(100, 100),
        width: type == ElementType.wall ? 200 : 60,
        height: type == ElementType.wall ? 20 : 60,
      );
      canvasElements.add(newEl);
      selectedElement = newEl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Row(
        children: [
          _buildInventory(), // Инвентарь слева
          Expanded(
            child: Stack(
              children: [
                _buildEditorCanvas(), // Рабочая область
                if (selectedElement != null) _buildPropertyPanel(), // Свойства справа
                _buildTopToolbar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ИНВЕНТАРЬ ---
  Widget _buildInventory() {
    return Container(
      width: 100,
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 50),
          _inventoryItem(Icons.crop_16_9, "Wall", ElementType.wall),
          _inventoryItem(Icons.circle, "Table", ElementType.table),
          _inventoryItem(Icons.grid_3x3, "Seats", ElementType.seatBlock),
          _inventoryItem(Icons.rectangle, "Bar", ElementType.bar),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => setState(() {
              canvasElements.clear();
              selectedElement = null;
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _inventoryItem(IconData icon, String label, ElementType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: InkWell(
        onTap: () => _addElement(type),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 30),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // --- ХОЛСТ РЕДАКТОРА ---
  Widget _buildEditorCanvas() {
    return GestureDetector(
      onTap: () => setState(() => selectedElement = null),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.5,
        maxScale: 2.0,
        child: Container(
          width: 2000,
          height: 2000,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            image: isGridEnabled
                ? const DecorationImage(
                    image: NetworkImage('https://www.transparenttextures.com/patterns/grid-me.png'),
                    repeat: ImageRepeat.repeat,
                    opacity: 0.2,
                  )
                : null,
          ),
          child: Stack(children: canvasElements.map((el) => _buildDraggableElement(el)).toList()),
        ),
      ),
    );
  }

  Widget _buildDraggableElement(EditorElement el) {
    bool isSelected = selectedElement?.id == el.id;

    return Positioned(
      left: el.position.dx,
      top: el.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            selectedElement = el;
            double newX = el.position.dx + details.delta.dx;
            double newY = el.position.dy + details.delta.dy;

            // Привязка к сетке
            if (isGridEnabled) {
              newX = (newX / gridSize).round() * gridSize;
              newY = (newY / gridSize).round() * gridSize;
            }
            el.position = Offset(newX, newY);
          });
        },
        onTap: () => setState(() => selectedElement = el),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: Colors.blueAccent, width: 2) : null,
            boxShadow: isSelected ? [const BoxShadow(color: Colors.blueAccent, blurRadius: 10)] : null,
          ),
          child: _renderElementByType(el),
        ),
      ),
    );
  }

  Widget _renderElementByType(EditorElement el) {
    switch (el.type) {
      case ElementType.wall:
        return Container(width: el.width, height: el.height, color: Colors.white24);
      case ElementType.table:
        return _TableWidget(property: el.property);
      case ElementType.seatBlock:
        return _SeatBlockWidget(property: el.property);
      case ElementType.bar:
        return Container(
          width: 150,
          height: 40,
          decoration: BoxDecoration(color: Colors.brown, borderRadius: BorderRadius.circular(4)),
          child: const Center(child: Text("BAR", style: TextStyle(fontSize: 9))),
        );
    }
  }

  // --- ПАНЕЛЬ СВОЙСТВ ---
  Widget _buildPropertyPanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 200,
        color: Colors.black87,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PROPERTIES",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24),
            Text("Type: ${selectedElement!.type.name}", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            const Text("Sub-elements:", style: TextStyle(color: Colors.white54, fontSize: 12)),
            Slider(
              value: selectedElement!.property.toDouble(),
              min: 1,
              max: 20,
              onChanged: (val) => setState(() => selectedElement!.property = val.toInt()),
            ),
            Text("Count: ${selectedElement!.property}", style: const TextStyle(color: Colors.white)),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => setState(() {
                canvasElements.remove(selectedElement);
                selectedElement = null;
              }),
              child: const Text("Delete Object"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopToolbar() {
    return Positioned(
      top: 20,
      left: 120,
      child: Row(
        children: [
          _toolButton(Icons.grid_on, () => setState(() => isGridEnabled = !isGridEnabled)),
          const SizedBox(width: 10),
          _toolButton(Icons.save, () {
            // Здесь можно добавить экспорт в JSON
            print("Layout Saved!");
          }),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: Colors.black87,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

// --- ВИЗУАЛЬНЫЕ КОМПОНЕНТЫ ---

class _TableWidget extends StatelessWidget {
  final int property;
  const _TableWidget({required this.property});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle),
        ),
        ...List.generate(property, (i) {
          double angle = (2 * math.pi / property) * i;
          return Transform.translate(
            offset: Offset(math.cos(angle) * 30, math.sin(angle) * 30),
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            ),
          );
        }),
      ],
    );
  }
}

class _SeatBlockWidget extends StatelessWidget {
  final int property;
  const _SeatBlockWidget({required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        property,
        (r) => Row(
          children: List.generate(
            8,
            (c) => Container(
              margin: const EdgeInsets.all(1),
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
      ),
    );
  }
}
