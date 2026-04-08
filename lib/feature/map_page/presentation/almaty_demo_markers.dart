import 'package:side_project/core/shared/app_map.dart';

/// Демо-маркеры по территории Алматы (приблизительные координаты, равномерный «разброс»).
List<MapMarker> almatyDemoMarkers() {
  final markers = <MapMarker>[];

  const data = <({String id, double lat, double lng, String emoji})>[
    (id: 'alm_01', lat: 43.2385, lng: 76.9458, emoji: '🎉'),
    (id: 'alm_02', lat: 43.2552, lng: 76.9184, emoji: '🎵'),
    (id: 'alm_03', lat: 43.2210, lng: 76.9021, emoji: '🎭'),
    (id: 'alm_04', lat: 43.2063, lng: 76.8789, emoji: '🌳'),
    (id: 'alm_05', lat: 43.2318, lng: 76.8642, emoji: '⚽'),
    (id: 'alm_06', lat: 43.2489, lng: 76.8915, emoji: '🎨'),
    (id: 'alm_07', lat: 43.2641, lng: 76.9127, emoji: '🍜'),
    (id: 'alm_08', lat: 43.2725, lng: 76.9483, emoji: '☕'),
    (id: 'alm_09', lat: 43.2880, lng: 76.9310, emoji: '🎪'),
    (id: 'alm_10', lat: 43.3124, lng: 76.8975, emoji: '📍'),
    (id: 'alm_11', lat: 43.3348, lng: 76.9280, emoji: '🎸'),
    (id: 'alm_12', lat: 43.3485, lng: 77.0085, emoji: '🎬'),
    (id: 'alm_13', lat: 43.3180, lng: 77.0320, emoji: '🏃'),
    (id: 'alm_14', lat: 43.2673, lng: 77.0185, emoji: '🧘'),
    (id: 'alm_15', lat: 43.2412, lng: 77.0020, emoji: '🎤'),
    (id: 'alm_16', lat: 43.1985, lng: 76.9880, emoji: '🖼'),
    (id: 'alm_17', lat: 43.1680, lng: 76.9620, emoji: '🎿'),
    (id: 'alm_18', lat: 43.1520, lng: 76.9220, emoji: '🚌'),
    (id: 'alm_19', lat: 43.1605, lng: 76.8820, emoji: '🛍'),
    (id: 'alm_20', lat: 43.1755, lng: 76.8480, emoji: '🍕'),
    (id: 'alm_21', lat: 43.1920, lng: 76.8180, emoji: '🌿'),
    (id: 'alm_22', lat: 43.2160, lng: 76.8260, emoji: '🎈'),
    (id: 'alm_23', lat: 43.2280, lng: 76.7920, emoji: '📷'),
    (id: 'alm_24', lat: 43.2440, lng: 76.8150, emoji: '🎮'),
    (id: 'alm_25', lat: 43.2580, lng: 76.8680, emoji: '🎁'),
    (id: 'alm_26', lat: 43.2760, lng: 76.9050, emoji: '🌅'),
    (id: 'alm_27', lat: 43.2980, lng: 76.9600, emoji: '🏔'),
    (id: 'alm_28', lat: 43.3220, lng: 76.9750, emoji: '💃'),
    (id: 'alm_29', lat: 43.1850, lng: 76.9050, emoji: '🎊'),
    (id: 'alm_30', lat: 43.2090, lng: 76.9520, emoji: '🍹'),
  ];

  for (final r in data) {
    Map<String, dynamic>? meta;
    if (r.id == 'alm_01') {
      meta = {
        'organizerId': 'org_lumos',
        'organizerName': 'Lumos Coffee',
        'organizerCity': 'Алматы · Бостандык',
        'organizerAvatarUrl': 'https://picsum.photos/seed/lumos/200/200',
        'title': 'Джаз на террасе',
        'subtitle': 'Живая музыка · вход свободный при заказе напитка',
        'description':
            'Сегодня играем акустический сет. Успейте занять место у окна — вид на горы. '
            'Бронь не нужна, но в чате можем держать столик.',
        'startsAt': _isoTonight(19, 0),
        'venueLabel': 'пр. Абая, 150 (вход с торца)',
        'coverImageUrls': [
          'https://picsum.photos/seed/jazz1/800/450',
          'https://picsum.photos/seed/jazz2/800/450',
          'https://picsum.photos/seed/jazz3/800/450',
        ],
      };
    } else if (r.id == 'alm_05') {
      meta = {
        'organizerId': 'org_urban_yard',
        'organizerName': 'Urban Yard',
        'organizerCity': 'Алматы · Медеу',
        'title': 'Трансляция матча на большом экране',
        'subtitle': 'Компания · угощаем снеками первые столы',
        'description':
            'Собираемся посмотреть игру вместе. Закажите напитки у бармена — расскажут акцию дня.',
        'startsAt': _isoTonight(21, 30),
        'venueLabel': 'ул. Кабанбай батыра, 85',
        'coverImageUrls': [
          'https://picsum.photos/seed/sport1/800/450',
          'https://picsum.photos/seed/sport2/800/450',
          'https://picsum.photos/seed/sport3/800/450',
          'https://picsum.photos/seed/sport4/800/450',
        ],
      };
    } else if (r.id == 'alm_12') {
      meta = {
        'organizerId': 'org_wave',
        'organizerName': 'Wave Studio',
        'organizerCity': 'Алматы · Самал',
        'organizerAvatarUrl': 'https://picsum.photos/seed/wave/200/200',
        'title': 'Открытая встреча с бариста',
        'subtitle': 'Дегустация новых зёрен · 45 минут',
        'description':
            'Расскажем, откуда зерно и как готовим ваш любимый эспрессо. Для гостей — мини-сет напитков.',
        'startsAt': _isoTomorrow(17, 0),
        'venueLabel': 'мкр. Самал-2, 58а, 1 этаж',
        'coverImageUrls': [
          'https://picsum.photos/seed/coffee1/800/450',
          'https://picsum.photos/seed/coffee2/800/450',
        ],
      };
    }

    markers.add(MapMarker(id: r.id, lat: r.lat, lng: r.lng, emoji: r.emoji, metadata: meta));
  }

  return markers;
}

String _isoTonight(int hour, int minute) {
  final n = DateTime.now();
  var d = DateTime(n.year, n.month, n.day, hour, minute);
  if (d.isBefore(n)) {
    d = d.add(const Duration(days: 1));
  }
  return d.toUtc().toIso8601String();
}

String _isoTomorrow(int hour, int minute) {
  final n = DateTime.now().add(const Duration(days: 1));
  return DateTime(n.year, n.month, n.day, hour, minute).toUtc().toIso8601String();
}

/// Центр Алматы для начального положения камеры.
const double almatyCenterLat = 43.2400;
const double almatyCenterLng = 76.9150;
