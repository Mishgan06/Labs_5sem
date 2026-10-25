-- Дополнительные проверки качества. Только SELECT, без изменения учебной БД.
-- Это подготовленные запросы, а не протокол их выполнения.
-- Используйте только при наличии разрешённого SQL-редактора/QL-чарта.
-- Проверьте реальные схему и имена столбцов. Неполное имя таблицы
-- pr_1_gostinicy должно разрешаться через search_path вашего подключения.

-- 1. Типы столбцов и доступная схема.
SELECT table_schema, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'pr_1_gostinicy'
ORDER BY table_schema, ordinal_position;

-- 2. Полнота и уникальность идентификатора.
SELECT COUNT(*) AS rows_total,
       COUNT("№ в ГТИБД") AS ids_not_null,
       COUNT(DISTINCT "№ в ГТИБД") AS unique_ids,
       COUNT(*) - COUNT("№ в ГТИБД") AS ids_null
FROM pr_1_gostinicy;

-- 3. Повторения идентификатора: проверять смысл повторов до удаления.
SELECT "№ в ГТИБД", COUNT(*) AS occurrences,
       COUNT(DISTINCT "Класс") AS classes
FROM pr_1_gostinicy
WHERE "№ в ГТИБД" IS NOT NULL
GROUP BY "№ в ГТИБД"
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 50;

-- 4. Варианты одного написания после нормализации пробелов/регистра.
SELECT LOWER(BTRIM("Класс")) AS normalized_class,
       ARRAY_AGG(DISTINCT "Класс") AS original_variants,
       COUNT(*) AS rows_total
FROM pr_1_gostinicy
GROUP BY LOWER(BTRIM("Класс"))
HAVING COUNT(DISTINCT "Класс") > 1
LIMIT 50;

-- 5. Пропуски группирующих полей.
SELECT SUM(CASE WHEN NULLIF(BTRIM("Класс"), '') IS NULL THEN 1 ELSE 0 END) AS missing_class,
       SUM(CASE WHEN NULLIF(BTRIM("Район"), '') IS NULL THEN 1 ELSE 0 END) AS missing_district
FROM pr_1_gostinicy;

-- 6. Нечисловые/пустые значения полей вместимости.
-- Проверка консервативная: допускаются только неотрицательные целые.
-- Ноль проверяется отдельно по смыслу, не объявляется автоматически ошибкой.
SELECT "№ в ГТИБД", "Кол-во комнат", "Кол-во спальных мест"
FROM pr_1_gostinicy
WHERE COALESCE(BTRIM("Кол-во комнат"::text), '') !~ '^[0-9]+$'
   OR COALESCE(BTRIM("Кол-во спальных мест"::text), '') !~ '^[0-9]+$'
LIMIT 50;
