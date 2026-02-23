import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PstPage extends StatefulWidget {
  const PstPage({super.key});

  @override
  State<PstPage> createState() => _PstPageState();
}

class _PstPageState extends State<PstPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

// // --- МОДЕЛИ ДАННЫХ ---
// class PostModel {
//   final String id;
//   final List<String> media;
//   final bool isVideo;

//   PostModel({required this.id, required this.media, this.isVideo = false});
// }

// // --- ОСНОВНАЯ СТРАНИЦА ПРОФИЛЯ ---
// class UniqueProfilePage extends StatefulWidget {
//   const UniqueProfilePage({super.key});

//   @override
//   State<UniqueProfilePage> createState() => _UniqueProfilePageState();
// }

// class _UniqueProfilePageState extends State<UniqueProfilePage> {
//   int? selectedStackIndex;
//   bool isFollowed = false;

//   final List<Map<String, dynamic>> stacks = [
//     {
//       'title': 'Travel',
//       'color': const Color(0xFF4A90E2),
//       'posts': List.generate(
//         9,
//         (i) => PostModel(id: 'tr_$i', media: ['https://picsum.photos/800?random=tr$i']),
//       ),
//     },
//     {
//       'title': 'Design',
//       'color': const Color(0xFFBD10E0),
//       'posts': List.generate(
//         6,
//         (i) => PostModel(id: 'ds_$i', media: ['https://picsum.photos/800?random=ds$i']),
//       ),
//     },
//     {
//       'title': 'Vibe',
//       'color': const Color(0xFF7ED321),
//       'posts': List.generate(
//         12,
//         (i) => PostModel(id: 'vb_$i', media: ['https://picsum.photos/800?random=vb$i']),
//       ),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(child: _buildCreativeHeader()),
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                   child: Text(
//                     "Collections",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 180,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     itemCount: stacks.length,
//                     itemBuilder: (context, index) => JellyStackItem(
//                       data: stacks[index],
//                       isSelected: selectedStackIndex == index,
//                       onTap: () => setState(() => selectedStackIndex = index),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Сетка 3 в ряд
//           if (selectedStackIndex != null)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(8, 20, 8, 40), // Уменьшенный паддинг
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3, // Три в ряд
//                   mainAxisSpacing: 4, // Плотная сетка
//                   crossAxisSpacing: 4,
//                   childAspectRatio: 1.0, // Квадратные кадры
//                 ),
//                 delegate: SliverChildBuilderDelegate((context, index) {
//                   final post = stacks[selectedStackIndex!]['posts'][index];
//                   return ScatterItem(key: ValueKey(post.id), post: post, index: index);
//                 }, childCount: stacks[selectedStackIndex!]['posts'].length),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCreativeHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 90,
//                 height: 90,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                   image: const DecorationImage(
//                     image: NetworkImage('https://picsum.photos/400?grayscale'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Expanded(
//                 child: Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _buildTagStat("1.2k", "Art"),
//                     _buildTagStat("45", "Folders"),
//                     _buildTagStat("8k", "Fans"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "ALEX_VISION",
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
//           ),
//           const Text(
//             "Visual Storyteller.\nCaptured through my lens.",
//             style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
//           ),
//           const SizedBox(height: 15),
//           _buildActionButtons(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTagStat(String value, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black.withOpacity(0.05)),
//       ),
//       child: Column(
//         children: [
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//           Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _JellyFollowButton(
//             isFollowed: isFollowed,
//             onPressed: () => setState(() => isFollowed = !isFollowed),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           height: 44,
//           width: 44,
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: const Icon(Icons.camera_alt_outlined, size: 20),
//         ),
//       ],
//     );
//   }
// }

// class ScatterItem extends StatefulWidget {
//   final int index;
//   final PostModel post;

//   const ScatterItem({super.key, required this.index, required this.post});

//   @override
//   State<ScatterItem> createState() => _ScatterItemState();
// }

// class _ScatterItemState extends State<ScatterItem> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
//     _scale = Tween<double>(
//       begin: 0.4,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
//     Future.delayed(Duration(milliseconds: widget.index * 40), () {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Условие стопки: если больше 1 медиа или видео
//     final bool showAsStack = widget.post.media.length > 1 || widget.post.isVideo;

//     return ScaleTransition(
//       scale: _scale,
//       child: GestureDetector(
//         onTap: () =>
//             Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: widget.post))),
//         child: Hero(
//           tag: widget.post.id,
//           child: Container(
//             // margin: const EdgeInsets.all(4), // Уменьшенный внешний отступ
//             child: Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 // 1. Нижний муляж (белый контейнер)
//                 if (showAsStack)
//                   Positioned.fill(
//                     child: Transform.translate(
//                       offset: const Offset(-2, -2),
//                       child: Transform.rotate(angle: -0.1, child: _buildStackDummyFrame(0.5)),
//                     ),
//                   ),
//                 // 2. Средний муляж (белый контейнер)
//                 if (showAsStack)
//                   Positioned.fill(
//                     child: Transform.translate(
//                       offset: const Offset(2, -1),
//                       child: Transform.rotate(angle: 0.06, child: _buildStackDummyFrame(0.8)),
//                     ),
//                   ),
//                 // 3. Основное фото
//                 _buildMainPhoto(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Виджет-муляж: просто пустая карточка фотобумаги
//   Widget _buildStackDummyFrame(double opacity) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(opacity),
//         borderRadius: BorderRadius.circular(6), // Уменьшенный радиус
//         border: Border.all(color: Colors.white, width: 1.5),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2, offset: const Offset(0, 1)),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainPhoto() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6), // Уменьшенный радиус
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(6), // Уменьшенный радиус
//         child: Stack(
//           children: [
//             // Изображение
//             Positioned.fill(child: Image.network(widget.post.media.first, fit: BoxFit.cover)),
//             // Уголки фотоаппарата
//             Positioned.fill(child: CustomPaint(painter: CameraCornersPainter())),
//             // Индикаторы
//             if (widget.post.media.length > 1)
//               Positioned(top: 4, right: 4, child: _buildMiniBadge(Icons.style_rounded)),
//             if (widget.post.isVideo)
//               Positioned(top: 4, left: 4, child: _buildMiniBadge(Icons.videocam_rounded)),
//             if (widget.post.isVideo)
//               const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMiniBadge(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
//       child: Icon(icon, color: Colors.white, size: 10),
//     );
//   }
// }

// // Рисует уголки видоискателя
// class CameraCornersPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.6)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     const len = 10.0; // Длина уголка

//     // Левый верхний
//     canvas.drawPath(
//       Path()
//         ..moveTo(0, len)
//         ..lineTo(0, 0)
//         ..lineTo(len, 0),
//       paint,
//     );
//     // Правый верхний
//     canvas.drawPath(
//       Path()
//         ..moveTo(size.width - len, 0)
//         ..lineTo(size.width, 0)
//         ..lineTo(size.width, len),
//       paint,
//     );
//     // Левый нижний
//     canvas.drawPath(
//       Path()
//         ..moveTo(0, size.height - len)
//         ..lineTo(0, size.height)
//         ..lineTo(len, size.height),
//       paint,
//     );
//     // Правый нижний
//     canvas.drawPath(
//       Path()
//         ..moveTo(size.width - len, size.height)
//         ..lineTo(size.width, size.height)
//         ..lineTo(size.width, size.height - len),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // --- ЖЕЛЕЙНАЯ КНОПКА ---
// class _JellyFollowButton extends StatefulWidget {
//   final bool isFollowed;
//   final VoidCallback onPressed;
//   const _JellyFollowButton({required this.isFollowed, required this.onPressed});

//   @override
//   State<_JellyFollowButton> createState() => _JellyFollowButtonState();
// }

// class _JellyFollowButtonState extends State<_JellyFollowButton> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
//     _scale = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
//   }

//   void _trigger() {
//     HapticFeedback.mediumImpact();
//     _scale = Tween<double>(
//       begin: 0.9,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
//     _controller.forward(from: 0.0);
//     widget.onPressed();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _scale,
//       builder: (context, child) {
//         final scale = _scale.value;
//         return Transform.scale(scale: scale, child: child);
//       },
//       child: GestureDetector(
//         onTap: _trigger,
//         child: Container(
//           height: 44,
//           decoration: BoxDecoration(
//             color: widget.isFollowed ? Colors.white : Colors.black,
//             borderRadius: BorderRadius.circular(15),
//             border: widget.isFollowed ? Border.all(color: Colors.black12) : null,
//           ),
//           child: Center(
//             child: Text(
//               widget.isFollowed ? "Following" : "Follow",
//               style: TextStyle(
//                 color: widget.isFollowed ? Colors.black : Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- СТОПКА (FOLDER) С ЭФФЕКТОМ ЖЕЛЕ И РАСКРЫТИЯ ---
// class JellyStackItem extends StatefulWidget {
//   final Map<String, dynamic> data;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const JellyStackItem({super.key, required this.data, required this.isSelected, required this.onTap});

//   @override
//   State<JellyStackItem> createState() => _JellyStackItemState();
// }

// class _JellyStackItemState extends State<JellyStackItem> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _jelly;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
//     _jelly = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
//   }

//   void _trigger() {
//     HapticFeedback.heavyImpact();
//     _jelly = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
//     _controller.forward(from: 0.0);
//     widget.onTap();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Берем первые 3 фото из коллекции для отображения в стопке
//     final List<PostModel> posts = widget.data['posts'];
//     final String img1 = posts.isNotEmpty ? posts[0].media.first : '';
//     final String img2 = posts.length > 1 ? posts[1].media.first : img1;
//     final String img3 = posts.length > 2 ? posts[2].media.first : img2;

//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         final double scale = _jelly.value;
//         final double vScale = 1.0 + (1.0 - scale) * 0.6;
//         return Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.diagonal3Values(scale, vScale, 1.0),
//           child: child,
//         );
//       },
//       child: GestureDetector(
//         onTap: _trigger,
//         child: Container(
//           width: 130,
//           margin: const EdgeInsets.only(right: 15),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Нижнее фото (уходит влево)
//               _buildCard(
//                 angle: widget.isSelected ? -0.3 : -0.15,
//                 offset: widget.isSelected ? const Offset(-25, -15) : const Offset(-8, -6),
//                 opacity: 1.0,
//                 imageUrl: img3,
//               ),
//               // Среднее фото (уходит вправо)
//               _buildCard(
//                 angle: widget.isSelected ? 0.25 : 0.1,
//                 offset: widget.isSelected ? const Offset(25, -8) : const Offset(8, 2),
//                 opacity: 1.0,
//                 imageUrl: img2,
//               ),
//               // Верхнее фото (основное)
//               _buildCard(
//                 angle: widget.isSelected ? -0.05 : 0,
//                 offset: Offset.zero,
//                 opacity: 1,
//                 imageUrl: img1,
//               ),
//               // Текст названия коллекции (можно наложить поверх нижнего поля фото)
//               Positioned(
//                 bottom: 25,
//                 child: IgnorePointer(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       widget.data['title'].toString().toUpperCase(),
//                       style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard({
//     required double angle,
//     required Offset offset,
//     required double opacity,
//     String? imageUrl,
//   }) {
//     return AnimatedSlide(
//       offset: offset.scale(0.01, 0.01),
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeOutBack,
//       child: AnimatedRotation(
//         turns: angle / (2 * 3.14),
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOutBack,
//         child: Container(
//           width: 100, // Чуть шире для стиля Polaroid
//           height: 125,
//           padding: const EdgeInsets.fromLTRB(6, 6, 6, 18), // Белые поля: узкие сверху/сбоку, широкое снизу
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(4), // У фото острые или слегка скругленные края
//             boxShadow: [
//               BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
//             ],
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFEFEFEF), // Плейсхолдер пока грузится фото
//               borderRadius: BorderRadius.circular(2),
//               image: imageUrl != null
//                   ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
//                   : null,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- ЭКРАН ПОСТА (КАРУСЕЛЬ) ---
// class PostDetailScreen extends StatelessWidget {
//   final PostModel post;
//   const PostDetailScreen({super.key, required this.post});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
//       body: Column(
//         children: [
//           const ListTile(
//             leading: CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/200')),
//             title: Text('ALEX_VISION', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           Expanded(
//             child: Hero(
//               tag: post.id,
//               child: PageView.builder(
//                 itemCount: post.media.length,
//                 itemBuilder: (context, index) {
//                   return InteractiveViewer(child: Image.network(post.media[index], fit: BoxFit.contain));
//                 },
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Icon(Icons.favorite_border, size: 30),
//                 SizedBox(width: 20),
//                 Icon(Icons.chat_bubble_outline, size: 30),
//                 Spacer(),
//                 Icon(Icons.bookmark_border, size: 30),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
