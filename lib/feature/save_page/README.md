## Сохранённые посты

Отдельная фича от ленты/постов: экран «Сохранённое», кубит и **`SavedListRepository`** (RPC `list_my_saved_posts`).

Модель контента — общая **`PostModel`** (`lib/feature/posts/data/models/`). Операции «сохранить/убрать» остаются в **`PostsRepository`**.

Маршрут: **`SavedRoute`** (`presentation/page/saved_page.dart`).
