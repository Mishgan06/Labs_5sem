-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

SELECT a.accidentId, a.accidentDate,
       a.city, a.street, a.house,
       COUNT(ac.carId) AS participant_count
FROM gibdd.accidents AS a
JOIN gibdd.accident_cars AS ac
  ON ac.accidentId = a.accidentId
WHERE a.accidentDate BETWEEN '2025-01-01'
                         AND '2025-12-31'
GROUP BY a.accidentId, a.accidentDate,
         a.city, a.street, a.house
HAVING COUNT(ac.carId) >= 2
ORDER BY participant_count DESC,
         a.accidentDate, a.accidentId;
