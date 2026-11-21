USE gibdd;
-- Рисунок 2: список всех триггеров базы.
SELECT TRIGGER_NAME,EVENT_MANIPULATION,ACTION_TIMING,EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA='gibdd'
ORDER BY TRIGGER_NAME;
-- Рисунок 9: после всех ROLLBACK сравнить с исходными значениями.
SELECT 'citizens' AS table_name,COUNT(*) AS row_count FROM citizens
UNION ALL SELECT 'cars',COUNT(*) FROM cars
UNION ALL SELECT 'accidents',COUNT(*) FROM accidents
UNION ALL SELECT 'accident_cars',COUNT(*) FROM accident_cars
UNION ALL SELECT 'sales',COUNT(*) FROM sales;
SELECT carId,releaseYear FROM cars WHERE carId=1;
SELECT COUNT(*) AS test_rows_left FROM accidents WHERE city='LR8_TEST';
