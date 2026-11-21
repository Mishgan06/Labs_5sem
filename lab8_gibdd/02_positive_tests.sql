USE gibdd;
SET NAMES utf8mb4;
-- Рисунок 3: выполнить весь блок INSERT до ROLLBACK включительно.
START TRANSACTION;
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES ('2025-11-01','12:00:00','LR8_TEST','Insert','1');
SET @lr8_insert_id=LAST_INSERT_ID();
SELECT accidentId,accidentDate,city FROM accidents
WHERE accidentId=@lr8_insert_id;
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback FROM accidents
WHERE accidentId=@lr8_insert_id;

-- Рисунок 5: автомобиль 1, исходный год 2020; допустимый новый год 2021.
START TRANSACTION;
SELECT carId,releaseYear AS year_before FROM cars WHERE carId=1;
UPDATE cars SET releaseYear=2021 WHERE carId=1;
SELECT carId,releaseYear AS year_after FROM cars WHERE carId=1;
ROLLBACK;
SELECT carId,releaseYear AS year_restored FROM cars WHERE carId=1;

-- Рисунок 7: временное ДТП с двумя участниками, удаление одного допустимо.
START TRANSACTION;
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES ('2025-11-01','12:00:00','LR8_TEST','Delete positive','1');
SET @lr8_delete_id=LAST_INSERT_ID();
INSERT INTO accident_cars (accidentId,carId)
VALUES (@lr8_delete_id,1),(@lr8_delete_id,2);
SET @lr8_before=(SELECT COUNT(*) FROM accident_cars
                WHERE accidentId=@lr8_delete_id);
DELETE FROM accident_cars WHERE accidentId=@lr8_delete_id AND carId=1;
SELECT @lr8_before AS participants_before,
       COUNT(*) AS participants_after FROM accident_cars
WHERE accidentId=@lr8_delete_id;
ROLLBACK;
SELECT COUNT(*) AS temporary_accidents_after_rollback FROM accidents
WHERE accidentId=@lr8_delete_id;
