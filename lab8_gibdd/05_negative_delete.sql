USE gibdd;
-- Рисунок 8. A: создать временное ДТП с единственным участником.
START TRANSACTION;
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES ('2025-11-01','12:00:00','LR8_TEST','Delete negative','1');
SET @lr8_single_id=LAST_INSERT_ID();
INSERT INTO accident_cars (accidentId,carId) VALUES (@lr8_single_id,1);
-- B: выполнить только DELETE. Ожидается Error 1644: LR8: last participant.
DELETE FROM accident_cars WHERE accidentId=@lr8_single_id AND carId=1;
-- C: после скриншота ошибки выполнить отдельно; участник остался, затем откат.
SELECT COUNT(*) AS participants_after_error FROM accident_cars
WHERE accidentId=@lr8_single_id;
ROLLBACK;
SELECT COUNT(*) AS temporary_accidents_after_rollback FROM accidents
WHERE accidentId=@lr8_single_id;
