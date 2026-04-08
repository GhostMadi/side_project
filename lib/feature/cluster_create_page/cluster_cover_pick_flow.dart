import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:side_project/core/router/app_router.gr.dart';

/// Шаг 1: выбрать исходную картинку (без редактора).
Future<Uint8List?> pickClusterCoverRaw(BuildContext context) async {
  final picker = ImagePicker();
  final x = await picker.pickImage(source: ImageSource.gallery);
  if (x == null || !context.mounted) return null;
  final Uint8List bytes;
  try {
    bytes = await x.readAsBytes();
  } catch (_) {
    return null;
  }
  return context.mounted ? bytes : null;
}

/// Шаг 2: редактирование (квадрат 1:1) через [ProfileImageEditPage].
Future<Uint8List?> editClusterCover(BuildContext context, Uint8List rawBytes) {
  return context.router.push<Uint8List>(
    ProfileImageEditRoute(
      imageBytes: rawBytes,
      isCover: false,
      clusterCollectionThumb: true,
    ),
  );
}

/// Legacy helper: выбрать и сразу отредактировать.
Future<Uint8List?> pickCropClusterCover(BuildContext context) async {
  final raw = await pickClusterCoverRaw(context);
  if (raw == null || !context.mounted) return null;
  return editClusterCover(context, raw);
}
