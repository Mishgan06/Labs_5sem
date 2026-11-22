-- ROOT. Рисунок 12A: выборочные глобальные права на заблокированной lr9_demo.
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,ALTER,DROP ON *.*
TO 'lr9_demo'@'localhost' WITH GRANT OPTION;
SHOW GRANTS FOR 'lr9_demo'@'localhost';
-- Рисунок 12B: снять выданные права; возможность делегирования отзывается явно.
REVOKE ALL PRIVILEGES ON *.* FROM 'lr9_demo'@'localhost';
SHOW GRANTS FOR 'lr9_demo'@'localhost';
REVOKE GRANT OPTION ON *.* FROM 'lr9_demo'@'localhost';
SHOW GRANTS FOR 'lr9_demo'@'localhost';
