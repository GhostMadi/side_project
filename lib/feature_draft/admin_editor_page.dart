import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AdminEditorPage extends StatefulWidget {
  const AdminEditorPage({super.key});

  @override
  State<AdminEditorPage> createState() => _AdminEditorPageState();
}

class _AdminEditorPageState extends State<AdminEditorPage> {
  @override
  Widget build(BuildContext context) {
    return const AdminVenueEditor();
  }
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
            debugPrint('Layout saved (draft)');
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
