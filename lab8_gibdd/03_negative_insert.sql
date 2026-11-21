USE gibdd;
-- Рисунок 4. A: выполнить подготовку.
START TRANSACTION;
SET @lr8_accidents_before=(SELECT COUNT(*) FROM accidents);
-- B: выполнить только INSERT. Ожидается Error 1644: LR8: future accident date.
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES (CURRENT_DATE()+INTERVAL 1 DAY,'12:00:00','LR8_TEST','Future','1');
-- C: после скриншота ошибки выделить и выполнить оставшийся блок отдельно.
SELECT @lr8_accidents_before AS rows_before, COUNT(*) AS rows_after
FROM accidents;
ROLLBACK;
