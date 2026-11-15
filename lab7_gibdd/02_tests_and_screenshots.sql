USE gibdd;
SET NAMES utf8mb4;
-- Рисунок 2: список всех функций базы. Выделить и выполнить этот SELECT.
SELECT ROUTINE_NAME, ROUTINE_TYPE, DATA_TYPE, IS_DETERMINISTIC, SQL_DATA_ACCESS
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'gibdd' AND ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;
-- Рисунок 3: выполнить SET и SELECT вместе; ожидаются 1, 2, 9, 0.
SET @lr7_car_id = 1;
SET @lr7_no_accidents_car_id = 9;
SELECT @lr7_car_id AS car_id,
       lr7_simple_car_count(@lr7_car_id) AS accident_count,
       @lr7_no_accidents_car_id AS second_car_id,
       lr7_simple_car_count(@lr7_no_accidents_car_id) AS second_count;
-- Рисунок 4: все четыре результата равны -1, если 999999 отсутствует.
SELECT lr7_simple_car_count(NULL) AS null_id,
       lr7_simple_car_count(0) AS zero_id,
       lr7_simple_car_count(-1) AS negative_id,
       lr7_simple_car_count(999999) AS missing_id;
-- Рисунок 5: выполнить SET и SELECT вместе; ожидаются 2025, 5, 2024, 0.
SET @lr7_report_year = 2025;
SET @lr7_empty_year = 2024;
SELECT @lr7_report_year AS report_year,
       lr7_simple_year_count(@lr7_report_year) AS accident_count,
       @lr7_empty_year AS empty_year,
       lr7_simple_year_count(@lr7_empty_year) AS empty_count;
-- Рисунок 6: допустимые границы; ожидаются 0 и 0.
SELECT lr7_simple_year_count(1901) AS min_year,
       lr7_simple_year_count(2155) AS max_year;
-- Рисунок 7: недопустимые годы; ожидаются -1, -1, -1.
SELECT lr7_simple_year_count(NULL) AS null_year,
       lr7_simple_year_count(1900) AS below_min,
       lr7_simple_year_count(2156) AS above_max;
-- Рисунок 8: независимая проверка; столбцы каждой пары должны совпасть.
SELECT lr7_simple_car_count(1) AS function_car_1,
       (SELECT COUNT(*) FROM accident_cars WHERE carId = 1) AS direct_car_1,
       lr7_simple_car_count(9) AS function_car_9,
       (SELECT COUNT(*) FROM accident_cars WHERE carId = 9) AS direct_car_9,
       lr7_simple_year_count(2025) AS function_year,
       (SELECT COUNT(*) FROM accidents
        WHERE accidentDate >= '2025-01-01' AND accidentDate < '2026-01-01') AS direct_year;
