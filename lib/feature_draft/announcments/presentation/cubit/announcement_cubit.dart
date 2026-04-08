// import 'dart:developer';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:side_project/feature/announcments/data/model/announcement_model.dart';
// import 'package:side_project/feature/announcments/domain/repository/announcement_repository.dart';

// import 'announcement_state.dart';

// class AnnouncementCubit extends Cubit<AnnouncementState> {
//   final AnnouncementRepository repository;

//   AnnouncementCubit({required this.repository})
//     : super(const AnnouncementState());

//   /// Загрузить все объявления
//   Future<void> loadAnnouncements() async {
//     try {
//       emit(state.copyWith(isLoading: true, error: null));

//       final items = await repository.getAnnouncements();

//       emit(
//         state.copyWith(
//           isLoading: false,
//           items: items,
//           // если ранее было selected и оно есть в новом списке —
//           // можем его обновить
//           selected: state.selected != null
//               ? items.firstWhere(
//                   (e) => e.id == state.selected!.id,
//                   orElse: () => state.selected!,
//                 )
//               : null,
//         ),
//       );
//     } catch (e, s) {
//       log('loadAnnouncements error: $e', stackTrace: s);
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   /// Обновить список (удобный алиас)
//   Future<void> refresh() => loadAnnouncements();

//   /// Загрузить одно объявление по id и положить в selected
//   Future<void> loadById(String id) async {
//     try {
//       emit(state.copyWith(isLoading: true, error: null));

//       final item = await repository.getAnnouncementById(id);

//       emit(state.copyWith(isLoading: false, selected: item));
//     } catch (e, s) {
//       log('loadById error: $e', stackTrace: s);
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   /// Просто выбрать уже загруженное объявление из списка
//   void selectLocal(Announcement announcement) {
//     emit(state.copyWith(selected: announcement));
//   }

//   // ================== СОЗДАНИЕ / ОБНОВЛЕНИЕ ================== //

//   /// Создать объявление (если imageUrls уже готовы)
//   Future<void> create(Announcement announcement) async {
//     try {
//       emit(state.copyWith(isLoading: true, error: null));

//       final created = await repository.createAnnouncement(announcement);

//       final updatedItems = List<Announcement>.from(state.items)..add(created);

//       emit(
//         state.copyWith(
//           isLoading: false,
//           items: updatedItems,
//           selected: created,
//         ),
//       );
//     } catch (e, s) {
//       log('createAnnouncement error: $e', stackTrace: s);
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   /// Создать объявление вместе с загрузкой картинок
//   ///
//   /// [images] — файлы, которые надо залить в Supabase Storage
//   Future<void> createWithImages({
//     required String creatorId,
//     required String title,
//     String? type,
//     String? category,
//     required List<XFile> images,
//     List<AnnouncementDescription> descriptions = const [],
//   }) async {
//     try {
//       emit(state.copyWith(isLoading: true, error: null));

//       final created = await repository.createAnnouncementWithImages(
//         creatorId: creatorId,
//         title: title,
//         type: type,
//         category: category,
//         images: images,
//         descriptions: descriptions,
//       );

//       final updatedItems = List<Announcement>.from(state.items)..add(created);

//       emit(
//         state.copyWith(
//           isLoading: false,
//           items: updatedItems,
//           selected: created,
//         ),
//       );
//     } catch (e, s) {
//       log('createWithImages error: $e', stackTrace: s);
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   /// Обновить объявление
//   Future<void> update(Announcement announcement) async {
//     try {
//       emit(state.copyWith(isLoading: true, error: null));

//       final updated = await repository.updateAnnouncement(announcement);

//       // Обновляем элемент в списке
//       final updatedItems = state.items.map((e) {
//         if (e.id == updated.id) return updated;
//         return e;
//       }).toList();

//       emit(
//         state.copyWith(
//           isLoading: false,
//           items: updatedItems,
//           selected: updated,
//         ),
//       );
//     } catch (e, s) {
//       log('updateAnnouncement error: $e', stackTrace: s);
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   // =============== ОТДЕЛЬНАЯ ЗАГРУЗКА КАРТИНОК =============== //

//   /// Просто загрузить картинки и вернуть URL-ы
//   ///
//   /// Удобно, если ты хочешь сам собрать Announcement и потом вызвать [create].
//   Future<List<String>> uploadImages(List<XFile> images) async {
//     try {
//       emit(state.copyWith(isLoading: true, error: null));

//       final urls = await repository.uploadImages(images);

//       emit(state.copyWith(isLoading: false));

//       return urls;
//     } catch (e, s) {
//       log('uploadImages error: $e', stackTrace: s);
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//       rethrow;
//     }
//   }
// }
