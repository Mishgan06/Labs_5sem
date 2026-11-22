-- ROOT. Только заблокированная lr9_demo, рабочим пользователям *.* не выдаётся.
-- Рисунок 10A: показать все глобальные привилегии и блокировку входа.
GRANT ALL PRIVILEGES ON *.* TO 'lr9_demo'@'localhost';
SHOW GRANTS FOR 'lr9_demo'@'localhost';
SELECT User,Host,account_locked FROM mysql.user WHERE User='lr9_demo';
-- Рисунок 10B: выполнить обязательно, затем показать снятые права.
REVOKE ALL PRIVILEGES ON *.* FROM 'lr9_demo'@'localhost';
SHOW GRANTS FOR 'lr9_demo'@'localhost';
