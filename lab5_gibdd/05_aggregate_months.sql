-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

SELECT YEAR(accidentDate) AS accident_year,
       MONTH(accidentDate) AS accident_month,
       COUNT(*) AS accident_count
FROM gibdd.accidents
WHERE accidentDate BETWEEN '2025-01-01'
                       AND '2025-12-31'
GROUP BY YEAR(accidentDate), MONTH(accidentDate)
ORDER BY accident_year, accident_month;
