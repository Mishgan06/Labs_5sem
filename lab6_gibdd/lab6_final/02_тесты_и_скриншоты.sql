USE gibdd;
-- Рисунок 3: список всех процедур базы.
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'gibdd'
  AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
-- Рисунок 4: год с ДТП; ожидается 5.
CALL lr6_simple_year(2025);
SELECT @lr6_total AS total;
-- Рисунок 5: год без ДТП; ожидается 0.
CALL lr6_simple_year(2024);
SELECT @lr6_total AS total;
-- Рисунок 6: допустимые границы.
CALL lr6_simple_year(1901);
CALL lr6_simple_year(2155);
-- Рисунок 7: неверные годы; итог NULL.
-- Каждый CALL и SELECT запускать отдельно.
CALL lr6_simple_year(NULL);
SELECT @lr6_total AS total;
CALL lr6_simple_year(1900);
SELECT @lr6_total AS total;
CALL lr6_simple_year(2156);
SELECT @lr6_total AS total;
