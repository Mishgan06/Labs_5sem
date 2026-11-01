-- ЛР6. Запросы для скриншотов. ВАЖНО: не выполнять файл целиком.

-- Выделять один CALL или один SELECT. Ошибки 1644 в рисунках 11–17 ожидаемы.

USE gibdd;

SET NAMES utf8mb4;

-- Рисунок 1: схема EER, см. подробную инструкцию.

-- Рисунки 2 и 3: готовые блок-схемы в отчёте.

-- Рисунок 4: список ВСЕХ процедур базы.

SELECT ROUTINE_NAME, ROUTINE_TYPE, SQL_DATA_ACCESS
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'gibdd' AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

-- Рисунок 5. Карточка. CALL и SELECT запускать отдельно в одном сеансе.

CALL gibdd.lr6_car_card(1);

SELECT @lr6_status AS status, @lr6_last_accident_count AS accident_count;

-- Рисунок 6. Карточка. CALL и SELECT запускать отдельно в одном сеансе.

CALL gibdd.lr6_car_card(9);

SELECT @lr6_status AS status, @lr6_last_accident_count AS accident_count;

-- Рисунок 7. Год 2025.

CALL gibdd.lr6_accidents_by_month(2025);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;

-- Рисунок 8. Год 2024.

CALL gibdd.lr6_accidents_by_month(2024);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;

-- Рисунок 9. Год 1901.

CALL gibdd.lr6_accidents_by_month(1901);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;

-- Рисунок 10. Год 2155.

CALL gibdd.lr6_accidents_by_month(2155);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;

-- Рисунок 11. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_car_card(NULL);

SELECT @lr6_status AS status, @lr6_last_accident_count AS accident_count;

-- Рисунок 12. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_car_card(0);

SELECT @lr6_status AS status, @lr6_last_accident_count AS accident_count;

-- Рисунок 13. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_car_card(-1);

SELECT @lr6_status AS status, @lr6_last_accident_count AS accident_count;

-- Рисунок 14. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_car_card(999999);

SELECT @lr6_status AS status, @lr6_last_accident_count AS accident_count;

-- Рисунок 15. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_accidents_by_month(NULL);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;

-- Рисунок 16. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_accidents_by_month(1900);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;

-- Рисунок 17. Выполнить только этот CALL; затем отдельно SELECT.

CALL gibdd.lr6_accidents_by_month(2156);

SELECT @lr6_status AS status, @lr6_last_year_total AS year_total;
