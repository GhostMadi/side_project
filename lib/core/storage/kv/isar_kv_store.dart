import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:side_project/core/storage/kv/isar_kv_entry.dart';

@lazySingleton
class IsarKvStore {
  IsarKvStore(this._isar);

  final Isar _isar;

  Future<void> write(String key, String? value) async {
    await _isar.writeTxn(() async {
      if (value == null) {
        final existing = await _isar.isarKvEntrys.filter().keyEqualTo(key).findFirst();
        if (existing != null) {
          await _isar.isarKvEntrys.delete(existing.id);
        }
        return;
      }
      final e = IsarKvEntry()
        ..key = key
        ..value = value;
      await _isar.isarKvEntrys.put(e);
    });
  }

  Future<String?> read(String key) async {
    final existing = await _isar.isarKvEntrys.filter().keyEqualTo(key).findFirst();
    return existing?.value;
  }

  Future<bool> contains(String key) async {
    return await _isar.isarKvEntrys.filter().keyEqualTo(key).isNotEmpty();
  }

  Future<void> delete(String key) async {
    await write(key, null);
  }
}
