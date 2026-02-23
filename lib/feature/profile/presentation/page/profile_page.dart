import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/feature/profile/models/post_model.dart';
import 'package:side_project/feature/profile/presentation/widget/jelly_stack_item.dart';
import 'package:side_project/feature/profile/presentation/widget/profile_header.dart';
import 'package:side_project/feature/profile/presentation/widget/scatter_item.dart';

@RoutePage()
// --- PROFILE PAGE ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? selectedStackIndex = 0;
  bool isFollowed = false;

  final List<Map<String, dynamic>> stacks = [
    {
      'title': 'Travel',
      'posts': List.generate(
        100,
        (i) => PostModel(id: 'tr_$i', media: ['https://picsum.photos/800?random=tr$i']),
      ),
    },
    {
      'title': 'Design',
      'posts': List.generate(
        200,
        (i) => PostModel(id: 'ds_$i', media: ['https://picsum.photos/800?random=ds$i']),
      ),
    },
    {
      'title': 'Vibe',
      'posts': List.generate(
        300,
        (i) => PostModel(id: 'vb_$i', media: ['https://picsum.photos/800?random=vb$i']),
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Используем ProfileBody как генератор сливеров
    final profileBody = ProfileBody(
      stacks: stacks,
      selectedStackIndex: selectedStackIndex,
      onStackSelected: (index) => setState(() => selectedStackIndex = index),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER
            SliverToBoxAdapter(
              child: ProfileHeader(
                username: "ALEX_VISION",
                fullName: "Alex Rivera",
                category: "Digital Artist",
                location: "Madrid, Spain",
                bio:
                    "Visual Storyteller. Captured through my lens. Exploring the intersection of light and shadow.",
                isFollowed: isFollowed,
                onFollowTap: () => setState(() => isFollowed = !isFollowed),
                onMessageTap: () {},
                onMoreTap: () {},
              ),
            ),

            // 2. BODY (Collections + Grid)
            ...profileBody.buildSlivers(),
          ],
        ),
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final List<Map<String, dynamic>> stacks;
  final int? selectedStackIndex;
  final Function(int) onStackSelected;

  const ProfileBody({
    super.key,
    required this.stacks,
    required this.selectedStackIndex,
    required this.onStackSelected,
  });

  @override
  Widget build(BuildContext context) {
    // В Flutter мы не можем вернуть список сливеров напрямую в массив,
    // но мы можем использовать оператор spread (...) в CustomScrollView
    return const SizedBox.shrink(); // Этот метод build не будет использоваться напрямую
  }

  // Метод, который генерирует массив сливеров для CustomScrollView
  List<Widget> buildSlivers() {
    return [
      // Заголовок "Collections"
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: Text(
            "Collections(12)",
            style: AppTextStyle.base(
              18,
              color: const Color(0xFF1A1D1E),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),

      // Горизонтальный список коллекций
      SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: stacks.length,
            itemBuilder: (context, index) => JellyStackItem(
              data: stacks[index],
              isSelected: selectedStackIndex == index,
              onTap: () => onStackSelected(index),
            ),
          ),
        ),
      ),

      // Сетка постов (если выбрана коллекция)
      if (selectedStackIndex != null) _buildPostsGrid(),

      // Отступ снизу
      const SliverToBoxAdapter(child: SizedBox(height: 50)),
    ];
  }

  Widget _buildPostsGrid() {
    final posts = stacks[selectedStackIndex!]['posts'] as List<PostModel>;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 1), // Минимальные отступы как в инсте
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1, // Тонкие линии между постами
          crossAxisSpacing: 1,
          childAspectRatio: 0.8, // Делает элементы строго квадратными
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ScatterItem(key: ValueKey(posts[index].id), post: posts[index], index: index),
          childCount: posts.length,
        ),
      ),
    );
  }
}
