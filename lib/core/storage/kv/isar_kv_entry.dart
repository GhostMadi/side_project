import 'package:isar_community/isar.dart';

part 'isar_kv_entry.g.dart';

@collection
class IsarKvEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  String? value;
}
