import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PublicPage extends StatelessWidget {
  const PublicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TelegramChatPage());
  }
}

// Модель данных для чата
class ChatSummary {
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final String time;
  final int unreadCount;

  ChatSummary({
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.time,
    this.unreadCount = 0,
  });
}

class TelegramChatPage extends StatefulWidget {
  const TelegramChatPage({super.key});

  @override
  State<TelegramChatPage> createState() => _TelegramChatPageState();
}

class _TelegramChatPageState extends State<TelegramChatPage> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Использовал bgColor (0xFF0D140A) для темной темы или Colors.white для светлой
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAnimatedAppBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _isSearching
                    ? Column(
                        key: const ValueKey('searchMode'),
                        children: [
                          TabBar(
                            controller: _tabController,
                            // Используем activeColor для индикатора
                            indicatorColor: const Color(0xFF8BC34A),
                            labelColor: const Color(0xFF1A1D1E),
                            unselectedLabelColor: const Color(0xFF6A6A6A),
                            indicatorSize: TabBarIndicatorSize.label,
                            tabs: const [
                              Tab(text: 'Chats'),
                              Tab(text: 'People'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildPlaceholder("Searching in messages..."),
                                _buildPlaceholder("Searching for people..."),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildMainList(key: const ValueKey('listMode')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      height: 60,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching
            ? Row(
                key: const ValueKey('searchBar'),
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF8BC34A)),
                    onPressed: () => setState(() => _isSearching = false),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: AppTextStyle.base(16, color: const Color(0xFF1A1D1E)),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: AppTextStyle.base(16, color: const Color(0xFF6A6A6A)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6A6A6A)),
                    onPressed: () => _searchController.clear(),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('normalBar'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Clever',
                      style: AppTextStyle.base(
                        26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: const Color(0xFF1A1D1E),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 28, color: Color(0xFF1A1D1E)),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMainList({required Key key}) {
    return ListView.separated(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: 15,
      separatorBuilder: (context, index) =>
          // Линия не подпирает аватар, создавая чистый вид
          const Divider(indent: 85, height: 1, color: Color(0xFFF1F1F1)),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // ЗОНА 1: АВАТАР (Интерактивная область профиля)
              _AvatarButton(onTap: () {}, index: index),

              // ЗОНА 2: ИНФОРМАЦИЯ О ЧАТЕ (Кликабельная область сообщения)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => print("Переход в чат $index"),
                    // Используем твои цвета для эффекта нажатия
                    highlightColor: const Color(0xFF8BC34A).withOpacity(0.05),
                    splashColor: const Color(0xFF8BC34A).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'User ${index + 1}',
                                style: AppTextStyle.base(
                                  16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1D1E),
                                ),
                              ),
                              Text('12:45', style: AppTextStyle.base(12, color: const Color(0xFF6A6A6A))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Привет! Как продвигается разработка приложения?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.base(14, color: const Color(0xFF6A6A6A)),
                                ),
                              ),
                              if (index % 3 == 0) _buildUnreadCounter(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Вспомогательный виджет для счетчика сообщений
  Widget _buildUnreadCounter() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF8BC34A), borderRadius: BorderRadius.circular(12)),
      child: Text(
        "2",
        style: AppTextStyle.base(10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaceholder(String text) {
    return FadeInUp(
      child: Center(
        child: Text(text, style: AppTextStyle.base(14, color: const Color(0xFF6A6A6A))),
      ),
    );
  }
}

// Вспомогательный класс стиля (как в твоем примере)
class AppTextStyle {
  static TextStyle base(
    double size, {
    double? height,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) => TextStyle(
    fontSize: size, // Убрал .sp для универсальности, добавь если используешь ScreenUtil
    color: color,
    fontFamily: 'Manrope',
    fontWeight: fontWeight ?? FontWeight.w300,
    height: height,
    letterSpacing: letterSpacing,
  );
}

class FadeInUp extends StatelessWidget {
  final Widget child;
  const FadeInUp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final safeValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - safeValue)),
          child: Opacity(opacity: safeValue, child: child),
        );
      },
      child: child,
    );
  }
}

class _AvatarButton extends StatefulWidget {
  final VoidCallback onTap;
  final int index;
  const _AvatarButton({required this.onTap, required this.index});

  @override
  State<_AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<_AvatarButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack, // Пружинистая анимация
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          padding: const EdgeInsets.all(2.5), // Отступ для кольца
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8BC34A).withOpacity(0.5), // Твое кольцо "активности"
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xffB7F5FE),
                child: Text(
                  "${widget.index + 1}",
                  style: AppTextStyle.base(14, color: const Color(0xFF1A1D1E), fontWeight: FontWeight.bold),
                ),
              ),
              // Маленькая точка статуса — делает аватар "живым"
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A), // Твой основной зеленый
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
