-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

SELECT COUNT(*) AS car_count,
       MIN(price) AS min_price,
       MAX(price) AS max_price,
       ROUND(AVG(price), 2) AS avg_price,
       SUM(price) AS total_price
FROM gibdd.cars;
