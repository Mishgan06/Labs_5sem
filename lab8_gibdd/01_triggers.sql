USE gibdd;
SET NAMES utf8mb4;
DROP TRIGGER IF EXISTS lr8_bi_accident_date;
DROP TRIGGER IF EXISTS lr8_bu_car_year;
DROP TRIGGER IF EXISTS lr8_bd_last_participant;
DELIMITER $$
CREATE TRIGGER lr8_bi_accident_date
BEFORE INSERT ON accidents
FOR EACH ROW
BEGIN
    -- 1. NEW содержит добавляемое происшествие.
    -- 2. Дата ДТП не должна быть позже даты сервера.
    IF NEW.accidentDate > CURRENT_DATE() THEN
        -- 3. Отменяем недопустимую вставку.
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'LR8: future accident date';
    END IF;
END$$

CREATE TRIGGER lr8_bu_car_year
BEFORE UPDATE ON cars
FOR EACH ROW
BEGIN
    -- 1. Проверяем только изменение года выпуска.
    IF NEW.releaseYear <> OLD.releaseYear THEN
        -- 2. Автомобиль не мог участвовать в ДТП до выпуска.
        IF EXISTS (
            SELECT 1
            FROM accident_cars ac
            JOIN accidents a ON a.accidentId=ac.accidentId
            WHERE ac.carId=OLD.carId
              AND YEAR(a.accidentDate) < NEW.releaseYear
        ) THEN
            -- 3. Отклоняем противоречивое исправление года.
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'LR8: car newer than accident';
        END IF;
    END IF;
END$$

CREATE TRIGGER lr8_bd_last_participant
BEFORE DELETE ON accident_cars
FOR EACH ROW
BEGIN
    DECLARE v_count INT DEFAULT 0;
    -- 1. OLD указывает удаляемое участие автомобиля.
    SELECT COUNT(*) INTO v_count
    FROM accident_cars
    WHERE accidentId=OLD.accidentId;
    -- 2. Удаление разрешено, пока останутся другие участники.
    IF v_count <= 1 THEN
        -- 3. Сохраняем последнего участника происшествия.
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'LR8: last participant';
    END IF;
END$$
DELIMITER ;
