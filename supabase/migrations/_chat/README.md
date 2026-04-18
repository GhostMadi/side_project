## Сообщения чата (chat messages)

Миграции **не переносить** из корня `supabase/migrations/` — Supabase учитывает только файлы по timestamp в корне. Эта папка — навигатор по домену **чаты / сообщения**.

### Идея доступа к данным

- Таблицы `chat_*` включены под **RLS**, прямой `insert/update/delete` из клиента **не задуман** (`revoke … from authenticated`).
- Основной путь — **`SECURITY DEFINER`** RPC (`send_message`, `send_message_with_attachments`, списки, поиск и т.д.), см. `20260417161000_chat_rpc.sql` и последующие итерации.
- Вложения: байты в **Storage** bucket `chat_media`, метаданные — `chat_message_attachments`, см. `20260421103000_chat_media_storage_send_attachments.sql`.

### Миграции по порядку внедрения

| Файл | Назначение |
|------|------------|
| `../20260417160000_chat_schema.sql` | Enum’ы (`chat_message_kind`: `text`, `media`, `file`, `post_ref`, `system`), таблицы `chat_conversations`, `chat_participants`, `chat_messages`, `chat_message_reactions`, `chat_message_attachments`, `chat_message_post_refs`; индексы; RLS + revoke прямого DML. |
| `../20260417161000_chat_rpc.sql` | RPC: `chat_assert_participant`, `create_dm`, `create_group`, участники, **`list_messages_enriched`**, **`send_message`** (ранняя версия сигнатуры), **`list_conversations_enriched`**, **`mark_conversation_read`**, поиск и др.; все через definer + `row_security off`. |
| `../20260417162000_chat_search_fts.sql` | Полнотекстовый поиск по чату (FTS для сообщений участника). |
| `../20260421103000_chat_media_storage_send_attachments.sql` | Bucket **`chat_media`**, политики Storage; RPC **`send_message_with_attachments`** — коммит сообщения + строки вложений после загрузки файлов. |
| `../20260422140000_chat_relax_storage_attach_cap.sql` | Ослабление лимита размера/типов под реальные вложения (уточнение поверх bucket). |
| `../20260423120000_chat_get_message_enriched.sql` | **`get_message_enriched(message_id)`** — одна строка в том же JSON-форме, что `list_messages_enriched` (дельта-синхрон без полного перечитывания ленты). |
| `../20260423180000_chat_realtime_publication.sql` | Добавление таблиц чата в publication **`supabase_realtime`** — клиентские **`postgres_changes`** по INSERT/UPDATE в сообщениях и связках. |
| `../20260425120000_chat_broadcast_message_enriched.sql` | Broadcast на канал темы **`chat_thread_<conversation_id>`**, событие **`message_enriched`** — enriched JSON после INSERT (обёртка над тем же содержимым, что enriched-списки). |
| `../20260425180000_chat_client_message_id.sql` | Колонка **`client_message_id`** (уникальный nullable), обновление **`send_message`** — reconcile оптимистичных отправок с клиентским UUID. |

### Связь с приложением (Flutter)

- URL проекта и anon key — `lib/core/config/supabase_config.dart` (должен совпадать с Dashboard и с `project-ref` после `supabase link`).
- Edge Function **`send_chat_attachments`** — см. `supabase/functions/send_chat_attachments/` и секцию deploy в корневом `supabase/README.md`.

### См. также

- Общий индекс: `supabase/MIGRATIONS_INDEX.md` (раздел про чат).
- Посты и репосты в чат: `chat_message_post_refs` → таблица `posts` из домена **`_posts/README.md`**.
