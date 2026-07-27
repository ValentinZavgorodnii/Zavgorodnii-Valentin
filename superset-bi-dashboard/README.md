# E-Commerce Analytics & RFM Dashboard

---

## О проекте

Интерактивная панель управления для отдела маркетинга на базе Apache Superset. Дашборд подключён к витрине данных PostgreSQL, построенной на основе реальных транзакций интернет-магазина.

**Целевая аудитория:** Маркетологи, продуктовые менеджеры, аналитики.

**Бизнес-ценность:** Позволяет оперативно отслеживать структуру клиентской базы, динамику продаж и удержание пользователей без необходимости писать SQL-запросы.

---

## Ключевые метрики и визуализации

| Виджет | Тип | Что показывает |
| --- | --- | --- |
| **Total Revenue** | Big Number | Общая выручка за всё время |
| **Total Customers** | Big Number | Количество уникальных клиентов |
| **Revenue Trends** | Line Chart | Динамика выручки по месяцам (MoM) |
| **RFM Segmentation** | Treemap / Donut | Распределение клиентов по 5 сегментам: Champions, Loyal, Potential, At Risk, и др. |
| **Retention Heatmap** | Heatmap | Когортная матрица удержания (% возврата клиентов по месяцам жизни) |

### Логика расчёта метрик

| Метрика | Формула / Описание |
| --- | --- |
| **Total Revenue** | `SUM(quantity * unit_price)` по всем заказам |
| **Total Customers** | `COUNT(DISTINCT customer_id)` |
| **RFM-сегментация** | Клиенты сегментированы на основе Recency, Frequency, Monetary (квантильный метод) |
| **Retention** | Доля клиентов когорты, совершивших покупку в месяце `n` от месяца привлечения |



### Использованные таблицы

| Таблица | Описание |
| --- | --- |
| `online_retail_core` | Основная таблица сырых транзакций |
| `cohort_retention` | Витрина с когортной матрицей удержания |
| `rfm_segments` | RFM-скоринг и сегменты клиентов |

---


## Технологический стек

| Компонент | Технология | Назначение |
| --- | --- | --- |
| **База данных** | PostgreSQL | Хранение витрин данных |
| **BI-система** | Apache Superset | Визуализация и дашборды |
| **Инфраструктура** | Docker & Docker Compose | Контейнеризация и оркестрация |
| **Кэширование** | Redis | Ускорение загрузки дашборда |
| **Обработка данных** | Python (Pandas, SQLAlchemy) | Подготовка витрин |

---

## Запуск проекта

### 1. Клонируйте репозиторий

```bash
git clone <URL>
cd superset-bi-dashboard

```

### 2. Настройте переменные окружения

Создайте файл `.env` в корне проекта:

```env
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin
POSTGRES_DB=ecommerce
SUPERSET_ADMIN_USER=admin
SUPERSET_ADMIN_PASSWORD=admin

```

### 3. Запустите инфраструктуру

```bash
docker-compose up -d

```

### 4. Подключитесь к Superset

* Откройте браузер: `http://localhost:8088`
* Логин: `admin` / пароль: `admin` (или из `.env`)
* В интерфейсе Superset добавьте коннект к PostgreSQL:
* **Host:** `postgres`
* **Database:** `ecommerce`
* **Username:** `admin` (из `.env`)



---

## Обновление данных

Дашборд работает на основе витрин в PostgreSQL. Для обновления расчётов можно запустить SQL-скрипты витрин (например, пересоздание `VIEW cohort_retention`).

**Планируемый интервал обновления:** ежедневно.

---


## Контакты

**Автор:** Valentin Zavgorodnii
**Telegram:** [@waka0waka](https://t.me/waka0waka)
**GitHub:** [ValentinZavgorodnii](https://github.com/ValentinZavgorodnii)