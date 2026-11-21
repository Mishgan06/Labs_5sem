USE gibdd;
SET NAMES utf8mb4;
SELECT VERSION() AS mysql_version, DATABASE() AS db,
       CURRENT_DATE() AS server_date;
SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'gibdd' ORDER BY TABLE_NAME;
SELECT 'citizens' AS table_name, COUNT(*) AS row_count FROM citizens
UNION ALL SELECT 'cars', COUNT(*) FROM cars
UNION ALL SELECT 'accidents', COUNT(*) FROM accidents
UNION ALL SELECT 'accident_cars', COUNT(*) FROM accident_cars
UNION ALL SELECT 'sales', COUNT(*) FROM sales;
SELECT carId, releaseYear FROM cars WHERE carId IN (1,2);
SELECT MIN(YEAR(a.accidentDate)) AS first_accident_year
FROM accident_cars ac JOIN accidents a ON a.accidentId=ac.accidentId
WHERE ac.carId=1;
SHOW TRIGGERS FROM gibdd;
