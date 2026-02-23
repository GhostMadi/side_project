import 'package:flutter/material.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';

class ProfileHeader extends StatefulWidget {
  final String username;
  final String fullName;
  final String category;
  final String location;
  final String bio;
  final bool isFollowed;
  final VoidCallback onFollowTap;
  final VoidCallback onMessageTap;
  final VoidCallback onMoreTap;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.fullName,
    required this.category,
    required this.location,
    required this.bio,
    required this.isFollowed,
    required this.onFollowTap,
    required this.onMessageTap,
    required this.onMoreTap,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Квадратная обложка сверху
          _buildSquareCover(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Аватар и Статистика
                Row(
                  children: [
                    _buildInstagramAvatar(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem("8.4k", "Подписчики"),
                          _buildStatItem("152", "Подписки"),
                          _buildStatItem("24", "Eventers"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. ИМЯ, НИКНЕЙМ И КАТЕГОРИЯ
                Text(
                  widget.fullName,
                  style: AppTextStyle.base(18, color: const Color(0xFF1A1D1E), fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                // Добавляем никнейм через @
                Text(
                  "@${widget.username}",
                  style: AppTextStyle.base(
                    14,
                    color: const Color(0xFF8BC34A), // Салатовый акцент для ника
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.category,
                  style: AppTextStyle.base(13, color: const Color(0xFF6A6A6A), fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 12),

                // 4. БИО (Разворачивающееся)
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyle.base(14, color: const Color(0xFF1A1D1E), height: 1.4),
                      children: [
                        TextSpan(
                          text: widget.bio.length > 90 && !isExpanded
                              ? "${widget.bio.substring(0, 90)}..."
                              : widget.bio,
                        ),
                        if (widget.bio.length > 90 && !isExpanded)
                          TextSpan(
                            text: " еще",
                            style: AppTextStyle.base(
                              14,
                              color: const Color(0xFF8BC34A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. ЛОКАЦИЯ
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8BC34A)),
                    const SizedBox(width: 4),
                    Text(
                      widget.location,
                      style: AppTextStyle.base(
                        12,
                        color: const Color(0xFF8BC34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 6. КНОПКИ (Follow, Message, More)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: widget.isFollowed
                          ? AppOutlinedButton(text: "Following", onPressed: widget.onFollowTap)
                          : AppButton(text: "Follow", onPressed: widget.onFollowTap),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: AppOutlinedButton(text: "Message", onPressed: widget.onMessageTap),
                    ),
                    const SizedBox(width: 8),
                    // Кнопка More через твой AppButton
                    AppButton(
                      text: "",
                      isExpanded: false,
                      onPressed: widget.onMoreTap,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17),
                        child: Icon(Icons.more_horiz, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательные методы
  Widget _buildSquareCover() {
    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(image: NetworkImage('https://picsum.photos/800/400'), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildInstagramAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC5FEB7)),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://picsum.photos/200')),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.base(18, color: const Color(0xFF1A1D1E), fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: AppTextStyle.base(12, color: const Color(0xFF6A6A6A), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
