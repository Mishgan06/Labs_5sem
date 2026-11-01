USE gibdd;
SET NAMES utf8mb4;
DROP FUNCTION IF EXISTS lr7_simple_car_count;
DROP FUNCTION IF EXISTS lr7_simple_year_count;
DELIMITER $$
CREATE FUNCTION lr7_simple_car_count(p_car_id INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_count INT DEFAULT 0;
    -- 1. Отрицательный результат -1 означает ошибочный параметр.
    IF p_car_id IS NULL OR p_car_id <= 0 THEN
        RETURN -1;
    END IF;
    -- 2. Положительный код тоже нужно проверить на существование.
    SELECT COUNT(*) INTO v_exists
    FROM gibdd.cars WHERE carId = p_car_id;
    IF v_exists = 0 THEN
        RETURN -1;
    END IF;
    -- 3. Считаем участия; составной ключ исключает дубли одного ДТП.
    SELECT COUNT(*) INTO v_count
    FROM gibdd.accident_cars WHERE carId = p_car_id;
    RETURN v_count;
END$$

CREATE FUNCTION lr7_simple_year_count(p_year INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_month INT DEFAULT 1;
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    -- 1. Проверяем год; -1 нельзя спутать с нулём ДТП.
    IF p_year IS NULL OR p_year < 1901 OR p_year > 2155 THEN
        RETURN -1;
    END IF;
    -- 2. Цикл считает происшествия для каждого из 12 месяцев.
    WHILE v_month <= 12 DO
        SELECT COUNT(*) INTO v_count
        FROM gibdd.accidents
        WHERE YEAR(accidentDate) = p_year
          AND MONTH(accidentDate) = v_month;
        SET v_total = v_total + v_count;
        SET v_month = v_month + 1;
    END WHILE;
    -- 3. Функция возвращает одно целое число.
    RETURN v_total;
END$$
DELIMITER ;
