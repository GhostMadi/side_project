# ТЗ: аватар и обложка профиля (`avatar_url`, `background_url`)

## 1. Таблица `public.profiles`

Уже есть поля:

| Колонка | Тип | Назначение |
|--------|-----|------------|
| `avatar_url` | `text null` | Публичный URL файла аватара в Storage |
| `background_url` | `text null` | Публичный URL файла обложки (фон над профилем) |

Клиент после успешной загрузки файла записывает в профиль **полный публичный URL** строки, которую отдаёт Supabase Storage (или собирает его по шаблону из раздела 3).

Ограничения на формат URL в БД не заданы: источник истины — бакеты и политики Storage.

## 2. Storage (миграция `20260330120000_profile_storage_avatars_backgrounds.sql`)

### Бакеты

| ID бакета | Назначение | Публичный | Лимит размера | MIME |
|-----------|------------|-----------|---------------|------|
| `avatars` | Avatar | да | 10 MiB | jpeg, png, webp, gif |
| `profile_backgrounds` | Обложка/фон | да | 10 MiB | jpeg, png, webp |

### Путь к объекту (обязательно)

```
{user_uuid}/{имя_файла}
```

Первая папка в пути **должна совпадать с `auth.uid()`** (в политиках: `(storage.foldername(name))[1] = auth.uid()::text`). Иначе запись отклоняется RLS.

Примеры:

- `avatars/<userId>/avatar.jpg`
- `profile_backgrounds/<userId>/cover.webp`

### Политики

Имена в миграции: `public_read_avatars`, `public_read_profile_backgrounds`, `avatars_write_own`, `profile_backgrounds_write_own`, `avatars_update_own`, `profile_backgrounds_update_own`, `avatars_delete_own`, `profile_backgrounds_delete_own`.

- **Чтение** (`select`): роль `public` — скачивание/листинг объектов в бакете.
- **Запись** (`insert` / `update` / `delete`): только `authenticated`, первая папка в `name` = `auth.uid()` (`storage.foldername(name))[1]`).

Анонимы не загружают и не меняют файлы.

## 3. Публичный URL (для записи в `profiles`)

Шаблон:

```text
https://<PROJECT_REF>.supabase.co/storage/v1/object/public/<bucket_id>/<path>
```

Пример:

```text
https://xyzcompany.supabase.co/storage/v1/object/public/avatars/550e8400-e29b-41d4-a716-446655440000/avatar.jpg
```

Для `background_url` — тот же шаблон, но `bucket_id = profile_backgrounds`.

В Flutter можно получить URL после `upload` через `getPublicUrl` (или эквивалент в `supabase_flutter`).

## 4. Поток на клиенте

1. Пользователь выбирает изображение (кроп/сжатие — по UX, вне БД).
2. `upload` в нужный бакет по пути `{uid}/{fileName}`.
3. Получить публичный URL.
4. `update` строки `profiles` для текущего пользователя: `avatar_url` и/или `background_url` (остальные поля без изменений или с теми же значениями, что в `ProfileCubit`).

Удаление старого файла в Storage при смене картинки — по желанию (отдельный `remove` по старому пути), чтобы не копить мусор.

## 5. Связь с RLS `profiles`

`profiles_update_own` по-прежнему позволяет пользователю обновлять только свою строку. Значения `avatar_url` / `background_url` — произвольные строки; ответственность за то, что это URL из своего бакета, на клиенте и в договорённости с Storage.

При необходимости жёстче привязать URL к домену проекта можно добавить `CHECK` на `avatar_url` / `background_url` (префикс хоста) — отдельной миграцией.

## 6. Применение миграции

```bash
supabase db push
```

или выполнить SQL в Supabase Dashboard → SQL Editor.
