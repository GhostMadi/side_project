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

### Profiles / reference data
- `20260329120000_reference_countries_cities_categories.sql` (справочники)
- `20260329140000_profiles_username_change_limit.sql`
- `20260330120000_profile_storage_avatars_backgrounds.sql`

