USE gibdd;
SET NAMES utf8mb4;
SELECT VERSION() AS mysql_version, DATABASE() AS current_database;
SELECT 'citizens' AS table_name, COUNT(*) AS row_count FROM citizens
UNION ALL SELECT 'cars', COUNT(*) FROM cars
UNION ALL SELECT 'accidents', COUNT(*) FROM accidents
UNION ALL SELECT 'accident_cars', COUNT(*) FROM accident_cars
UNION ALL SELECT 'sales', COUNT(*) FROM sales;
SELECT YEAR(accidentDate) AS report_year, MONTH(accidentDate) AS report_month,
       COUNT(*) AS accident_count FROM accidents
GROUP BY YEAR(accidentDate), MONTH(accidentDate)
ORDER BY report_year, report_month;
SELECT c.carId, COUNT(ac.accidentId) AS accident_count
FROM cars c LEFT JOIN accident_cars ac ON ac.carId = c.carId
GROUP BY c.carId ORDER BY c.carId;
SHOW VARIABLES WHERE Variable_name IN ('log_bin', 'log_bin_trust_function_creators');
