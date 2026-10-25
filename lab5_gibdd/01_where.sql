-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

SELECT carId, brand, releaseYear, price, ownerId
FROM gibdd.cars
WHERE releaseYear >= 2020 AND price <= 1500000.00
ORDER BY price DESC, carId;
