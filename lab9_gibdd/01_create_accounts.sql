-- ROOT. Только локальный учебный сервер. Замените учебные пароли своими.
-- Пароли в комплекте опубликованы и не подходят для реального сервера.
-- Создание не сбрасывает существующие учётные записи: совпадение имени даст ошибку.
CREATE USER 'lr9_admin'@'localhost'
IDENTIFIED BY 'LR9_Admin_2026!Aa1';
CREATE USER 'lr9_analyst'@'localhost'
IDENTIFIED BY 'LR9_Analyst_2026!Aa1';
CREATE USER 'lr9_inspector'@'localhost'
IDENTIFIED BY 'LR9_Inspector_2026!Aa1';
-- Демонстрационные пользователи не могут входить на сервер.
CREATE USER 'lr9_demo'@'localhost'
IDENTIFIED BY 'LR9_Demo_2026!Aa1' ACCOUNT LOCK;
CREATE USER 'lr9_empty'@'localhost'
IDENTIFIED BY 'LR9_Empty_2026!Aa1' ACCOUNT LOCK;
-- Роли MySQL 8.0; host % является частью имени роли, не разрешением входа.
CREATE ROLE 'lr9_role_admin'@'%', 'lr9_role_reader'@'%';
