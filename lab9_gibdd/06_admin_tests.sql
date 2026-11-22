-- ОТДЕЛЬНОЕ СОЕДИНЕНИЕ lr9_admin, не root.
USE gibdd;
-- Рисунок 9. Временная таблица существует только в данном соединении.
SELECT CURRENT_USER() AS matched_account,CURRENT_ROLE() AS active_roles;
CREATE TEMPORARY TABLE lr9_admin_probe (id INT PRIMARY KEY);
ALTER TABLE lr9_admin_probe ADD note VARCHAR(30);
INSERT INTO lr9_admin_probe VALUES (1,'LR9 admin check');
SHOW COLUMNS FROM lr9_admin_probe;
SELECT * FROM lr9_admin_probe;
DROP TEMPORARY TABLE lr9_admin_probe;
-- Рисунок 9B: администратор gibdd не является администратором всего сервера.
-- Выполнить отдельно. Ожидается Error 1142: SELECT command denied.
SELECT User,Host FROM mysql.user LIMIT 1;
