-- Выполнить под root в MySQL 8.0.
SELECT VERSION() AS mysql_version, CURRENT_USER() AS admin_account;
SHOW DATABASES LIKE 'gibdd';
SELECT User,Host,account_locked FROM mysql.user
WHERE User LIKE 'lr9\_%' ORDER BY User,Host;
-- При первом запуске последняя выборка должна быть пустой.
-- Если имена заняты, не запускайте CREATE повторно без разбора учётных записей.
SELECT 'citizens' AS table_name,COUNT(*) AS row_count FROM gibdd.citizens
UNION ALL SELECT 'cars',COUNT(*) FROM gibdd.cars
UNION ALL SELECT 'accidents',COUNT(*) FROM gibdd.accidents
UNION ALL SELECT 'accident_cars',COUNT(*) FROM gibdd.accident_cars
UNION ALL SELECT 'sales',COUNT(*) FROM gibdd.sales;
