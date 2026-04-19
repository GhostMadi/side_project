-- Optional JPEG poster URL for video tiles / previews (chosen frame at publish time).

alter table public.post_media
  add column if not exists poster_url text null;

comment on column public.post_media.poster_url is
  'Public Storage URL of JPEG poster/thumbnail for video items; null if only inline decode / legacy posts.';
