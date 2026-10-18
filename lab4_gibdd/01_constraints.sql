-- Выполнить ОДИН раз после создания пустых таблиц.
-- Требуется MySQL 8.0.16 или новее: ранние версии не исполняют CHECK.
USE gibdd;
ALTER TABLE cars
  ADD CONSTRAINT chk_cars_power CHECK (power > 0),
  ADD CONSTRAINT chk_cars_max_speed CHECK (maxSpeed > 0),
  ADD CONSTRAINT chk_cars_price CHECK (price >= 0),
  ADD CONSTRAINT chk_cars_year
    CHECK (releaseYear BETWEEN 1901 AND 2155);
ALTER TABLE sales
  ADD CONSTRAINT chk_sales_parties CHECK (sellerId <> buyerId);
