import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';

/// Галерея → кроп → загрузка в Storage (обложка или аватар).
Future<String?> pickCropAndUploadProfileImage({
  required BuildContext context,
  required bool isCover,
}) async {
  final cubit = context.read<ProfileCubit>();
  final picker = ImagePicker();
  final x = await picker.pickImage(source: ImageSource.gallery);
  if (x == null || !context.mounted) return null;
  final Uint8List bytes;
  try {
    bytes = await x.readAsBytes();
  } catch (e) {
    return '$e';
  }
  if (!context.mounted) return null;
  final cropped = await context.router.push<Uint8List>(
    ProfileImageEditRoute(imageBytes: bytes, isCover: isCover),
  );
  if (!context.mounted || cropped == null) return null;
  return isCover ? await cubit.uploadBackgroundImage(cropped) : await cubit.uploadAvatarImage(cropped);
}
