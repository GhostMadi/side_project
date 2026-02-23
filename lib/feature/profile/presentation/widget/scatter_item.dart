import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:side_project/feature/profile/models/post_model.dart';

class ScatterItem extends StatelessWidget {
  final int index;
  final PostModel post;

  const ScatterItem({super.key, required this.index, required this.post});

  @override
  Widget build(BuildContext context) {
    final bool isGallery = post.media.length > 1;
    final bool isVideo = post.isVideo;

    return GestureDetector(
      onTap: () {
        // Навигация на детали поста
      },
      child: Hero(
        tag: post.id,
        child: Container(
          color: Colors.grey[200], // Фоновый цвет до загрузки
          child: Stack(
            fit: StackFit.expand,
            children: [
              // КАРТИНКА
              Image.network(
                post.media.first,
                fit: BoxFit.cover, // Заполняет квадрат полностью
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  // Пока грузится — показываем Шиммер
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error_outline, size: 20)),
              ),

              // ИКОНКИ (Бейджи)
              if (isGallery)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.collections_rounded, color: Colors.white, size: 18),
                ),
              if (isVideo)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
