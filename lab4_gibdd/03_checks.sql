-- Раздел A: результаты для скриншотов (пять отдельных SELECT).
SET NAMES utf8mb4;
USE gibdd;
SELECT * FROM citizens ORDER BY citizenId;
SELECT * FROM cars ORDER BY carId;
SELECT * FROM accidents ORDER BY accidentId;
SELECT * FROM accident_cars ORDER BY accidentId, carId;
SELECT * FROM sales ORDER BY saleId;

-- Раздел B: количественная сверка; ожидаются 10, 10, 5, 10, 5.
SELECT 'citizens' AS table_name, COUNT(*) AS row_count FROM citizens
UNION ALL SELECT 'cars', COUNT(*) FROM cars
UNION ALL SELECT 'accidents', COUNT(*) FROM accidents
UNION ALL SELECT 'accident_cars', COUNT(*) FROM accident_cars
UNION ALL SELECT 'sales', COUNT(*) FROM sales;

-- В данной выборке покупатель последней продажи = текущий владелец.
-- Ожидаемый результат: 0 строк.
SELECT s.saleId, s.carId, s.buyerId, c.ownerId
FROM sales s
JOIN cars c ON c.carId = s.carId
WHERE NOT EXISTS (
  SELECT 1 FROM sales newer
  WHERE newer.carId = s.carId
    AND (newer.saleDate > s.saleDate OR
        (newer.saleDate = s.saleDate AND newer.saleId > s.saleId))
)
AND c.ownerId <> s.buyerId;

-- Ожидается 6 внешних ключей.
SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'gibdd'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Ожидается 5 действующих CHECK-ограничений после 01_constraints.sql.
SELECT TABLE_NAME, CONSTRAINT_NAME, ENFORCED
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'gibdd' AND CONSTRAINT_TYPE = 'CHECK'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Ожидается 5 таблиц InnoDB.
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'gibdd'
ORDER BY TABLE_NAME;
