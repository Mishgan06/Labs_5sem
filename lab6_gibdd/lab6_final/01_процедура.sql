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
  -- 1. Сбрасываем прошлый сессионный итог.
  SET @lr6_total = NULL;
  -- 2. Проверяем входной год.
  IF p_year IS NULL
     OR p_year < 1901 OR p_year > 2155 THEN
    SELECT
      'ERROR: year must be 1901..2155'
      AS message;
  ELSE
    -- 3. Считаем ДТП каждого из 12 месяцев.
    WHILE v_month <= 12 DO
      SELECT COUNT(*) INTO v_count
      FROM gibdd.accidents
      WHERE YEAR(accidentDate) = p_year
        AND MONTH(accidentDate) = v_month;
      SET v_total = v_total + v_count;
      SET v_month = v_month + 1;
    END WHILE;
    -- 4. Сохраняем и выводим итог.
    SET @lr6_total = v_total;
    SELECT p_year AS report_year,
           v_total AS accident_count;
  END IF;
END$$
DELIMITER ;
