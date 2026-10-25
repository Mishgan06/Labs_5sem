-- Только чтение. Ничего не создает, не удаляет и не заполняет.
SELECT VERSION() AS mysql_version,
       @@SESSION.sql_mode AS sql_mode,
       @@SESSION.sql_safe_updates AS safe_updates;
SHOW TABLES FROM gibdd;
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'gibdd' ORDER BY TABLE_NAME;
SELECT 'citizens' AS table_name, COUNT(*) AS row_count
FROM gibdd.citizens
UNION ALL SELECT 'cars', COUNT(*) FROM gibdd.cars
UNION ALL SELECT 'accidents', COUNT(*) FROM gibdd.accidents
UNION ALL SELECT 'accident_cars', COUNT(*) FROM gibdd.accident_cars
UNION ALL SELECT 'sales', COUNT(*) FROM gibdd.sales;
SELECT carId, brand, price FROM gibdd.cars WHERE carId = 10;
SELECT accidentId, carId FROM gibdd.accident_cars
WHERE accidentId = 5 ORDER BY carId;
