-- Лабораторная работа № 4. Вариант 13 «ГИБДД».
-- Эталонная структура по отчёту ЛР № 3, НЕ экспорт MySQL Workbench.
-- Основной путь по методичке: экспортировать собственную .mwb-модель.
-- Выполнять только на учебном сервере, где схема gibdd отсутствует.
-- Существующие БД и таблицы этот файл не удаляет.
SET NAMES utf8mb4;
CREATE DATABASE gibdd
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE gibdd;

CREATE TABLE citizens (
  citizenId INT NOT NULL AUTO_INCREMENT,
  surname VARCHAR(45) NOT NULL,
  name VARCHAR(45) NOT NULL,
  passport VARCHAR(45) NOT NULL,
  phone VARCHAR(45) NULL,
  PRIMARY KEY (citizenId),
  UNIQUE KEY uq_citizens_passport (passport)
) ENGINE=InnoDB;

CREATE TABLE cars (
  carId INT NOT NULL AUTO_INCREMENT,
  brand VARCHAR(50) NOT NULL,
  power INT NOT NULL,
  maxSpeed INT NOT NULL,
  releaseYear YEAR NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  ownerId INT NOT NULL,
  PRIMARY KEY (carId),
  CONSTRAINT fk_cars_citizens FOREIGN KEY (ownerId)
    REFERENCES citizens (citizenId)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE accidents (
  accidentId INT NOT NULL AUTO_INCREMENT,
  accidentDate DATE NOT NULL,
  accidentTime TIME NOT NULL,
  city VARCHAR(45) NOT NULL,
  street VARCHAR(45) NOT NULL,
  house VARCHAR(45) NOT NULL,
  PRIMARY KEY (accidentId)
) ENGINE=InnoDB;

CREATE TABLE accident_cars (
  accidentId INT NOT NULL,
  carId INT NOT NULL,
  PRIMARY KEY (accidentId, carId),
  CONSTRAINT fk_accident_cars_accidents
    FOREIGN KEY (accidentId) REFERENCES accidents (accidentId)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_accident_cars_cars
    FOREIGN KEY (carId) REFERENCES cars (carId)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE sales (
  saleId INT NOT NULL AUTO_INCREMENT,
  carId INT NOT NULL,
  sellerId INT NOT NULL,
  buyerId INT NOT NULL,
  saleDate DATE NOT NULL,
  PRIMARY KEY (saleId),
  CONSTRAINT fk_sales_cars FOREIGN KEY (carId)
    REFERENCES cars (carId)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_sales_seller FOREIGN KEY (sellerId)
    REFERENCES citizens (citizenId)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_sales_buyer FOREIGN KEY (buyerId)
    REFERENCES citizens (citizenId)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;
