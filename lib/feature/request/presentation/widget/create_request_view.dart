import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/extensions/context_extension.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_text_field.dart';

class CreateRequestView extends StatefulWidget {
  const CreateRequestView({super.key});

  @override
  State<CreateRequestView> createState() => _CreateRequestViewState();
}

class _CreateRequestViewState extends State<CreateRequestView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingMiddle,
        right: AppDimensions.paddingMiddle,
        bottom: context.viewInsets.bottom + AppDimensions.paddingSenior,
        top: AppDimensions.paddingJunior,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimensions.spaceMiddle,
          children: [
            Text('Юридическая информация', style: AppTextStyle.base(16)),
            AppTextField(hintText: 'Название как на вывеске'),

            AppTextField(hintText: 'ИИН / БИН'),
            AppTextField(hintText: 'ФИО владельца'),

            Text('Контактное лицо', style: AppTextStyle.base(16)),
            AppTextField(hintText: 'ФИО заявителя'),
            AppTextField(hintText: 'Телефон контактного лица'),
            AppTextField(hintText: 'Email (опционально)'),

            Text('Геолокация', style: AppTextStyle.base(16)),

            AppTextField(hintText: 'Адрес заведения'),

            AppTextField(hintText: 'lat lng'),
            AppTextField(hintText: 'полигон'),

            Text('Документы и фото(опционально)', style: AppTextStyle.base(16)),
            // AppFileUploader(
            //   onFilesChanged: (List<PlatformFile> files) {
            //     for (var f in files) {
            //       print(
            //         "Путь к файлу: ${f.path}",
            //       ); // path может быть null в Web
            //     }
            //   },
            //   title: '',
            //   type: FileUploaderType.image,
            // ),

            // AppFileUploader(
            //   onFilesChanged: (List<PlatformFile> files) {
            //     for (var f in files) {
            //       print(
            //         "Путь к файлу: ${f.path}",
            //       ); // path может быть null в Web
            //     }
            //   },
            //   title: '',
            //   type: FileUploaderType.document,
            // ),

            AppButton(text: 'Отправить', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
