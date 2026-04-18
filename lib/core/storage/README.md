# `lib/core/storage`

Локальное хранилище приложения: слой **не про бизнес-логику**, а про **где и как лежат строки** на устройстве.

## Структура папок

| Папка | Назначение |
|-------|------------|
| **`kv/`** | Низкоуровневый **key–value** на Isar: схема `IsarKvEntry`, синглтон `IsarKvStore`, обёртка `BaseStorage<T>` для одного ключа с типами `String` / `int` / `bool` / `double` / `List<String>`. |
| **`prefs/`** | **Доменные** обёртки над KV: код локали, кэш реакций на посты, мини-профиль. Регистрируются в DI как `@lazySingleton`. |
| **`secure/`** | Обёртка над **Flutter Secure Storage** (`BaseSecureStorage`). Сейчас в проекте может не использоваться — заготовка для токенов и чувствительных данных. |

## Поток данных (упрощённо)

```
Фичи / cubit / repository
        ↓
   prefs/* (смысловые ключи, JSON при необходимости)
        ↓
   IsarKvStore.read / write / delete
        ↓
   Isar коллекция IsarKvEntry (key → value)
```

`Isar` открывается в `AppModule` (список схем включает `IsarKvEntrySchema`).

## Таблица: кто что пишет

| Класс | Ключи / формат | Кто читает / пишет |
|-------|------------------|---------------------|
| `AppLocalePrefsStorage` | `app_locale_code` — строка (`ru`, `en`, …) | `AppLocaleCubit` при смене языка; старт приложения. |
| `PostReactionsPrefsStorage` | `post_reactions_cache_v1_<userId>` — JSON map `postId → kind`; `post_reactions_pending_v1_<userId>` — очередь желаемого состояния после сетевых вызовов | `PostsRepository` и связанные cubit’ы постов. |
| `ProfileMiniCacheStorage` | `profile_mini_v1_<userId>` — JSON `{ username, avatar_url }` | Профиль, деталь поста (автор), чтобы не дергать сеть без нужды. |

При смене пользователя важно не смешивать данные: реакции и мини-профиль уже **привязаны к `userId` в ключе**.

## Добавление нового «pref»

1. По возможности положить класс в **`prefs/`**, зависимость — только **`IsarKvStore`** (и при необходимости `BaseStorage` из `kv/`).
2. Зафиксировать префикс ключа и версию в имени (`*_v1_`), чтобы при смене формата можно было мигрировать или игнорировать старые ключи.
3. Пометить `@lazySingleton` (или `@injectable`, если нужен новый инстанс на экран — редко).
4. Запустить генерацию DI: `dart run build_runner build -d`.

## Генерация Isar

Файл `kv/isar_kv_entry.g.dart` генерируется из `kv/isar_kv_entry.dart`. После правок схемы:

```bash
dart run build_runner build -d
```
