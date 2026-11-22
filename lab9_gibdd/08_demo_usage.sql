-- ROOT. Рисунок 11A: созданная lr9_empty пока имеет только USAGE.
SHOW GRANTS FOR 'lr9_empty'@'localhost';
-- USAGE не даёт чтения/записи; GRANT OPTION всё же является правом делегирования.
GRANT USAGE ON *.* TO 'lr9_empty'@'localhost' WITH GRANT OPTION;
SHOW GRANTS FOR 'lr9_empty'@'localhost';
-- Рисунок 11B: убрать возможность делегирования, вход остаётся заблокированным.
REVOKE GRANT OPTION ON *.* FROM 'lr9_empty'@'localhost';
SHOW GRANTS FOR 'lr9_empty'@'localhost';
