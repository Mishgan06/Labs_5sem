-- ЛР6. Вариант 13 «ГИБДД». MySQL 8.0. Выполнить целиком.
-- Изменяются только две процедуры ЛР6; исходные таблицы не меняются.
USE gibdd;
SET NAMES utf8mb4;
DROP PROCEDURE IF EXISTS lr6_car_card;
DROP PROCEDURE IF EXISTS lr6_accidents_by_month;
DELIMITER $$
CREATE PROCEDURE lr6_car_card(IN p_car_id INT)
READS SQL DATA
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_accidents INT DEFAULT 0;
    -- Сессионные результаты сбрасываются до проверки параметра.
    SET @lr6_status = 'ERROR', @lr6_last_accident_count = NULL;
    -- Ошибка формата идентификатора.
    IF p_car_id IS NULL OR p_car_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'carId must be a positive integer';
    END IF;
    SELECT COUNT(*) INTO v_exists FROM gibdd.cars WHERE carId = p_car_id;
    -- Отдельная ветка для отсутствующего автомобиля.
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Car with this carId does not exist';
    END IF;
    SELECT COUNT(*) INTO v_accidents
    FROM gibdd.accident_cars WHERE carId = p_car_id;
    -- LEFT JOIN сохраняет карточку автомобиля даже без участий в ДТП.
    SELECT c.carId, c.brand, c.releaseYear, c.price,
           p.citizenId, p.surname, p.name,
           v_accidents AS accident_count,
           CASE WHEN v_accidents = 0 THEN 'NO_ACCIDENTS'
                ELSE 'HAS_ACCIDENTS' END AS accident_status
    FROM gibdd.cars AS c
    LEFT JOIN gibdd.citizens AS p ON p.citizenId = c.ownerId
    WHERE c.carId = p_car_id;
    -- Результат доступен после CALL в том же соединении.
    SET @lr6_last_accident_count = v_accidents, @lr6_status = 'OK';
END$$

CREATE PROCEDURE lr6_accidents_by_month(IN p_year INT)
MODIFIES SQL DATA
BEGIN
    DECLARE v_month INT DEFAULT 1;
    DECLARE v_date DATE;
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Очистка временного результата при любой SQL-ошибке.
        DROP TEMPORARY TABLE IF EXISTS lr6_month_result;
        SET @lr6_status = 'ERROR', @lr6_last_year_total = NULL;
        RESIGNAL;
    END;
    SET @lr6_status = 'ERROR', @lr6_last_year_total = NULL;
    -- Ограничение диапазона соответствует принятому учебному диапазону лет.
    IF p_year IS NULL OR p_year < 1901 OR p_year > 2155 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Year must be between 1901 and 2155';
    END IF;
    DROP TEMPORARY TABLE IF EXISTS lr6_month_result;
    CREATE TEMPORARY TABLE lr6_month_result (
        month_no INT PRIMARY KEY,
        accident_count INT NOT NULL,
        month_status VARCHAR(10) NOT NULL
    );
    -- Цикл формирует все 12 месяцев, включая месяцы без ДТП.
    WHILE v_month <= 12 DO
        SET v_date = STR_TO_DATE(CONCAT(p_year, '-', LPAD(v_month, 2, '0'), '-01'), '%Y-%m-%d');
        SELECT COUNT(*) INTO v_count FROM gibdd.accidents
        WHERE accidentDate >= v_date
          AND accidentDate < DATE_ADD(v_date, INTERVAL 1 MONTH);
        -- Обе ветки сохраняют строку с понятной отметкой активности.
        IF v_count = 0 THEN
            INSERT INTO lr6_month_result VALUES (v_month, 0, 'NO_DATA');
        ELSE
            INSERT INTO lr6_month_result VALUES (v_month, v_count, 'HAS_DATA');
        END IF;
        SET v_total = v_total + v_count;
        SET v_month = v_month + 1;
    END WHILE;
    SELECT p_year AS report_year, month_no, accident_count, month_status
    FROM lr6_month_result ORDER BY month_no;
    -- Итог возвращается в переменную текущего соединения.
    SET @lr6_last_year_total = v_total, @lr6_status = 'OK';
    DROP TEMPORARY TABLE lr6_month_result;
END$$
DELIMITER ;
