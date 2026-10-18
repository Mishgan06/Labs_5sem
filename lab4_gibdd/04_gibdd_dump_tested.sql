-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: gibdd
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `gibdd`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `gibdd` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `gibdd`;

--
-- Table structure for table `accident_cars`
--

DROP TABLE IF EXISTS `accident_cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accident_cars` (
  `accidentId` int NOT NULL,
  `carId` int NOT NULL,
  PRIMARY KEY (`accidentId`,`carId`),
  KEY `fk_accident_cars_cars` (`carId`),
  CONSTRAINT `fk_accident_cars_accidents` FOREIGN KEY (`accidentId`) REFERENCES `accidents` (`accidentId`),
  CONSTRAINT `fk_accident_cars_cars` FOREIGN KEY (`carId`) REFERENCES `cars` (`carId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accident_cars`
--

LOCK TABLES `accident_cars` WRITE;
/*!40000 ALTER TABLE `accident_cars` DISABLE KEYS */;
INSERT INTO `accident_cars` VALUES (1,1),(4,1),(1,2),(2,3),(3,4),(3,5),(2,6),(4,7),(5,8),(5,10);
/*!40000 ALTER TABLE `accident_cars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accidents`
--

DROP TABLE IF EXISTS `accidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accidents` (
  `accidentId` int NOT NULL AUTO_INCREMENT,
  `accidentDate` date NOT NULL,
  `accidentTime` time NOT NULL,
  `city` varchar(45) NOT NULL,
  `street` varchar(45) NOT NULL,
  `house` varchar(45) NOT NULL,
  PRIMARY KEY (`accidentId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accidents`
--

LOCK TABLES `accidents` WRITE;
/*!40000 ALTER TABLE `accidents` DISABLE KEYS */;
INSERT INTO `accidents` VALUES (1,'2025-08-12','08:35:00','Санкт-Петербург','Ленинский проспект','100'),(2,'2025-09-03','18:20:00','Санкт-Петербург','улица Типанова','12'),(3,'2025-09-17','14:10:00','Санкт-Петербург','Московский проспект','150'),(4,'2025-10-05','09:45:00','Санкт-Петербург','улица Седова','25'),(5,'2025-10-21','20:05:00','Санкт-Петербург','улица Бабушкина','40');
/*!40000 ALTER TABLE `accidents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cars`
--

DROP TABLE IF EXISTS `cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cars` (
  `carId` int NOT NULL AUTO_INCREMENT,
  `brand` varchar(50) NOT NULL,
  `power` int NOT NULL,
  `maxSpeed` int NOT NULL,
  `releaseYear` year NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `ownerId` int NOT NULL,
  PRIMARY KEY (`carId`),
  KEY `fk_cars_citizens` (`ownerId`),
  CONSTRAINT `fk_cars_citizens` FOREIGN KEY (`ownerId`) REFERENCES `citizens` (`citizenId`),
  CONSTRAINT `chk_cars_max_speed` CHECK ((`maxSpeed` > 0)),
  CONSTRAINT `chk_cars_power` CHECK ((`power` > 0)),
  CONSTRAINT `chk_cars_price` CHECK ((`price` >= 0)),
  CONSTRAINT `chk_cars_year` CHECK ((`releaseYear` between 1901 and 2155))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cars`
--

LOCK TABLES `cars` WRITE;
/*!40000 ALTER TABLE `cars` DISABLE KEYS */;
INSERT INTO `cars` VALUES (1,'Lada Vesta',106,178,2020,950000.00,2),(2,'Kia Rio',123,192,2019,1250000.00,3),(3,'Hyundai Solaris',123,192,2021,1450000.00,5),(4,'Renault Duster',114,167,2018,1300000.00,7),(5,'Skoda Octavia',150,223,2020,2100000.00,9),(6,'Volkswagen Polo',110,191,2017,1000000.00,1),(7,'Toyota Corolla',122,195,2022,2500000.00,4),(8,'Nissan Qashqai',144,194,2019,1950000.00,6),(9,'Ford Focus',125,193,2016,900000.00,8),(10,'Lada Granta',90,172,2023,850000.00,10);
/*!40000 ALTER TABLE `cars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `citizens`
--

DROP TABLE IF EXISTS `citizens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `citizens` (
  `citizenId` int NOT NULL AUTO_INCREMENT,
  `surname` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `passport` varchar(45) NOT NULL,
  `phone` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`citizenId`),
  UNIQUE KEY `uq_citizens_passport` (`passport`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `citizens`
--

LOCK TABLES `citizens` WRITE;
/*!40000 ALTER TABLE `citizens` DISABLE KEYS */;
INSERT INTO `citizens` VALUES (1,'Иванов','Алексей','4001 100001','+7-921-100-00-01'),(2,'Петрова','Мария','4001 100002','+7-921-100-00-02'),(3,'Смирнов','Дмитрий','4001 100003','+7-921-100-00-03'),(4,'Соколова','Анна','4001 100004','+7-921-100-00-04'),(5,'Кузнецов','Илья','4001 100005','+7-921-100-00-05'),(6,'Попова','Елена','4001 100006','+7-921-100-00-06'),(7,'Васильев','Михаил','4001 100007','+7-921-100-00-07'),(8,'Новикова','Ольга','4001 100008','+7-921-100-00-08'),(9,'Морозов','Андрей','4001 100009','+7-921-100-00-09'),(10,'Волкова','Ирина','4001 100010','+7-921-100-00-10');
/*!40000 ALTER TABLE `citizens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales` (
  `saleId` int NOT NULL AUTO_INCREMENT,
  `carId` int NOT NULL,
  `sellerId` int NOT NULL,
  `buyerId` int NOT NULL,
  `saleDate` date NOT NULL,
  PRIMARY KEY (`saleId`),
  KEY `fk_sales_cars` (`carId`),
  KEY `fk_sales_seller` (`sellerId`),
  KEY `fk_sales_buyer` (`buyerId`),
  CONSTRAINT `fk_sales_buyer` FOREIGN KEY (`buyerId`) REFERENCES `citizens` (`citizenId`),
  CONSTRAINT `fk_sales_cars` FOREIGN KEY (`carId`) REFERENCES `cars` (`carId`),
  CONSTRAINT `fk_sales_seller` FOREIGN KEY (`sellerId`) REFERENCES `citizens` (`citizenId`),
  CONSTRAINT `chk_sales_parties` CHECK ((`sellerId` <> `buyerId`))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` VALUES (1,1,1,2,'2024-10-15'),(2,2,2,3,'2025-02-10'),(3,3,4,5,'2025-03-21'),(4,4,6,7,'2025-05-18'),(5,5,8,9,'2025-07-09');
/*!40000 ALTER TABLE `sales` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-18 14:18:38
