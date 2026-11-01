USE gibdd;
-- Рисунок 3: все процедуры базы.
SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'gibdd' AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
-- Рисунок 4: 2025, итог 5. Выполнить CALL, затем SELECT в том же сеансе.
CALL lr6_simple_year(2025);
SELECT @lr6_total AS total;
-- Рисунок 5: допустимый год без ДТП, итог 0.
CALL lr6_simple_year(2024);
SELECT @lr6_total AS total;
-- Рисунок 6: обе допустимые границы, итог 0 на контрольном наборе.
CALL lr6_simple_year(1901);
CALL lr6_simple_year(2155);
-- Рисунок 7: три ошибочных вызова, каждый отдельно; итог NULL.
CALL lr6_simple_year(NULL);
SELECT @lr6_total AS total;
CALL lr6_simple_year(1900);
SELECT @lr6_total AS total;
CALL lr6_simple_year(2156);
SELECT @lr6_total AS total;
