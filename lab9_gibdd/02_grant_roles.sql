-- ROOT. Права администратора ограничены одной БД.
GRANT ALL PRIVILEGES ON gibdd.*
TO 'lr9_role_admin'@'%' WITH GRANT OPTION;
-- Общая роль чтения не раскрывает граждан, паспорта и продажи.
GRANT SELECT ON gibdd.cars TO 'lr9_role_reader'@'%';
GRANT SELECT ON gibdd.accidents TO 'lr9_role_reader'@'%';
GRANT SELECT ON gibdd.accident_cars TO 'lr9_role_reader'@'%';
-- Одна роль назначена одному пользователю, другая — двум.
GRANT 'lr9_role_admin'@'%' TO 'lr9_admin'@'localhost'
WITH ADMIN OPTION;
GRANT 'lr9_role_reader'@'%' TO 'lr9_analyst'@'localhost';
GRANT 'lr9_role_reader'@'%' TO 'lr9_inspector'@'localhost';
-- Дополнительные табличные права инспектора без DELETE.
GRANT INSERT,UPDATE ON gibdd.accidents
TO 'lr9_inspector'@'localhost';
GRANT INSERT,UPDATE ON gibdd.accident_cars
TO 'lr9_inspector'@'localhost';
-- Самостоятельная команда №1: роли автоматически активны после нового входа.
SET DEFAULT ROLE 'lr9_role_admin'@'%' TO 'lr9_admin'@'localhost';
SET DEFAULT ROLE 'lr9_role_reader'@'%'
TO 'lr9_analyst'@'localhost','lr9_inspector'@'localhost';
