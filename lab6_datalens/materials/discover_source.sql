-- Только SELECT. Методичка не сообщает имя исходной таблицы.
-- Выполняйте при наличии доступа к SQL на чтение в DataLens или своём SQL-клиенте.
-- 1. Таблицы/представления с ключевыми полями ДТП.
SELECT table_schema, table_name,
       COUNT(*) FILTER (WHERE column_name IN ('accident_id','datetime','latitude','longitude','region','light')) AS matching_fields
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog','information_schema')
GROUP BY table_schema, table_name
HAVING COUNT(*) FILTER (WHERE column_name IN ('accident_id','datetime','latitude','longitude','region','light')) >= 4
ORDER BY matching_fields DESC, table_schema, table_name;

-- 2. Список доступных полей для проверки имён категории и состояния дороги.
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE column_name IN ('accident_id','datetime','latitude','longitude','region','light',
                      'category','accident_category','road_conditions','road_condition',
                      'dead_count','injured_count','participant_gender',
                      'participant_years_of_driving_experience')
ORDER BY table_schema,table_name,ordinal_position;

-- До подготовки каких-либо сумм выберите реальную таблицу и проверьте:
-- COUNT(*) против COUNT(DISTINCT accident_id),
-- число разных dead_count/injured_count на один accident_id,
-- отсутствие конфликтов region/datetime/category/light внутри одного события.
-- Не выполняйте UPDATE/DELETE/ALTER учебного источника.
