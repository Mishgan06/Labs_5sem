USE gibdd;
SET NAMES utf8mb4;
-- Выполняйте по отмеченным блокам в том же учебном соединении.
-- Рисунки 4, 6 и 8 уже содержат ожидаемые ошибки. Их повторять не нужно.

-- 1. Сначала отмените незавершённую учебную транзакцию, затем проверьте остатки.
ROLLBACK;
SELECT COUNT(*) AS test_rows_left FROM accidents WHERE city='LR8_TEST';
SELECT a.accidentId,a.accidentDate,a.street,COUNT(ac.carId) AS participants
FROM accidents a LEFT JOIN accident_cars ac ON ac.accidentId=a.accidentId
WHERE a.city='LR8_TEST'
GROUP BY a.accidentId,a.accidentDate,a.street;
-- Если test_rows_left > 0: не удаляйте строки вслепую и не отключайте триггер.
-- Сохраните этот результат: запись могла быть ранее зафиксирована.

-- 2A. Рисунок 3: подготовка и доказательство успешного INSERT.
START TRANSACTION;
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES ('2025-11-01','12:00:00','LR8_TEST','Insert','1');
SET @lr8_insert_id=LAST_INSERT_ID();
SELECT accidentId,accidentDate,city FROM accidents
WHERE accidentId=@lr8_insert_id;
-- Снимите полученную строку ДО перехода к 2B.
-- 2B. Откат и контроль: ожидается 0. Снимите отдельно при необходимости.
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback FROM accidents
WHERE accidentId=@lr8_insert_id;

-- 3A. Рисунок 5: исходный год и разрешённый UPDATE.
START TRANSACTION;
SELECT carId,releaseYear AS year_before FROM cars WHERE carId=1;
UPDATE cars SET releaseYear=2021 WHERE carId=1;
SELECT carId,releaseYear AS year_after FROM cars WHERE carId=1;
-- Снимите year_after=2021 и при необходимости вкладку year_before=2020.
-- 3B. Откат; ожидается исходный год 2020.
ROLLBACK;
SELECT carId,releaseYear AS year_restored FROM cars WHERE carId=1;

-- 4A. Рисунок 7: полный блок с созданием ДТП и ДВУХ участников.
START TRANSACTION;
INSERT INTO accidents (accidentDate,accidentTime,city,street,house)
VALUES ('2025-11-01','12:00:00','LR8_TEST','Delete positive','1');
SET @lr8_delete_id=LAST_INSERT_ID();
INSERT INTO accident_cars (accidentId,carId)
VALUES (@lr8_delete_id,1),(@lr8_delete_id,2);
SET @lr8_before=(SELECT COUNT(*) FROM accident_cars
                WHERE accidentId=@lr8_delete_id);
DELETE FROM accident_cars
WHERE accidentId=@lr8_delete_id AND carId=1;
SELECT @lr8_before AS participants_before,
       COUNT(*) AS participants_after
FROM accident_cars WHERE accidentId=@lr8_delete_id;
-- Снимите 2/1. Если NULL/0: остановитесь, подготовка пропущена или соединение другое.
-- 4B. Обязательно выполните откат после снимка.
ROLLBACK;
SELECT COUNT(*) AS temporary_accidents_after_rollback FROM accidents
WHERE accidentId=@lr8_delete_id;

-- 5. Рисунок 9: ОТДЕЛЬНО покажите результаты трёх запросов.
SELECT 'citizens' AS table_name,COUNT(*) AS row_count FROM citizens
UNION ALL SELECT 'cars',COUNT(*) FROM cars
UNION ALL SELECT 'accidents',COUNT(*) FROM accidents
UNION ALL SELECT 'accident_cars',COUNT(*) FROM accident_cars
UNION ALL SELECT 'sales',COUNT(*) FROM sales;
SELECT carId,releaseYear FROM cars WHERE carId=1;
SELECT COUNT(*) AS test_rows_left FROM accidents WHERE city='LR8_TEST';
-- На исходном наборе: 10,10,5,10,5; год 2020; test_rows_left=0.
-- Если после ROLLBACK остаётся 1: нужен разбор конкретной записи из блока 1.
