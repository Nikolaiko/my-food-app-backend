# my-food-app-backend

[![Deploy](https://github.com/Nikolaiko/my-food-app-backend/actions/workflows/deploy.yml/badge.svg)](https://github.com/Nikolaiko/my-food-app-backend/actions/workflows/deploy.yml)
![Swift](https://img.shields.io/badge/Swift-6.2-orange?logo=swift)
![Vapor](https://img.shields.io/badge/Vapor-4-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)

Бэкенд приложения «Моё питание» ([ReceiptApp](https://github.com/Nikolaiko/my-food-app-ai-project)).
Хранит рецепты и по данным QR-кода кассового чека ФНС возвращает список
купленных продуктов.

Стек: **Swift 6.2**, **Vapor 4**, **Fluent** + **PostgreSQL**. Модели API
(`FoodRecipe`, `FoodProduct`, …) — отдельный таргет `Model` в этом же пакете.
Деплой через **Docker Compose** на VPS.

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
Наружу отдаются типы из таргета `Model` (`FoodRecipe`, `FoodProduct`), а в БД
лежат собственные Fluent-модели (`DBRecipeEntry`, `DBRecipeProductEntry`).
Маппинг между ними — в расширениях `+DBObject`.

```
routes.swift
 ├─► RecipeController ───► DataProvider ─────────────► Fluent (PostgreSQL)
 │                                                     DBRecipeEntry / DBRecipeProductEntry
 └─► ReceiptsController ─► QRDataParsingNetworkService ─► proverkacheka.com
                        └─► SimpleProductsParser  (название товара → FoodProductType, день покупки)

Все слои ──► Model (таргет Sources/Model): FoodRecipe, FoodProduct, QRCodeRawData, …
```

| Папка / файл | Назначение |
|---|---|
| `entrypoint.swift` | Точка входа (`@main`): окружение, логирование, запуск `Application` |
| `configure.swift` | Подключение к PostgreSQL, регистрация миграций, `autoMigrate`, роуты |
| `routes.swift` | Регистрация контроллеров |
| `Controllers/` | `RecipeController` (`/recipes`), `ReceiptsController` (`/receipts`) |
| `Service/DataProvider` | Работа с рецептами в БД: выборка, добавление и обновление в транзакциях |
| `Service/QRDataParsingNetworkService` | Запрос к API proverkacheka.com по сырой строке QR |
| `Service/SimpleProductsParser` | Определение `FoodProductType` по названию товара (поиск ключевых слов) и дня покупки |
| `Migrations/` | Схема БД, начальные данные и последующие изменения схемы |
| `Models/Database/` | Fluent-модели таблиц |
| `Models/Receipts/` | DTO ответа proverkacheka (`ReceiptData` → `json.items[]`, `json.dateTime`) |
| `Models/Extensions/` | `Content` для типов из `Model`, маппинг в DB-объекты и обратно |
| `Models/Errors/` | `CommonRequestError` → HTTP-статусы |
| `Consts/` | Имена и порты БД, имя и значение заголовка авторизации |

## API

Контракт описан OpenAPI-спекой в этом репозитории:
[`specs/backend_specs.yaml`](specs/backend_specs.yaml). Из неё генерируется
сетевой клиент iOS-приложения: скрипт `scripts/generate-backend-service.sh`
[клиента](https://github.com/Nikolaiko/my-food-app-ai-project) берёт спеку из
соседней папки `../my-food-app-backend`. Поэтому **при любом изменении API
обновляйте спеку** и перегенерируйте клиент.

| Метод | Путь | Тело запроса | Ответ | Авторизация |
|---|---|---|---|---|
| `GET` | `/recipes` | — | `[FoodRecipeShortInfo]` | да |
| `GET` | `/recipes/{recipeId}` | — | `FoodRecipe` | да |
| `POST` | `/recipes/add` | `NewFoodRecipe` (без id) | `FoodRecipe` с присвоенными id | да |
| `PUT` | `/recipes` | `FoodRecipeUpdate` (id рецепта, продукты без id) | `FoodRecipe` | да |
| `POST` | `/receipts/parse` | `QRCodeRawData` `{ "qrRawString": "t=…&s=…&fn=…" }` | `[FoodProduct]` | нет* |

\* Спека объявляет заголовок `auth` и для `/receipts/parse`, но сервер его
пока не проверяет.

**Авторизация** — заголовок `Auth` с фиксированным ключом (общий для всех
клиентов, не пользовательский токен). Нет заголовка или ключ не совпал → `401`.

**Входные модели** (`NewFoodRecipe`, `FoodRecipeUpdate`,
`NewFoodRecipeProductEntry`) не содержат id, которые присваивает сервер: в
`FoodRecipeUpdate` есть только id изменяемого рецепта. Лишние поля в запросе
игнорируются, поэтому клиент, который по-старому присылает `"id": ""`,
продолжает работать.

**Обновление рецепта** (`PUT /recipes`) меняет рецепт на месте в одной
транзакции: поля рецепта перезаписываются, продукты заменяются целиком и
получают новые id. Ответ — рецепт, перечитанный из БД. `POST /recipes/add`
отвечает так же.

**Ошибки** возвращаются стандартным телом Vapor `{ "error": true, "reason": "…" }`:

| Ошибка | Статус |
|---|---|
| `notAuthotized` | `401` |
| `notFound` | `404` |
| `unableToGetParameter` / `unableToParseParameter` | `400` |
| `urlError` / `emptyResponse` | `500` |
| `wrongStatusCode(n)` — proverkacheka ответил не-2xx | `n` |

**Количество продукта в рецепте** `FoodRecipeProductEntry.quantities` — массив
`{ "count": 500, "quantityMeasure": 1 }`: одно и то же количество в разных
единицах (например, 4 шт или 500 г). Массив может быть пустым.

**Пищевая ценность рецепта** — `proteins`, `fats`, `carbohydrates` (г) и
`calories` (ккал) на порцию, дробные числа, задаются вручную. Поля
необязательные: не указанное значение в ответе отсутствует, в запросе его можно
не передавать или передать `null`; `0` — настоящее значение. Есть в
`FoodRecipe`, `FoodRecipeShortInfo` и входных моделях. `PUT` без этих полей
сбрасывает их.

**Дата продукта** `FoodProduct.date` — день покупки строкой `YYYY-MM-DD`
(`"2026-07-12"`), как `format: date` в спеке. Откуда берётся день — в
[Про данные чека](#про-данные-чека).

## Про данные чека

QR-код чека ФНС содержит **только фискальные реквизиты** (`t,s,fn,i,fp,n`), а
не список товаров. Поэтому `/receipts/parse`:

1. принимает сырую строку QR (`QRCodeRawData.qrRawString`);
2. отправляет её как есть, в том числе без `t`, в
   `https://proverkacheka.com/api/v1/check/get` (form-urlencoded, `token` + `qrraw`);
3. из ответа берёт `data.json.items[]` и `data.json.dateTime`;
4. определяет день покупки (`SimpleProductsParser.purchaseDay`) по первому
   подходящему источнику: `data.json.dateTime` (`2024-01-17T11:26:00` →
   `2024-01-17`), иначе параметр `t` из QR (`t=20240117T1126` → `2024-01-17`),
   иначе сегодняшний день по UTC. Берётся только дата, как на чеке (время
   кассы), без пересчёта часовых поясов;
5. каждую позицию превращает в `FoodProduct` через `SimpleProductsParser`:
   тип определяется поиском ключевых слов в названии (яблоко, молоко, томаты,
   лук зелёный/красный…), иначе `.unknown`. Количество округляется вверх,
   `quantityType` = `.unknown`, `date` = день покупки из п. 4, `id` — новый UUID.

Новый тип продукта = новый case в `FoodProductType` (таргет `Model`) + ключевые
слова в `SimpleProductsParser`.

## База данных

PostgreSQL, схема создаётся миграциями (порядок важен — см. `configure.swift`):

| Миграция | Что делает |
|---|---|
| `CreateDBSchema` | Таблицы `recipe` (name, description, shortDescription) и `recipe-product-entry` (count, quantityMeasure, productType, `recipe_id` → `recipe.id` с `ON DELETE CASCADE`) |
| `AddInitialRecipes` | Добавляет стартовый рецепт «Овощной салат» с тремя продуктами |
| `ChangeQuantityToFloat` | Меняет тип `recipe-product-entry.count` с `int64` на `float` |
| `AddRecipeTags` | Добавляет в `recipe` колонку `tags` (`bigint[]`, по умолчанию пустой массив) |
| `MoveCountToQuantities` | Заменяет `count` и `quantityMeasure` в `recipe-product-entry` колонкой `quantities` (`jsonb[]`): старая пара становится единственным элементом массива |
| `MakeRecipeColumnsNotNull` | Запрещает NULL в `name`, `description`, `shortDescription` таблицы `recipe` и в `recipe-product-entry.productType`; найденные NULL заменяет на пустую строку и `Unknown` |
| `AddRecipeNutrition` | Добавляет в `recipe` nullable-колонки `proteins`, `fats`, `carbohydrates`, `calories` (`double precision`); у существующих рецептов они `NULL` |

`productType` хранится строкой (raw value `FoodProductType`), `quantities` —
массивом JSON-объектов `{"count": …, "quantityMeasure": …}` (`quantityMeasure` —
raw value `FoodQuantityType`), `tags` — массивом чисел. Новую миграцию добавляйте
**в конец** списка в `configure.swift`, существующие не редактируйте.

DB-классы в миграциях не используйте: они меняются вместе с моделями, и старая
миграция на чистой БД писала бы в колонки, которых на её шаге ещё нет. Поэтому
`AddInitialRecipes` вставляет стартовый рецепт по именам колонок через SQLKit.

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

**Деплой по релизу.** Push в `main` прод не трогает. Выкатывает публикация
GitHub Release: `.github/workflows/deploy.yml` по SSH переключает репозиторий на
VPS на тег релиза (`git fetch --tags` → `git checkout --detach <тег>`) и выполняет
`docker compose up -d --build` → `docker image prune -f` → `docker builder prune -af`.
Build cache чистится целиком: `COPY . .` всё равно инвалидирует `swift build` при
любом изменении, а диск на VPS маленький (2026-09-27 деплой упал с
`no space left on device`). Ручной запуск
workflow принимает тег — так передеплоить релиз или откатиться на старый:

```bash
gh release create 1.0.0 --generate-notes   # тег на текущем main → деплой
gh workflow run deploy.yml -f tag=1.0.0    # передеплой / откат на тег
```

Черновик релиза (`--draft`) деплой не запускает — только публикация. Репозиторий
на сервере после деплоя стоит на теге (detached HEAD), `git pull` там не нужен.
Нужные секреты репозитория: `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_PORT`.
Сборка образа на сервере долгая, поэтому таймаут шага — 30 минут.

> Сервер собирается под Linux: для `URLSession` нужен `FoundationNetworking`
> (`#if canImport(FoundationNetworking)`), а в runtime-образе — `libcurl4`.
> Если добавляете сетевой код, не забывайте про условный импорт.

## Модели (таргет `Model`)

Типы, которые ходят через API, лежат в отдельном таргете `Model`
(`Sources/Model`), `App` его импортирует:

| Тип | Где используется |
|---|---|
| `FoodRecipe`, `FoodRecipeProductEntry`, `FoodRecipeQuantity` | тело запросов и ответов `/recipes` |
| `FoodProduct` | ответ `POST /receipts/parse` |
| `QRCodeRawData` | тело запроса `POST /receipts/parse` |
| `FoodProductType`, `FoodQuantityType` | тип продукта и единица измерения, хранятся в БД |

Раньше они подключались пакетом [my-foodapp-models](https://github.com/Nikolaiko/my-foodapp-models);
перенесены из его версии 1.0.9 — только то, что использует бэкенд. Зависимости
от пакета больше нет, модели меняются прямо здесь.

- `FoodProduct.date` — день покупки строкой `YYYY-MM-DD`, как `format: date`
  в спеке.
- Raw value `FoodProductType` (строки) и `FoodQuantityType` (числа 0, 1, 2… по
  порядку case) лежат в Postgres: существующие не меняйте, новые case добавляйте
  в конец.
- Модели — часть контракта с клиентом: поменяли модель — обновите
  [OpenAPI-спеку](#api).

## Тесты

```bash
swift test
```

Тестам моделей (`ModelTests`) и разбора чека (`AppTests/Receipts`) база не
нужна, они на swift-testing. Тестам, которые поднимают приложение через
`Application.testable()`, нужен отдельный PostgreSQL на порту **5433** с БД
`products_test` (перед каждым тестом делается `autoRevert` + `autoMigrate`):

```bash
docker run -d --name food-db-test -p 5433:5432 \
  -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -e POSTGRES_DB=products_test \
  postgres:16-alpine
```

Без этой базы тесты рецептов (`AppTests/Recipes`, XCTest + XCTVapor) падают.
Каждый тест поднимает приложение через `Application.withTestable`, который
гасит его и при ошибке.

## Планы и известные ограничения

- Вынести секреты (ключ `Auth`, токен proverkacheka) из кода в переменные окружения.
- Проверять `Auth` в `/receipts/parse`, как того требует спека.
- Заменить общий ключ на пользовательскую аутентификацию (сейчас `login`/`register`
  в клиенте — мок).
- Добавить CI на прогон `swift test` (с тестовым PostgreSQL).
- Зависимость `fluent-mongo-driver` подключена, но не используется.
