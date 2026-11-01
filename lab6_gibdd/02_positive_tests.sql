USE gibdd;
-- Выполнять в том же соединении: @-переменные привязаны к сессии.
SELECT VERSION() AS mysql_version, @@SESSION.sql_mode AS session_sql_mode;
CALL lr6_car_card(1);
SELECT @lr6_status, @lr6_last_accident_count; -- OK, 2
CALL lr6_car_card(9);
SELECT @lr6_status, @lr6_last_accident_count; -- OK, 0
CALL lr6_accidents_by_month(2025);
SELECT @lr6_status, @lr6_last_year_total; -- OK, 5
CALL lr6_accidents_by_month(2024);
SELECT @lr6_status, @lr6_last_year_total; -- OK, 0
CALL lr6_accidents_by_month(1901); -- нижняя допустимая граница
CALL lr6_accidents_by_month(2155); -- верхняя допустимая граница
SELECT ROUTINE_NAME, ROUTINE_TYPE, SQL_DATA_ACCESS
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'gibdd' AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
SHOW CREATE PROCEDURE gibdd.lr6_car_card;
SHOW CREATE PROCEDURE gibdd.lr6_accidents_by_month;
