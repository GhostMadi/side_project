import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage()
class TicketViewPage extends StatefulWidget {
  const TicketViewPage({super.key});

  @override
  State<TicketViewPage> createState() => _TicketViewPageState();
}

class _TicketViewPageState extends State<TicketViewPage> {
  // Имитация получения данных с бэкенда
  late UniversalEvent mockEvent;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    mockEvent = UniversalEvent(
      id: 'evt-1024',
      title: 'Interstellar: Live Symphony',
      type: EventType.concert,
      date: DateTime(2026, 2, 10),
      venue: 'Astana Opera',
      posterUrl:
          'https://img.freepik.com/premium-psd/action-movie-poster_1117895-529.jpg?semt=ais_hybrid&w=740',
      description:
          'Experience Hans Zimmer’s masterpiece performed by a full symphonic orchestra with immersive visual effects.',
      sessions: [
        Session(
          id: 'sess-1',
          startTime: DateTime(2026, 2, 10, 18, 30),
          contextLabel: 'Main Hall',
          ticketGroups: [
            TicketGroup(
              id: 'tg-std',
              name: 'Parterre Standard',
              accessType: AccessType.seat,
              price: 15000,
              totalCount: 100,
              soldCount: 85,
              reservedCount: 5,
              rules: const TicketRules(fewLeftThreshold: 15),
            ),
            TicketGroup(
              id: 'tg-vip',
              name: 'VIP Box',
              accessType: AccessType.seat,
              price: 45000,
              totalCount: 12,
              soldCount: 8,
              reservedCount: 0,
            ),
          ],
        ),
        Session(
          id: 'sess-2',
          startTime: DateTime(2026, 2, 10, 21, 00),
          contextLabel: 'Main Hall',
          ticketGroups: [
            TicketGroup(
              id: 'tg-late',
              name: 'Night Entry',
              accessType: AccessType.entry,
              price: 12000,
              totalCount: 50,
              soldCount: 10,
              reservedCount: 2,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Возвращаем универсальный виджет выбора билетов, передавая в него данные
    return TicketingSelectionPage(event: mockEvent);
  }
}

enum EventType { cinema, theater, concert, club, festival, custom }

enum AccessType { entry, zone, seat }

enum LayoutType { seatMap, zoneMap, simpleMap }

class VisualZone {
  final String id;
  final String label;
  final Color color;
  final String? description;

  VisualZone({required this.id, required this.label, required this.color, this.description});
}

class VisualLayout {
  final String id;
  final LayoutType type;
  final String imageUrl; // Map of the venue
  final List<VisualZone> zones;

  VisualLayout({required this.id, required this.type, required this.imageUrl, required this.zones});
}

class TicketRules {
  final bool disableAfterStart;
  final bool hideWhenSoldOut;
  final int fewLeftThreshold;
  final int maxPerUser;

  const TicketRules({
    this.disableAfterStart = true,
    this.hideWhenSoldOut = false,
    this.fewLeftThreshold = 10,
    this.maxPerUser = 6,
  });
}

class TicketGroup {
  final String id;
  final String name;
  final AccessType accessType;
  final double price;
  final String currency;
  final int totalCount;
  final int soldCount;
  final int reservedCount;
  final TicketRules rules;
  final String? visualZoneId;

  TicketGroup({
    required this.id,
    required this.name,
    required this.accessType,
    required this.price,
    this.currency = '₸',
    required this.totalCount,
    required this.soldCount,
    required this.reservedCount,
    this.rules = const TicketRules(),
    this.visualZoneId,
  });

  int get availableCount => totalCount - soldCount - reservedCount;
}

class Session {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String contextLabel;
  final List<TicketGroup> ticketGroups;
  final VisualLayout? layout;

  Session({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.contextLabel,
    required this.ticketGroups,
    this.layout,
  });

  bool get isExpired => DateTime.now().isAfter(startTime);
}

class UniversalEvent {
  final String id;
  final String title;
  final EventType type;
  final DateTime date;
  final String venue;
  final String description;
  final String posterUrl;
  final List<Session> sessions;

  UniversalEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.venue,
    required this.description,
    required this.posterUrl,
    required this.sessions,
  });
}

class TicketingSelectionPage extends StatefulWidget {
  final UniversalEvent event;
  const TicketingSelectionPage({super.key, required this.event});

  @override
  State<TicketingSelectionPage> createState() => _TicketingSelectionPageState();
}

class _TicketingSelectionPageState extends State<TicketingSelectionPage> {
  Session? _selectedSession;
  final Map<String, int> _selectedQuantities = {};
  Timer? _reservationTimer;
  int _secondsRemaining = 0;
  static const int reservationDuration = 600; // 10 minutes

  void _onSessionSelected(Session session) {
    if (session.isExpired) return;
    setState(() {
      _selectedSession = session;
      _selectedQuantities.clear();
      _stopReservation();
    });
  }

  void _updateTicketQuantity(TicketGroup group, int delta) {
    setState(() {
      final current = _selectedQuantities[group.id] ?? 0;
      final next = current + delta;

      if (next >= 0 && next <= group.availableCount && next <= group.rules.maxPerUser) {
        _selectedQuantities[group.id] = next;
        if (next > 0) _startReservation();
        if (_totalSelectedCount == 0) _stopReservation();
      }
    });
  }

  int get _totalSelectedCount => _selectedQuantities.values.fold(0, (a, b) => a + b);
  double get _totalPrice => _selectedQuantities.entries.fold(0, (sum, entry) {
    final group = _selectedSession!.ticketGroups.firstWhere((g) => g.id == entry.key);
    return sum + (group.price * entry.value);
  });

  void _startReservation() {
    if (_reservationTimer != null) return;
    _secondsRemaining = reservationDuration;
    _reservationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopReservation();
          _selectedQuantities.clear();
          _showExpirationDialog();
        }
      });
    });
  }

  void _stopReservation() {
    _reservationTimer?.cancel();
    _reservationTimer = null;
  }

  void _showExpirationDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Your ticket reservation has timed out."),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
      ),
    );
  }

  @override
  void dispose() {
    _reservationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSessionList(),
              if (_selectedSession != null) _buildTicketGroups(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          if (_totalSelectedCount > 0) _buildStickyBottomBar(),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(widget.event.posterUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(widget.event.venue, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.event.description, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Select Session", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: widget.event.sessions.length,
              itemBuilder: (context, index) {
                final session = widget.event.sessions[index];
                final isSelected = _selectedSession?.id == session.id;
                return GestureDetector(
                  onTap: () => _onSessionSelected(session),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(session.startTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          session.contextLabel,
                          style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketGroups() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final group = _selectedSession!.ticketGroups[index];
          final quantity = _selectedQuantities[group.id] ?? 0;
          final isFewLeft = group.availableCount > 0 && group.availableCount <= group.rules.fewLeftThreshold;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: quantity > 0 ? Colors.deepPurple : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          "${group.price.toInt()} ${group.currency}",
                          style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                        ),
                        if (isFewLeft)
                          Text(
                            "Only ${group.availableCount} left!",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (group.availableCount > 0)
                    _buildQuantityPicker(group, quantity)
                  else
                    const Text(
                      "SOLD OUT",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          );
        }, childCount: _selectedSession!.ticketGroups.length),
      ),
    );
  }

  Widget _buildQuantityPicker(TicketGroup group, int quantity) {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () => _updateTicketQuantity(group, -1), quantity > 0),
        SizedBox(
          width: 30,
          child: Center(
            child: Text("$quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        _qtyBtn(Icons.add, () => _updateTicketQuantity(group, 1), quantity < group.availableCount),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool enabled) {
    return IconButton.filledTonal(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: enabled ? Colors.deepPurple.shade50 : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    "Reserved for $minutes:$seconds",
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$_totalSelectedCount Tickets",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          "${_totalPrice.toInt()} ₸",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Pay Now", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
