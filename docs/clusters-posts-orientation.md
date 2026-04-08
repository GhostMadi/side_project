# Ориентир: кластеры (коллекции) и посты

Документ фиксирует **целевую модель данных** для бэкенда и **как сейчас устроен клиент** (профиль, создание кластера/поста, лайки, комментарии, сохранения, «поделиться»). Его можно править по мере появления миграций Supabase и реальных репозиториев.

---

## 1. Что уже есть в приложении (клиент)

| Область | Реализация |
|--------|------------|
| **Профиль** | Загрузка `ProfileModel` (Supabase `public.profiles`), в т.ч. `cluster_count`. |
| **Создание контента** | Из шапки профиля: «Создать кластер» → `ClusterCreateRoute`, «Создать пост» → `PostCreateRoute`. |
| **Черновик кластера** | `ClusterPreviewSession` + локальная карточка в полосе коллекций (`_local_cluster_draft`), без API. |
| **Лента профиля** | `ProfilePostsMock` / `ProfileCollectionPreview` — **муляж** сетки и коллекций; замена списками с API запланирована в коде комментариями. |
| **Пост в UI** | `ProfilePostPreview`: медиа, title/subtitle/description, гео, теги людей, счётчики, комментарии (в т.ч. вложенные в модели). |
| **Детали поста** | `PostDetailScreen`: лайк / дизлайк / сохранить, карусель медиа, шторка комментариев `PostCommentsBottomSheet`. |
| **Создание поста** | Многошаговый флоу (галерея → редактор → детали): текст, коллекция, отметки людей, гео — уходит в **SnackBar-черновик**, без API. |

**Миграции Supabase:** `20260402120000_clusters.sql` → `clusters`; `20260402140000_posts_post_media_engagement.sql` → посты и вовлечённость; **`20260402150000_post_view_events.sql`** → события просмотров и `flush_post_view_events_batch()`. Ниже — согласованное описание.

---

## 2. Целевая схема БД (канон)

Имена сущностей и полей — в `snake_case` в PostgreSQL; в Dart обычно `camelCase`.

### 2.1. `clusters`

| Поле | Тип | Примечание |
|------|-----|------------|
| `id` | uuid, PK | |
| `owner_id` | uuid, FK → `profiles.id` | В клиенте раньше в комментариях фигурировали `lat`/`lng` у кластера — **в твоём списке нет**. Решение продукта: либо не хранить гео у кластера, либо добавить опционально `latitude` / `longitude` отдельной миграцией. |
| `title` | text | |
| `subtitle` | text, nullable | |
| `cover_url` | text, nullable | URL обложки в Storage; при **удалении** кластера файл в бакете **сам не удаляется** — нужен Edge/Webhook/чистка (см. § ниже). |
| `posts_count` | int, default 0 | Денормализация; **автоматически** ведётся триггерами на `posts` в миграции `20260402140000_posts_post_media_engagement.sql` — из Flutter руками не инкрементить. |
| `sort_order` | int | Порядок в профиле; массовый reorder в UI слегка нагружает индекс `(owner_id, sort_order)` — для сотен кластеров обычно ок. |
| `is_archived` | boolean | |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

Индексы: `(owner_id)`, `(owner_id, sort_order)` при необходимости.

**Нюансы эксплуатации**

1. **Storage и `cover_url`** — сама БД **не умеет** удалять файлы в Storage (это отдельный API). **Без Edge** можно сделать так: **из Flutter (или любого клиента)** в одном сценарии удаления кластера — **сначала** `storage.from('…').remove([path])` по пути объекта в бакете, **потом** `delete` строки `clusters` (или наоборот при откате: если Storage упал — не удалять строку). Нужен надёжный **путь в бакете** (`clusters_cover/uid/cluster_id.jpg` и т.д.): либо хранить отдельным полем `cover_storage_path`, либо аккуратно вытащить path из `cover_url`. Edge / Webhook / cron — альтернатива, если логику хотите не в клиенте.

2. **`posts_count`** — рассинхрон с реальным числом постов маловероятен, если все изменения идут через таблицу `posts`: триггеры там же поддерживают счётчик при insert/delete/update `cluster_id` и soft delete поста. Игнорировать это поле в клиенте при добавлении поста.

3. **`sort_order` и Reorderable List** — при перетаскивании обновляется несколько строк; индекс по `(owner_id, sort_order)` пересчитывается. Для типичного числа кластеров на пользователя это не проблема; сотни+ — при необходимости оптимизировать отдельно (редко).

Сохранения чужих кластеров в закладки (`cluster_saves`, `saves_count`) **пока не в модели** — при необходимости отдельная миграция.

---

### 2.2. `posts`

Массив URL в самой таблице поста **не используется** — медиа вынесены в **`post_media`** (тип, порядок, дальше можно добавить размер/thumbnail без ломки схемы).

| Поле | Тип | Примечание |
|------|-----|------------|
| `id` | uuid, PK | |
| `user_id` | uuid, FK | Автор. |
| `cluster_id` | uuid, FK, nullable | Только **свой** кластер (RLS); `null` — пост вне коллекции. |
| `title` | text, nullable | |
| `subtitle` | text, nullable | |
| `description` | text, nullable | |
| `is_archived` | boolean | Скрытие из общей ленты / «в архив». |
| `deleted_at` | timestamptz, nullable | Soft delete; отдельно от архива; лента в индексе `posts_feed_idx` без удалённых. |
| `likes_count` | int | Триггеры от `post_likes`. |
| `comments_count` | int | Триггеры от `comments` (insert / soft delete / delete). |
| `saves_count` | int | Триггеры от `post_saves`. |
| `sends_count` | int | Пока без таблицы событий — обновление из приложения. |
| `views_count` | int | Денормализация; накопление см. **§2.2b** — не инкрементировать синхронно на каждый просмотр. |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

Индексы в миграции: `(user_id)`, `(cluster_id)`, `(created_at desc)`; частичный **`posts_feed_idx`** на `(created_at desc) where is_archived = false and deleted_at is null` — лента.

#### 2.2b. Просмотры: `post_view_events` + `flush_post_view_events_batch()`

Миграция **`20260402150000_post_view_events.sql`**.

**Таблица `post_view_events`:** `post_id`, `viewer_hash` (отпечаток зрителя), `bucket_date` (обычно **дата** для дневного дедупа), `processed` (ещё не учтено в `posts.views_count`), `created_at`. **UNIQUE (`post_id`, `viewer_hash`, `bucket_date`)** — один «слот» просмотра на зрителя в бакете. Часовые бакеты при необходимости — отдельная колонка/миграция.

**Клиент:** `INSERT` (или `INSERT ... ON CONFLICT DO NOTHING` при гонках) — без прямого `UPDATE posts`. RLS: вставка только если пост **виден** по тем же правилам, что и `SELECT` постов.

**Агрегация:** функция **`public.flush_post_view_events_batch()`** (SECURITY DEFINER, **`EXECUTE` только у `service_role`**) — суммирует непросмотренные события по `post_id`, увеличивает `posts.views_count`, помечает строки `processed = true`. Вызывать по **cron** (например `pg_cron` каждые 1–5 мин) или из **Edge** с service role, не из клиента.

**Чтение в UI:** по-прежнему **`posts.views_count`**; при желании кэш на клиенте.

**Итог:** нет блокировок горячей строки `posts` на каждый показ; масштабирование — за счёт append-only и батчей. При огромном трафике — дублировать поток во внешнюю аналитику.

### 2.2a. `post_media`

| Поле | Тип |
|------|-----|
| `id` | uuid, PK |
| `post_id` | uuid, FK → `posts` |
| `url` | text |
| `type` | `public.media_type` enum (`image`, `video`) |
| `sort_order` | int |
| `created_at` | timestamptz |

**UNIQUE (`post_id`, `sort_order`)** — один порядковый номер на пост.

**Дополнительно (есть в UI, нет в твоём списке):**

- Гео поста: в муляже `latitude`, `longitude`, `location_label` — для продакшена понадобятся поля вроде `latitude`, `longitude`, `location_label` (или связь с таблицей мест). Добавить миграцией, когда будет гео с бэка.
- **Дизлайки:** в `PostDetailScreen` есть дизлайк и `dislikesCount` в превью. В предложенной схеме **нет** сущности «дизлайк поста». Варианты: (а) таблица `post_dislikes` по аналогии с `post_likes`, UNIQUE (`post_id`, `user_id`); (б) убрать дизлайк из продукта и вычистить UI.

---

### 2.3. `comments`

| Поле | Тип |
|------|-----|
| `id` | uuid, PK |
| `post_id` | uuid, FK |
| `user_id` | uuid, FK |
| `text` | text |
| `parent_comment_id` | uuid, nullable, FK → `comments.id` | Ветка ответов; в UI — `ProfilePostComment.replies`. |
| `likes_count` | int |
| `created_at` | timestamptz |
| `edited_at` | timestamptz, nullable |
| `is_deleted` | boolean | Soft delete; в ленте не показывать текст или показывать заглушку. |

Индекс **`(post_id, parent_comment_id)`** — дерево в рамках поста.

---

### 2.4. `post_likes`

| Поле | Тип |
|------|-----|
| `post_id` | uuid, FK, часть PK |
| `user_id` | uuid, FK, часть PK |
| `created_at` | timestamptz |

**PRIMARY KEY (`post_id`, `user_id`)** — отдельный `id` не обязателен.

---

### 2.5. `comment_likes`

| Поле | Тип |
|------|-----|
| `comment_id` | uuid, FK, часть PK |
| `user_id` | uuid, FK, часть PK |
| `created_at` | timestamptz |

**PRIMARY KEY (`comment_id`, `user_id`)**

---

### 2.6. `post_saves`

| Поле | Тип |
|------|-----|
| `post_id` | uuid, FK, часть PK |
| `user_id` | uuid, FK, часть PK |
| `created_at` | timestamptz |

**PRIMARY KEY (`post_id`, `user_id`)** — синхронизирует `posts.saves_count` триггерами.

---

### 2.7. `post_sends`

| Поле | Тип | Примечание |
|------|-----|------------|
| `id` | uuid, PK | |
| `post_id` | uuid, FK | |
| `sender_id` | uuid | Кто нажал «поделиться». |
| `receiver_id` | uuid | Кому ушло (чат/пользователь) — уточнить продукт: если «шаринг во вне» без получателя, схема может упроститься до счётчика без строки на каждое событие. |
| `created_at` | timestamptz | |

---

## 3. Сопоставление с экранами (кратко)

| Концепт | Клиент сейчас | Бэкенд (цель) |
|--------|----------------|---------------|
| Коллекция | `ProfileCollectionPreview` / черновик кластера | `clusters` + посты |
| Пост в сетке / детали | `ProfilePostPreview` | `posts` + счётчики + медиа |
| Лайк поста | Локальный toggle в `PostDetailScreen` | `post_likes` + инкремент `likes_count` |
| Комментарии | `ProfilePostComment`, шторка | `comments` + `comment_likes` |
| Сохранить пост | Локальный state | `post_saves` |
| Поделиться | Счётчик в муляже | `post_sends` или только `sends_count` |
| Сохранить кластер | Пока нет в UI | не заложено в БД |
| Дизлайк | Есть в UI | Нет в твоей схеме — решить отдельно (см. выше) |

---

## 4. Что подправить в твоём списке (итог)

Твой набор сущностей **согласован** с логикой приложения; имеет смысл явно зафиксировать:

1. **`sends_count`** в `posts` ↔ в клиенте название **`sharesCount`** — только нейминг.
2. **`views_count`** — в UI профиля пока не отображается; оставить в БД под ленту/статистику.
3. **Дизлайки** — либо добавить сущность, либо убрать из UI.
4. **Гео и подпись места у поста** — добавить полями, когда будет API.
5. **Гео кластера** — было в старом комментарии к `ClusterCreatePage`; в твоём списке нет — вынести в отдельное ADR (нужно / не нужно).

---

## 5. Файлы для ориентира в репозитории

- Профиль и навигация: `lib/feature/profile_page/presentation/page/profile_loaded_body.dart`
- Модели муляжа постов/коллекций: `lib/feature/profile_page/presentation/widget/profile_posts_section.dart`
- Детали поста: `lib/feature/profile_page/presentation/widget/post_detail_screen.dart`
- Комментарии: `lib/feature/profile_page/presentation/widget/post_comments_bottom_sheet.dart`
- Создание кластера: `lib/feature/cluster_create_page/cluster_create_page.dart`
- Черновик кластера на профиле: `lib/feature/cluster_create_page/cluster_preview_session.dart`
- Создание поста: `lib/feature/post_create_page/post_create_page.dart`
- Профиль в БД (уже есть): `lib/feature/profile/data/models/profile_model.dart`

Актуальные миграции: `supabase/migrations/20260402120000_clusters.sql`, `supabase/migrations/20260402140000_posts_post_media_engagement.sql`.
