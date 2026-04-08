import 'package:flutter/material.dart';
import 'package:side_project/feature/profile_page/presentation/models/profile_feed_preview.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_collection_card.dart';

/// Горизонтальная полоса коллекций над блоком публикаций: по центру при узком контенте, иначе скролл.
class ProfileCollectionsStrip extends StatelessWidget {
  const ProfileCollectionsStrip({
    super.key,
    required this.collections,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ProfileCollectionPreview> collections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < collections.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      ProfileCollectionCard(
                        index: i,
                        imageUrl: collections[i].effectiveCoverUrl,
                        memoryImageBytes: collections[i].coverMemory,
                        title: collections[i].title,
                        collectionSubtitle: collections[i].subtitle,
                        countLabel: collections[i].countLabel,
                        isSelected: i == selectedIndex,
                        onTap: () => onSelect(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
