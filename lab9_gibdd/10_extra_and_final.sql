-- ROOT. Рисунок 14: самостоятельная команда №2 — изменение состояния пароля.
ALTER USER 'lr9_empty'@'localhost' PASSWORD EXPIRE;
SELECT User,Host,account_locked,password_expired
FROM mysql.user WHERE User='lr9_empty';
-- Рисунок 15: глобальные флаги, динамические глобальные права и исходные записи.
SELECT User,Host,Select_priv,Insert_priv,Update_priv,Delete_priv,
       Create_priv,Drop_priv,Grant_priv,Create_user_priv
FROM mysql.user WHERE User LIKE 'lr9\_%' ORDER BY User;
SELECT COUNT(*) AS dynamic_global_grants
FROM mysql.global_grants WHERE USER LIKE 'lr9\_%';
SELECT 'citizens' AS table_name,COUNT(*) AS row_count FROM gibdd.citizens
UNION ALL SELECT 'cars',COUNT(*) FROM gibdd.cars
UNION ALL SELECT 'accidents',COUNT(*) FROM gibdd.accidents
UNION ALL SELECT 'accident_cars',COUNT(*) FROM gibdd.accident_cars
UNION ALL SELECT 'sales',COUNT(*) FROM gibdd.sales;
SELECT COUNT(*) AS test_rows_left FROM gibdd.accidents WHERE city='LR9_TEST';
