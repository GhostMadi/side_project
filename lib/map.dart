// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart' as fsvg;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class SnapshotterExample extends StatefulWidget {
//   const SnapshotterExample({super.key});

//   @override
//   State<SnapshotterExample> createState() => SnapshotterExampleState();
// }

// class SnapshotterExampleState extends State<SnapshotterExample> {
//   MapboxMap? mapboxMap;
//   bool _styleReady = false;
//   bool _is3D = false;

//   static const _srcId = 'places';
//   static const _imgFood = 'img_food';
//   static const _imgCoffee = 'img_coffee';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: MapWidget(
//               styleUri: MapboxStyles.STANDARD,
//               cameraOptions: CameraOptions(
//                 center: Point(coordinates: Position(76.80, 43.20)),
//                 zoom: 14,
//               ),
//               onMapCreated: (map) => mapboxMap = map,
//               onStyleLoadedListener: (_) async {
//                 if (_styleReady) return;
//                 _styleReady = true;

//                 await _addSvgImagesToStyle();
//                 await _addMarkers();
//               },
//             ),
//           ),

//           /// 🔥 3D BUTTON
//           Positioned(
//             right: 16,
//             bottom: 24,
//             child: _ThreeDButton(onPressed: _toggle3D),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // 3D TOGGLE
//   // ---------------------------------------------------------------------------

//   Future<void> _toggle3D() async {
//     if (mapboxMap == null) return;

//     final camera = await mapboxMap!.getCameraState();
//     _is3D = !_is3D;

//     await mapboxMap!.setCamera(
//       CameraOptions(
//         pitch: _is3D ? 60.0 : 0.0,
//         bearing: _is3D ? (camera.bearing ?? 0.0) : 0.0,
//         zoom: camera.zoom,
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // SVG → PNG → Mapbox Image
//   // ---------------------------------------------------------------------------

//   Future<void> _addSvgImagesToStyle() async {
//     final style = mapboxMap!.style;

//     await _addSvgAssetAsStyleImage(
//       style: style,
//       imageId: _imgFood,
//       assetPath: 'assets/svg/YetY.svg',
//       logicalSize: 28,
//     );

//     await _addSvgAssetAsStyleImage(
//       style: style,
//       imageId: _imgCoffee,
//       assetPath: 'assets/svg/YetY.svg',
//       logicalSize: 28,
//     );
//   }

//   Future<void> _addSvgAssetAsStyleImage({
//     required StyleManager style,
//     required String imageId,
//     required String assetPath,
//     required int logicalSize,
//   }) async {
//     if (await style.hasStyleImage(imageId)) return;

//     final dpr = MediaQuery.of(context).devicePixelRatio;
//     final px = math.max(1, (logicalSize * dpr).round());

//     final pictureInfo = await fsvg.vg.loadPicture(
//       fsvg.SvgAssetLoader(assetPath),
//       context,
//     );

//     final ui.Image image = await _rasterizeToSquare(
//       pictureInfo.picture,
//       pictureInfo.size,
//       px,
//     );

//     pictureInfo.picture.dispose();

//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     image.dispose();

//     final Uint8List pngBytes = byteData!.buffer.asUint8List();

//     final mbxImage = MbxImage(width: px, height: px, data: pngBytes);

//     await style.addStyleImage(
//       imageId,
//       dpr,
//       mbxImage,
//       false,
//       const [],
//       const [],
//       null,
//     );
//   }

//   Future<ui.Image> _rasterizeToSquare(
//     ui.Picture picture,
//     ui.Size srcSize,
//     int px,
//   ) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = ui.Canvas(recorder);

//     final w = srcSize.width == 0 ? 1.0 : srcSize.width;
//     final h = srcSize.height == 0 ? 1.0 : srcSize.height;

//     final scale = math.min(px / w, px / h);
//     final dx = (px - w * scale) / 2;
//     final dy = (px - h * scale) / 2;

//     canvas.translate(dx, dy);
//     canvas.scale(scale, scale);
//     canvas.drawPicture(picture);

//     final pictureOut = recorder.endRecording();
//     final image = await pictureOut.toImage(px, px);
//     pictureOut.dispose();
//     return image;
//   }

//   // ---------------------------------------------------------------------------
//   // MARKERS + CLUSTERS
//   // ---------------------------------------------------------------------------

//   Future<void> _addMarkers() async {
//     final style = mapboxMap!.style;

//     await _safeRemove(style.removeStyleLayer, 'clusters');
//     await _safeRemove(style.removeStyleLayer, 'cluster-count');
//     await _safeRemove(style.removeStyleLayer, 'unclustered-circle');
//     await _safeRemove(style.removeStyleLayer, 'unclustered-icon');
//     await _safeRemove(style.removeStyleSource, _srcId);

//     final features = List.generate(1000, (i) {
//       return {
//         "type": "Feature",
//         "geometry": {
//           "type": "Point",
//           "coordinates": [76.80 + (i % 40) * 0.002, 43.20 + (i ~/ 40) * 0.002],
//         },
//         "properties": {"icon": i.isEven ? _imgFood : _imgCoffee},
//       };
//     });

//     await style.addStyleSource(
//       _srcId,
//       jsonEncode({
//         "type": "geojson",
//         "data": {"type": "FeatureCollection", "features": features},
//         "cluster": true,
//         "clusterRadius": 50,
//       }),
//     );

//     await style.addStyleLayer(
//       jsonEncode({
//         "id": "clusters",
//         "type": "circle",
//         "source": _srcId,
//         "filter": ["has", "point_count"],
//         "paint": {"circle-color": "#4E7CF2", "circle-radius": 22},
//       }),
//       null,
//     );

//     await style.addStyleLayer(
//       jsonEncode({
//         "id": "cluster-count",
//         "type": "symbol",
//         "source": _srcId,
//         "filter": ["has", "point_count"],
//         "layout": {"text-field": "{point_count_abbreviated}", "text-size": 12},
//         "paint": {"text-color": "#ffffff"},
//       }),
//       null,
//     );

//     await style.addStyleLayer(
//       jsonEncode({
//         "id": "unclustered-circle",
//         "type": "circle",
//         "source": _srcId,
//         "filter": [
//           "!",
//           ["has", "point_count"],
//         ],
//         "paint": {"circle-color": "#ffffff", "circle-radius": 16},
//       }),
//       null,
//     );

//     await style.addStyleLayer(
//       jsonEncode({
//         "id": "unclustered-icon",
//         "type": "symbol",
//         "source": _srcId,
//         "filter": [
//           "!",
//           ["has", "point_count"],
//         ],
//         "layout": {
//           "icon-image": ["get", "icon"],
//           "icon-size": 1.0,
//           "icon-allow-overlap": true,
//         },
//       }),
//       null,
//     );
//   }

//   Future<void> _safeRemove(
//     Future<void> Function(String id) remover,
//     String id,
//   ) async {
//     try {
//       await remover(id);
//     } catch (_) {}
//   }
// }

// // -----------------------------------------------------------------------------
// // 3D BUTTON WIDGET
// // -----------------------------------------------------------------------------

// class _ThreeDButton extends StatefulWidget {
//   final VoidCallback onPressed;

//   const _ThreeDButton({required this.onPressed});

//   @override
//   State<_ThreeDButton> createState() => _ThreeDButtonState();
// }

// class _ThreeDButtonState extends State<_ThreeDButton> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _pressed = true),
//       onTapUp: (_) {
//         setState(() => _pressed = false);
//         widget.onPressed();
//       },
//       onTapCancel: () => setState(() => _pressed = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 120),
//         curve: Curves.easeOut,
//         width: 56,
//         height: 56,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: _pressed
//                 ? [const Color(0xFF2C6AF6), const Color(0xFF1F4ED8)]
//                 : [const Color(0xFF4E7CF2), const Color(0xFF2C5CF6)],
//           ),
//           boxShadow: _pressed
//               ? [
//                   const BoxShadow(
//                     color: Colors.black26,
//                     offset: Offset(0, 2),
//                     blurRadius: 4,
//                   ),
//                 ]
//               : [
//                   const BoxShadow(
//                     color: Colors.black38,
//                     offset: Offset(0, 10),
//                     blurRadius: 20,
//                   ),
//                   const BoxShadow(
//                     color: Colors.white24,
//                     offset: Offset(-4, -4),
//                     blurRadius: 8,
//                   ),
//                 ],
//         ),
//         child: const Icon(Icons.threed_rotation, color: Colors.white, size: 28),
//       ),
//     );
//   }
// }
