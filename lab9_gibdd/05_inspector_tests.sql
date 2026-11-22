-- ОТДЕЛЬНОЕ СОЕДИНЕНИЕ lr9_inspector, не root.
USE gibdd;
SELECT CURRENT_USER() AS matched_account,CURRENT_ROLE() AS active_roles;
-- Рисунок 7A: выполнить до SELECT включительно, снять вставленную строку.
START TRANSACTION;
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES ('2025-11-01','12:00:00','LR9_TEST','Inspector','1');
SET @lr9_accident_id=LAST_INSERT_ID();
SELECT accidentId,accidentDate,city FROM accidents
WHERE accidentId=@lr9_accident_id;
-- Рисунок 7B: выполнить отдельно, ожидается 0 после отката.
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback FROM accidents
WHERE accidentId=@lr9_accident_id;
-- Рисунок 8: отдельно. Ожидается Error 1142: DELETE command denied.
-- Несуществующий ключ исключает удаление настоящих участий даже при ошибке прав.
DELETE FROM accident_cars WHERE accidentId=-1 AND carId=-1;
