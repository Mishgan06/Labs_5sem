USE gibdd;
SET NAMES utf8mb4;
DROP PROCEDURE IF EXISTS lr6_simple_year;
DELIMITER $$
CREATE PROCEDURE lr6_simple_year(IN p_year INT)
READS SQL DATA
BEGIN
    DECLARE v_month INT DEFAULT 1;
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    -- 1. Сбрасываем результат предыдущего вызова в этом соединении.
    SET @lr6_total = NULL;
    -- 2. Проверяем год: ошибка возвращается понятным сообщением.
    IF p_year IS NULL OR p_year < 1901 OR p_year > 2155 THEN
        SELECT 'ERROR: year must be 1901..2155' AS message;
    ELSE
        -- 3. Перебираем 12 месяцев и считаем ДТП каждого месяца.
        WHILE v_month <= 12 DO
            SELECT COUNT(*) INTO v_count
            FROM gibdd.accidents
            WHERE YEAR(accidentDate) = p_year
              AND MONTH(accidentDate) = v_month;
            SET v_total = v_total + v_count;
            SET v_month = v_month + 1;
        END WHILE;
        -- 4. Сохраняем итог в сессии и выдаём одну строку результата.
        SET @lr6_total = v_total;
        SELECT p_year AS report_year, v_total AS accident_count;
    END IF;
END$$
DELIMITER ;
