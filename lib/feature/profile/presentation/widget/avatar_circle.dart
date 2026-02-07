// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:side_project/core/dependencies/get_it.dart';
// import 'package:side_project/core/feature/profile/cubit/profile_cubit.dart';
// import 'package:side_project/core/resources/color_settings/color_extension.dart';
// import 'package:side_project/core/resources/icons/app_icons.dart';
// import 'package:side_project/core/shared/app_circle_progress.dart';
// import 'package:sizer/sizer.dart';

// class ProfileCircleAvatar extends StatelessWidget {
//   const ProfileCircleAvatar({super.key});

//   // Функция для выбора и отправки фото
//   Future<void> _pickAndUploadImage(BuildContext context) async {
//     final picker = ImagePicker();
//     // Открываем галерею
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       final file = File(image.path);
//       // Вызываем метод кубита (используем sl<UserCubit>() или context.read<UserCubit>())
//       sl<ProfileCubit>().updateAvatar(file);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppColors;
//     final double size = 20.w; // Убедитесь, что .w работает (ScreenUtil)

//     return GestureDetector(
//       onTap: () => _pickAndUploadImage(context),
//       child: SizedBox(
//         width: size,
//         height: size,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // 1. АВАТАРКА
//             Positioned.fill(
//               child: ClipOval(
//                 // Используем BlocBuilder, чтобы картинка обновилась сама при смене стейта
//                 child: BlocBuilder<ProfileCubit, ProfileState>(
//                   bloc: sl<ProfileCubit>(), // Подключаем кубит
//                   builder: (context, state) {
//                     // Получаем актуальный URL прямо из стейта или геттера
//                     final user = sl<ProfileCubit>().currentUser;
//                     bool isLoading = state == ProfileState.loading();
//                     return isLoading
//                         ? const Center(child: AppCircleProgress())
//                         : CachedNetworkImage(
//                             imageUrl: user?.avatarUrl ?? '',
//                             fit: BoxFit.cover,
//                             // Если идет загрузка (например, отправка фото), можно показать спиннер
//                             placeholder: (context, url) =>
//                                 const Center(child: AppCircleProgress()),
//                             errorWidget: (context, url, error) => CircleAvatar(
//                               backgroundColor: colors.fourth,
//                               child: Icon(
//                                 AppIcons.user.icon,
//                                 color: colors.secondary,
//                               ),
//                             ),
//                           );
//                   },
//                 ),
//               ),
//             ),

//             // 2. КНОПКА ДОБАВИТЬ (с логикой нажатия)
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: GestureDetector(
//                 // <--- ДОБАВИЛИ ОБРАБОТКУ НАЖАТИЯ
//                 onTap: () => _pickAndUploadImage(context),
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: colors.brand,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: colors.primary,
//                       width: 2,
//                     ), // Добавил обводку для красоты
//                   ),
//                   child: Icon(
//                     CupertinoIcons.add,
//                     size: 14,
//                     color: colors.primary,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
