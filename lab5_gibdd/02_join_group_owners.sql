-- Лабораторная № 5. Вариант 13 «ГИБДД».
SET NAMES utf8mb4;

SELECT p.citizenId, p.surname, p.name,
       COUNT(DISTINCT c.carId) AS involved_cars,
       COUNT(DISTINCT a.accidentId) AS accident_count
FROM gibdd.citizens AS p
JOIN gibdd.cars AS c ON c.ownerId = p.citizenId
JOIN gibdd.accident_cars AS ac ON ac.carId = c.carId
JOIN gibdd.accidents AS a
  ON a.accidentId = ac.accidentId
WHERE a.accidentDate BETWEEN '2025-01-01'
                         AND '2025-12-31'
GROUP BY p.citizenId, p.surname, p.name
ORDER BY accident_count DESC, p.citizenId;
