USE gibdd;
-- Каждый CALL выполнять отдельно: ошибка 1644 / SQLSTATE 45000 ожидаема.
CALL lr6_car_card(NULL);
CALL lr6_car_card(0);
CALL lr6_car_card(-1);
CALL lr6_car_card(999999);
CALL lr6_accidents_by_month(NULL);
CALL lr6_accidents_by_month(1900);
CALL lr6_accidents_by_month(2156);
-- После любой ошибки отдельно проверить сброс сессионного результата:
SELECT @lr6_status, @lr6_last_accident_count, @lr6_last_year_total;
