USE gibdd;
-- Рисунок 6. A: подготовка; у автомобиля 1 есть ДТП за 2025 год.
START TRANSACTION;
SELECT carId,releaseYear AS year_before FROM cars WHERE carId=1;
-- B: выполнить только UPDATE. Ожидается Error 1644: LR8: car newer than accident.
UPDATE cars SET releaseYear=2026 WHERE carId=1;
-- C: после скриншота ошибки выполнить отдельно; год остаётся 2020.
SELECT carId,releaseYear AS year_after_error FROM cars WHERE carId=1;
ROLLBACK;
