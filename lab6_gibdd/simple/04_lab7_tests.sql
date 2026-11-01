USE gibdd;
-- Рисунок 4: все функции базы.
SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'gibdd' AND ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;
-- Рисунок 5: число ДТП автомобиля: ожидаются 2 и 0.
SET @car_id = 1;
SELECT @car_id AS carId, lr7_simple_car_count(@car_id) AS accident_count;
SET @car_id = 9;
SELECT @car_id AS carId, lr7_simple_car_count(@car_id) AS accident_count;
-- Рисунок 6: ошибки кода: ожидаются четыре значения -1.
SELECT lr7_simple_car_count(NULL) AS null_id,
       lr7_simple_car_count(0) AS zero_id,
       lr7_simple_car_count(-1) AS negative_id,
       lr7_simple_car_count(999999) AS missing_id;
-- Рисунок 7: итоги за годы: ожидаются 5 и 0.
SET @report_year = 2025;
SELECT @report_year AS report_year, lr7_simple_year_count(@report_year) AS accident_count;
SET @report_year = 2024;
SELECT @report_year AS report_year, lr7_simple_year_count(@report_year) AS accident_count;
-- Рисунок 8: допустимые границы: ожидаются 0 и 0.
SELECT lr7_simple_year_count(1901) AS min_year,
       lr7_simple_year_count(2155) AS max_year;
-- Рисунок 9: ошибки года: ожидаются три значения -1.
SELECT lr7_simple_year_count(NULL) AS null_year,
       lr7_simple_year_count(1900) AS below_min,
       lr7_simple_year_count(2156) AS above_max;
