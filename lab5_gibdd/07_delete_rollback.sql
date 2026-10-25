-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

START TRANSACTION;

-- 7A. Снимок ДО удаления: две строки.
SELECT accidentId, carId
FROM gibdd.accident_cars
WHERE accidentId = 5
ORDER BY carId;

-- 7B. Удаление и снимок ПОСЛЕ: одна строка.
DELETE FROM gibdd.accident_cars
WHERE accidentId = 5 AND carId = 10;
SELECT accidentId, carId
FROM gibdd.accident_cars
WHERE accidentId = 5
ORDER BY carId;

-- 7C. Восстановление и снимок: снова две строки.
ROLLBACK;
SELECT accidentId, carId
FROM gibdd.accident_cars
WHERE accidentId = 5
ORDER BY carId;
