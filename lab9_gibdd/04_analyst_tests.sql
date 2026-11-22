-- ОТДЕЛЬНОЕ СОЕДИНЕНИЕ lr9_analyst, не root.
USE gibdd;
-- Рисунок 5: выполнить в консольном клиенте (либо продублировать в Workbench).
SELECT USER() AS connection_identity,CURRENT_USER() AS matched_account,
       CURRENT_ROLE() AS active_roles;
SELECT accidentId,accidentDate FROM accidents ORDER BY accidentId LIMIT 5;
-- Рисунок 6: выполнить отдельно; ожидается Error 1142: UPDATE command denied.
-- Присваивание price=price не меняет данные даже при неверно расширенных правах.
UPDATE cars SET price=price WHERE carId=1;
