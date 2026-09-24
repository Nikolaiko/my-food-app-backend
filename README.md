# my-food-app-backend

[![Deploy](https://github.com/Nikolaiko/my-food-app-backend/actions/workflows/deploy.yml/badge.svg)](https://github.com/Nikolaiko/my-food-app-backend/actions/workflows/deploy.yml)
![Swift](https://img.shields.io/badge/Swift-6.2-orange?logo=swift)
![Vapor](https://img.shields.io/badge/Vapor-4-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)

Бэкенд приложения «Моё питание» ([ReceiptApp](https://github.com/Nikolaiko/my-food-app-ai-project)).
Хранит рецепты и по данным QR-кода кассового чека ФНС возвращает список
купленных продуктов.

Стек: **Swift 6.2**, **Vapor 4**, **Fluent** + **PostgreSQL**. Общие модели
берутся из пакета [my-foodapp-models](https://github.com/Nikolaiko/my-foodapp-models)
(продукт `Model`). Деплой через **Docker Compose** на VPS.

## Быстрый старт

Приложению нужен PostgreSQL. Проще всего поднять его в Docker с логином и
паролем по умолчанию (`root`/`root`, см. `configure.swift`):

```bash
# 1. Поднять локальную БД
docker run -d --name food-db -p 5432:5432 \
  -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -e POSTGRES_DB=products \
  postgres:16-alpine

# 2. Собрать и запустить сервер (по умолчанию http://127.0.0.1:8080)
swift run App serve
```

Миграции применяются автоматически при старте (`app.autoMigrate()` в
`configure.swift`), отдельно запускать `migrate` не нужно.

Проверка:

```bash
curl -H "Auth: <ключ>" http://127.0.0.1:8080/recipes
```

> Ключ для заголовка `Auth` задан в `Sources/App/Consts/IDs.swift`.

## Архитектура

Классический Vapor-проект: контроллеры → сервисы → Fluent-модели БД.
Наружу отдаются типы из пакета `Model` (`FoodRecipe`, `FoodProduct`), а в БД
лежат собственные Fluent-модели (`DBRecipeEntry`, `DBRecipeProductEntry`).
Маппинг между ними — в расширениях `+DBObject`.

```
routes.swift
 ├─► RecipeController ───► DataProvider ─────────────► Fluent (PostgreSQL)
 │                                                     DBRecipeEntry / DBRecipeProductEntry
 └─► ReceiptsController ─► QRDataParsingNetworkService ─► proverkacheka.com
                        └─► SimpleProductsParser  (название товара → FoodProductType)

Все слои ──► Model (my-foodapp-models): FoodRecipe, FoodProduct, QRCodeRawData, …
```

| Папка / файл | Назначение |
|---|---|
| `entrypoint.swift` | Точка входа (`@main`): окружение, логирование, запуск `Application` |
| `configure.swift` | Подключение к PostgreSQL, регистрация миграций, `autoMigrate`, роуты |
| `routes.swift` | Регистрация контроллеров |
| `Controllers/` | `RecipeController` (`/recipes`), `ReceiptsController` (`/receipts`) |
| `Service/DataProvider` | Работа с рецептами в БД: выборка, добавление и обновление в транзакциях |
| `Service/QRDataParsingNetworkService` | Запрос к API proverkacheka.com по сырой строке QR |
| `Service/SimpleProductsParser` | Определение `FoodProductType` по названию товара (поиск ключевых слов) |
| `Migrations/` | Схема БД, начальные данные, смена типа `count` на `Float` |
| `Models/Database/` | Fluent-модели таблиц |
| `Models/Receipts/` | DTO ответа proverkacheka (`ReceiptData` → `json.items[]`) |
| `Models/Extensions/` | `Content`/`Codable` для типов из `Model`, маппинг в DB-объекты и обратно |
| `Models/Errors/` | `CommonRequestError`, `ParsingError` → HTTP-статусы |
| `Consts/` | Имена и порты БД, имя и значение заголовка авторизации |

## API

Контракт описан OpenAPI-спекой в репозитории клиента:
[`specs/backend_specs.yaml`](https://github.com/Nikolaiko/my-food-app-ai-project/blob/main/specs/backend_specs.yaml).
Из неё генерируется сетевой клиент iOS-приложения, поэтому **при любом
изменении API обновляйте спеку** и перегенерируйте клиент.

| Метод | Путь | Тело запроса | Ответ | Авторизация |
|---|---|---|---|---|
| `GET` | `/recipes` | — | `[FoodRecipeShortInfo]` | да |
| `GET` | `/recipes/{recipeId}` | — | `FoodRecipe` | да |
| `POST` | `/recipes/add` | `FoodRecipe` (id можно пустым) | `FoodRecipe` с присвоенными id | да |
| `PUT` | `/recipes` | `FoodRecipe` (id обязателен) | `FoodRecipe` | да |
| `POST` | `/receipts/parse` | `QRCodeRawData` `{ "qrRawString": "t=…&s=…&fn=…" }` | `[FoodProduct]` | нет* |

\* Спека объявляет заголовок `auth` и для `/receipts/parse`, но сервер его
пока не проверяет.

**Авторизация** — заголовок `Auth` с фиксированным ключом (общий для всех
клиентов, не пользовательский токен). Нет заголовка или ключ не совпал → `401`.

**Обновление рецепта** (`PUT /recipes`) — это «удалить и вставить заново» в
одной транзакции: старая запись удаляется (продукты — каскадом), новая
сохраняется с тем же `id`.

**Ошибки** возвращаются стандартным телом Vapor `{ "error": true, "reason": "…" }`:

| Ошибка | Статус |
|---|---|
| `notAuthotized` | `401` |
| `notFound` | `404` |
| `unableToGetParameter` / `unableToParseParameter` | `400` |
| `urlError` / `emptyResponse`, `ParsingError` | `500` |
| `wrongStatusCode(n)` — proverkacheka ответил не-2xx | `n` |

**Даты** в JSON — ISO 8601 (дефолтный энкодер Vapor).

## Про данные чека

QR-код чека ФНС содержит **только фискальные реквизиты** (`t,s,fn,i,fp,n`), а
не список товаров. Поэтому `/receipts/parse`:

1. принимает сырую строку QR (`QRCodeRawData.qrRawString`);
2. отправляет её в `https://proverkacheka.com/api/v1/check/get` (form-urlencoded, `token` + `qrraw`);
3. из ответа берёт `data.json.items[]`;
4. каждую позицию превращает в `FoodProduct` через `SimpleProductsParser`:
   тип определяется поиском ключевых слов в названии (яблоко, молоко, томаты,
   лук зелёный/красный…), иначе `.unknown`. Количество округляется вверх,
   `quantityType` = `.unknown`, `date` = текущая дата, `id` — новый UUID.

Новый тип продукта = новый case в `FoodProductType` (пакет `Model`) + ключевые
слова в `SimpleProductsParser`.

## База данных

PostgreSQL, схема создаётся миграциями (порядок важен — см. `configure.swift`):

| Миграция | Что делает |
|---|---|
| `CreateDBSchema` | Таблицы `recipe` (name, description, shortDescription) и `recipe-product-entry` (count, quantityMeasure, productType, `recipe_id` → `recipe.id` с `ON DELETE CASCADE`) |
| `AddInitialRecipes` | Добавляет стартовый рецепт «Овощной салат» с тремя продуктами |
| `ChangeQuantityToFloat` | Меняет тип `recipe-product-entry.count` с `int64` на `float` |

`productType` хранится строкой (raw value `FoodProductType`), `quantityMeasure` —
числом (raw value `FoodQuantityType`). Новую миграцию добавляйте **в конец**
списка в `configure.swift`, существующие не редактируйте.

## Конфигурация

Переменные окружения (при локальном запуске можно положить в `.env`, Vapor
подхватит его сам):

| Переменная | По умолчанию | Назначение |
|---|---|---|
| `DATABASE_HOST` | `localhost` | Хост PostgreSQL |
| `DATABASE_NAME` | `products` (`products_test` в тестах) | Имя БД |
| `DATABASE_USERNAME` | `root` | Пользователь БД |
| `DATABASE_PASSWORD` | `root` | Пароль БД |
| `LOG_LEVEL` | `info` | Уровень логов |

Порт БД через окружение не задаётся: `5432`, в тестовом окружении — `5433`
(`Consts/Database.swift`).

## Деплой

Продакшн — Docker Compose на VPS: сервис `app` (образ из `Dockerfile`) +
`db` (`postgres:16-alpine`, данные в volume `db_data`). Приложение слушает
`8080` внутри контейнера и публикуется на порт **8085** хоста; порт БД наружу
не открыт.

```bash
cp .env.example .env              # заполнить DATABASE_* (пароль: openssl rand -base64 24)
docker compose up -d --build      # первый запуск / обновление
docker compose logs -f app        # логи
docker compose down               # остановить (данные БД сохраняются)
```

**Авто-деплой.** Push в `main` (или ручной запуск) запускает
`.github/workflows/deploy.yml`: по SSH на VPS выполняется
`git pull --ff-only` → `docker compose up -d --build` → `docker image prune -f`.
Нужные секреты репозитория: `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_PORT`.
Сборка образа на сервере долгая, поэтому таймаут шага — 30 минут.

> Сервер собирается под Linux: для `URLSession` нужен `FoundationNetworking`
> (`#if canImport(FoundationNetworking)`), а в runtime-образе — `libcurl4`.
> Если добавляете сетевой код, не забывайте про условный импорт.

## Модели (my-foodapp-models)

Общие типы подключаются SPM-пакетом `my-foodapp-models` по semver-тегу
(`.upToNextMajor(from: "1.0.5")`); точная версия зафиксирована в
`Package.resolved` (закоммичен, Docker-сборка использует его как есть).

Изменили модели → выпустили новый тег в `my-foodapp-models` → здесь:

```bash
swift package update my-foodapp-models
```

и закоммитить обновлённый `Package.resolved`.

## Тесты

```bash
swift test
```

Тестам нужен отдельный PostgreSQL на порту **5433** с БД `products_test`
(`Application.testable()` перед каждым тестом делает `autoRevert` + `autoMigrate`):

```bash
docker run -d --name food-db-test -p 5433:5432 \
  -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -e POSTGRES_DB=products_test \
  postgres:16-alpine
```

> Сейчас все тесты рецептов (`Tests/AppTests/Recipes`) закомментированы — их
> нужно актуализировать под async-API Vapor и `Float`-количество.

## Планы и известные ограничения

- Вынести секреты (ключ `Auth`, токен proverkacheka) из кода в переменные окружения.
- Проверять `Auth` в `/receipts/parse`, как того требует спека.
- Заменить общий ключ на пользовательскую аутентификацию (сейчас `login`/`register`
  в клиенте — мок).
- Вернуть тесты и добавить CI на прогон `swift test`.
- `tags` у рецептов пока не хранятся в БД — всегда отдаются пустым массивом.
- Зависимость `fluent-mongo-driver` подключена, но не используется.
