-- НЕ ОБЯЗАТЕЛЬНО. ROOT. Выполнять только после сдачи и только для созданных в ЛР9 имён.
-- Удаляет учебные учётные записи/роли; сама gibdd, её записи и программы сохраняются.
DROP USER IF EXISTS 'lr9_admin'@'localhost','lr9_analyst'@'localhost',
 'lr9_inspector'@'localhost','lr9_demo'@'localhost','lr9_empty'@'localhost';
DROP ROLE IF EXISTS 'lr9_role_admin'@'%','lr9_role_reader'@'%';
