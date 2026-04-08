# ТЗ (фронт): справочники стран, городов, категорий профиля

## 1. Источник данных

Supabase, таблицы `public.countries`, `public.cities`, `public.profile_categories`.  
Чтение через PostgREST (`supabase_flutter`), политики RLS: `SELECT` для `anon` / `authenticated`.

## 2. Контракт полей (как в БД)

### 2.1. `countries`

| Поле JSON       | Тип    | Примечание                          |
|-----------------|--------|-------------------------------------|
| `code`          | string | **lower-case**, 2 символа: `kz`, `ru` |
| `is_active`     | bool   | фильтровать `true` на клиенте (дубль БД) |
| `sort_order`    | int    | сортировка списка по возрастанию    |

### 2.2. `cities`

| Поле JSON       | Тип    | Примечание |
|-----------------|--------|------------|
| `country_code`  | string | FK → `countries.code` |
| `city_code`     | string | **camelCase** внутри кода: `almaty`, `saintPetersburg` |
| `is_active`     | bool   | |
| `sort_order`    | int    | |

Идентификатор города — **пара** `(country_code, city_code)`.

### 2.3. `profile_categories`

| Поле JSON    | Тип    | Примечание |
|--------------|--------|------------|
| `code`       | string | camelCase: `store`, `barbershop`, `salon`, `restaurant` |
| `is_active`  | bool   | |
| `sort_order` | int    | |

## 3. Начальные данные (сид бэка)

**Страны:** `kz` (1), `ru` (2).

**Города:**

| country | city_code        | sort |
|---------|------------------|------|
| kz      | almaty           | 1    |
| kz      | astana           | 2    |
| kz      | shymkent         | 3    |
| ru      | moscow           | 1    |
| ru      | saintPetersburg  | 2    |
| ru      | kazan            | 3    |

**Категории:** `store` (1), `barbershop` (2), `salon` (3), `restaurant` (4).

## 4. Архитектура (Flutter)

- **Три фичи** (отдельные папки): `countries`, `cities`, `profile_categories`.
- Каждая: `data/` (модели, enum-коды, репозиторий + impl), `presentation/cubit/` (состояние + загрузка).
- DI: `get_it` + `injectable` — репозитории `lazySingleton`, кубиты `lazySingleton` (кэш списков в памяти).
- Состояние кубитов: `freezed` (`initial` / `loading` / `loaded` / `error`).

## 5. Enum и модели

- **Страна:** enum `CountryCode` с значениями `kz`, `ru` (строка совпадает с БД) + `String` в модели для будущих стран без релиза приложения.
- **Категория:** enum `ProfileCategoryCode` — `store`, `barbershop`, `salon`, `restaurant` + `tryParse` для строки из API.
- **Город:** глобальный enum не используется (код не уникален без страны). Модель `CityModel` с `countryCode` + `cityCode`; при необходимости `CityKey`/`==` по паре.

## 6. Поведение кубитов

| Кубит                 | Метод        | Описание |
|-----------------------|--------------|----------|
| `CountriesCubit`      | `load()`     | Загрузка активных стран, сортировка `sort_order`. |
| `CitiesCubit`         | `load(String countryCode)` | Города по выбранной стране; при смене страны — повторный вызов. |
| `ProfileCategoriesCubit` | `load()`  | Активные категории, сортировка `sort_order`. |

Предзагрузка: при старте приложения можно вызвать `CountriesCubit.load()` и `ProfileCategoriesCubit.load()`; города — по выбору страны на экране редактирования профиля.

## 7. Связь с `profiles`

Поля профиля хранят те же строковые коды, что и в справочниках (`country_code`, `city_id` / `city_code`, `category_id` — унифицировать имена с бэком). Отображение подписей — **l10n по кодам** (отдельные ключи ARB), не из этих таблиц.

## 8. Критерии готовности

- Три репозитория возвращают списки без ошибок на тестовом проекте Supabase.
- Три кубита регистрируются в DI и доступны в `MultiBlocProvider` корневого приложения.
- Enum’ы парсятся с `tryParse` для строк из API и совпадают с сидом п. 3.
