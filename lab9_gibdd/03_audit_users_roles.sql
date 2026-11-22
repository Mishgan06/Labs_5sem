-- ROOT. Рисунок 2: пользователи и глобальные флаги из системной БД mysql.
SELECT User,Host,account_locked,Select_priv,Insert_priv,Update_priv,
       Delete_priv,Grant_priv,Create_user_priv
FROM mysql.user WHERE User LIKE 'lr9\_%' ORDER BY User,Host;
-- SELECT * FROM mysql.user — форма из методички, включает authentication_string.
-- Для отчёта выбраны поля без хешей паролей; таблица-источник та же.
-- Рисунок 3: эффективные права, включая назначенные роли.
SHOW GRANTS FOR 'lr9_admin'@'localhost'
USING 'lr9_role_admin'@'%';
SHOW GRANTS FOR 'lr9_analyst'@'localhost'
USING 'lr9_role_reader'@'%';
SHOW GRANTS FOR 'lr9_inspector'@'localhost'
USING 'lr9_role_reader'@'%';
-- Рисунок 4: список двух ролей и все три назначения.
SELECT u.User AS role_name,u.Host AS role_host,
       e.TO_USER AS assigned_user,e.TO_HOST AS assigned_host,
       e.WITH_ADMIN_OPTION
FROM mysql.user u LEFT JOIN mysql.role_edges e
  ON e.FROM_USER=u.User AND e.FROM_HOST=u.Host
WHERE u.User IN ('lr9_role_admin','lr9_role_reader')
ORDER BY role_name,assigned_user;
SELECT USER,HOST,DEFAULT_ROLE_USER,DEFAULT_ROLE_HOST
FROM mysql.default_roles WHERE USER LIKE 'lr9\_%' ORDER BY USER;
-- Рисунок 13: пользователи модели, имеющие доступ к gibdd через прямые права/роли.
-- Это права доступа, а не список открытых соединений.
WITH principals AS (
 SELECT User,Host,User gu,Host gh
 FROM mysql.user
 WHERE User IN
 ('lr9_admin','lr9_analyst','lr9_inspector')
 UNION ALL
 SELECT TO_USER,TO_HOST,FROM_USER,FROM_HOST
 FROM mysql.role_edges
 WHERE TO_USER IN
 ('lr9_admin','lr9_analyst','lr9_inspector')
)
SELECT DISTINCT p.User,p.Host,
 'gibdd' AS database_name
FROM principals p
LEFT JOIN mysql.db d ON d.User=p.gu
 AND d.Host=p.gh AND d.Db='gibdd'
LEFT JOIN mysql.tables_priv t ON t.User=p.gu
 AND t.Host=p.gh AND t.Db='gibdd'
WHERE d.Db IS NOT NULL OR t.Db IS NOT NULL
ORDER BY p.User;
