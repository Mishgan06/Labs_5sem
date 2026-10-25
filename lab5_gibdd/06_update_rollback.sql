-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

START TRANSACTION;

-- 6A. Снимок ДО изменения.
SELECT carId, brand, price
FROM gibdd.cars
WHERE carId = 10;

-- 6B. Изменение и снимок ПОСЛЕ.
UPDATE gibdd.cars
SET price = 900000.00
WHERE carId = 10 AND price = 850000.00;
SELECT carId, brand, price
FROM gibdd.cars
WHERE carId = 10;

-- 6C. Возврат к исходным данным и снимок.
ROLLBACK;
SELECT carId, brand, price
FROM gibdd.cars
WHERE carId = 10;
