## Supabase migrations index

Важно: Supabase применяет миграции **только** из корня `supabase/migrations/` и по имени файла (timestamp).  
Поэтому `.sql` файлы **не переносим** в подпапки. Подпапки ниже — только для навигации.

### Clusters (1 основная миграция)
- `20260402120000_clusters.sql`
  - **tables**: `public.clusters`
  - **triggers**: `clusters_set_updated_at`, `clusters_sync_profile_cluster_count` (поддержка `profiles.cluster_count`)
  - **RLS**: policies для select/insert/update/delete
  - **storage**: bucket `cluster_covers` + policies (cover_url)

### Posts (3 миграции)
- `20260402140000_posts_post_media_engagement.sql`
  - **types**: `public.media_type`
  - **tables**: `public.posts`, `public.post_media`, `public.comments`, `public.post_likes`, `public.comment_likes`, `public.post_saves`
  - **triggers**: счётчики `likes_count/comments_count/saves_count`, `clusters.posts_count`, `posts.updated_at`
  - **indexes**: global feed / cluster feed / user feed + дерево комментариев
  - **RLS** + grants

- `20260402150000_post_view_events.sql`
  - **tables**: `public.post_view_events`
  - **batch aggregation**: `public.flush_post_view_events_batch()` (service_role/cron)
  - **RLS**: только insert (authenticated) по видимому посту

- `20260407193000_posts_storage_views_sends.sql`
  - **storage**: bucket `post_media` + policies (path: `posts/{post_id}/{media_id}.*`)
  - **tables**: `public.post_send_events`
  - **triggers**: `posts.sends_count`

- `20260407201000_hot_feed_materialized_view.sql`
  - **materialized view**: `public.hot_posts_24h` (hot feed last 24h)
  - **refresh**: `public.refresh_hot_posts_24h()` + best-effort `pg_cron` schedule (every 5 min)

- `20260412100000_comments_contract_and_root_index.sql`
  - **comments**: частичный индекс `comments_post_root_created_desc_idx` под список корневых комментариев поста (как в приложении)
  - **comment on**: контракт колонок и embed `profiles!comments_user_id_fkey` для PostgREST

### Profiles / reference data
- `20260329120000_reference_countries_cities_categories.sql` (справочники)
- `20260329140000_profiles_username_change_limit.sql`
- `20260330120000_profile_storage_avatars_backgrounds.sql`
- `20260416100000_profiles_post_count.sql` — `profiles.post_count`, триггеры на `posts`

### Состояние аккаунта (сон / видимость) — **актуальный бэкенд**

Клиент вызывает только **`public.hibernate_account()`** (и при необходимости **`wake_up_if_needed()`**).  
Сброс контента (удаление постов/медиа) **не используется**.

| Файл | Назначение |
|------|------------|
| `20260416112425_account_state_reset_hibernate.sql` | Колонки `profiles`: `account_state`, `content_visible`, `reset_at`, `last_reset_at`, `last_hibernate_at`; soft-delete полей у `clusters`; RLS для скрытия «спящих»; RPC **`hibernate_account`**, **`wake_up_if_needed`**, первая версия **`reset_account`** (исторически — сброс контента). |
| `20260416140000_account_rpc_set_row_security_off.sql` | `SET row_security TO off` на эти RPC (definer + RLS). |
| `20260416150000_reset_account_storage_best_effort.sql` | Итерация `reset_account`: storage try/catch. |
| `20260417100000_reset_account_hard_delete_content.sql` | Итерация `reset_account`: hard-delete строк. |
| `20260418130000_reset_account_storage_posts_clusters.sql` | Итерация `reset_account`: очистка префиксов в Storage. |
| **`20260419000000_disable_reset_account_content_wipe.sql`** | **Финал:** `reset_account()` только `raise exception`; **`revoke execute` у `authenticated`**. Полное удаление контента с клиента отключено. |

Ремонт таблицы кластеров на проектах без ранней миграции:

- `20260418120000_ensure_clusters_for_postgrest.sql` — идемпотентно `public.clusters`, RLS, bucket `cluster_covers`.

### Социальный граф (follow)

Спека: `supabase/SPEC_SUPABASE_SOCIAL_GRAPH_AND_ACCOUNT.md`.

| Файл | Назначение |
|------|------------|
| `20260420120000_profile_follows_social_graph.sql` | `profile_follows`, счётчики на `profiles`, триггеры ±1, RLS, RPC `follow_user` / `unfollow_user` / `is_following_user`, списки подписчиков/подписок. |
| `20260421100000_social_graph_blocks_notifications_feed_reconcile.sql` | `profile_blocks`, `notification_events` (dedupe), `can_user_interact`, расширенный `follow_user` (блоки, 200/h, нотификация), `list_following_feed_enriched_cursor`, `reconcile_profile_follow_counts` (service_role). |

### Чат и сообщения (messages)

Подробный разбор файлов и потока данных — **`migrations/_chat/README.md`**.

| Файл | Назначение |
|------|------------|
| `20260417160000_chat_schema.sql` | Таблицы `chat_conversations`, `chat_participants`, `chat_messages`, реакции, вложения, ссылки на посты; RLS без прямого DML с клиента. |
| `20260417161000_chat_rpc.sql` | RPC чата (создание dm/group, списки enriched, отправка текста, read markers, поиск и т.д.). |
| `20260417162000_chat_search_fts.sql` | FTS по сообщениям в чатах пользователя. |
| `20260421103000_chat_media_storage_send_attachments.sql` | Bucket `chat_media`, `send_message_with_attachments`. |
| `20260422140000_chat_relax_storage_attach_cap.sql` | Коррекция лимитов Storage для вложений. |
| `20260423120000_chat_get_message_enriched.sql` | `get_message_enriched` — одно сообщение в формате списка. |
| `20260423180000_chat_realtime_publication.sql` | Таблицы чата в `supabase_realtime` для `postgres_changes`. |
| `20260425120000_chat_broadcast_message_enriched.sql` | Broadcast `message_enriched` после INSERT. |
| `20260425180000_chat_client_message_id.sql` | `client_message_id`, reconcile оптимистичных отправок. |

### Ленты / RPC (часть)
- `20260411150000_list_user_feed_enriched_rpc.sql`, `20260411160000_hot_feed_enriched_profile_cursor.sql`, `20260416120000_user_feed_cluster_filter.sql` и др. — см. имена файлов в `supabase/migrations/`.
