/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.20-12.3.3-MariaDB, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: aime
-- ------------------------------------------------------
-- Server version	10.11.16-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `aime_card`
--

DROP TABLE IF EXISTS `aime_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `aime_card` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `access_code` varchar(20) NOT NULL,
  `idm` varchar(16) DEFAULT NULL,
  `chip_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT current_timestamp(),
  `last_login_date` timestamp NULL DEFAULT NULL,
  `is_locked` tinyint(1) DEFAULT 0,
  `is_banned` tinyint(1) DEFAULT 0,
  `memo` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aime_card_uk` (`user`,`access_code`),
  UNIQUE KEY `access_code` (`access_code`),
  UNIQUE KEY `idm` (`idm`),
  UNIQUE KEY `chip_id` (`chip_id`),
  CONSTRAINT `aime_card_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aime_card`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `aime_card` WRITE;
/*!40000 ALTER TABLE `aime_card` DISABLE KEYS */;
INSERT INTO `aime_card` VALUES
(34,1,'47032768188559557046',NULL,NULL,'2026-09-15 15:46:01',NULL,0,0,NULL);
/*!40000 ALTER TABLE `aime_card` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `aime_user`
--

DROP TABLE IF EXISTS `aime_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `aime_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(25) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `permissions` int(11) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT current_timestamp(),
  `last_login_date` timestamp NULL DEFAULT NULL,
  `suspend_expire_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aime_user`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `aime_user` WRITE;
/*!40000 ALTER TABLE `aime_user` DISABLE KEYS */;
INSERT INTO `aime_user` VALUES
(1,'Master','Master@fgo.local','',1,'2026-09-15 15:46:01',NULL,NULL);
/*!40000 ALTER TABLE `aime_user` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alembic_version`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `alembic_version` WRITE;
/*!40000 ALTER TABLE `alembic_version` DISABLE KEYS */;
INSERT INTO `alembic_version` VALUES
('d478fe5b757f');
/*!40000 ALTER TABLE `alembic_version` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `arcade`
--

DROP TABLE IF EXISTS `arcade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `arcade` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `country` varchar(3) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `arcade`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `arcade` WRITE;
/*!40000 ALTER TABLE `arcade` DISABLE KEYS */;
/*!40000 ALTER TABLE `arcade` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `arcade_owner`
--

DROP TABLE IF EXISTS `arcade_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `arcade_owner` (
  `user` int(11) NOT NULL,
  `arcade` int(11) NOT NULL,
  `permissions` int(11) NOT NULL,
  PRIMARY KEY (`user`,`arcade`),
  KEY `arcade` (`arcade`),
  CONSTRAINT `arcade_owner_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `arcade_owner_ibfk_2` FOREIGN KEY (`arcade`) REFERENCES `arcade` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `arcade_owner`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `arcade_owner` WRITE;
/*!40000 ALTER TABLE `arcade_owner` DISABLE KEYS */;
/*!40000 ALTER TABLE `arcade_owner` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `campaign`
--

DROP TABLE IF EXISTS `campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(127) NOT NULL,
  `announce_date` timestamp NULL DEFAULT NULL,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `distrib_start_date` timestamp NULL DEFAULT NULL,
  `distrib_end_date` timestamp NULL DEFAULT NULL,
  `info0` int(11) DEFAULT NULL,
  `info1` int(11) DEFAULT NULL,
  `info2` int(11) DEFAULT NULL,
  `info3` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `campaign` WRITE;
/*!40000 ALTER TABLE `campaign` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `campaign_game`
--

DROP TABLE IF EXISTS `campaign_game`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_game` (
  `campaign_id` int(11) NOT NULL,
  `game_id` varchar(5) NOT NULL,
  UNIQUE KEY `campaign_game_uk` (`campaign_id`,`game_id`),
  CONSTRAINT `campaign_game_ibfk_1` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_game`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `campaign_game` WRITE;
/*!40000 ALTER TABLE `campaign_game` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_game` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `campaign_progress`
--

DROP TABLE IF EXISTS `campaign_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_progress` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `is_participating` int(11) NOT NULL DEFAULT 0,
  `progress` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_progress_uk` (`campaign_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `campaign_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `campaign_progress_ibfk_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_progress`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `campaign_progress` WRITE;
/*!40000 ALTER TABLE `campaign_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_progress` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_character`
--

DROP TABLE IF EXISTS `chuni_item_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_character` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `characterId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  `skillId` int(11) DEFAULT NULL,
  `isNewMark` tinyint(1) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `friendshipExp` int(11) DEFAULT NULL,
  `assignIllust` int(11) DEFAULT NULL,
  `exMaxLv` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_character_uk` (`user`,`characterId`),
  CONSTRAINT `chuni_item_character_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_character`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_character` WRITE;
/*!40000 ALTER TABLE `chuni_item_character` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_character` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_cmission`
--

DROP TABLE IF EXISTS `chuni_item_cmission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_cmission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `missionId` int(11) NOT NULL,
  `point` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_cmission_uk` (`user`,`missionId`),
  CONSTRAINT `chuni_item_cmission_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_cmission`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_cmission` WRITE;
/*!40000 ALTER TABLE `chuni_item_cmission` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_cmission` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_cmission_progress`
--

DROP TABLE IF EXISTS `chuni_item_cmission_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_cmission_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `missionId` int(11) NOT NULL,
  `order` int(11) DEFAULT NULL,
  `stage` int(11) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_cmission_progress_uk` (`user`,`missionId`,`order`),
  CONSTRAINT `chuni_item_cmission_progress_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_cmission_progress`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_cmission_progress` WRITE;
/*!40000 ALTER TABLE `chuni_item_cmission_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_cmission_progress` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_duel`
--

DROP TABLE IF EXISTS `chuni_item_duel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_duel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `duelId` int(11) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `lastPlayDate` varchar(25) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `param3` int(11) DEFAULT NULL,
  `param4` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_duel_uk` (`user`,`duelId`),
  CONSTRAINT `chuni_item_duel_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_duel`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_duel` WRITE;
/*!40000 ALTER TABLE `chuni_item_duel` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_duel` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_favorite`
--

DROP TABLE IF EXISTS `chuni_item_favorite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_favorite` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `favId` int(11) NOT NULL,
  `favKind` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_favorite_uk` (`version`,`user`,`favId`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_item_favorite_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_favorite`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_favorite` WRITE;
/*!40000 ALTER TABLE `chuni_item_favorite` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_favorite` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_gacha`
--

DROP TABLE IF EXISTS `chuni_item_gacha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_gacha` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `gachaId` int(11) NOT NULL,
  `totalGachaCnt` int(11) DEFAULT 0,
  `ceilingGachaCnt` int(11) DEFAULT 0,
  `dailyGachaCnt` int(11) DEFAULT 0,
  `fiveGachaCnt` int(11) DEFAULT 0,
  `elevenGachaCnt` int(11) DEFAULT 0,
  `dailyGachaDate` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_gacha_uk` (`user`,`gachaId`),
  CONSTRAINT `chuni_item_gacha_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_gacha`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_gacha` WRITE;
/*!40000 ALTER TABLE `chuni_item_gacha` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_gacha` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_item`
--

DROP TABLE IF EXISTS `chuni_item_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `itemId` int(11) DEFAULT NULL,
  `itemKind` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_item_uk` (`user`,`itemId`,`itemKind`),
  CONSTRAINT `chuni_item_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_item` WRITE;
/*!40000 ALTER TABLE `chuni_item_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_linked_verse`
--

DROP TABLE IF EXISTS `chuni_item_linked_verse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_linked_verse` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `linkedVerseId` int(11) NOT NULL,
  `progress` varchar(255) DEFAULT NULL,
  `statusOpen` int(11) DEFAULT NULL,
  `statusUnlock` int(11) DEFAULT NULL,
  `isFirstClear` int(11) DEFAULT NULL,
  `numClear` int(11) DEFAULT NULL,
  `clearCourseId` int(11) DEFAULT NULL,
  `clearCourseLevel` int(11) DEFAULT NULL,
  `clearScore` int(11) DEFAULT NULL,
  `clearDate` varchar(25) DEFAULT NULL,
  `clearUserId1` int(11) DEFAULT NULL,
  `clearUserId2` int(11) DEFAULT NULL,
  `clearUserId3` int(11) DEFAULT NULL,
  `clearUserName0` varchar(20) DEFAULT NULL,
  `clearUserName1` varchar(20) DEFAULT NULL,
  `clearUserName2` varchar(20) DEFAULT NULL,
  `clearUserName3` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_linked_verse_uk` (`user`,`linkedVerseId`),
  CONSTRAINT `chuni_item_linked_verse_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_linked_verse`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_linked_verse` WRITE;
/*!40000 ALTER TABLE `chuni_item_linked_verse` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_linked_verse` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_login_bonus`
--

DROP TABLE IF EXISTS `chuni_item_login_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_login_bonus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `presetId` int(11) NOT NULL,
  `bonusCount` int(11) NOT NULL DEFAULT 0,
  `lastUpdateDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `isWatched` tinyint(1) DEFAULT 0,
  `isFinished` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_login_bonus_uk` (`version`,`user`,`presetId`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_item_login_bonus_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_login_bonus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_login_bonus` WRITE;
/*!40000 ALTER TABLE `chuni_item_login_bonus` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_login_bonus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_map`
--

DROP TABLE IF EXISTS `chuni_item_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_map` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `mapId` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `areaId` int(11) DEFAULT NULL,
  `routeNumber` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  `statusCount` int(11) DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_map_uk` (`user`,`mapId`),
  CONSTRAINT `chuni_item_map_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_map`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_map` WRITE;
/*!40000 ALTER TABLE `chuni_item_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_map` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_map_area`
--

DROP TABLE IF EXISTS `chuni_item_map_area`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_map_area` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `mapAreaId` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `isLocked` tinyint(1) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `statusCount` int(11) DEFAULT NULL,
  `remainGridCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_map_area_uk` (`user`,`mapAreaId`),
  CONSTRAINT `chuni_item_map_area_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_map_area`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_map_area` WRITE;
/*!40000 ALTER TABLE `chuni_item_map_area` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_map_area` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_matching`
--

DROP TABLE IF EXISTS `chuni_item_matching`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_matching` (
  `roomId` int(11) NOT NULL,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `restMSec` int(11) NOT NULL DEFAULT 60,
  `isFull` tinyint(1) NOT NULL DEFAULT 0,
  `matchingMemberInfoList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`matchingMemberInfoList`)),
  PRIMARY KEY (`roomId`,`version`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_item_matching_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_matching`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_matching` WRITE;
/*!40000 ALTER TABLE `chuni_item_matching` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_matching` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_print_detail`
--

DROP TABLE IF EXISTS `chuni_item_print_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_print_detail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `printDate` timestamp NOT NULL,
  `serialId` varchar(20) NOT NULL,
  `placeId` int(11) NOT NULL,
  `clientId` varchar(11) NOT NULL,
  `printerSerialId` varchar(20) NOT NULL,
  `printOption1` tinyint(1) DEFAULT 0,
  `printOption2` tinyint(1) DEFAULT 0,
  `printOption3` tinyint(1) DEFAULT 0,
  `printOption4` tinyint(1) DEFAULT 0,
  `printOption5` tinyint(1) DEFAULT 0,
  `printOption6` tinyint(1) DEFAULT 0,
  `printOption7` tinyint(1) DEFAULT 0,
  `printOption8` tinyint(1) DEFAULT 0,
  `printOption9` tinyint(1) DEFAULT 0,
  `printOption10` tinyint(1) DEFAULT 0,
  `created` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_print_detail_uk` (`serialId`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_item_print_detail_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_print_detail`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_print_detail` WRITE;
/*!40000 ALTER TABLE `chuni_item_print_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_print_detail` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_print_state`
--

DROP TABLE IF EXISTS `chuni_item_print_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_print_state` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `hasCompleted` tinyint(1) NOT NULL DEFAULT 0,
  `limitDate` timestamp NOT NULL DEFAULT '2037-12-31 16:00:00',
  `placeId` int(11) DEFAULT NULL,
  `cardId` int(11) DEFAULT NULL,
  `gachaId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_print_state_uk` (`id`,`user`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_item_print_state_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_print_state`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_print_state` WRITE;
/*!40000 ALTER TABLE `chuni_item_print_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_print_state` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_item_unlock_challenge`
--

DROP TABLE IF EXISTS `chuni_item_unlock_challenge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_item_unlock_challenge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `user` int(11) NOT NULL,
  `unlockChallengeId` int(11) NOT NULL,
  `status` int(11) DEFAULT NULL,
  `clearCourseId` int(11) DEFAULT NULL,
  `conditionType` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `life` int(11) DEFAULT NULL,
  `clearDate` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_item_unlock_challenge_uk` (`version`,`user`,`unlockChallengeId`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_item_unlock_challenge_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_item_unlock_challenge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_item_unlock_challenge` WRITE;
/*!40000 ALTER TABLE `chuni_item_unlock_challenge` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_item_unlock_challenge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_activity`
--

DROP TABLE IF EXISTS `chuni_profile_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `kind` int(11) DEFAULT NULL,
  `activityId` int(11) DEFAULT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `param3` int(11) DEFAULT NULL,
  `param4` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_activity_uk` (`user`,`kind`,`activityId`),
  CONSTRAINT `chuni_profile_activity_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_activity`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_activity` WRITE;
/*!40000 ALTER TABLE `chuni_profile_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_activity` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_charge`
--

DROP TABLE IF EXISTS `chuni_profile_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_charge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `chargeId` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `purchaseDate` varchar(25) DEFAULT NULL,
  `validDate` varchar(25) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `paramDate` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_charge_uk` (`user`,`chargeId`),
  CONSTRAINT `chuni_profile_charge_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_charge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_charge` WRITE;
/*!40000 ALTER TABLE `chuni_profile_charge` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_charge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_data`
--

DROP TABLE IF EXISTS `chuni_profile_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `exp` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `frameId` int(11) DEFAULT NULL,
  `isMaimai` tinyint(1) DEFAULT NULL,
  `trophyId` int(11) DEFAULT NULL,
  `trophyIdSub1` int(11) DEFAULT -1,
  `trophyIdSub2` int(11) DEFAULT -1,
  `userName` varchar(25) DEFAULT NULL,
  `isWebJoin` tinyint(1) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `lastGameId` varchar(25) DEFAULT NULL,
  `totalPoint` bigint(20) DEFAULT NULL,
  `characterId` int(11) DEFAULT NULL,
  `firstGameId` varchar(25) DEFAULT NULL,
  `friendCount` int(11) DEFAULT NULL,
  `lastPlaceId` int(11) DEFAULT NULL,
  `nameplateId` int(11) DEFAULT NULL,
  `totalMapNum` bigint(20) DEFAULT NULL,
  `lastAllNetId` int(11) DEFAULT NULL,
  `lastClientId` varchar(25) DEFAULT NULL,
  `lastPlayDate` varchar(25) DEFAULT NULL,
  `lastRegionId` int(11) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `totalHiScore` bigint(20) DEFAULT NULL,
  `webLimitDate` varchar(25) DEFAULT NULL,
  `firstPlayDate` varchar(25) DEFAULT NULL,
  `highestRating` int(11) DEFAULT NULL,
  `lastPlaceName` varchar(25) DEFAULT NULL,
  `multiWinCount` int(11) DEFAULT NULL,
  `acceptResCount` int(11) DEFAULT NULL,
  `lastRegionName` varchar(25) DEFAULT NULL,
  `lastRomVersion` varchar(25) DEFAULT NULL,
  `multiPlayCount` int(11) DEFAULT NULL,
  `firstRomVersion` varchar(25) DEFAULT NULL,
  `lastDataVersion` varchar(25) DEFAULT NULL,
  `requestResCount` int(11) DEFAULT NULL,
  `successResCount` int(11) DEFAULT NULL,
  `eventWatchedDate` varchar(25) DEFAULT NULL,
  `firstDataVersion` varchar(25) DEFAULT NULL,
  `reincarnationNum` int(11) DEFAULT NULL,
  `playedTutorialBit` int(11) DEFAULT NULL,
  `totalBasicHighScore` bigint(20) DEFAULT NULL,
  `totalExpertHighScore` bigint(20) DEFAULT NULL,
  `totalMasterHighScore` bigint(20) DEFAULT NULL,
  `totalRepertoireCount` bigint(20) DEFAULT NULL,
  `firstTutorialCancelNum` int(11) DEFAULT NULL,
  `totalAdvancedHighScore` bigint(20) DEFAULT NULL,
  `masterTutorialCancelNum` int(11) DEFAULT NULL,
  `ext1` int(11) DEFAULT NULL,
  `ext2` int(11) DEFAULT NULL,
  `ext3` int(11) DEFAULT NULL,
  `ext4` int(11) DEFAULT NULL,
  `ext5` int(11) DEFAULT NULL,
  `ext6` int(11) DEFAULT NULL,
  `ext7` int(11) DEFAULT NULL,
  `ext8` int(11) DEFAULT NULL,
  `ext9` int(11) DEFAULT NULL,
  `ext10` int(11) DEFAULT NULL,
  `extStr1` varchar(255) DEFAULT NULL,
  `extStr2` varchar(255) DEFAULT NULL,
  `extLong1` int(11) DEFAULT NULL,
  `extLong2` int(11) DEFAULT NULL,
  `mapIconId` int(11) DEFAULT NULL,
  `compatibleCmVersion` varchar(25) DEFAULT NULL,
  `medal` int(11) DEFAULT NULL,
  `voiceId` int(11) DEFAULT NULL,
  `teamId` int(11) DEFAULT NULL,
  `eliteRankPoint` int(11) DEFAULT 0,
  `stockedGridCount` int(11) DEFAULT 0,
  `netBattleLoseCount` int(11) DEFAULT 0,
  `netBattleHostErrCnt` int(11) DEFAULT 0,
  `netBattle4thCount` int(11) DEFAULT 0,
  `overPowerRate` int(11) DEFAULT 0,
  `battleRewardStatus` int(11) DEFAULT 0,
  `netBattle1stCount` int(11) DEFAULT 0,
  `charaIllustId` int(11) DEFAULT 0,
  `userNameEx` varchar(8) DEFAULT '',
  `netBattleWinCount` int(11) DEFAULT 0,
  `netBattleCorrection` int(11) DEFAULT 0,
  `classEmblemMedal` int(11) DEFAULT 0,
  `overPowerPoint` int(11) DEFAULT 0,
  `netBattleErrCnt` int(11) DEFAULT 0,
  `battleRankId` int(11) DEFAULT 0,
  `netBattle3rdCount` int(11) DEFAULT 0,
  `netBattleConsecutiveWinCount` int(11) DEFAULT 0,
  `overPowerLowerRank` int(11) DEFAULT 0,
  `classEmblemBase` int(11) DEFAULT 0,
  `battleRankPoint` int(11) DEFAULT 0,
  `netBattle2ndCount` int(11) DEFAULT 0,
  `totalUltimaHighScore` bigint(20) DEFAULT 0,
  `skillId` int(11) DEFAULT 0,
  `lastCountryCode` varchar(5) DEFAULT 'JPN',
  `isNetBattleHost` tinyint(1) DEFAULT 0,
  `battleRewardCount` int(11) DEFAULT 0,
  `battleRewardIndex` int(11) DEFAULT 0,
  `netBattlePlayCount` int(11) DEFAULT 0,
  `exMapLoopCount` int(11) DEFAULT 0,
  `netBattleEndState` int(11) DEFAULT 0,
  `rankUpChallengeResults` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`rankUpChallengeResults`)),
  `avatarBack` int(11) DEFAULT 0,
  `avatarFace` int(11) DEFAULT 0,
  `avatarPoint` int(11) DEFAULT 0,
  `avatarItem` int(11) DEFAULT 0,
  `avatarWear` int(11) DEFAULT 0,
  `avatarFront` int(11) DEFAULT 0,
  `avatarSkin` int(11) DEFAULT 0,
  `avatarHead` int(11) DEFAULT 0,
  `stageId` int(11) NOT NULL DEFAULT 99999,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_profile_uk` (`user`,`version`),
  KEY `teamId` (`teamId`),
  CONSTRAINT `chuni_profile_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chuni_profile_data_ibfk_2` FOREIGN KEY (`teamId`) REFERENCES `chuni_profile_team` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_data` WRITE;
/*!40000 ALTER TABLE `chuni_profile_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_data_ex`
--

DROP TABLE IF EXISTS `chuni_profile_data_ex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_data_ex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `ext1` int(11) DEFAULT NULL,
  `ext2` int(11) DEFAULT NULL,
  `ext3` int(11) DEFAULT NULL,
  `ext4` int(11) DEFAULT NULL,
  `ext5` int(11) DEFAULT NULL,
  `ext6` int(11) DEFAULT NULL,
  `ext7` int(11) DEFAULT NULL,
  `ext8` int(11) DEFAULT NULL,
  `ext9` int(11) DEFAULT NULL,
  `ext10` int(11) DEFAULT NULL,
  `ext11` int(11) DEFAULT NULL,
  `ext12` int(11) DEFAULT NULL,
  `ext13` int(11) DEFAULT NULL,
  `ext14` int(11) DEFAULT NULL,
  `ext15` int(11) DEFAULT NULL,
  `ext16` int(11) DEFAULT NULL,
  `ext17` int(11) DEFAULT NULL,
  `ext18` int(11) DEFAULT NULL,
  `ext19` int(11) DEFAULT NULL,
  `ext20` int(11) DEFAULT NULL,
  `medal` int(11) DEFAULT NULL,
  `extStr1` varchar(255) DEFAULT NULL,
  `extStr2` varchar(255) DEFAULT NULL,
  `extStr3` varchar(255) DEFAULT NULL,
  `extStr4` varchar(255) DEFAULT NULL,
  `extStr5` varchar(255) DEFAULT NULL,
  `voiceId` int(11) DEFAULT NULL,
  `extLong1` int(11) DEFAULT NULL,
  `extLong2` int(11) DEFAULT NULL,
  `extLong3` int(11) DEFAULT NULL,
  `extLong4` int(11) DEFAULT NULL,
  `extLong5` int(11) DEFAULT NULL,
  `mapIconId` int(11) DEFAULT NULL,
  `compatibleCmVersion` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_data_ex_uk` (`user`,`version`),
  CONSTRAINT `chuni_profile_data_ex_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_data_ex`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_data_ex` WRITE;
/*!40000 ALTER TABLE `chuni_profile_data_ex` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_data_ex` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_emoney`
--

DROP TABLE IF EXISTS `chuni_profile_emoney`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_emoney` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `ext1` int(11) DEFAULT NULL,
  `ext2` int(11) DEFAULT NULL,
  `ext3` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `emoneyBrand` int(11) DEFAULT NULL,
  `emoneyCredit` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_emoney_uk` (`user`,`emoneyBrand`),
  CONSTRAINT `chuni_profile_emoney_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_emoney`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_emoney` WRITE;
/*!40000 ALTER TABLE `chuni_profile_emoney` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_emoney` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_net_battle`
--

DROP TABLE IF EXISTS `chuni_profile_net_battle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_net_battle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `isRankUpChallengeFailed` tinyint(1) DEFAULT NULL,
  `highestBattleRankId` int(11) DEFAULT NULL,
  `battleIconId` int(11) DEFAULT NULL,
  `battleIconNum` int(11) DEFAULT NULL,
  `avatarEffectPoint` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user` (`user`),
  CONSTRAINT `chuni_profile_net_battle_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_net_battle`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_net_battle` WRITE;
/*!40000 ALTER TABLE `chuni_profile_net_battle` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_net_battle` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_option`
--

DROP TABLE IF EXISTS `chuni_profile_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `speed` int(11) DEFAULT NULL,
  `bgInfo` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `privacy` int(11) DEFAULT NULL,
  `judgePos` int(11) DEFAULT NULL,
  `matching` int(11) DEFAULT NULL,
  `guideLine` int(11) DEFAULT NULL,
  `headphone` int(11) DEFAULT NULL,
  `optionSet` int(11) DEFAULT NULL,
  `fieldColor` int(11) DEFAULT NULL,
  `guideSound` int(11) DEFAULT NULL,
  `successAir` int(11) DEFAULT NULL,
  `successTap` int(11) DEFAULT NULL,
  `judgeAttack` int(11) DEFAULT NULL,
  `playerLevel` int(11) DEFAULT NULL,
  `soundEffect` int(11) DEFAULT NULL,
  `judgeJustice` int(11) DEFAULT NULL,
  `successExTap` int(11) DEFAULT NULL,
  `successFlick` int(11) DEFAULT NULL,
  `successSkill` int(11) DEFAULT NULL,
  `successSlideHold` int(11) DEFAULT NULL,
  `successTapTimbre` int(11) DEFAULT NULL,
  `ext1` int(11) DEFAULT NULL,
  `ext2` int(11) DEFAULT NULL,
  `ext3` int(11) DEFAULT NULL,
  `ext4` int(11) DEFAULT NULL,
  `ext5` int(11) DEFAULT NULL,
  `ext6` int(11) DEFAULT NULL,
  `ext7` int(11) DEFAULT NULL,
  `ext8` int(11) DEFAULT NULL,
  `ext9` int(11) DEFAULT NULL,
  `ext10` int(11) DEFAULT NULL,
  `categoryDetail` int(11) DEFAULT 0,
  `judgeTimingOffset_120` int(11) DEFAULT 0,
  `resultVoiceShort` int(11) DEFAULT 0,
  `judgeAppendSe` int(11) DEFAULT 0,
  `judgeCritical` int(11) DEFAULT 0,
  `trackSkip` int(11) DEFAULT 0,
  `selectMusicFilterLv` int(11) DEFAULT 0,
  `sortMusicFilterLv` int(11) DEFAULT 0,
  `sortMusicGenre` int(11) DEFAULT 0,
  `speed_120` int(11) DEFAULT 0,
  `judgeTimingOffset` int(11) DEFAULT 0,
  `mirrorFumen` int(11) DEFAULT 0,
  `playTimingOffset_120` int(11) DEFAULT 0,
  `hardJudge` int(11) DEFAULT 0,
  `notesThickness` int(11) DEFAULT 0,
  `fieldWallPosition` int(11) DEFAULT 0,
  `playTimingOffset` int(11) DEFAULT 0,
  `fieldWallPosition_120` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_option_uk` (`user`),
  CONSTRAINT `chuni_profile_option_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_option`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_option` WRITE;
/*!40000 ALTER TABLE `chuni_profile_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_option` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_option_ex`
--

DROP TABLE IF EXISTS `chuni_profile_option_ex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_option_ex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `ext1` int(11) DEFAULT NULL,
  `ext2` int(11) DEFAULT NULL,
  `ext3` int(11) DEFAULT NULL,
  `ext4` int(11) DEFAULT NULL,
  `ext5` int(11) DEFAULT NULL,
  `ext6` int(11) DEFAULT NULL,
  `ext7` int(11) DEFAULT NULL,
  `ext8` int(11) DEFAULT NULL,
  `ext9` int(11) DEFAULT NULL,
  `ext10` int(11) DEFAULT NULL,
  `ext11` int(11) DEFAULT NULL,
  `ext12` int(11) DEFAULT NULL,
  `ext13` int(11) DEFAULT NULL,
  `ext14` int(11) DEFAULT NULL,
  `ext15` int(11) DEFAULT NULL,
  `ext16` int(11) DEFAULT NULL,
  `ext17` int(11) DEFAULT NULL,
  `ext18` int(11) DEFAULT NULL,
  `ext19` int(11) DEFAULT NULL,
  `ext20` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_option_ex_uk` (`user`),
  CONSTRAINT `chuni_profile_option_ex_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_option_ex`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_option_ex` WRITE;
/*!40000 ALTER TABLE `chuni_profile_option_ex` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_option_ex` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_overpower`
--

DROP TABLE IF EXISTS `chuni_profile_overpower`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_overpower` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `genreId` int(11) DEFAULT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_emoney_uk` (`user`,`genreId`,`difficulty`),
  CONSTRAINT `chuni_profile_overpower_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_overpower`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_overpower` WRITE;
/*!40000 ALTER TABLE `chuni_profile_overpower` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_overpower` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_rating`
--

DROP TABLE IF EXISTS `chuni_profile_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `index` int(11) NOT NULL,
  `musicId` int(11) DEFAULT NULL,
  `difficultId` int(11) DEFAULT NULL,
  `romVersionCode` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_rating_best_uk` (`user`,`version`,`type`,`index`),
  CONSTRAINT `chuni_profile_rating_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_rating`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_rating` WRITE;
/*!40000 ALTER TABLE `chuni_profile_rating` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_rating` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_recent_rating`
--

DROP TABLE IF EXISTS `chuni_profile_recent_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_recent_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `recentRating` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recentRating`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_recent_rating_uk` (`user`),
  CONSTRAINT `chuni_profile_recent_rating_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_recent_rating`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_recent_rating` WRITE;
/*!40000 ALTER TABLE `chuni_profile_recent_rating` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_recent_rating` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_region`
--

DROP TABLE IF EXISTS `chuni_profile_region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_region` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `regionId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_profile_region_uk` (`user`,`regionId`),
  CONSTRAINT `chuni_profile_region_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_region`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_region` WRITE;
/*!40000 ALTER TABLE `chuni_profile_region` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_region` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_profile_team`
--

DROP TABLE IF EXISTS `chuni_profile_team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_profile_team` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `teamName` varchar(255) DEFAULT NULL,
  `teamPoint` int(11) DEFAULT NULL,
  `userTeamPoint` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`userTeamPoint`)),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_profile_team`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_profile_team` WRITE;
/*!40000 ALTER TABLE `chuni_profile_team` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_profile_team` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_score_best`
--

DROP TABLE IF EXISTS `chuni_score_best`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_score_best` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `scoreMax` int(11) DEFAULT NULL,
  `resRequestCount` int(11) DEFAULT NULL,
  `resAcceptCount` int(11) DEFAULT NULL,
  `resSuccessCount` int(11) DEFAULT NULL,
  `missCount` int(11) DEFAULT NULL,
  `maxComboCount` int(11) DEFAULT NULL,
  `isFullCombo` tinyint(1) DEFAULT NULL,
  `isAllJustice` tinyint(1) DEFAULT NULL,
  `isSuccess` int(11) DEFAULT NULL,
  `fullChain` int(11) DEFAULT NULL,
  `maxChain` int(11) DEFAULT NULL,
  `scoreRank` int(11) DEFAULT NULL,
  `isLock` tinyint(1) DEFAULT NULL,
  `ext1` int(11) DEFAULT NULL,
  `theoryCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_score_best_uk` (`user`,`musicId`,`level`),
  CONSTRAINT `chuni_score_best_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_score_best`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_score_best` WRITE;
/*!40000 ALTER TABLE `chuni_score_best` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_score_best` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_score_course`
--

DROP TABLE IF EXISTS `chuni_score_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_score_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `courseId` int(11) DEFAULT NULL,
  `classId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `scoreMax` int(11) DEFAULT NULL,
  `isFullCombo` tinyint(1) DEFAULT NULL,
  `isAllJustice` tinyint(1) DEFAULT NULL,
  `isSuccess` int(11) DEFAULT NULL,
  `scoreRank` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `lastPlayDate` varchar(25) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `param3` int(11) DEFAULT NULL,
  `param4` int(11) DEFAULT NULL,
  `isClear` int(11) DEFAULT NULL,
  `theoryCount` int(11) DEFAULT NULL,
  `orderId` int(11) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_score_course_uk` (`user`,`courseId`),
  CONSTRAINT `chuni_score_course_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_score_course`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_score_course` WRITE;
/*!40000 ALTER TABLE `chuni_score_course` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_score_course` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_score_playlog`
--

DROP TABLE IF EXISTS `chuni_score_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_score_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `orderId` int(11) DEFAULT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `playDate` varchar(20) DEFAULT NULL,
  `userPlayDate` varchar(20) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `customId` int(11) DEFAULT NULL,
  `playedUserId1` int(11) DEFAULT NULL,
  `playedUserId2` int(11) DEFAULT NULL,
  `playedUserId3` int(11) DEFAULT NULL,
  `playedUserName1` varchar(20) DEFAULT NULL,
  `playedUserName2` varchar(20) DEFAULT NULL,
  `playedUserName3` varchar(20) DEFAULT NULL,
  `playedMusicLevel1` int(11) DEFAULT NULL,
  `playedMusicLevel2` int(11) DEFAULT NULL,
  `playedMusicLevel3` int(11) DEFAULT NULL,
  `playedCustom1` int(11) DEFAULT NULL,
  `playedCustom2` int(11) DEFAULT NULL,
  `playedCustom3` int(11) DEFAULT NULL,
  `track` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `maxCombo` int(11) DEFAULT NULL,
  `maxChain` int(11) DEFAULT NULL,
  `rateTap` int(11) DEFAULT NULL,
  `rateHold` int(11) DEFAULT NULL,
  `rateSlide` int(11) DEFAULT NULL,
  `rateAir` int(11) DEFAULT NULL,
  `rateFlick` int(11) DEFAULT NULL,
  `judgeGuilty` int(11) DEFAULT NULL,
  `judgeAttack` int(11) DEFAULT NULL,
  `judgeJustice` int(11) DEFAULT NULL,
  `judgeCritical` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `isNewRecord` tinyint(1) DEFAULT NULL,
  `isFullCombo` tinyint(1) DEFAULT NULL,
  `fullChainKind` int(11) DEFAULT NULL,
  `isAllJustice` tinyint(1) DEFAULT NULL,
  `isContinue` tinyint(1) DEFAULT NULL,
  `isFreeToPlay` tinyint(1) DEFAULT NULL,
  `characterId` int(11) DEFAULT NULL,
  `skillId` int(11) DEFAULT NULL,
  `playKind` int(11) DEFAULT NULL,
  `isClear` int(11) DEFAULT NULL,
  `skillLevel` int(11) DEFAULT NULL,
  `skillEffect` int(11) DEFAULT NULL,
  `placeName` varchar(255) DEFAULT NULL,
  `isMaimai` tinyint(1) DEFAULT NULL,
  `commonId` int(11) DEFAULT NULL,
  `charaIllustId` int(11) DEFAULT NULL,
  `romVersion` varchar(255) DEFAULT NULL,
  `judgeHeaven` int(11) DEFAULT NULL,
  `regionId` int(11) DEFAULT NULL,
  `machineType` int(11) DEFAULT NULL,
  `ticketId` int(11) DEFAULT NULL,
  `monthPoint` int(11) DEFAULT NULL,
  `eventPoint` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `chuni_score_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_score_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_score_playlog` WRITE;
/*!40000 ALTER TABLE `chuni_score_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_score_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_avatar`
--

DROP TABLE IF EXISTS `chuni_static_avatar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_avatar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `avatarAccessoryId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `iconPath` varchar(255) DEFAULT NULL,
  `texturePath` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `sortName` varchar(255) DEFAULT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_avatar_uk` (`version`,`avatarAccessoryId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_avatar_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_avatar`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_avatar` WRITE;
/*!40000 ALTER TABLE `chuni_static_avatar` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_avatar` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_cards`
--

DROP TABLE IF EXISTS `chuni_static_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `charaName` varchar(255) NOT NULL,
  `charaId` int(11) NOT NULL,
  `presentName` varchar(255) NOT NULL,
  `rarity` int(11) DEFAULT 2,
  `labelType` int(11) NOT NULL,
  `difType` int(11) NOT NULL,
  `miss` int(11) NOT NULL,
  `combo` int(11) NOT NULL,
  `chain` int(11) NOT NULL,
  `skillName` varchar(255) NOT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_cards_uk` (`version`,`cardId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_cards_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `cm_static_opts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_cards`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_cards` WRITE;
/*!40000 ALTER TABLE `chuni_static_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_cards` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_character`
--

DROP TABLE IF EXISTS `chuni_static_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_character` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `characterId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sortName` varchar(255) DEFAULT NULL,
  `worksName` varchar(255) DEFAULT NULL,
  `rareType` int(11) DEFAULT NULL,
  `imagePath1` varchar(255) DEFAULT NULL,
  `imagePath2` varchar(255) DEFAULT NULL,
  `imagePath3` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_character_uk` (`version`,`characterId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_character_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_character`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_character` WRITE;
/*!40000 ALTER TABLE `chuni_static_character` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_character` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_charge`
--

DROP TABLE IF EXISTS `chuni_static_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_charge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `chargeId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `expirationDays` int(11) DEFAULT NULL,
  `consumeType` int(11) DEFAULT NULL,
  `sellingAppeal` tinyint(1) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_charge_uk` (`version`,`chargeId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_charge_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_charge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_charge` WRITE;
/*!40000 ALTER TABLE `chuni_static_charge` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_charge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_events`
--

DROP TABLE IF EXISTS `chuni_static_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `eventId` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `startDate` timestamp NULL DEFAULT current_timestamp(),
  `enabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_events_uk` (`version`,`eventId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_events_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_events`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_events` WRITE;
/*!40000 ALTER TABLE `chuni_static_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_events` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_gacha_cards`
--

DROP TABLE IF EXISTS `chuni_static_gacha_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_gacha_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gachaId` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `rarity` int(11) NOT NULL,
  `weight` int(11) DEFAULT 1,
  `isPickup` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_gacha_cards_uk` (`gachaId`,`cardId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_gacha_cards`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_gacha_cards` WRITE;
/*!40000 ALTER TABLE `chuni_static_gacha_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_gacha_cards` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_gachas`
--

DROP TABLE IF EXISTS `chuni_static_gachas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_gachas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `gachaId` int(11) NOT NULL,
  `gachaName` varchar(255) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0,
  `kind` int(11) NOT NULL DEFAULT 0,
  `isCeiling` tinyint(1) DEFAULT 0,
  `ceilingCnt` int(11) DEFAULT 10,
  `changeRateCnt1` int(11) DEFAULT 0,
  `changeRateCnt2` int(11) DEFAULT 0,
  `startDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `endDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `noticeStartDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `noticeEndDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_gachas_uk` (`version`,`gachaId`,`gachaName`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_gachas_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `cm_static_opts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_gachas`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_gachas` WRITE;
/*!40000 ALTER TABLE `chuni_static_gachas` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_gachas` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_linked_verse`
--

DROP TABLE IF EXISTS `chuni_static_linked_verse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_linked_verse` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `linkedVerseId` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) NOT NULL DEFAULT 1,
  `startDate` timestamp NULL DEFAULT current_timestamp(),
  `courseId1` int(11) DEFAULT NULL,
  `courseId2` int(11) DEFAULT NULL,
  `courseId3` int(11) DEFAULT NULL,
  `courseId4` int(11) DEFAULT NULL,
  `courseId5` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_linked_verse_uk` (`version`,`linkedVerseId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_linked_verse`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_linked_verse` WRITE;
/*!40000 ALTER TABLE `chuni_static_linked_verse` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_linked_verse` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_login_bonus`
--

DROP TABLE IF EXISTS `chuni_static_login_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_login_bonus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `presetId` int(11) NOT NULL,
  `loginBonusId` int(11) NOT NULL,
  `loginBonusName` varchar(255) NOT NULL,
  `presentId` int(11) NOT NULL,
  `presentName` varchar(255) NOT NULL,
  `itemNum` int(11) NOT NULL,
  `needLoginDayCount` int(11) NOT NULL,
  `loginBonusCategoryType` int(11) NOT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_login_bonus_uk` (`version`,`presetId`,`loginBonusId`),
  KEY `chuni_static_login_bonus_ibfk_1` (`presetId`,`version`),
  KEY `chuni_static_login_bonus_ibfk_2` (`opt`),
  CONSTRAINT `chuni_static_login_bonus_ibfk_1` FOREIGN KEY (`presetId`, `version`) REFERENCES `chuni_static_login_bonus_preset` (`presetId`, `version`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chuni_static_login_bonus_ibfk_2` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE CASCADE ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_login_bonus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_login_bonus` WRITE;
/*!40000 ALTER TABLE `chuni_static_login_bonus` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_login_bonus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_login_bonus_preset`
--

DROP TABLE IF EXISTS `chuni_static_login_bonus_preset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_login_bonus_preset` (
  `presetId` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `presetName` varchar(255) NOT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`presetId`,`version`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_login_bonus_preset_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_login_bonus_preset`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_login_bonus_preset` WRITE;
/*!40000 ALTER TABLE `chuni_static_login_bonus_preset` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_login_bonus_preset` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_map_icon`
--

DROP TABLE IF EXISTS `chuni_static_map_icon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_map_icon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `mapIconId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sortName` varchar(255) DEFAULT NULL,
  `iconPath` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_mapicon_uk` (`version`,`mapIconId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_map_icon_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_map_icon`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_map_icon` WRITE;
/*!40000 ALTER TABLE `chuni_static_map_icon` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_map_icon` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_music`
--

DROP TABLE IF EXISTS `chuni_static_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `songId` int(11) DEFAULT NULL,
  `chartId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `artist` varchar(255) DEFAULT NULL,
  `level` float DEFAULT NULL,
  `genre` varchar(255) DEFAULT NULL,
  `jacketPath` varchar(255) DEFAULT NULL,
  `worldsEndTag` varchar(7) DEFAULT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_music_uk` (`version`,`songId`,`chartId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_music_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_music` WRITE;
/*!40000 ALTER TABLE `chuni_static_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_nameplate`
--

DROP TABLE IF EXISTS `chuni_static_nameplate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_nameplate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `nameplateId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `texturePath` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `sortName` varchar(255) DEFAULT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_nameplate_uk` (`version`,`nameplateId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_nameplate_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_nameplate`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_nameplate` WRITE;
/*!40000 ALTER TABLE `chuni_static_nameplate` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_nameplate` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_opt`
--

DROP TABLE IF EXISTS `chuni_static_opt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_opt` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `name` varchar(4) NOT NULL,
  `sequence` int(11) NOT NULL,
  `whenRead` timestamp NOT NULL DEFAULT current_timestamp(),
  `isEnable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_opt_uk` (`version`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_opt`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_opt` WRITE;
/*!40000 ALTER TABLE `chuni_static_opt` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_opt` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_stage`
--

DROP TABLE IF EXISTS `chuni_static_stage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_stage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `stageId` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `imagePath` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_stage_uk` (`version`,`stageId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_stage_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_stage`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_stage` WRITE;
/*!40000 ALTER TABLE `chuni_static_stage` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_stage` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_system_voice`
--

DROP TABLE IF EXISTS `chuni_static_system_voice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_system_voice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `voiceId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sortName` varchar(255) DEFAULT NULL,
  `imagePath` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_systemvoice_uk` (`version`,`voiceId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_system_voice_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_system_voice`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_system_voice` WRITE;
/*!40000 ALTER TABLE `chuni_static_system_voice` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_system_voice` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_trophy`
--

DROP TABLE IF EXISTS `chuni_static_trophy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_trophy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `trophyId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `rareType` int(11) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `defaultHave` tinyint(1) DEFAULT 0,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_trophy_uk` (`version`,`trophyId`),
  KEY `opt` (`opt`),
  CONSTRAINT `chuni_static_trophy_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `chuni_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_trophy`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_trophy` WRITE;
/*!40000 ALTER TABLE `chuni_static_trophy` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_trophy` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chuni_static_unlock_challenge`
--

DROP TABLE IF EXISTS `chuni_static_unlock_challenge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chuni_static_unlock_challenge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `unlockChallengeId` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `isEnabled` tinyint(1) DEFAULT 1,
  `startDate` timestamp NULL DEFAULT current_timestamp(),
  `courseId1` int(11) DEFAULT NULL,
  `courseId2` int(11) DEFAULT NULL,
  `courseId3` int(11) DEFAULT NULL,
  `courseId4` int(11) DEFAULT NULL,
  `courseId5` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chuni_static_unlock_challenge_uk` (`version`,`unlockChallengeId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chuni_static_unlock_challenge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chuni_static_unlock_challenge` WRITE;
/*!40000 ALTER TABLE `chuni_static_unlock_challenge` DISABLE KEYS */;
/*!40000 ALTER TABLE `chuni_static_unlock_challenge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cm_static_opts`
--

DROP TABLE IF EXISTS `cm_static_opts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cm_static_opts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `name` varchar(4) NOT NULL,
  `sequence` int(11) DEFAULT NULL,
  `gekiVersion` int(11) DEFAULT NULL,
  `gekiReleaseVer` int(11) DEFAULT NULL,
  `maiVersion` int(11) DEFAULT NULL,
  `maiReleaseVer` int(11) DEFAULT NULL,
  `whenRead` timestamp NOT NULL DEFAULT current_timestamp(),
  `isEnable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cm_static_opts_uk` (`version`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cm_static_opts`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cm_static_opts` WRITE;
/*!40000 ALTER TABLE `cm_static_opts` DISABLE KEYS */;
/*!40000 ALTER TABLE `cm_static_opts` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cxb_playlog`
--

DROP TABLE IF EXISTS `cxb_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cxb_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `song_mcode` varchar(7) DEFAULT NULL,
  `chart_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `clear` int(11) DEFAULT NULL,
  `flawless` int(11) DEFAULT NULL,
  `super` int(11) DEFAULT NULL,
  `cool` int(11) DEFAULT NULL,
  `fast` int(11) DEFAULT NULL,
  `fast2` int(11) DEFAULT NULL,
  `slow` int(11) DEFAULT NULL,
  `slow2` int(11) DEFAULT NULL,
  `fail` int(11) DEFAULT NULL,
  `combo` int(11) DEFAULT NULL,
  `grade` int(11) DEFAULT NULL,
  `date_scored` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `cxb_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cxb_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cxb_playlog` WRITE;
/*!40000 ALTER TABLE `cxb_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `cxb_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cxb_profile`
--

DROP TABLE IF EXISTS `cxb_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cxb_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `index` int(11) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `cxb_profile_uk` (`user`,`index`),
  CONSTRAINT `cxb_profile_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cxb_profile`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cxb_profile` WRITE;
/*!40000 ALTER TABLE `cxb_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `cxb_profile` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cxb_ranking`
--

DROP TABLE IF EXISTS `cxb_ranking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cxb_ranking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `rev_id` int(11) DEFAULT NULL,
  `song_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `clear` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cxb_ranking_uk` (`user`,`rev_id`),
  CONSTRAINT `cxb_ranking_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cxb_ranking`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cxb_ranking` WRITE;
/*!40000 ALTER TABLE `cxb_ranking` DISABLE KEYS */;
/*!40000 ALTER TABLE `cxb_ranking` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cxb_rev_energy`
--

DROP TABLE IF EXISTS `cxb_rev_energy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cxb_rev_energy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `energy` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cxb_rev_energy_uk` (`user`),
  CONSTRAINT `cxb_rev_energy_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cxb_rev_energy`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cxb_rev_energy` WRITE;
/*!40000 ALTER TABLE `cxb_rev_energy` DISABLE KEYS */;
/*!40000 ALTER TABLE `cxb_rev_energy` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cxb_score`
--

DROP TABLE IF EXISTS `cxb_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cxb_score` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `game_version` int(11) DEFAULT NULL,
  `song_mcode` varchar(7) DEFAULT NULL,
  `song_index` int(11) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `cxb_score_uk` (`user`,`song_mcode`,`song_index`),
  CONSTRAINT `cxb_score_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cxb_score`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cxb_score` WRITE;
/*!40000 ALTER TABLE `cxb_score` DISABLE KEYS */;
/*!40000 ALTER TABLE `cxb_score` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cxb_static_music`
--

DROP TABLE IF EXISTS `cxb_static_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cxb_static_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `songId` varchar(255) DEFAULT NULL,
  `index` int(11) DEFAULT NULL,
  `chartId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `artist` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `level` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cxb_static_music_uk` (`version`,`songId`,`chartId`,`index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cxb_static_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cxb_static_music` WRITE;
/*!40000 ALTER TABLE `cxb_static_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `cxb_static_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_playlog`
--

DROP TABLE IF EXISTS `diva_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `pv_id` int(11) DEFAULT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `edition` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `atn_pnt` int(11) DEFAULT NULL,
  `clr_kind` int(11) DEFAULT NULL,
  `sort_kind` int(11) DEFAULT NULL,
  `cool` int(11) DEFAULT NULL,
  `fine` int(11) DEFAULT NULL,
  `safe` int(11) DEFAULT NULL,
  `sad` int(11) DEFAULT NULL,
  `worst` int(11) DEFAULT NULL,
  `max_combo` int(11) DEFAULT NULL,
  `date_scored` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `diva_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_playlog` WRITE;
/*!40000 ALTER TABLE `diva_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_profile`
--

DROP TABLE IF EXISTS `diva_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `player_name` varchar(10) NOT NULL,
  `lv_str` varchar(24) NOT NULL DEFAULT 'Dab on ''em',
  `lv_num` int(11) NOT NULL DEFAULT 0,
  `lv_pnt` int(11) NOT NULL DEFAULT 0,
  `vcld_pts` int(11) NOT NULL DEFAULT 0,
  `hp_vol` int(11) NOT NULL DEFAULT 100,
  `btn_se_vol` int(11) NOT NULL DEFAULT 100,
  `btn_se_vol2` int(11) NOT NULL DEFAULT 100,
  `sldr_se_vol2` int(11) NOT NULL DEFAULT 100,
  `sort_kind` int(11) NOT NULL DEFAULT 2,
  `use_pv_mdl_eqp` tinyint(1) NOT NULL DEFAULT 1,
  `use_mdl_pri` tinyint(1) NOT NULL DEFAULT 0,
  `use_pv_skn_eqp` tinyint(1) NOT NULL DEFAULT 0,
  `use_pv_btn_se_eqp` tinyint(1) NOT NULL DEFAULT 1,
  `use_pv_sld_se_eqp` tinyint(1) NOT NULL DEFAULT 0,
  `use_pv_chn_sld_se_eqp` tinyint(1) NOT NULL DEFAULT 0,
  `use_pv_sldr_tch_se_eqp` tinyint(1) NOT NULL DEFAULT 0,
  `btn_se_eqp` int(11) NOT NULL DEFAULT -1,
  `sld_se_eqp` int(11) NOT NULL DEFAULT -1,
  `chn_sld_se_eqp` int(11) NOT NULL DEFAULT -1,
  `sldr_tch_se_eqp` int(11) NOT NULL DEFAULT -1,
  `nxt_pv_id` int(11) NOT NULL DEFAULT 708,
  `nxt_dffclty` int(11) NOT NULL DEFAULT 2,
  `nxt_edtn` int(11) NOT NULL DEFAULT 0,
  `cnp_cid` int(11) NOT NULL DEFAULT -1,
  `cnp_val` int(11) NOT NULL DEFAULT -1,
  `cnp_rr` int(11) NOT NULL DEFAULT -1,
  `cnp_sp` varchar(255) NOT NULL DEFAULT '',
  `dsp_clr_brdr` int(11) NOT NULL DEFAULT 7,
  `dsp_intrm_rnk` int(11) NOT NULL DEFAULT 1,
  `dsp_clr_sts` int(11) NOT NULL DEFAULT 1,
  `rgo_sts` int(11) NOT NULL DEFAULT 1,
  `lv_efct_id` int(11) NOT NULL DEFAULT 0,
  `lv_plt_id` int(11) NOT NULL DEFAULT 1,
  `skn_eqp` int(11) NOT NULL DEFAULT 0,
  `passwd_stat` int(11) NOT NULL DEFAULT 0,
  `passwd` varchar(12) NOT NULL DEFAULT '**********',
  `my_qst_id` varchar(128) DEFAULT '-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',
  `my_qst_sts` varchar(128) DEFAULT '-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_profile_uk` (`user`,`version`),
  CONSTRAINT `diva_profile_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_profile`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_profile` WRITE;
/*!40000 ALTER TABLE `diva_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_profile` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_profile_customize_item`
--

DROP TABLE IF EXISTS `diva_profile_customize_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_profile_customize_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_profile_customize_item_uk` (`user`,`version`,`item_id`),
  CONSTRAINT `diva_profile_customize_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_profile_customize_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_profile_customize_item` WRITE;
/*!40000 ALTER TABLE `diva_profile_customize_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_profile_customize_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_profile_module`
--

DROP TABLE IF EXISTS `diva_profile_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_profile_module` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `module_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_profile_module_uk` (`user`,`version`,`module_id`),
  CONSTRAINT `diva_profile_module_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_profile_module`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_profile_module` WRITE;
/*!40000 ALTER TABLE `diva_profile_module` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_profile_module` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_profile_pv_customize`
--

DROP TABLE IF EXISTS `diva_profile_pv_customize`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_profile_pv_customize` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `pv_id` int(11) NOT NULL,
  `mdl_eqp_ary` varchar(14) DEFAULT '-999,-999,-999',
  `c_itm_eqp_ary` varchar(59) DEFAULT '-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999',
  `ms_itm_flg_ary` varchar(59) DEFAULT '-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',
  `skin` int(11) DEFAULT -1,
  `btn_se` int(11) DEFAULT -1,
  `sld_se` int(11) DEFAULT -1,
  `chsld_se` int(11) DEFAULT -1,
  `sldtch_se` int(11) DEFAULT -1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_profile_pv_customize_uk` (`user`,`version`,`pv_id`),
  CONSTRAINT `diva_profile_pv_customize_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_profile_pv_customize`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_profile_pv_customize` WRITE;
/*!40000 ALTER TABLE `diva_profile_pv_customize` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_profile_pv_customize` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_profile_shop`
--

DROP TABLE IF EXISTS `diva_profile_shop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_profile_shop` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `mdl_eqp_ary` varchar(32) DEFAULT NULL,
  `c_itm_eqp_ary` varchar(59) DEFAULT NULL,
  `ms_itm_flg_ary` varchar(59) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_profile_shop_uk` (`user`,`version`),
  CONSTRAINT `diva_profile_shop_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_profile_shop`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_profile_shop` WRITE;
/*!40000 ALTER TABLE `diva_profile_shop` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_profile_shop` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_score`
--

DROP TABLE IF EXISTS `diva_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_score` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `pv_id` int(11) DEFAULT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `edition` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `atn_pnt` int(11) DEFAULT NULL,
  `clr_kind` int(11) DEFAULT NULL,
  `sort_kind` int(11) DEFAULT NULL,
  `cool` int(11) DEFAULT NULL,
  `fine` int(11) DEFAULT NULL,
  `safe` int(11) DEFAULT NULL,
  `sad` int(11) DEFAULT NULL,
  `worst` int(11) DEFAULT NULL,
  `max_combo` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_score_uk` (`user`,`pv_id`,`difficulty`,`edition`),
  CONSTRAINT `diva_score_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_score`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_score` WRITE;
/*!40000 ALTER TABLE `diva_score` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_score` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_static_items`
--

DROP TABLE IF EXISTS `diva_static_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_static_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `itemId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `unknown_0` int(11) DEFAULT NULL,
  `start_date` varchar(255) DEFAULT NULL,
  `end_date` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_static_items_uk` (`version`,`itemId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_static_items`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_static_items` WRITE;
/*!40000 ALTER TABLE `diva_static_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_static_items` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_static_music`
--

DROP TABLE IF EXISTS `diva_static_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_static_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `songId` int(11) DEFAULT NULL,
  `chartId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `vocaloid_arranger` varchar(255) DEFAULT NULL,
  `pv_illustrator` varchar(255) DEFAULT NULL,
  `lyrics` varchar(255) DEFAULT NULL,
  `bg_music` varchar(255) DEFAULT NULL,
  `level` float DEFAULT NULL,
  `bpm` int(11) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_static_music_uk` (`version`,`songId`,`chartId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_static_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_static_music` WRITE;
/*!40000 ALTER TABLE `diva_static_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_static_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_static_quests`
--

DROP TABLE IF EXISTS `diva_static_quests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_static_quests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `questId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `quest_enable` tinyint(1) DEFAULT 1,
  `kind` int(11) DEFAULT NULL,
  `unknown_0` int(11) DEFAULT NULL,
  `unknown_1` int(11) DEFAULT NULL,
  `unknown_2` int(11) DEFAULT NULL,
  `quest_order` int(11) DEFAULT NULL,
  `start_datetime` varchar(255) DEFAULT NULL,
  `end_datetime` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_static_quests_uk` (`version`,`questId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_static_quests`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_static_quests` WRITE;
/*!40000 ALTER TABLE `diva_static_quests` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_static_quests` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `diva_static_shop`
--

DROP TABLE IF EXISTS `diva_static_shop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diva_static_shop` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `shopId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `unknown_0` int(11) DEFAULT NULL,
  `start_date` varchar(255) DEFAULT NULL,
  `end_date` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `diva_static_shop_uk` (`version`,`shopId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diva_static_shop`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `diva_static_shop` WRITE;
/*!40000 ALTER TABLE `diva_static_shop` DISABLE KEYS */;
/*!40000 ALTER TABLE `diva_static_shop` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_log`
--

DROP TABLE IF EXISTS `event_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `severity` int(11) NOT NULL,
  `user` int(11) DEFAULT NULL,
  `arcade` int(11) DEFAULT NULL,
  `machine` int(11) DEFAULT NULL,
  `ip` tinytext DEFAULT NULL,
  `game` tinytext DEFAULT NULL,
  `version` tinytext DEFAULT NULL,
  `message` varchar(1000) NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`details`)),
  `when_logged` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  KEY `arcade` (`arcade`),
  KEY `machine` (`machine`),
  CONSTRAINT `event_log_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `event_log_ibfk_2` FOREIGN KEY (`arcade`) REFERENCES `arcade` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `event_log_ibfk_3` FOREIGN KEY (`machine`) REFERENCES `machine` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=790 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_log` WRITE;
/*!40000 ALTER TABLE `event_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_profile`
--

DROP TABLE IF EXISTS `idac_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `username` varchar(8) DEFAULT NULL,
  `country` int(11) DEFAULT NULL,
  `store` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT 0,
  `total_play` int(11) DEFAULT 0,
  `daily_play` int(11) DEFAULT 0,
  `day_play` int(11) DEFAULT 0,
  `mileage` int(11) DEFAULT 0,
  `asset_version` int(11) DEFAULT 1,
  `last_play_date` timestamp NULL DEFAULT current_timestamp(),
  `mytitle_id` int(11) DEFAULT 0,
  `mytitle_efffect_id` int(11) DEFAULT 0,
  `sticker_id` int(11) DEFAULT 0,
  `sticker_effect_id` int(11) DEFAULT 0,
  `papercup_id` int(11) DEFAULT 0,
  `tachometer_id` int(11) DEFAULT 0,
  `aura_id` int(11) DEFAULT 0,
  `aura_color_id` int(11) DEFAULT 0,
  `aura_line_id` int(11) DEFAULT 0,
  `bgm_id` int(11) DEFAULT 0,
  `keyholder_id` int(11) DEFAULT 0,
  `start_menu_bg_id` int(11) DEFAULT 0,
  `use_car_id` int(11) DEFAULT 1,
  `use_style_car_id` int(11) DEFAULT 1,
  `bothwin_count` int(11) DEFAULT 0,
  `bothwin_score` int(11) DEFAULT 0,
  `subcard_count` int(11) DEFAULT 0,
  `vs_history` int(11) DEFAULT 0,
  `stamp_key_assign_0` int(11) DEFAULT NULL,
  `stamp_key_assign_1` int(11) DEFAULT NULL,
  `stamp_key_assign_2` int(11) DEFAULT NULL,
  `stamp_key_assign_3` int(11) DEFAULT NULL,
  `name_change_category` int(11) DEFAULT 0,
  `factory_disp` int(11) DEFAULT 0,
  `create_date` timestamp NULL DEFAULT current_timestamp(),
  `cash` int(11) DEFAULT 0,
  `dressup_point` int(11) DEFAULT 0,
  `avatar_point` int(11) DEFAULT 0,
  `total_cash` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_profile_uk` (`user`,`version`),
  CONSTRAINT `idac_profile_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_profile`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_profile` WRITE;
/*!40000 ALTER TABLE `idac_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_profile` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_profile_avatar`
--

DROP TABLE IF EXISTS `idac_profile_avatar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_profile_avatar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `sex` int(11) DEFAULT NULL,
  `face` int(11) DEFAULT NULL,
  `eye` int(11) DEFAULT NULL,
  `mouth` int(11) DEFAULT NULL,
  `hair` int(11) DEFAULT NULL,
  `glasses` int(11) DEFAULT NULL,
  `face_accessory` int(11) DEFAULT NULL,
  `body` int(11) DEFAULT NULL,
  `body_accessory` int(11) DEFAULT NULL,
  `behind` int(11) DEFAULT NULL,
  `bg` int(11) DEFAULT NULL,
  `effect` int(11) DEFAULT NULL,
  `special` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_profile_avatar_uk` (`user`),
  CONSTRAINT `idac_profile_avatar_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_profile_avatar`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_profile_avatar` WRITE;
/*!40000 ALTER TABLE `idac_profile_avatar` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_profile_avatar` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_profile_config`
--

DROP TABLE IF EXISTS `idac_profile_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_profile_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `config_id` int(11) DEFAULT NULL,
  `steering_intensity` int(11) DEFAULT NULL,
  `transmission_type` int(11) DEFAULT NULL,
  `default_viewpoint` int(11) DEFAULT NULL,
  `favorite_bgm` int(11) DEFAULT NULL,
  `bgm_volume` int(11) DEFAULT NULL,
  `se_volume` int(11) DEFAULT NULL,
  `master_volume` int(11) DEFAULT NULL,
  `store_battle_policy` int(11) DEFAULT NULL,
  `battle_onomatope_display` int(11) DEFAULT NULL,
  `cornering_guide` int(11) DEFAULT NULL,
  `minimap` int(11) DEFAULT NULL,
  `line_guide` int(11) DEFAULT NULL,
  `ghost` int(11) DEFAULT NULL,
  `race_exit` int(11) DEFAULT NULL,
  `result_skip` int(11) DEFAULT NULL,
  `stamp_select_skip` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_profile_config_uk` (`user`),
  CONSTRAINT `idac_profile_config_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_profile_config`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_profile_config` WRITE;
/*!40000 ALTER TABLE `idac_profile_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_profile_config` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_profile_rank`
--

DROP TABLE IF EXISTS `idac_profile_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_profile_rank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `story_rank_exp` int(11) DEFAULT 0,
  `story_rank` int(11) DEFAULT 1,
  `time_trial_rank_exp` int(11) DEFAULT 0,
  `time_trial_rank` int(11) DEFAULT 1,
  `online_battle_rank_exp` int(11) DEFAULT 0,
  `online_battle_rank` int(11) DEFAULT 1,
  `store_battle_rank_exp` int(11) DEFAULT 0,
  `store_battle_rank` int(11) DEFAULT 1,
  `theory_exp` int(11) DEFAULT 0,
  `theory_rank` int(11) DEFAULT 1,
  `pride_group_id` int(11) DEFAULT 0,
  `pride_point` int(11) DEFAULT 0,
  `grade_exp` int(11) DEFAULT 0,
  `grade` int(11) DEFAULT 1,
  `grade_reward_dist` int(11) DEFAULT 0,
  `story_rank_reward_dist` int(11) DEFAULT 0,
  `time_trial_rank_reward_dist` int(11) DEFAULT 0,
  `online_battle_rank_reward_dist` int(11) DEFAULT 0,
  `store_battle_rank_reward_dist` int(11) DEFAULT 0,
  `theory_rank_reward_dist` int(11) DEFAULT 0,
  `max_attained_online_battle_rank` int(11) DEFAULT 1,
  `max_attained_pride_point` int(11) DEFAULT 0,
  `is_last_max` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_profile_rank_uk` (`user`,`version`),
  CONSTRAINT `idac_profile_rank_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_profile_rank`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_profile_rank` WRITE;
/*!40000 ALTER TABLE `idac_profile_rank` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_profile_rank` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_profile_stock`
--

DROP TABLE IF EXISTS `idac_profile_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_profile_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `mytitle_list` varchar(1024) DEFAULT '',
  `mytitle_new_list` varchar(1024) DEFAULT '',
  `avatar_face_list` varchar(255) DEFAULT '',
  `avatar_face_new_list` varchar(255) DEFAULT '',
  `avatar_eye_list` varchar(255) DEFAULT '',
  `avatar_eye_new_list` varchar(255) DEFAULT '',
  `avatar_hair_list` varchar(255) DEFAULT '',
  `avatar_hair_new_list` varchar(255) DEFAULT '',
  `avatar_body_list` varchar(255) DEFAULT '',
  `avatar_body_new_list` varchar(255) DEFAULT '',
  `avatar_mouth_list` varchar(255) DEFAULT '',
  `avatar_mouth_new_list` varchar(255) DEFAULT '',
  `avatar_glasses_list` varchar(255) DEFAULT '',
  `avatar_glasses_new_list` varchar(255) DEFAULT '',
  `avatar_face_accessory_list` varchar(255) DEFAULT '',
  `avatar_face_accessory_new_list` varchar(255) DEFAULT '',
  `avatar_body_accessory_list` varchar(255) DEFAULT '',
  `avatar_body_accessory_new_list` varchar(255) DEFAULT '',
  `avatar_behind_list` varchar(255) DEFAULT '',
  `avatar_behind_new_list` varchar(255) DEFAULT '',
  `avatar_bg_list` varchar(255) DEFAULT '',
  `avatar_bg_new_list` varchar(255) DEFAULT '',
  `avatar_effect_list` varchar(255) DEFAULT '',
  `avatar_effect_new_list` varchar(255) DEFAULT '',
  `avatar_special_list` varchar(255) DEFAULT '',
  `avatar_special_new_list` varchar(255) DEFAULT '',
  `stamp_list` varchar(255) DEFAULT '',
  `stamp_new_list` varchar(255) DEFAULT '',
  `keyholder_list` varchar(256) DEFAULT '',
  `keyholder_new_list` varchar(256) DEFAULT '',
  `papercup_list` varchar(255) DEFAULT '',
  `papercup_new_list` varchar(255) DEFAULT '',
  `tachometer_list` varchar(255) DEFAULT '',
  `tachometer_new_list` varchar(255) DEFAULT '',
  `aura_list` varchar(255) DEFAULT '',
  `aura_new_list` varchar(255) DEFAULT '',
  `aura_color_list` varchar(255) DEFAULT '',
  `aura_color_new_list` varchar(255) DEFAULT '',
  `aura_line_list` varchar(255) DEFAULT '',
  `aura_line_new_list` varchar(255) DEFAULT '',
  `bgm_list` varchar(255) DEFAULT '',
  `bgm_new_list` varchar(255) DEFAULT '',
  `dx_color_list` varchar(255) DEFAULT '',
  `dx_color_new_list` varchar(255) DEFAULT '',
  `start_menu_bg_list` varchar(255) DEFAULT '',
  `start_menu_bg_new_list` varchar(255) DEFAULT '',
  `under_neon_list` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_profile_stock_uk` (`user`,`version`),
  CONSTRAINT `idac_profile_stock_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_profile_stock`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_profile_stock` WRITE;
/*!40000 ALTER TABLE `idac_profile_stock` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_profile_stock` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_profile_theory`
--

DROP TABLE IF EXISTS `idac_profile_theory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_profile_theory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `play_count` int(11) DEFAULT 0,
  `play_count_multi` int(11) DEFAULT 0,
  `partner_id` int(11) DEFAULT NULL,
  `partner_progress` int(11) DEFAULT NULL,
  `partner_progress_score` int(11) DEFAULT NULL,
  `practice_start_rank` int(11) DEFAULT 0,
  `general_flag` int(11) DEFAULT 0,
  `vs_history` int(11) DEFAULT 0,
  `vs_history_multi` int(11) DEFAULT 0,
  `win_count` int(11) DEFAULT 0,
  `win_count_multi` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_profile_theory_uk` (`user`,`version`),
  CONSTRAINT `idac_profile_theory_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_profile_theory`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_profile_theory` WRITE;
/*!40000 ALTER TABLE `idac_profile_theory` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_profile_theory` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_car`
--

DROP TABLE IF EXISTS `idac_user_car`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_car` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `version` int(11) NOT NULL,
  `car_id` int(11) DEFAULT NULL,
  `style_car_id` int(11) DEFAULT NULL,
  `color` int(11) DEFAULT NULL,
  `bureau` int(11) DEFAULT NULL,
  `kana` int(11) DEFAULT NULL,
  `s_no` int(11) DEFAULT NULL,
  `l_no` int(11) DEFAULT NULL,
  `car_flag` int(11) DEFAULT NULL,
  `tune_point` int(11) DEFAULT NULL,
  `tune_level` int(11) DEFAULT 1,
  `tune_parts` int(11) DEFAULT NULL,
  `infinity_tune` int(11) DEFAULT 0,
  `online_vs_win` int(11) DEFAULT 0,
  `pickup_seq` int(11) DEFAULT 1,
  `purchase_seq` int(11) DEFAULT 1,
  `color_stock_list` varchar(32) DEFAULT NULL,
  `color_stock_new_list` varchar(32) DEFAULT NULL,
  `parts_stock_list` varchar(48) DEFAULT NULL,
  `parts_stock_new_list` varchar(48) DEFAULT NULL,
  `parts_set_equip_list` varchar(48) DEFAULT NULL,
  `parts_list` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`parts_list`)),
  `equip_parts_count` int(11) DEFAULT 0,
  `total_car_parts_count` int(11) DEFAULT 0,
  `use_count` int(11) DEFAULT 0,
  `story_use_count` int(11) DEFAULT 0,
  `timetrial_use_count` int(11) DEFAULT 0,
  `vs_use_count` int(11) DEFAULT 0,
  `net_vs_use_count` int(11) DEFAULT 0,
  `theory_use_count` int(11) DEFAULT 0,
  `car_mileage` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_car_uk` (`user`,`version`,`style_car_id`),
  CONSTRAINT `idac_user_car_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_car`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_car` WRITE;
/*!40000 ALTER TABLE `idac_user_car` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_car` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_challenge`
--

DROP TABLE IF EXISTS `idac_user_challenge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_challenge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `vs_type` int(11) DEFAULT NULL,
  `play_difficulty` int(11) DEFAULT NULL,
  `cleared_difficulty` int(11) DEFAULT NULL,
  `story_type` int(11) DEFAULT NULL,
  `play_count` int(11) DEFAULT 1,
  `weak_difficulty` int(11) DEFAULT 0,
  `eval_id` int(11) DEFAULT NULL,
  `advantage` int(11) DEFAULT NULL,
  `sec1_advantage_avg` int(11) DEFAULT NULL,
  `sec2_advantage_avg` int(11) DEFAULT NULL,
  `sec3_advantage_avg` int(11) DEFAULT NULL,
  `sec4_advantage_avg` int(11) DEFAULT NULL,
  `nearby_advantage_rate` int(11) DEFAULT NULL,
  `win_flag` int(11) DEFAULT NULL,
  `result` int(11) DEFAULT NULL,
  `record` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `last_play_course_id` int(11) DEFAULT NULL,
  `style_car_id` int(11) DEFAULT NULL,
  `course_day` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_challenge_uk` (`user`,`vs_type`,`play_difficulty`),
  CONSTRAINT `idac_user_challenge_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_challenge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_challenge` WRITE;
/*!40000 ALTER TABLE `idac_user_challenge` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_challenge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_course`
--

DROP TABLE IF EXISTS `idac_user_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `run_counts` int(11) DEFAULT 1,
  `skill_level_exp` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_course_uk` (`user`,`course_id`),
  CONSTRAINT `idac_user_course_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_course`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_course` WRITE;
/*!40000 ALTER TABLE `idac_user_course` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_course` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_stamp`
--

DROP TABLE IF EXISTS `idac_user_stamp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_stamp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `m_stamp_event_id` int(11) DEFAULT NULL,
  `select_flag` int(11) DEFAULT NULL,
  `stamp_masu` int(11) DEFAULT NULL,
  `daily_bonus` int(11) DEFAULT NULL,
  `weekly_bonus` int(11) DEFAULT NULL,
  `weekday_bonus` int(11) DEFAULT NULL,
  `weekend_bonus` int(11) DEFAULT NULL,
  `total_bonus` int(11) DEFAULT NULL,
  `day_total_bonus` int(11) DEFAULT NULL,
  `store_battle_bonus` int(11) DEFAULT NULL,
  `story_bonus` int(11) DEFAULT NULL,
  `online_battle_bonus` int(11) DEFAULT NULL,
  `timetrial_bonus` int(11) DEFAULT NULL,
  `fasteststreetlegaltheory_bonus` int(11) DEFAULT NULL,
  `collaboration_bonus` int(11) DEFAULT NULL,
  `add_bonus_daily_flag_1` int(11) DEFAULT NULL,
  `add_bonus_daily_flag_2` int(11) DEFAULT NULL,
  `add_bonus_daily_flag_3` int(11) DEFAULT NULL,
  `create_date_daily` timestamp NULL DEFAULT current_timestamp(),
  `create_date_weekly` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_stamp_uk` (`user`,`m_stamp_event_id`),
  CONSTRAINT `idac_user_stamp_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_stamp`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_stamp` WRITE;
/*!40000 ALTER TABLE `idac_user_stamp` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_stamp` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_story`
--

DROP TABLE IF EXISTS `idac_user_story`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_story` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `story_type` int(11) DEFAULT NULL,
  `chapter` int(11) DEFAULT NULL,
  `loop_count` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_story_uk` (`user`,`chapter`),
  CONSTRAINT `idac_user_story_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_story`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_story` WRITE;
/*!40000 ALTER TABLE `idac_user_story` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_story` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_story_episode`
--

DROP TABLE IF EXISTS `idac_user_story_episode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_story_episode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `chapter` int(11) DEFAULT NULL,
  `episode` int(11) DEFAULT NULL,
  `play_status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_story_episode_uk` (`user`,`chapter`,`episode`),
  CONSTRAINT `idac_user_story_episode_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_story_episode`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_story_episode` WRITE;
/*!40000 ALTER TABLE `idac_user_story_episode` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_story_episode` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_story_episode_difficulty`
--

DROP TABLE IF EXISTS `idac_user_story_episode_difficulty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_story_episode_difficulty` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `episode` int(11) DEFAULT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `play_count` int(11) DEFAULT NULL,
  `clear_count` int(11) DEFAULT NULL,
  `play_status` int(11) DEFAULT NULL,
  `play_score` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_story_episode_difficulty_uk` (`user`,`episode`,`difficulty`),
  CONSTRAINT `idac_user_story_episode_difficulty_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_story_episode_difficulty`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_story_episode_difficulty` WRITE;
/*!40000 ALTER TABLE `idac_user_story_episode_difficulty` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_story_episode_difficulty` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_theory_course`
--

DROP TABLE IF EXISTS `idac_user_theory_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_theory_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `max_victory_grade` int(11) DEFAULT 0,
  `run_count` int(11) DEFAULT 1,
  `powerhouse_lv` int(11) DEFAULT NULL,
  `powerhouse_exp` int(11) DEFAULT NULL,
  `played_powerhouse_lv` int(11) DEFAULT NULL,
  `update_dt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_theory_course_uk` (`user`,`course_id`),
  CONSTRAINT `idac_user_theory_course_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_theory_course`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_theory_course` WRITE;
/*!40000 ALTER TABLE `idac_user_theory_course` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_theory_course` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_theory_partner`
--

DROP TABLE IF EXISTS `idac_user_theory_partner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_theory_partner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `partner_id` int(11) DEFAULT NULL,
  `fellowship_lv` int(11) DEFAULT NULL,
  `fellowship_exp` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_theory_partner_uk` (`user`,`partner_id`),
  CONSTRAINT `idac_user_theory_partner_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_theory_partner`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_theory_partner` WRITE;
/*!40000 ALTER TABLE `idac_user_theory_partner` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_theory_partner` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_theory_running`
--

DROP TABLE IF EXISTS `idac_user_theory_running`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_theory_running` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `attack` int(11) DEFAULT NULL,
  `defense` int(11) DEFAULT NULL,
  `safety` int(11) DEFAULT NULL,
  `runaway` int(11) DEFAULT NULL,
  `trick_flag` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_theory_running_uk` (`user`,`course_id`),
  CONSTRAINT `idac_user_theory_running_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_theory_running`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_theory_running` WRITE;
/*!40000 ALTER TABLE `idac_user_theory_running` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_theory_running` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_ticket`
--

DROP TABLE IF EXISTS `idac_user_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_ticket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `ticket_id` int(11) DEFAULT NULL,
  `ticket_cnt` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_ticket_uk` (`user`,`ticket_id`),
  CONSTRAINT `idac_user_ticket_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_ticket`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_ticket` WRITE;
/*!40000 ALTER TABLE `idac_user_ticket` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_ticket` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_time_trial`
--

DROP TABLE IF EXISTS `idac_user_time_trial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_time_trial` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `version` int(11) NOT NULL,
  `style_car_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `eval_id` int(11) DEFAULT 0,
  `goal_time` int(11) DEFAULT NULL,
  `section_time_1` int(11) DEFAULT NULL,
  `section_time_2` int(11) DEFAULT NULL,
  `section_time_3` int(11) DEFAULT NULL,
  `section_time_4` int(11) DEFAULT NULL,
  `mission` int(11) DEFAULT NULL,
  `play_dt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_time_trial_uk` (`user`,`version`,`course_id`,`style_car_id`),
  CONSTRAINT `idac_user_time_trial_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_time_trial`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_time_trial` WRITE;
/*!40000 ALTER TABLE `idac_user_time_trial` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_time_trial` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_timetrial_event`
--

DROP TABLE IF EXISTS `idac_user_timetrial_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_timetrial_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `timetrial_event_id` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_timetrial_event_uk` (`user`,`timetrial_event_id`),
  CONSTRAINT `idac_user_timetrial_event_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_timetrial_event`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_timetrial_event` WRITE;
/*!40000 ALTER TABLE `idac_user_timetrial_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_timetrial_event` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `idac_user_vs_info`
--

DROP TABLE IF EXISTS `idac_user_vs_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `idac_user_vs_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `group_key` varchar(25) DEFAULT NULL,
  `win_flg` int(11) DEFAULT NULL,
  `style_car_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `course_day` int(11) DEFAULT NULL,
  `players_num` int(11) DEFAULT NULL,
  `winning` int(11) DEFAULT NULL,
  `advantage_1` int(11) DEFAULT NULL,
  `advantage_2` int(11) DEFAULT NULL,
  `advantage_3` int(11) DEFAULT NULL,
  `advantage_4` int(11) DEFAULT NULL,
  `select_course_id` int(11) DEFAULT NULL,
  `select_course_day` int(11) DEFAULT NULL,
  `select_course_random` int(11) DEFAULT NULL,
  `matching_success_sec` int(11) DEFAULT NULL,
  `boost_flag` int(11) DEFAULT NULL,
  `vs_history` int(11) DEFAULT NULL,
  `break_count` int(11) DEFAULT NULL,
  `break_penalty_flag` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idac_user_vs_info_uk` (`user`,`group_key`),
  CONSTRAINT `idac_user_vs_info_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idac_user_vs_info`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `idac_user_vs_info` WRITE;
/*!40000 ALTER TABLE `idac_user_vs_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `idac_user_vs_info` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `machine`
--

DROP TABLE IF EXISTS `machine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `machine` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `arcade` int(11) NOT NULL,
  `serial` varchar(15) NOT NULL,
  `board` varchar(15) DEFAULT NULL,
  `game` varchar(4) DEFAULT NULL,
  `country` varchar(3) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `is_cab` tinyint(1) DEFAULT NULL,
  `ota_channel` varchar(260) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  PRIMARY KEY (`id`),
  KEY `arcade` (`arcade`),
  CONSTRAINT `machine_ibfk_1` FOREIGN KEY (`arcade`) REFERENCES `arcade` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `machine`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `machine` WRITE;
/*!40000 ALTER TABLE `machine` DISABLE KEYS */;
/*!40000 ALTER TABLE `machine` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `machine_billing_charge`
--

DROP TABLE IF EXISTS `machine_billing_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `machine_billing_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `machine` int(11) NOT NULL,
  `game_id` char(5) NOT NULL,
  `game_ver` float NOT NULL,
  `play_count` int(11) NOT NULL,
  `play_limit` int(11) NOT NULL,
  `product_code` int(11) NOT NULL,
  `product_count` int(11) NOT NULL,
  `func_type` int(11) NOT NULL,
  `player_number` int(11) NOT NULL,
  `ins_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `machine` (`machine`),
  CONSTRAINT `machine_billing_charge_ibfk_1` FOREIGN KEY (`machine`) REFERENCES `machine` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `machine_billing_charge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `machine_billing_charge` WRITE;
/*!40000 ALTER TABLE `machine_billing_charge` DISABLE KEYS */;
/*!40000 ALTER TABLE `machine_billing_charge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `machine_billing_credit`
--

DROP TABLE IF EXISTS `machine_billing_credit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `machine_billing_credit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `machine` int(11) NOT NULL,
  `game_id` char(5) NOT NULL,
  `chute_type` int(11) NOT NULL,
  `service_type` int(11) NOT NULL,
  `operation_type` int(11) NOT NULL,
  `coin_rate0` int(11) NOT NULL,
  `coin_rate1` int(11) NOT NULL,
  `coin_bonus` int(11) NOT NULL,
  `credit_rate` int(11) NOT NULL,
  `coin_count_slot0` int(11) NOT NULL,
  `coin_count_slot1` int(11) NOT NULL,
  `coin_count_slot2` int(11) NOT NULL,
  `coin_count_slot3` int(11) NOT NULL,
  `coin_count_slot4` int(11) NOT NULL,
  `coin_count_slot5` int(11) NOT NULL,
  `coin_count_slot6` int(11) NOT NULL,
  `coin_count_slot7` int(11) NOT NULL,
  `ins_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  `upd_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `machine_billing_credit_uk` (`machine`,`game_id`),
  CONSTRAINT `machine_billing_credit_ibfk_1` FOREIGN KEY (`machine`) REFERENCES `machine` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `machine_billing_credit`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `machine_billing_credit` WRITE;
/*!40000 ALTER TABLE `machine_billing_credit` DISABLE KEYS */;
/*!40000 ALTER TABLE `machine_billing_credit` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `machine_billing_playcount`
--

DROP TABLE IF EXISTS `machine_billing_playcount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `machine_billing_playcount` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `machine` int(11) NOT NULL,
  `game_id` char(5) NOT NULL,
  `year` int(11) NOT NULL,
  `month` int(11) NOT NULL,
  `playct` bigint(20) NOT NULL DEFAULT 1,
  `ins_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  `upd_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `machine_billing_playcount_uk` (`machine`,`game_id`,`year`,`month`),
  CONSTRAINT `machine_billing_playcount_ibfk_1` FOREIGN KEY (`machine`) REFERENCES `machine` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `machine_billing_playcount`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `machine_billing_playcount` WRITE;
/*!40000 ALTER TABLE `machine_billing_playcount` DISABLE KEYS */;
/*!40000 ALTER TABLE `machine_billing_playcount` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `machine_update`
--

DROP TABLE IF EXISTS `machine_update`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `machine_update` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `game` char(4) NOT NULL,
  `version` varchar(15) NOT NULL,
  `channel` varchar(260) NOT NULL,
  `app_ini` varchar(260) DEFAULT NULL,
  `opt_ini` varchar(260) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `machine_update_uk` (`game`,`version`,`channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `machine_update`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `machine_update` WRITE;
/*!40000 ALTER TABLE `machine_update` DISABLE KEYS */;
/*!40000 ALTER TABLE `machine_update` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_card`
--

DROP TABLE IF EXISTS `mai2_item_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_card` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `cardId` int(11) DEFAULT NULL,
  `cardTypeId` int(11) DEFAULT NULL,
  `charaId` int(11) DEFAULT NULL,
  `mapId` int(11) DEFAULT NULL,
  `startDate` timestamp NULL DEFAULT current_timestamp(),
  `endDate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_card_uk` (`user`,`cardId`,`cardTypeId`),
  CONSTRAINT `mai2_item_card_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_card`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_card` WRITE;
/*!40000 ALTER TABLE `mai2_item_card` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_card` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_character`
--

DROP TABLE IF EXISTS `mai2_item_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_character` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `characterId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `awakening` int(11) DEFAULT NULL,
  `useCount` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_character_uk` (`user`,`characterId`),
  CONSTRAINT `mai2_item_character_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_character`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_character` WRITE;
/*!40000 ALTER TABLE `mai2_item_character` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_character` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_charge`
--

DROP TABLE IF EXISTS `mai2_item_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_charge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `chargeId` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `purchaseDate` varchar(255) DEFAULT NULL,
  `validDate` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_charge_uk` (`user`,`chargeId`),
  CONSTRAINT `mai2_item_charge_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_charge`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_charge` WRITE;
/*!40000 ALTER TABLE `mai2_item_charge` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_charge` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_favorite`
--

DROP TABLE IF EXISTS `mai2_item_favorite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_favorite` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `itemKind` int(11) DEFAULT NULL,
  `itemIdList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`itemIdList`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_favorite_uk` (`user`,`itemKind`),
  CONSTRAINT `mai2_item_favorite_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_favorite`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_favorite` WRITE;
/*!40000 ALTER TABLE `mai2_item_favorite` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_favorite` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_favorite_music`
--

DROP TABLE IF EXISTS `mai2_item_favorite_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_favorite_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `musicId` int(11) NOT NULL,
  `orderId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_favorite_music_uk` (`user`,`musicId`),
  CONSTRAINT `mai2_item_favorite_music_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_favorite_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_favorite_music` WRITE;
/*!40000 ALTER TABLE `mai2_item_favorite_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_favorite_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_friend_season_ranking`
--

DROP TABLE IF EXISTS `mai2_item_friend_season_ranking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_friend_season_ranking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `seasonId` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `rewardGet` tinyint(1) DEFAULT NULL,
  `userName` varchar(8) DEFAULT NULL,
  `recordDate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_friend_season_ranking_uk` (`user`,`seasonId`,`userName`),
  CONSTRAINT `mai2_item_friend_season_ranking_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_friend_season_ranking`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_friend_season_ranking` WRITE;
/*!40000 ALTER TABLE `mai2_item_friend_season_ranking` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_friend_season_ranking` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_item`
--

DROP TABLE IF EXISTS `mai2_item_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `itemId` int(11) DEFAULT NULL,
  `itemKind` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_item_uk` (`user`,`itemId`,`itemKind`),
  CONSTRAINT `mai2_item_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_item` WRITE;
/*!40000 ALTER TABLE `mai2_item_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_login_bonus`
--

DROP TABLE IF EXISTS `mai2_item_login_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_login_bonus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `bonusId` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `isCurrent` tinyint(1) DEFAULT NULL,
  `isComplete` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_login_bonus_uk` (`user`,`bonusId`),
  CONSTRAINT `mai2_item_login_bonus_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_login_bonus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_login_bonus` WRITE;
/*!40000 ALTER TABLE `mai2_item_login_bonus` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_login_bonus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_map`
--

DROP TABLE IF EXISTS `mai2_item_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_map` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `mapId` int(11) DEFAULT NULL,
  `distance` int(11) DEFAULT NULL,
  `isLock` tinyint(1) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `isComplete` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_map_uk` (`user`,`mapId`),
  CONSTRAINT `mai2_item_map_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_map`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_map` WRITE;
/*!40000 ALTER TABLE `mai2_item_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_map` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_present`
--

DROP TABLE IF EXISTS `mai2_item_present`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_present` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) DEFAULT NULL,
  `user` int(11) DEFAULT NULL,
  `itemKind` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 1,
  `startDate` timestamp NULL DEFAULT NULL,
  `endDate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_present_uk` (`version`,`user`,`itemKind`,`itemId`),
  KEY `user` (`user`),
  CONSTRAINT `mai2_item_present_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_present`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_present` WRITE;
/*!40000 ALTER TABLE `mai2_item_present` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_present` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_item_print_detail`
--

DROP TABLE IF EXISTS `mai2_item_print_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_item_print_detail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `orderId` int(11) DEFAULT NULL,
  `printNumber` int(11) DEFAULT NULL,
  `printDate` timestamp NULL DEFAULT current_timestamp(),
  `serialId` varchar(20) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `clientId` varchar(11) DEFAULT NULL,
  `printerSerialId` varchar(20) DEFAULT NULL,
  `cardRomVersion` int(11) DEFAULT NULL,
  `isHolograph` tinyint(1) DEFAULT 1,
  `printOption1` tinyint(1) DEFAULT 0,
  `printOption2` tinyint(1) DEFAULT 0,
  `printOption3` tinyint(1) DEFAULT 0,
  `printOption4` tinyint(1) DEFAULT 0,
  `printOption5` tinyint(1) DEFAULT 0,
  `printOption6` tinyint(1) DEFAULT 0,
  `printOption7` tinyint(1) DEFAULT 0,
  `printOption8` tinyint(1) DEFAULT 0,
  `printOption9` tinyint(1) DEFAULT 0,
  `printOption10` tinyint(1) DEFAULT 0,
  `created` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_item_print_detail_uk` (`user`,`serialId`),
  CONSTRAINT `mai2_item_print_detail_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_item_print_detail`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_item_print_detail` WRITE;
/*!40000 ALTER TABLE `mai2_item_print_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_item_print_detail` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_playlog`
--

DROP TABLE IF EXISTS `mai2_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `userId` bigint(20) DEFAULT NULL,
  `orderId` int(11) DEFAULT NULL,
  `playlogId` bigint(20) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `placeName` varchar(255) DEFAULT NULL,
  `loginDate` bigint(20) DEFAULT NULL,
  `playDate` varchar(255) DEFAULT NULL,
  `userPlayDate` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `trackNo` int(11) DEFAULT NULL,
  `vsMode` int(11) DEFAULT NULL,
  `vsUserName` varchar(255) DEFAULT NULL,
  `vsStatus` int(11) DEFAULT NULL,
  `vsUserRating` int(11) DEFAULT NULL,
  `vsUserAchievement` int(11) DEFAULT NULL,
  `vsUserGradeRank` int(11) DEFAULT NULL,
  `vsRank` int(11) DEFAULT NULL,
  `playerNum` int(11) DEFAULT NULL,
  `playedUserId1` bigint(20) DEFAULT NULL,
  `playedUserName1` varchar(255) DEFAULT NULL,
  `playedMusicLevel1` int(11) DEFAULT NULL,
  `playedUserId2` bigint(20) DEFAULT NULL,
  `playedUserName2` varchar(255) DEFAULT NULL,
  `playedMusicLevel2` int(11) DEFAULT NULL,
  `playedUserId3` bigint(20) DEFAULT NULL,
  `playedUserName3` varchar(255) DEFAULT NULL,
  `playedMusicLevel3` int(11) DEFAULT NULL,
  `characterId1` int(11) DEFAULT NULL,
  `characterLevel1` int(11) DEFAULT NULL,
  `characterAwakening1` int(11) DEFAULT NULL,
  `characterId2` int(11) DEFAULT NULL,
  `characterLevel2` int(11) DEFAULT NULL,
  `characterAwakening2` int(11) DEFAULT NULL,
  `characterId3` int(11) DEFAULT NULL,
  `characterLevel3` int(11) DEFAULT NULL,
  `characterAwakening3` int(11) DEFAULT NULL,
  `characterId4` int(11) DEFAULT NULL,
  `characterLevel4` int(11) DEFAULT NULL,
  `characterAwakening4` int(11) DEFAULT NULL,
  `characterId5` int(11) DEFAULT NULL,
  `characterLevel5` int(11) DEFAULT NULL,
  `characterAwakening5` int(11) DEFAULT NULL,
  `achievement` int(11) DEFAULT NULL,
  `deluxscore` int(11) DEFAULT NULL,
  `scoreRank` int(11) DEFAULT NULL,
  `maxCombo` int(11) DEFAULT NULL,
  `totalCombo` int(11) DEFAULT NULL,
  `maxSync` int(11) DEFAULT NULL,
  `totalSync` int(11) DEFAULT NULL,
  `tapCriticalPerfect` int(11) DEFAULT NULL,
  `tapPerfect` int(11) DEFAULT NULL,
  `tapGreat` int(11) DEFAULT NULL,
  `tapGood` int(11) DEFAULT NULL,
  `tapMiss` int(11) DEFAULT NULL,
  `holdCriticalPerfect` int(11) DEFAULT NULL,
  `holdPerfect` int(11) DEFAULT NULL,
  `holdGreat` int(11) DEFAULT NULL,
  `holdGood` int(11) DEFAULT NULL,
  `holdMiss` int(11) DEFAULT NULL,
  `slideCriticalPerfect` int(11) DEFAULT NULL,
  `slidePerfect` int(11) DEFAULT NULL,
  `slideGreat` int(11) DEFAULT NULL,
  `slideGood` int(11) DEFAULT NULL,
  `slideMiss` int(11) DEFAULT NULL,
  `touchCriticalPerfect` int(11) DEFAULT NULL,
  `touchPerfect` int(11) DEFAULT NULL,
  `touchGreat` int(11) DEFAULT NULL,
  `touchGood` int(11) DEFAULT NULL,
  `touchMiss` int(11) DEFAULT NULL,
  `breakCriticalPerfect` int(11) DEFAULT NULL,
  `breakPerfect` int(11) DEFAULT NULL,
  `breakGreat` int(11) DEFAULT NULL,
  `breakGood` int(11) DEFAULT NULL,
  `breakMiss` int(11) DEFAULT NULL,
  `isTap` tinyint(1) DEFAULT NULL,
  `isHold` tinyint(1) DEFAULT NULL,
  `isSlide` tinyint(1) DEFAULT NULL,
  `isTouch` tinyint(1) DEFAULT NULL,
  `isBreak` tinyint(1) DEFAULT NULL,
  `isCriticalDisp` tinyint(1) DEFAULT NULL,
  `isFastLateDisp` tinyint(1) DEFAULT NULL,
  `fastCount` int(11) DEFAULT NULL,
  `lateCount` int(11) DEFAULT NULL,
  `isAchieveNewRecord` tinyint(1) DEFAULT NULL,
  `isDeluxscoreNewRecord` tinyint(1) DEFAULT NULL,
  `comboStatus` int(11) DEFAULT NULL,
  `syncStatus` int(11) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `beforeRating` int(11) DEFAULT NULL,
  `afterRating` int(11) DEFAULT NULL,
  `beforeGrade` int(11) DEFAULT NULL,
  `afterGrade` int(11) DEFAULT NULL,
  `afterGradeRank` int(11) DEFAULT NULL,
  `beforeDeluxRating` int(11) DEFAULT NULL,
  `afterDeluxRating` int(11) DEFAULT NULL,
  `isPlayTutorial` tinyint(1) DEFAULT NULL,
  `isEventMode` tinyint(1) DEFAULT NULL,
  `isFreedomMode` tinyint(1) DEFAULT NULL,
  `playMode` int(11) DEFAULT NULL,
  `isNewFree` tinyint(1) DEFAULT NULL,
  `extNum1` int(11) DEFAULT NULL,
  `extNum2` int(11) DEFAULT NULL,
  `extNum4` int(11) DEFAULT NULL,
  `extBool1` tinyint(1) DEFAULT NULL,
  `extBool2` tinyint(1) DEFAULT NULL,
  `extBool3` tinyint(1) DEFAULT NULL,
  `trialPlayAchievement` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `mai2_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_playlog` WRITE;
/*!40000 ALTER TABLE `mai2_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_playlog_2p`
--

DROP TABLE IF EXISTS `mai2_playlog_2p`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_playlog_2p` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `userId1` int(11) DEFAULT NULL,
  `userId2` int(11) DEFAULT NULL,
  `userName1` varchar(25) DEFAULT NULL,
  `userName2` varchar(25) DEFAULT NULL,
  `regionId` int(11) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `user2pPlaylogDetailList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`user2pPlaylogDetailList`)),
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `mai2_playlog_2p_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_playlog_2p`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_playlog_2p` WRITE;
/*!40000 ALTER TABLE `mai2_playlog_2p` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_playlog_2p` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_activity`
--

DROP TABLE IF EXISTS `mai2_profile_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `kind` int(11) DEFAULT NULL,
  `activityId` int(11) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `param3` int(11) DEFAULT NULL,
  `param4` int(11) DEFAULT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_activity_uk` (`user`,`kind`,`activityId`),
  CONSTRAINT `mai2_profile_activity_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_activity`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_activity` WRITE;
/*!40000 ALTER TABLE `mai2_profile_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_activity` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_consec_logins`
--

DROP TABLE IF EXISTS `mai2_profile_consec_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_consec_logins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `logins` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_consec_logins_uk` (`user`,`version`),
  CONSTRAINT `mai2_profile_consec_logins_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_consec_logins`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_consec_logins` WRITE;
/*!40000 ALTER TABLE `mai2_profile_consec_logins` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_consec_logins` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_detail`
--

DROP TABLE IF EXISTS `mai2_profile_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_detail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `userName` varchar(25) DEFAULT NULL,
  `isNetMember` int(11) DEFAULT NULL,
  `iconId` int(11) DEFAULT NULL,
  `plateId` int(11) DEFAULT NULL,
  `titleId` int(11) DEFAULT NULL,
  `partnerId` int(11) DEFAULT NULL,
  `frameId` int(11) DEFAULT NULL,
  `selectMapId` int(11) DEFAULT NULL,
  `totalAwake` int(11) DEFAULT NULL,
  `gradeRating` int(11) DEFAULT NULL,
  `musicRating` int(11) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `highestRating` int(11) DEFAULT NULL,
  `gradeRank` int(11) DEFAULT NULL,
  `classRank` int(11) DEFAULT NULL,
  `courseRank` int(11) DEFAULT NULL,
  `charaSlot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`charaSlot`)),
  `charaLockSlot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`charaLockSlot`)),
  `contentBit` bigint(20) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `currentPlayCount` int(11) DEFAULT NULL,
  `renameCredit` int(11) DEFAULT NULL,
  `mapStock` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `totalPoint` int(11) DEFAULT NULL,
  `eventWatchedDate` varchar(25) DEFAULT NULL,
  `lastGameId` varchar(25) DEFAULT NULL,
  `lastRomVersion` varchar(25) DEFAULT NULL,
  `lastDataVersion` varchar(25) DEFAULT NULL,
  `lastLoginDate` varchar(25) DEFAULT NULL,
  `lastPairLoginDate` varchar(25) DEFAULT NULL,
  `lastPlayDate` varchar(25) DEFAULT NULL,
  `lastTrialPlayDate` varchar(25) DEFAULT NULL,
  `lastPlayCredit` int(11) DEFAULT NULL,
  `lastPlayMode` int(11) DEFAULT NULL,
  `lastPlaceId` int(11) DEFAULT NULL,
  `lastPlaceName` varchar(25) DEFAULT NULL,
  `lastAllNetId` int(11) DEFAULT NULL,
  `lastRegionId` int(11) DEFAULT NULL,
  `lastRegionName` varchar(25) DEFAULT NULL,
  `lastClientId` varchar(25) DEFAULT NULL,
  `lastCountryCode` varchar(25) DEFAULT NULL,
  `lastSelectEMoney` int(11) DEFAULT NULL,
  `lastSelectTicket` int(11) DEFAULT NULL,
  `lastSelectCourse` int(11) DEFAULT NULL,
  `lastCountCourse` int(11) DEFAULT NULL,
  `firstGameId` varchar(25) DEFAULT NULL,
  `firstRomVersion` varchar(25) DEFAULT NULL,
  `firstDataVersion` varchar(25) DEFAULT NULL,
  `firstPlayDate` varchar(25) DEFAULT NULL,
  `compatibleCmVersion` varchar(25) DEFAULT NULL,
  `dailyBonusDate` varchar(25) DEFAULT NULL,
  `dailyCourseBonusDate` varchar(25) DEFAULT NULL,
  `playVsCount` int(11) DEFAULT NULL,
  `playSyncCount` int(11) DEFAULT NULL,
  `winCount` int(11) DEFAULT NULL,
  `helpCount` int(11) DEFAULT NULL,
  `comboCount` int(11) DEFAULT NULL,
  `totalDeluxscore` bigint(20) DEFAULT NULL,
  `totalBasicDeluxscore` bigint(20) DEFAULT NULL,
  `totalAdvancedDeluxscore` bigint(20) DEFAULT NULL,
  `totalExpertDeluxscore` bigint(20) DEFAULT NULL,
  `totalMasterDeluxscore` bigint(20) DEFAULT NULL,
  `totalReMasterDeluxscore` bigint(20) DEFAULT NULL,
  `totalSync` int(11) DEFAULT NULL,
  `totalBasicSync` int(11) DEFAULT NULL,
  `totalAdvancedSync` int(11) DEFAULT NULL,
  `totalExpertSync` int(11) DEFAULT NULL,
  `totalMasterSync` int(11) DEFAULT NULL,
  `totalReMasterSync` int(11) DEFAULT NULL,
  `totalAchievement` bigint(20) DEFAULT NULL,
  `totalBasicAchievement` bigint(20) DEFAULT NULL,
  `totalAdvancedAchievement` bigint(20) DEFAULT NULL,
  `totalExpertAchievement` bigint(20) DEFAULT NULL,
  `totalMasterAchievement` bigint(20) DEFAULT NULL,
  `totalReMasterAchievement` bigint(20) DEFAULT NULL,
  `playerOldRating` bigint(20) DEFAULT NULL,
  `playerNewRating` bigint(20) DEFAULT NULL,
  `dateTime` bigint(20) DEFAULT NULL,
  `friendRegistSkip` smallint(6) DEFAULT NULL,
  `banState` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_detail_uk` (`user`,`version`),
  CONSTRAINT `mai2_profile_detail_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_detail`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_detail` WRITE;
/*!40000 ALTER TABLE `mai2_profile_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_detail` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_extend`
--

DROP TABLE IF EXISTS `mai2_profile_extend`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_extend` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `selectMusicId` int(11) DEFAULT NULL,
  `selectDifficultyId` int(11) DEFAULT NULL,
  `categoryIndex` int(11) DEFAULT NULL,
  `musicIndex` int(11) DEFAULT NULL,
  `extraFlag` int(11) DEFAULT NULL,
  `selectScoreType` int(11) DEFAULT NULL,
  `extendContentBit` bigint(20) DEFAULT NULL,
  `isPhotoAgree` tinyint(1) DEFAULT NULL,
  `isGotoCodeRead` tinyint(1) DEFAULT NULL,
  `selectResultDetails` tinyint(1) DEFAULT NULL,
  `selectResultScoreViewType` int(11) DEFAULT NULL,
  `sortCategorySetting` int(11) DEFAULT NULL,
  `sortMusicSetting` int(11) DEFAULT NULL,
  `selectedCardList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`selectedCardList`)),
  `encountMapNpcList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`encountMapNpcList`)),
  `playStatusSetting` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_extend_uk` (`user`,`version`),
  CONSTRAINT `mai2_profile_extend_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_extend`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_extend` WRITE;
/*!40000 ALTER TABLE `mai2_profile_extend` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_extend` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_ghost`
--

DROP TABLE IF EXISTS `mai2_profile_ghost`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_ghost` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version_int` int(11) NOT NULL,
  `name` varchar(25) DEFAULT NULL,
  `iconId` int(11) DEFAULT NULL,
  `plateId` int(11) DEFAULT NULL,
  `titleId` int(11) DEFAULT NULL,
  `rate` int(11) DEFAULT NULL,
  `udemaeRate` int(11) DEFAULT NULL,
  `courseRank` int(11) DEFAULT NULL,
  `classRank` int(11) DEFAULT NULL,
  `classValue` int(11) DEFAULT NULL,
  `playDatetime` varchar(25) DEFAULT NULL,
  `shopId` int(11) DEFAULT NULL,
  `regionCode` int(11) DEFAULT NULL,
  `typeId` int(11) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `resultBitList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`resultBitList`)),
  `resultNum` int(11) DEFAULT NULL,
  `achievement` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_ghost_uk` (`user`,`version`,`musicId`,`difficulty`),
  CONSTRAINT `mai2_profile_ghost_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_ghost`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_ghost` WRITE;
/*!40000 ALTER TABLE `mai2_profile_ghost` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_ghost` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_option`
--

DROP TABLE IF EXISTS `mai2_profile_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `selectMusicId` int(11) DEFAULT NULL,
  `optionKind` int(11) DEFAULT NULL,
  `noteSpeed` int(11) DEFAULT NULL,
  `slideSpeed` int(11) DEFAULT NULL,
  `touchSpeed` int(11) DEFAULT NULL,
  `tapDesign` int(11) DEFAULT NULL,
  `tapSe` int(11) DEFAULT 0,
  `holdDesign` int(11) DEFAULT NULL,
  `slideDesign` int(11) DEFAULT NULL,
  `starType` int(11) DEFAULT NULL,
  `outlineDesign` int(11) DEFAULT NULL,
  `noteSize` int(11) DEFAULT NULL,
  `slideSize` int(11) DEFAULT NULL,
  `touchSize` int(11) DEFAULT NULL,
  `starRotate` int(11) DEFAULT NULL,
  `dispCenter` int(11) DEFAULT NULL,
  `outFrameType` int(11) DEFAULT NULL,
  `dispChain` int(11) DEFAULT NULL,
  `dispRate` int(11) DEFAULT NULL,
  `dispBar` int(11) DEFAULT NULL,
  `touchEffect` int(11) DEFAULT NULL,
  `submonitorAnimation` int(11) DEFAULT NULL,
  `submonitorAchive` int(11) DEFAULT NULL,
  `submonitorAppeal` int(11) DEFAULT NULL,
  `matching` int(11) DEFAULT NULL,
  `trackSkip` int(11) DEFAULT NULL,
  `brightness` int(11) DEFAULT NULL,
  `mirrorMode` int(11) DEFAULT NULL,
  `dispJudge` int(11) DEFAULT NULL,
  `dispJudgePos` int(11) DEFAULT NULL,
  `dispJudgeTouchPos` int(11) DEFAULT NULL,
  `adjustTiming` int(11) DEFAULT NULL,
  `judgeTiming` int(11) DEFAULT NULL,
  `ansVolume` int(11) DEFAULT NULL,
  `tapHoldVolume` int(11) DEFAULT NULL,
  `criticalSe` int(11) DEFAULT NULL,
  `breakSe` int(11) DEFAULT NULL,
  `breakVolume` int(11) DEFAULT NULL,
  `exSe` int(11) DEFAULT NULL,
  `exVolume` int(11) DEFAULT NULL,
  `slideSe` int(11) DEFAULT NULL,
  `slideVolume` int(11) DEFAULT NULL,
  `breakSlideVolume` int(11) DEFAULT NULL,
  `touchVolume` int(11) DEFAULT NULL,
  `touchHoldVolume` int(11) DEFAULT NULL,
  `damageSeVolume` int(11) DEFAULT NULL,
  `headPhoneVolume` int(11) DEFAULT NULL,
  `sortTab` int(11) DEFAULT NULL,
  `sortMusic` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_option_uk` (`user`,`version`),
  CONSTRAINT `mai2_profile_option_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_option`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_option` WRITE;
/*!40000 ALTER TABLE `mai2_profile_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_option` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_rating`
--

DROP TABLE IF EXISTS `mai2_profile_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL,
  `ratingList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`ratingList`)),
  `newRatingList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`newRatingList`)),
  `nextRatingList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`nextRatingList`)),
  `nextNewRatingList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`nextNewRatingList`)),
  `udemae` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`udemae`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_rating_uk` (`user`,`version`),
  CONSTRAINT `mai2_profile_rating_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_rating`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_rating` WRITE;
/*!40000 ALTER TABLE `mai2_profile_rating` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_rating` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_profile_region`
--

DROP TABLE IF EXISTS `mai2_profile_region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_profile_region` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `regionId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT 1,
  `created` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_region_uk` (`user`,`regionId`),
  CONSTRAINT `mai2_profile_region_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_profile_region`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_profile_region` WRITE;
/*!40000 ALTER TABLE `mai2_profile_region` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_profile_region` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_score_best`
--

DROP TABLE IF EXISTS `mai2_score_best`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_score_best` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `achievement` int(11) DEFAULT NULL,
  `comboStatus` int(11) DEFAULT NULL,
  `syncStatus` int(11) DEFAULT NULL,
  `deluxscoreMax` int(11) DEFAULT NULL,
  `scoreRank` int(11) DEFAULT NULL,
  `extNum1` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_score_best_uk` (`user`,`musicId`,`level`),
  CONSTRAINT `mai2_score_best_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_score_best`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_score_best` WRITE;
/*!40000 ALTER TABLE `mai2_score_best` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_score_best` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_score_course`
--

DROP TABLE IF EXISTS `mai2_score_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_score_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `courseId` int(11) DEFAULT NULL,
  `isLastClear` tinyint(1) DEFAULT NULL,
  `totalRestlife` int(11) DEFAULT NULL,
  `totalAchievement` int(11) DEFAULT NULL,
  `totalDeluxscore` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `clearDate` varchar(25) DEFAULT NULL,
  `lastPlayDate` varchar(25) DEFAULT NULL,
  `bestAchievement` int(11) DEFAULT NULL,
  `bestAchievementDate` varchar(25) DEFAULT NULL,
  `bestDeluxscore` int(11) DEFAULT NULL,
  `bestDeluxscoreDate` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_score_best_uk` (`user`,`courseId`),
  CONSTRAINT `mai2_score_course_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_score_course`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_score_course` WRITE;
/*!40000 ALTER TABLE `mai2_score_course` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_score_course` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_score_kaleidxscope`
--

DROP TABLE IF EXISTS `mai2_score_kaleidxscope`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_score_kaleidxscope` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `gateId` int(11) DEFAULT NULL,
  `isGateFound` tinyint(1) DEFAULT NULL,
  `isKeyFound` tinyint(1) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `totalRestLife` int(11) DEFAULT NULL,
  `totalAchievement` int(11) DEFAULT NULL,
  `totalDeluxscore` int(11) DEFAULT NULL,
  `bestAchievement` int(11) DEFAULT NULL,
  `bestDeluxscore` int(11) DEFAULT NULL,
  `bestAchievementDate` varchar(25) DEFAULT NULL,
  `bestDeluxscoreDate` varchar(25) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `clearDate` varchar(25) DEFAULT NULL,
  `lastPlayDate` varchar(25) DEFAULT NULL,
  `isInfoWatched` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_score_best_uk` (`user`,`gateId`),
  CONSTRAINT `mai2_score_kaleidxscope_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_score_kaleidxscope`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_score_kaleidxscope` WRITE;
/*!40000 ALTER TABLE `mai2_score_kaleidxscope` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_score_kaleidxscope` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_static_cards`
--

DROP TABLE IF EXISTS `mai2_static_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_static_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `cardName` varchar(255) NOT NULL,
  `startDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `endDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `noticeStartDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `noticeEndDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `enabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_static_cards_uk` (`version`,`cardId`,`cardName`),
  KEY `opt` (`opt`),
  CONSTRAINT `mai2_static_cards_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `cm_static_opts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_static_cards`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_static_cards` WRITE;
/*!40000 ALTER TABLE `mai2_static_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_static_cards` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_static_event`
--

DROP TABLE IF EXISTS `mai2_static_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_static_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `eventId` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `startDate` timestamp NULL DEFAULT current_timestamp(),
  `enabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_static_event_uk` (`version`,`eventId`,`type`),
  KEY `opt` (`opt`),
  CONSTRAINT `mai2_static_event_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `mai2_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_static_event`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_static_event` WRITE;
/*!40000 ALTER TABLE `mai2_static_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_static_event` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_static_music`
--

DROP TABLE IF EXISTS `mai2_static_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_static_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `songId` int(11) DEFAULT NULL,
  `chartId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `artist` varchar(255) DEFAULT NULL,
  `genre` varchar(255) DEFAULT NULL,
  `bpm` int(11) DEFAULT NULL,
  `addedVersion` varchar(255) DEFAULT NULL,
  `difficulty` float DEFAULT NULL,
  `noteDesigner` varchar(255) DEFAULT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_static_music_uk` (`songId`,`chartId`,`version`),
  KEY `opt` (`opt`),
  CONSTRAINT `mai2_static_music_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `mai2_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_static_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_static_music` WRITE;
/*!40000 ALTER TABLE `mai2_static_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_static_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_static_opt`
--

DROP TABLE IF EXISTS `mai2_static_opt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_static_opt` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `name` varchar(4) NOT NULL,
  `sequence` int(11) NOT NULL,
  `cmReleaseVer` int(11) NOT NULL,
  `whenRead` timestamp NOT NULL DEFAULT current_timestamp(),
  `isEnable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_static_opt_uk` (`version`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_static_opt`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_static_opt` WRITE;
/*!40000 ALTER TABLE `mai2_static_opt` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_static_opt` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_static_ticket`
--

DROP TABLE IF EXISTS `mai2_static_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_static_ticket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `ticketId` int(11) DEFAULT NULL,
  `kind` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` int(11) DEFAULT 1,
  `enabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_static_ticket_uk` (`version`,`ticketId`),
  KEY `opt` (`opt`),
  CONSTRAINT `mai2_static_ticket_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `mai2_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_static_ticket`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_static_ticket` WRITE;
/*!40000 ALTER TABLE `mai2_static_ticket` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_static_ticket` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_user_intimate`
--

DROP TABLE IF EXISTS `mai2_user_intimate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_user_intimate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `partnerId` int(11) NOT NULL,
  `intimateLevel` int(11) NOT NULL,
  `intimateCountRewarded` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_user_intimate_uk` (`user`,`partnerId`),
  CONSTRAINT `mai2_user_intimate_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_user_intimate`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_user_intimate` WRITE;
/*!40000 ALTER TABLE `mai2_user_intimate` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_user_intimate` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_user_photo`
--

DROP TABLE IF EXISTS `mai2_user_photo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_user_photo` (
  `id` varchar(36) NOT NULL,
  `user` int(11) NOT NULL,
  `playlog_num` int(11) NOT NULL,
  `track_num` int(11) NOT NULL,
  `when_upload` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_user_photo_uk` (`user`,`playlog_num`,`track_num`),
  CONSTRAINT `mai2_user_photo_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_user_photo`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_user_photo` WRITE;
/*!40000 ALTER TABLE `mai2_user_photo` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_user_photo` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mai2_user_rival`
--

DROP TABLE IF EXISTS `mai2_user_rival`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mai2_user_rival` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `rival` int(11) NOT NULL,
  `show` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_user_rival_uk` (`user`,`rival`),
  KEY `rival` (`rival`),
  CONSTRAINT `mai2_user_rival_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `mai2_user_rival_ibfk_2` FOREIGN KEY (`rival`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mai2_user_rival`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mai2_user_rival` WRITE;
/*!40000 ALTER TABLE `mai2_user_rival` DISABLE KEYS */;
/*!40000 ALTER TABLE `mai2_user_rival` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_playlog`
--

DROP TABLE IF EXISTS `maimai_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `orderId` int(11) DEFAULT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `placeName` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `regionId` int(11) DEFAULT NULL,
  `playDate` varchar(255) DEFAULT NULL,
  `userPlayDate` varchar(255) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `gameMode` int(11) DEFAULT NULL,
  `rivalNum` int(11) DEFAULT NULL,
  `track` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `isFreeToPlay` tinyint(1) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `playedUserId1` int(11) DEFAULT NULL,
  `playedUserId2` int(11) DEFAULT NULL,
  `playedUserId3` int(11) DEFAULT NULL,
  `playedUserName1` varchar(255) DEFAULT NULL,
  `playedUserName2` varchar(255) DEFAULT NULL,
  `playedUserName3` varchar(255) DEFAULT NULL,
  `playedMusicLevel1` int(11) DEFAULT NULL,
  `playedMusicLevel2` int(11) DEFAULT NULL,
  `playedMusicLevel3` int(11) DEFAULT NULL,
  `achievement` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `tapScore` int(11) DEFAULT NULL,
  `holdScore` int(11) DEFAULT NULL,
  `slideScore` int(11) DEFAULT NULL,
  `breakScore` int(11) DEFAULT NULL,
  `syncRate` int(11) DEFAULT NULL,
  `vsWin` int(11) DEFAULT NULL,
  `isAllPerfect` tinyint(1) DEFAULT NULL,
  `fullCombo` int(11) DEFAULT NULL,
  `maxFever` int(11) DEFAULT NULL,
  `maxCombo` int(11) DEFAULT NULL,
  `tapPerfect` int(11) DEFAULT NULL,
  `tapGreat` int(11) DEFAULT NULL,
  `tapGood` int(11) DEFAULT NULL,
  `tapBad` int(11) DEFAULT NULL,
  `holdPerfect` int(11) DEFAULT NULL,
  `holdGreat` int(11) DEFAULT NULL,
  `holdGood` int(11) DEFAULT NULL,
  `holdBad` int(11) DEFAULT NULL,
  `slidePerfect` int(11) DEFAULT NULL,
  `slideGreat` int(11) DEFAULT NULL,
  `slideGood` int(11) DEFAULT NULL,
  `slideBad` int(11) DEFAULT NULL,
  `breakPerfect` int(11) DEFAULT NULL,
  `breakGreat` int(11) DEFAULT NULL,
  `breakGood` int(11) DEFAULT NULL,
  `breakBad` int(11) DEFAULT NULL,
  `judgeStyle` int(11) DEFAULT NULL,
  `isTrackSkip` tinyint(1) DEFAULT NULL,
  `isHighScore` tinyint(1) DEFAULT NULL,
  `isChallengeTrack` tinyint(1) DEFAULT NULL,
  `challengeLife` int(11) DEFAULT NULL,
  `challengeRemain` int(11) DEFAULT NULL,
  `isAllPerfectPlus` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `maimai_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_playlog` WRITE;
/*!40000 ALTER TABLE `maimai_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_profile_boss`
--

DROP TABLE IF EXISTS `maimai_profile_boss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_profile_boss` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `pandoraFlagList0` bigint(20) DEFAULT NULL,
  `pandoraFlagList1` bigint(20) DEFAULT NULL,
  `pandoraFlagList2` bigint(20) DEFAULT NULL,
  `pandoraFlagList3` bigint(20) DEFAULT NULL,
  `pandoraFlagList4` bigint(20) DEFAULT NULL,
  `pandoraFlagList5` bigint(20) DEFAULT NULL,
  `pandoraFlagList6` bigint(20) DEFAULT NULL,
  `emblemFlagList` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_boss_uk` (`user`),
  CONSTRAINT `maimai_profile_boss_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_profile_boss`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_profile_boss` WRITE;
/*!40000 ALTER TABLE `maimai_profile_boss` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_profile_boss` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_profile_detail`
--

DROP TABLE IF EXISTS `maimai_profile_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_profile_detail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `lastDataVersion` int(11) DEFAULT NULL,
  `userName` varchar(8) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `totalPoint` int(11) DEFAULT NULL,
  `iconId` int(11) DEFAULT NULL,
  `nameplateId` int(11) DEFAULT NULL,
  `frameId` int(11) DEFAULT NULL,
  `trophyId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `playVsCount` int(11) DEFAULT NULL,
  `playSyncCount` int(11) DEFAULT NULL,
  `winCount` int(11) DEFAULT NULL,
  `helpCount` int(11) DEFAULT NULL,
  `comboCount` int(11) DEFAULT NULL,
  `feverCount` int(11) DEFAULT NULL,
  `totalHiScore` int(11) DEFAULT NULL,
  `totalEasyHighScore` int(11) DEFAULT NULL,
  `totalBasicHighScore` int(11) DEFAULT NULL,
  `totalAdvancedHighScore` int(11) DEFAULT NULL,
  `totalExpertHighScore` int(11) DEFAULT NULL,
  `totalMasterHighScore` int(11) DEFAULT NULL,
  `totalReMasterHighScore` int(11) DEFAULT NULL,
  `totalHighSync` int(11) DEFAULT NULL,
  `totalEasySync` int(11) DEFAULT NULL,
  `totalBasicSync` int(11) DEFAULT NULL,
  `totalAdvancedSync` int(11) DEFAULT NULL,
  `totalExpertSync` int(11) DEFAULT NULL,
  `totalMasterSync` int(11) DEFAULT NULL,
  `totalReMasterSync` int(11) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `highestRating` int(11) DEFAULT NULL,
  `rankAuthTailId` int(11) DEFAULT NULL,
  `eventWatchedDate` varchar(255) DEFAULT NULL,
  `webLimitDate` varchar(255) DEFAULT NULL,
  `challengeTrackPhase` int(11) DEFAULT NULL,
  `firstPlayBits` int(11) DEFAULT NULL,
  `lastPlayDate` varchar(255) DEFAULT NULL,
  `lastPlaceId` int(11) DEFAULT NULL,
  `lastPlaceName` varchar(255) DEFAULT NULL,
  `lastRegionId` int(11) DEFAULT NULL,
  `lastRegionName` varchar(255) DEFAULT NULL,
  `lastClientId` varchar(255) DEFAULT NULL,
  `lastCountryCode` varchar(255) DEFAULT NULL,
  `eventPoint` int(11) DEFAULT NULL,
  `totalLv` int(11) DEFAULT NULL,
  `lastLoginBonusDay` int(11) DEFAULT NULL,
  `lastSurvivalBonusDay` int(11) DEFAULT NULL,
  `loginBonusLv` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `maimai_profile_detail_uk` (`user`,`version`),
  CONSTRAINT `maimai_profile_detail_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_profile_detail`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_profile_detail` WRITE;
/*!40000 ALTER TABLE `maimai_profile_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_profile_detail` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_profile_grade_status`
--

DROP TABLE IF EXISTS `maimai_profile_grade_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_profile_grade_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `gradeVersion` int(11) DEFAULT NULL,
  `gradeLevel` int(11) DEFAULT NULL,
  `gradeSubLevel` int(11) DEFAULT NULL,
  `gradeMaxId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `maimai_profile_grade_status_uk` (`user`,`gradeVersion`),
  CONSTRAINT `maimai_profile_grade_status_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_profile_grade_status`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_profile_grade_status` WRITE;
/*!40000 ALTER TABLE `maimai_profile_grade_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_profile_grade_status` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_profile_option`
--

DROP TABLE IF EXISTS `maimai_profile_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_profile_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `soudEffect` int(11) DEFAULT NULL,
  `mirrorMode` int(11) DEFAULT NULL,
  `guideSpeed` int(11) DEFAULT NULL,
  `bgInfo` int(11) DEFAULT NULL,
  `brightness` int(11) DEFAULT NULL,
  `isStarRot` int(11) DEFAULT NULL,
  `breakSe` int(11) DEFAULT NULL,
  `slideSe` int(11) DEFAULT NULL,
  `hardJudge` int(11) DEFAULT NULL,
  `isTagJump` int(11) DEFAULT NULL,
  `breakSeVol` int(11) DEFAULT NULL,
  `slideSeVol` int(11) DEFAULT NULL,
  `isUpperDisp` int(11) DEFAULT NULL,
  `trackSkip` int(11) DEFAULT NULL,
  `optionMode` int(11) DEFAULT NULL,
  `simpleOptionParam` int(11) DEFAULT NULL,
  `adjustTiming` int(11) DEFAULT NULL,
  `dispTiming` int(11) DEFAULT NULL,
  `timingPos` int(11) DEFAULT NULL,
  `ansVol` int(11) DEFAULT NULL,
  `noteVol` int(11) DEFAULT NULL,
  `dmgVol` int(11) DEFAULT NULL,
  `appealFlame` int(11) DEFAULT NULL,
  `isFeverDisp` int(11) DEFAULT NULL,
  `dispJudge` int(11) DEFAULT NULL,
  `judgePos` int(11) DEFAULT NULL,
  `ratingGuard` int(11) DEFAULT NULL,
  `selectChara` int(11) DEFAULT NULL,
  `sortType` int(11) DEFAULT NULL,
  `filterGenre` int(11) DEFAULT NULL,
  `filterLevel` int(11) DEFAULT NULL,
  `filterRank` int(11) DEFAULT NULL,
  `filterVersion` int(11) DEFAULT NULL,
  `filterRec` int(11) DEFAULT NULL,
  `filterFullCombo` int(11) DEFAULT NULL,
  `filterAllPerfect` int(11) DEFAULT NULL,
  `filterDifficulty` int(11) DEFAULT NULL,
  `filterFullSync` int(11) DEFAULT NULL,
  `filterReMaster` int(11) DEFAULT NULL,
  `filterMaxFever` int(11) DEFAULT NULL,
  `finalSelectId` int(11) DEFAULT NULL,
  `finalSelectCategory` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `maimai_profile_option_uk` (`user`,`version`),
  CONSTRAINT `maimai_profile_option_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_profile_option`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_profile_option` WRITE;
/*!40000 ALTER TABLE `maimai_profile_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_profile_option` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_profile_recent_rating`
--

DROP TABLE IF EXISTS `maimai_profile_recent_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_profile_recent_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `userRecentRatingList` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`userRecentRatingList`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `mai2_profile_recent_rating_uk` (`user`),
  CONSTRAINT `maimai_profile_recent_rating_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_profile_recent_rating`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_profile_recent_rating` WRITE;
/*!40000 ALTER TABLE `maimai_profile_recent_rating` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_profile_recent_rating` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_profile_web_option`
--

DROP TABLE IF EXISTS `maimai_profile_web_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_profile_web_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `isNetMember` tinyint(1) DEFAULT NULL,
  `dispRate` int(11) DEFAULT NULL,
  `dispJudgeStyle` int(11) DEFAULT NULL,
  `dispRank` int(11) DEFAULT NULL,
  `dispHomeRanker` int(11) DEFAULT NULL,
  `dispTotalLv` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `maimai_profile_web_option_uk` (`user`,`version`),
  CONSTRAINT `maimai_profile_web_option_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_profile_web_option`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_profile_web_option` WRITE;
/*!40000 ALTER TABLE `maimai_profile_web_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_profile_web_option` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `maimai_score_best`
--

DROP TABLE IF EXISTS `maimai_score_best`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `maimai_score_best` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `achievement` int(11) DEFAULT NULL,
  `scoreMax` int(11) DEFAULT NULL,
  `syncRateMax` int(11) DEFAULT NULL,
  `isAllPerfect` tinyint(1) DEFAULT NULL,
  `isAllPerfectPlus` int(11) DEFAULT NULL,
  `fullCombo` int(11) DEFAULT NULL,
  `maxFever` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `maimai_score_best_uk` (`user`,`musicId`,`level`),
  CONSTRAINT `maimai_score_best_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maimai_score_best`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `maimai_score_best` WRITE;
/*!40000 ALTER TABLE `maimai_score_best` DISABLE KEYS */;
/*!40000 ALTER TABLE `maimai_score_best` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_gp_log`
--

DROP TABLE IF EXISTS `ongeki_gp_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_gp_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `usedCredit` int(11) DEFAULT NULL,
  `placeName` varchar(255) DEFAULT NULL,
  `trxnDate` varchar(255) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `kind` int(11) DEFAULT NULL,
  `pattern` int(11) DEFAULT NULL,
  `currentGP` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `ongeki_gp_log_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_gp_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_gp_log` WRITE;
/*!40000 ALTER TABLE `ongeki_gp_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_gp_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_activity`
--

DROP TABLE IF EXISTS `ongeki_profile_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `kind` int(11) DEFAULT NULL,
  `activityId` int(11) DEFAULT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  `param1` int(11) DEFAULT NULL,
  `param2` int(11) DEFAULT NULL,
  `param3` int(11) DEFAULT NULL,
  `param4` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_activity_uk` (`user`,`kind`,`activityId`),
  CONSTRAINT `ongeki_profile_activity_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_activity`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_activity` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_activity` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_data`
--

DROP TABLE IF EXISTS `ongeki_profile_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `userName` varchar(8) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `reincarnationNum` int(11) DEFAULT NULL,
  `exp` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  `totalPoint` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `jewelCount` int(11) DEFAULT NULL,
  `totalJewelCount` int(11) DEFAULT NULL,
  `medalCount` int(11) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `highestRating` int(11) DEFAULT NULL,
  `battlePoint` int(11) DEFAULT NULL,
  `nameplateId` int(11) DEFAULT NULL,
  `trophyId` int(11) DEFAULT NULL,
  `cardId` int(11) DEFAULT NULL,
  `characterId` int(11) DEFAULT NULL,
  `characterVoiceNo` int(11) DEFAULT NULL,
  `tabSetting` int(11) DEFAULT NULL,
  `tabSortSetting` int(11) DEFAULT NULL,
  `cardCategorySetting` int(11) DEFAULT NULL,
  `cardSortSetting` int(11) DEFAULT NULL,
  `playedTutorialBit` int(11) DEFAULT NULL,
  `firstTutorialCancelNum` int(11) DEFAULT NULL,
  `sumTechHighScore` bigint(20) DEFAULT NULL,
  `sumTechBasicHighScore` bigint(20) DEFAULT NULL,
  `sumTechAdvancedHighScore` bigint(20) DEFAULT NULL,
  `sumTechExpertHighScore` bigint(20) DEFAULT NULL,
  `sumTechMasterHighScore` bigint(20) DEFAULT NULL,
  `sumTechLunaticHighScore` bigint(20) DEFAULT NULL,
  `sumBattleHighScore` bigint(20) DEFAULT NULL,
  `sumBattleBasicHighScore` bigint(20) DEFAULT NULL,
  `sumBattleAdvancedHighScore` bigint(20) DEFAULT NULL,
  `sumBattleExpertHighScore` bigint(20) DEFAULT NULL,
  `sumBattleMasterHighScore` bigint(20) DEFAULT NULL,
  `sumBattleLunaticHighScore` bigint(20) DEFAULT NULL,
  `eventWatchedDate` varchar(255) DEFAULT NULL,
  `cmEventWatchedDate` varchar(255) DEFAULT NULL,
  `firstGameId` varchar(8) DEFAULT NULL,
  `firstRomVersion` varchar(8) DEFAULT NULL,
  `firstDataVersion` varchar(8) DEFAULT NULL,
  `firstPlayDate` varchar(255) DEFAULT NULL,
  `lastGameId` varchar(8) DEFAULT NULL,
  `lastRomVersion` varchar(8) DEFAULT NULL,
  `lastDataVersion` varchar(8) DEFAULT NULL,
  `compatibleCmVersion` varchar(8) DEFAULT NULL,
  `lastPlayDate` varchar(255) DEFAULT NULL,
  `lastPlaceId` int(11) DEFAULT NULL,
  `lastPlaceName` varchar(255) DEFAULT NULL,
  `lastRegionId` int(11) DEFAULT NULL,
  `lastRegionName` varchar(255) DEFAULT NULL,
  `lastAllNetId` int(11) DEFAULT NULL,
  `lastClientId` varchar(16) DEFAULT NULL,
  `lastUsedDeckId` int(11) DEFAULT NULL,
  `lastPlayMusicLevel` int(11) DEFAULT NULL,
  `banStatus` int(11) DEFAULT 0,
  `rivalScoreCategorySetting` int(11) DEFAULT 0,
  `overDamageBattlePoint` int(11) DEFAULT 0,
  `bestBattlePoint` int(11) DEFAULT 0,
  `lastEmoneyBrand` int(11) DEFAULT 0,
  `lastEmoneyCredit` int(11) DEFAULT 0,
  `isDialogWatchedSuggestMemory` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_profile_uk` (`user`,`version`),
  CONSTRAINT `ongeki_profile_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_data` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_kop`
--

DROP TABLE IF EXISTS `ongeki_profile_kop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_kop` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `authKey` int(11) DEFAULT NULL,
  `kopId` int(11) DEFAULT NULL,
  `areaId` int(11) DEFAULT NULL,
  `totalTechScore` int(11) DEFAULT NULL,
  `totalPlatinumScore` int(11) DEFAULT NULL,
  `techRecordDate` varchar(25) DEFAULT NULL,
  `isTotalTechNewRecord` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_kop_uk` (`user`,`kopId`),
  CONSTRAINT `ongeki_profile_kop_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_kop`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_kop` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_kop` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_kop` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_option`
--

DROP TABLE IF EXISTS `ongeki_profile_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `optionSet` int(11) DEFAULT NULL,
  `speed` int(11) DEFAULT NULL,
  `mirror` int(11) DEFAULT NULL,
  `judgeTiming` int(11) DEFAULT NULL,
  `judgeAdjustment` int(11) DEFAULT NULL,
  `abort` int(11) DEFAULT NULL,
  `tapSound` int(11) DEFAULT NULL,
  `volGuide` int(11) DEFAULT NULL,
  `volAll` int(11) DEFAULT NULL,
  `volTap` int(11) DEFAULT NULL,
  `volCrTap` int(11) DEFAULT NULL,
  `volHold` int(11) DEFAULT NULL,
  `volSide` int(11) DEFAULT NULL,
  `volFlick` int(11) DEFAULT NULL,
  `volBell` int(11) DEFAULT NULL,
  `volEnemy` int(11) DEFAULT NULL,
  `volSkill` int(11) DEFAULT NULL,
  `volDamage` int(11) DEFAULT NULL,
  `colorField` int(11) DEFAULT NULL,
  `colorLaneBright` int(11) DEFAULT NULL,
  `colorLane` int(11) DEFAULT NULL,
  `colorSide` int(11) DEFAULT NULL,
  `effectDamage` int(11) DEFAULT NULL,
  `effectPos` int(11) DEFAULT NULL,
  `judgeDisp` int(11) DEFAULT NULL,
  `judgePos` int(11) DEFAULT NULL,
  `judgeBreak` int(11) DEFAULT NULL,
  `judgeHit` int(11) DEFAULT NULL,
  `platinumBreakDisp` int(11) DEFAULT NULL,
  `judgeCriticalBreak` int(11) DEFAULT NULL,
  `matching` int(11) DEFAULT NULL,
  `dispPlayerLv` int(11) DEFAULT NULL,
  `dispRating` int(11) DEFAULT NULL,
  `dispBP` int(11) DEFAULT NULL,
  `headphone` int(11) DEFAULT NULL,
  `stealthField` int(11) DEFAULT NULL,
  `colorWallBright` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_option_uk` (`user`),
  CONSTRAINT `ongeki_profile_option_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_option`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_option` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_option` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_rating`
--

DROP TABLE IF EXISTS `ongeki_profile_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `index` int(11) NOT NULL,
  `musicId` int(11) DEFAULT NULL,
  `difficultId` int(11) DEFAULT NULL,
  `romVersionCode` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_rating_best_uk` (`user`,`version`,`type`,`index`),
  CONSTRAINT `ongeki_profile_rating_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_rating`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_rating` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_rating` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_rating` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_rating_log`
--

DROP TABLE IF EXISTS `ongeki_profile_rating_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_rating_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `highestRating` int(11) DEFAULT NULL,
  `dataVersion` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_rating_log_uk` (`user`,`dataVersion`),
  CONSTRAINT `ongeki_profile_rating_log_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_rating_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_rating_log` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_rating_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_rating_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_recent_rating`
--

DROP TABLE IF EXISTS `ongeki_profile_recent_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_recent_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `recentRating` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recentRating`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_recent_rating_uk` (`user`),
  CONSTRAINT `ongeki_profile_recent_rating_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_recent_rating`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_recent_rating` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_recent_rating` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_recent_rating` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_region`
--

DROP TABLE IF EXISTS `ongeki_profile_region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_region` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `regionId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `created` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_region_uk` (`user`,`regionId`),
  CONSTRAINT `ongeki_profile_region_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_region`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_region` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_region` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_region` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_rival`
--

DROP TABLE IF EXISTS `ongeki_profile_rival`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_rival` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `rivalUserId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_rival_uk` (`user`,`rivalUserId`),
  KEY `rivalUserId` (`rivalUserId`),
  CONSTRAINT `ongeki_profile_rival_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ongeki_profile_rival_ibfk_2` FOREIGN KEY (`rivalUserId`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_rival`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_rival` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_rival` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_rival` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_profile_training_room`
--

DROP TABLE IF EXISTS `ongeki_profile_training_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_profile_training_room` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `roomId` int(11) DEFAULT NULL,
  `authKey` int(11) DEFAULT NULL,
  `cardId` int(11) DEFAULT NULL,
  `valueDate` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_profile_training_room_uk` (`user`,`roomId`),
  CONSTRAINT `ongeki_profile_training_room_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_profile_training_room`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_profile_training_room` WRITE;
/*!40000 ALTER TABLE `ongeki_profile_training_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_profile_training_room` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_score_best`
--

DROP TABLE IF EXISTS `ongeki_score_best`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_score_best` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `musicId` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `playCount` int(11) NOT NULL,
  `techScoreMax` int(11) NOT NULL,
  `techScoreRank` int(11) NOT NULL,
  `battleScoreMax` int(11) NOT NULL,
  `battleScoreRank` int(11) NOT NULL,
  `maxComboCount` int(11) NOT NULL,
  `maxOverKill` float NOT NULL,
  `maxTeamOverKill` float NOT NULL,
  `isFullBell` tinyint(1) NOT NULL,
  `isFullCombo` tinyint(1) NOT NULL,
  `isAllBreake` tinyint(1) NOT NULL,
  `isLock` tinyint(1) NOT NULL,
  `clearStatus` int(11) NOT NULL,
  `isStoryWatched` tinyint(1) NOT NULL,
  `platinumScoreMax` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_best_score_uk` (`user`,`musicId`,`level`),
  CONSTRAINT `ongeki_score_best_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_score_best`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_score_best` WRITE;
/*!40000 ALTER TABLE `ongeki_score_best` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_score_best` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_score_playlog`
--

DROP TABLE IF EXISTS `ongeki_score_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_score_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `placeName` varchar(255) DEFAULT NULL,
  `playDate` timestamp NULL DEFAULT NULL,
  `userPlayDate` timestamp NULL DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `playKind` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `eventName` varchar(255) DEFAULT NULL,
  `eventPoint` int(11) DEFAULT NULL,
  `playedUserId1` int(11) DEFAULT NULL,
  `playedUserId2` int(11) DEFAULT NULL,
  `playedUserId3` int(11) DEFAULT NULL,
  `playedUserName1` varchar(8) DEFAULT NULL,
  `playedUserName2` varchar(8) DEFAULT NULL,
  `playedUserName3` varchar(8) DEFAULT NULL,
  `playedMusicLevel1` int(11) DEFAULT NULL,
  `playedMusicLevel2` int(11) DEFAULT NULL,
  `playedMusicLevel3` int(11) DEFAULT NULL,
  `cardId1` int(11) DEFAULT NULL,
  `cardId2` int(11) DEFAULT NULL,
  `cardId3` int(11) DEFAULT NULL,
  `cardLevel1` int(11) DEFAULT NULL,
  `cardLevel2` int(11) DEFAULT NULL,
  `cardLevel3` int(11) DEFAULT NULL,
  `cardAttack1` int(11) DEFAULT NULL,
  `cardAttack2` int(11) DEFAULT NULL,
  `cardAttack3` int(11) DEFAULT NULL,
  `bossCharaId` int(11) DEFAULT NULL,
  `bossLevel` int(11) DEFAULT NULL,
  `bossAttribute` int(11) DEFAULT NULL,
  `clearStatus` int(11) DEFAULT NULL,
  `techScore` int(11) DEFAULT NULL,
  `techScoreRank` int(11) DEFAULT NULL,
  `battleScore` int(11) DEFAULT NULL,
  `battleScoreRank` int(11) DEFAULT NULL,
  `maxCombo` int(11) DEFAULT NULL,
  `judgeMiss` int(11) DEFAULT NULL,
  `judgeHit` int(11) DEFAULT NULL,
  `judgeBreak` int(11) DEFAULT NULL,
  `judgeCriticalBreak` int(11) DEFAULT NULL,
  `rateTap` int(11) DEFAULT NULL,
  `rateHold` int(11) DEFAULT NULL,
  `rateFlick` int(11) DEFAULT NULL,
  `rateSideTap` int(11) DEFAULT NULL,
  `rateSideHold` int(11) DEFAULT NULL,
  `bellCount` int(11) DEFAULT NULL,
  `totalBellCount` int(11) DEFAULT NULL,
  `damageCount` int(11) DEFAULT NULL,
  `overDamage` int(11) DEFAULT NULL,
  `isTechNewRecord` tinyint(1) DEFAULT NULL,
  `isBattleNewRecord` tinyint(1) DEFAULT NULL,
  `isOverDamageNewRecord` tinyint(1) DEFAULT NULL,
  `isFullCombo` tinyint(1) DEFAULT NULL,
  `isFullBell` tinyint(1) DEFAULT NULL,
  `isAllBreak` tinyint(1) DEFAULT NULL,
  `playerRating` int(11) DEFAULT NULL,
  `battlePoint` int(11) DEFAULT NULL,
  `platinumScore` int(11) DEFAULT NULL,
  `platinumScoreMax` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `ongeki_score_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_score_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_score_playlog` WRITE;
/*!40000 ALTER TABLE `ongeki_score_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_score_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_score_tech_count`
--

DROP TABLE IF EXISTS `ongeki_score_tech_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_score_tech_count` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `levelId` int(11) NOT NULL,
  `allBreakCount` int(11) DEFAULT NULL,
  `allBreakPlusCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_tech_count_uk` (`user`,`levelId`),
  CONSTRAINT `ongeki_score_tech_count_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_score_tech_count`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_score_tech_count` WRITE;
/*!40000 ALTER TABLE `ongeki_score_tech_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_score_tech_count` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_session_log`
--

DROP TABLE IF EXISTS `ongeki_session_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_session_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `sortNumber` int(11) DEFAULT NULL,
  `placeId` int(11) DEFAULT NULL,
  `playDate` varchar(10) DEFAULT NULL,
  `userPlayDate` varchar(25) DEFAULT NULL,
  `isPaid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `ongeki_session_log_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_session_log`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_session_log` WRITE;
/*!40000 ALTER TABLE `ongeki_session_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_session_log` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_cards`
--

DROP TABLE IF EXISTS `ongeki_static_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `charaId` int(11) NOT NULL,
  `nickName` varchar(255) DEFAULT NULL,
  `school` varchar(255) NOT NULL,
  `attribute` varchar(5) NOT NULL,
  `gakunen` varchar(255) NOT NULL,
  `rarity` int(11) NOT NULL,
  `levelParam` varchar(255) NOT NULL,
  `skillId` int(11) NOT NULL,
  `choKaikaSkillId` int(11) NOT NULL,
  `cardNumber` varchar(255) DEFAULT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_cards_uk` (`version`,`cardId`),
  KEY `opt` (`opt`),
  CONSTRAINT `ongeki_static_cards_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `ongeki_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_cards`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_cards` WRITE;
/*!40000 ALTER TABLE `ongeki_static_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_cards` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_client_testmode`
--

DROP TABLE IF EXISTS `ongeki_static_client_testmode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_client_testmode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `regionId` int(11) NOT NULL,
  `placeId` int(11) NOT NULL,
  `clientId` varchar(11) NOT NULL,
  `updateDate` timestamp NOT NULL,
  `isDelivery` tinyint(1) NOT NULL,
  `groupId` int(11) NOT NULL,
  `groupRole` int(11) NOT NULL,
  `continueMode` int(11) NOT NULL,
  `selectMusicTime` int(11) NOT NULL,
  `advertiseVolume` int(11) NOT NULL,
  `eventMode` int(11) NOT NULL,
  `eventMusicNum` int(11) NOT NULL,
  `patternGp` int(11) NOT NULL,
  `limitGp` int(11) NOT NULL,
  `maxLeverMovable` int(11) NOT NULL,
  `minLeverMovable` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_client_testmode_uk` (`clientId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_client_testmode`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_client_testmode` WRITE;
/*!40000 ALTER TABLE `ongeki_static_client_testmode` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_client_testmode` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_events`
--

DROP TABLE IF EXISTS `ongeki_static_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `startDate` timestamp NULL DEFAULT current_timestamp(),
  `endDate` timestamp NULL DEFAULT current_timestamp(),
  `enabled` tinyint(1) DEFAULT 1,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_events_uk` (`version`,`eventId`,`type`),
  KEY `opt` (`opt`),
  CONSTRAINT `ongeki_static_events_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `ongeki_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_events`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_events` WRITE;
/*!40000 ALTER TABLE `ongeki_static_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_events` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_gacha_cards`
--

DROP TABLE IF EXISTS `ongeki_static_gacha_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_gacha_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gachaId` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `rarity` int(11) NOT NULL,
  `weight` int(11) DEFAULT 1,
  `isPickup` tinyint(1) DEFAULT 0,
  `isSelect` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_gacha_cards_uk` (`gachaId`,`cardId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_gacha_cards`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_gacha_cards` WRITE;
/*!40000 ALTER TABLE `ongeki_static_gacha_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_gacha_cards` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_gachas`
--

DROP TABLE IF EXISTS `ongeki_static_gachas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_gachas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `gachaId` int(11) NOT NULL,
  `gachaName` varchar(255) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0,
  `kind` int(11) NOT NULL DEFAULT 0,
  `isCeiling` tinyint(1) DEFAULT 0,
  `maxSelectPoint` int(11) DEFAULT 0,
  `ceilingCnt` int(11) DEFAULT 10,
  `changeRateCnt1` int(11) DEFAULT 0,
  `changeRateCnt2` int(11) DEFAULT 0,
  `startDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `endDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `noticeStartDate` timestamp NULL DEFAULT '2017-12-31 16:00:00',
  `noticeEndDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `convertEndDate` timestamp NULL DEFAULT '2037-12-31 16:00:00',
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_gachas_uk` (`version`,`gachaId`,`gachaName`),
  KEY `opt` (`opt`),
  CONSTRAINT `ongeki_static_gachas_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `cm_static_opts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_gachas`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_gachas` WRITE;
/*!40000 ALTER TABLE `ongeki_static_gachas` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_gachas` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_game_point`
--

DROP TABLE IF EXISTS `ongeki_static_game_point`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_game_point` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `cost` int(11) NOT NULL,
  `startDate` varchar(25) NOT NULL DEFAULT '2000-01-01 05:00:00.0',
  `endDate` varchar(25) NOT NULL DEFAULT '2099-01-01 05:00:00.0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_game_point_uk` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_game_point`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_game_point` WRITE;
/*!40000 ALTER TABLE `ongeki_static_game_point` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_game_point` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_music`
--

DROP TABLE IF EXISTS `ongeki_static_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) DEFAULT NULL,
  `songId` int(11) DEFAULT NULL,
  `chartId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `artist` varchar(255) DEFAULT NULL,
  `genre` varchar(255) DEFAULT NULL,
  `level` float DEFAULT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_music_uk` (`version`,`songId`,`chartId`),
  KEY `opt` (`opt`),
  CONSTRAINT `ongeki_static_music_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `ongeki_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_music` WRITE;
/*!40000 ALTER TABLE `ongeki_static_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_opt`
--

DROP TABLE IF EXISTS `ongeki_static_opt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_opt` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `name` varchar(4) NOT NULL,
  `sequence` int(11) NOT NULL,
  `cmReleaseVer` int(11) NOT NULL,
  `whenRead` timestamp NOT NULL DEFAULT current_timestamp(),
  `isEnable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_opt_uk` (`version`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_opt`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_opt` WRITE;
/*!40000 ALTER TABLE `ongeki_static_opt` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_opt` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_present_list`
--

DROP TABLE IF EXISTS `ongeki_static_present_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_present_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `presentId` int(11) NOT NULL,
  `presentName` varchar(255) NOT NULL,
  `rewardId` int(11) NOT NULL,
  `stock` int(11) NOT NULL,
  `message` varchar(255) DEFAULT NULL,
  `startDate` varchar(25) NOT NULL,
  `endDate` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_present_list_uk` (`version`,`presentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_present_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_present_list` WRITE;
/*!40000 ALTER TABLE `ongeki_static_present_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_present_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_rewards`
--

DROP TABLE IF EXISTS `ongeki_static_rewards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_rewards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `rewardId` int(11) NOT NULL,
  `rewardname` varchar(255) NOT NULL,
  `itemKind` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `opt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_rewards_uk` (`version`,`rewardId`),
  KEY `opt` (`opt`),
  CONSTRAINT `ongeki_static_rewards_ibfk_1` FOREIGN KEY (`opt`) REFERENCES `ongeki_static_opt` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_rewards`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_rewards` WRITE;
/*!40000 ALTER TABLE `ongeki_static_rewards` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_rewards` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_static_tech_music`
--

DROP TABLE IF EXISTS `ongeki_static_tech_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_static_tech_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `eventId` int(11) NOT NULL,
  `musicId` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_static_tech_music_uk` (`version`,`eventId`,`musicId`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_static_tech_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_static_tech_music` WRITE;
/*!40000 ALTER TABLE `ongeki_static_tech_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_static_tech_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_tech_event_ranking`
--

DROP TABLE IF EXISTS `ongeki_tech_event_ranking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_tech_event_ranking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `date` varchar(25) DEFAULT NULL,
  `eventId` int(11) NOT NULL,
  `rank` int(11) DEFAULT NULL,
  `totalPlatinumScore` int(11) NOT NULL,
  `totalTechScore` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_tech_event_ranking_uk` (`user`,`eventId`),
  CONSTRAINT `ongeki_tech_event_ranking_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_tech_event_ranking`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_tech_event_ranking` WRITE;
/*!40000 ALTER TABLE `ongeki_tech_event_ranking` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_tech_event_ranking` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_boss`
--

DROP TABLE IF EXISTS `ongeki_user_boss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_boss` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `damage` int(11) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_boss_uk` (`user`,`musicId`,`eventId`),
  CONSTRAINT `ongeki_user_boss_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_boss`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_boss` WRITE;
/*!40000 ALTER TABLE `ongeki_user_boss` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_boss` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_card`
--

DROP TABLE IF EXISTS `ongeki_user_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_card` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `cardId` int(11) DEFAULT NULL,
  `digitalStock` int(11) DEFAULT NULL,
  `analogStock` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `maxLevel` int(11) DEFAULT NULL,
  `exp` int(11) DEFAULT NULL,
  `printCount` int(11) DEFAULT NULL,
  `useCount` int(11) DEFAULT NULL,
  `isNew` tinyint(1) DEFAULT NULL,
  `kaikaDate` varchar(25) DEFAULT NULL,
  `choKaikaDate` varchar(25) DEFAULT NULL,
  `skillId` int(11) DEFAULT NULL,
  `isAcquired` tinyint(1) DEFAULT NULL,
  `created` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_card_uk` (`user`,`cardId`),
  CONSTRAINT `ongeki_user_card_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_card`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_card` WRITE;
/*!40000 ALTER TABLE `ongeki_user_card` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_card` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_chapter`
--

DROP TABLE IF EXISTS `ongeki_user_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_chapter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `chapterId` int(11) DEFAULT NULL,
  `jewelCount` int(11) DEFAULT NULL,
  `isStoryWatched` tinyint(1) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `lastPlayMusicId` int(11) DEFAULT NULL,
  `lastPlayMusicCategory` int(11) DEFAULT NULL,
  `lastPlayMusicLevel` int(11) DEFAULT NULL,
  `skipTiming1` int(11) DEFAULT NULL,
  `skipTiming2` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_chapter_uk` (`user`,`chapterId`),
  CONSTRAINT `ongeki_user_chapter_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_chapter`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_chapter` WRITE;
/*!40000 ALTER TABLE `ongeki_user_chapter` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_chapter` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_character`
--

DROP TABLE IF EXISTS `ongeki_user_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_character` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `characterId` int(11) DEFAULT NULL,
  `costumeId` int(11) DEFAULT NULL,
  `attachmentId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  `intimateLevel` int(11) DEFAULT NULL,
  `intimateCount` int(11) DEFAULT NULL,
  `intimateCountRewarded` int(11) DEFAULT NULL,
  `intimateCountDate` varchar(25) DEFAULT NULL,
  `isNew` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_character_uk` (`user`,`characterId`),
  CONSTRAINT `ongeki_user_character_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_character`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_character` WRITE;
/*!40000 ALTER TABLE `ongeki_user_character` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_character` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_deck`
--

DROP TABLE IF EXISTS `ongeki_user_deck`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_deck` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `deckId` int(11) DEFAULT NULL,
  `cardId1` int(11) DEFAULT NULL,
  `cardId2` int(11) DEFAULT NULL,
  `cardId3` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_deck_uk` (`user`,`deckId`),
  CONSTRAINT `ongeki_user_deck_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_deck`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_deck` WRITE;
/*!40000 ALTER TABLE `ongeki_user_deck` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_deck` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_event_music`
--

DROP TABLE IF EXISTS `ongeki_user_event_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_event_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `techScoreMax` int(11) DEFAULT NULL,
  `platinumScoreMax` int(11) DEFAULT NULL,
  `techRecordDate` varchar(25) DEFAULT NULL,
  `isTechNewRecord` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_event_music` (`user`,`eventId`,`type`,`musicId`,`level`),
  CONSTRAINT `ongeki_user_event_music_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_event_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_event_music` WRITE;
/*!40000 ALTER TABLE `ongeki_user_event_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_event_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_event_point`
--

DROP TABLE IF EXISTS `ongeki_user_event_point`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_event_point` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `version` int(11) NOT NULL,
  `eventId` int(11) NOT NULL,
  `point` int(11) NOT NULL,
  `rank` int(11) DEFAULT NULL,
  `type` int(11) NOT NULL,
  `date` varchar(25) DEFAULT NULL,
  `isRankingRewarded` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_event_point_uk` (`user`,`eventId`),
  CONSTRAINT `ongeki_user_event_point_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_event_point`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_event_point` WRITE;
/*!40000 ALTER TABLE `ongeki_user_event_point` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_event_point` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_gacha`
--

DROP TABLE IF EXISTS `ongeki_user_gacha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_gacha` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `gachaId` int(11) NOT NULL,
  `totalGachaCnt` int(11) DEFAULT 0,
  `ceilingGachaCnt` int(11) DEFAULT 0,
  `selectPoint` int(11) DEFAULT 0,
  `useSelectPoint` int(11) DEFAULT 0,
  `dailyGachaCnt` int(11) DEFAULT 0,
  `fiveGachaCnt` int(11) DEFAULT 0,
  `elevenGachaCnt` int(11) DEFAULT 0,
  `dailyGachaDate` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_gacha_uk` (`user`,`gachaId`),
  CONSTRAINT `ongeki_user_gacha_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_gacha`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_gacha` WRITE;
/*!40000 ALTER TABLE `ongeki_user_gacha` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_gacha` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_gacha_supply`
--

DROP TABLE IF EXISTS `ongeki_user_gacha_supply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_gacha_supply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_gacha_supply_uk` (`user`,`cardId`),
  CONSTRAINT `ongeki_user_gacha_supply_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_gacha_supply`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_gacha_supply` WRITE;
/*!40000 ALTER TABLE `ongeki_user_gacha_supply` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_gacha_supply` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_item`
--

DROP TABLE IF EXISTS `ongeki_user_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `itemKind` int(11) DEFAULT NULL,
  `itemId` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_item_uk` (`user`,`itemKind`,`itemId`),
  CONSTRAINT `ongeki_user_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_item` WRITE;
/*!40000 ALTER TABLE `ongeki_user_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_login_bonus`
--

DROP TABLE IF EXISTS `ongeki_user_login_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_login_bonus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `bonusId` int(11) DEFAULT NULL,
  `bonusCount` int(11) DEFAULT NULL,
  `lastUpdateDate` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_login_bonus_uk` (`user`,`bonusId`),
  CONSTRAINT `ongeki_user_login_bonus_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_login_bonus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_login_bonus` WRITE;
/*!40000 ALTER TABLE `ongeki_user_login_bonus` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_login_bonus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_memorychapter`
--

DROP TABLE IF EXISTS `ongeki_user_memorychapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_memorychapter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `chapterId` int(11) DEFAULT NULL,
  `gaugeId` int(11) DEFAULT NULL,
  `gaugeNum` int(11) DEFAULT NULL,
  `jewelCount` int(11) DEFAULT NULL,
  `isStoryWatched` tinyint(1) DEFAULT NULL,
  `isBossWatched` tinyint(1) DEFAULT NULL,
  `isDialogWatched` tinyint(1) DEFAULT NULL,
  `isEndingWatched` tinyint(1) DEFAULT NULL,
  `isClear` tinyint(1) DEFAULT NULL,
  `lastPlayMusicId` int(11) DEFAULT NULL,
  `lastPlayMusicLevel` int(11) DEFAULT NULL,
  `lastPlayMusicCategory` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_memorychapter_uk` (`user`,`chapterId`),
  CONSTRAINT `ongeki_user_memorychapter_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_memorychapter`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_memorychapter` WRITE;
/*!40000 ALTER TABLE `ongeki_user_memorychapter` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_memorychapter` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_mission_point`
--

DROP TABLE IF EXISTS `ongeki_user_mission_point`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_mission_point` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL,
  `point` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_mission_point_uk` (`user`,`eventId`),
  CONSTRAINT `ongeki_user_mission_point_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_mission_point`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_mission_point` WRITE;
/*!40000 ALTER TABLE `ongeki_user_mission_point` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_mission_point` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_music_item`
--

DROP TABLE IF EXISTS `ongeki_user_music_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_music_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `musicId` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_music_item_uk` (`user`,`musicId`),
  CONSTRAINT `ongeki_user_music_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_music_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_music_item` WRITE;
/*!40000 ALTER TABLE `ongeki_user_music_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_music_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_print_detail`
--

DROP TABLE IF EXISTS `ongeki_user_print_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_print_detail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `cardId` int(11) NOT NULL,
  `cardType` int(11) DEFAULT 0,
  `printDate` timestamp NOT NULL,
  `serialId` varchar(20) NOT NULL,
  `placeId` int(11) NOT NULL,
  `clientId` varchar(11) NOT NULL,
  `printerSerialId` varchar(20) NOT NULL,
  `isHolograph` tinyint(1) DEFAULT 0,
  `isAutographed` tinyint(1) DEFAULT 0,
  `printOption1` tinyint(1) DEFAULT 1,
  `printOption2` tinyint(1) DEFAULT 1,
  `printOption3` tinyint(1) DEFAULT 1,
  `printOption4` tinyint(1) DEFAULT 1,
  `printOption5` tinyint(1) DEFAULT 1,
  `printOption6` tinyint(1) DEFAULT 1,
  `printOption7` tinyint(1) DEFAULT 1,
  `printOption8` tinyint(1) DEFAULT 1,
  `printOption9` tinyint(1) DEFAULT 1,
  `printOption10` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_print_detail_uk` (`serialId`),
  KEY `user` (`user`),
  CONSTRAINT `ongeki_user_print_detail_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_print_detail`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_print_detail` WRITE;
/*!40000 ALTER TABLE `ongeki_user_print_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_print_detail` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_scenerio`
--

DROP TABLE IF EXISTS `ongeki_user_scenerio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_scenerio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `scenarioId` int(11) DEFAULT NULL,
  `playCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_scenerio_uk` (`user`,`scenarioId`),
  CONSTRAINT `ongeki_user_scenerio_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_scenerio`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_scenerio` WRITE;
/*!40000 ALTER TABLE `ongeki_user_scenerio` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_scenerio` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_story`
--

DROP TABLE IF EXISTS `ongeki_user_story`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_story` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `storyId` int(11) DEFAULT NULL,
  `jewelCount` int(11) DEFAULT NULL,
  `lastChapterId` int(11) DEFAULT NULL,
  `lastPlayMusicId` int(11) DEFAULT NULL,
  `lastPlayMusicCategory` int(11) DEFAULT NULL,
  `lastPlayMusicLevel` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_story_uk` (`user`,`storyId`),
  CONSTRAINT `ongeki_user_story_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_story`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_story` WRITE;
/*!40000 ALTER TABLE `ongeki_user_story` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_story` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_tech_event`
--

DROP TABLE IF EXISTS `ongeki_user_tech_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_tech_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `version` int(11) NOT NULL,
  `eventId` int(11) NOT NULL,
  `totalTechScore` int(11) NOT NULL,
  `totalPlatinumScore` int(11) NOT NULL,
  `techRecordDate` varchar(25) DEFAULT NULL,
  `isRankingRewarded` tinyint(1) DEFAULT NULL,
  `isTotalTechNewRecord` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_tech_event_uk` (`user`,`eventId`),
  CONSTRAINT `ongeki_user_tech_event_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_tech_event`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_tech_event` WRITE;
/*!40000 ALTER TABLE `ongeki_user_tech_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_tech_event` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ongeki_user_trade_item`
--

DROP TABLE IF EXISTS `ongeki_user_trade_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongeki_user_trade_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `chapterId` int(11) DEFAULT NULL,
  `tradeItemId` int(11) DEFAULT NULL,
  `tradeCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongeki_user_trade_item_uk` (`user`,`chapterId`,`tradeItemId`),
  CONSTRAINT `ongeki_user_trade_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongeki_user_trade_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ongeki_user_trade_item` WRITE;
/*!40000 ALTER TABLE `ongeki_user_trade_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `ongeki_user_trade_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pokken_item`
--

DROP TABLE IF EXISTS `pokken_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pokken_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `category` int(11) DEFAULT NULL,
  `content` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user` (`user`),
  UNIQUE KEY `pokken_item_uk` (`user`,`category`,`content`,`type`),
  CONSTRAINT `pokken_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pokken_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pokken_item` WRITE;
/*!40000 ALTER TABLE `pokken_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `pokken_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pokken_match_data`
--

DROP TABLE IF EXISTS `pokken_match_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pokken_match_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `num_games` int(11) DEFAULT NULL,
  `play_modes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`play_modes`)),
  `results` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`results`)),
  `ex_ko_num` int(11) DEFAULT NULL,
  `wko_num` int(11) DEFAULT NULL,
  `timeup_win_num` int(11) DEFAULT NULL,
  `cool_ko_num` int(11) DEFAULT NULL,
  `perfect_ko_num` int(11) DEFAULT NULL,
  `use_navi` int(11) DEFAULT NULL,
  `use_navi_cloth` int(11) DEFAULT NULL,
  `use_aid_skill` int(11) DEFAULT NULL,
  `play_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `pokken_match_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pokken_match_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pokken_match_data` WRITE;
/*!40000 ALTER TABLE `pokken_match_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `pokken_match_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pokken_pokemon_data`
--

DROP TABLE IF EXISTS `pokken_pokemon_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pokken_pokemon_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `char_id` int(11) DEFAULT NULL,
  `illustration_book_no` int(11) NOT NULL,
  `pokemon_exp` int(11) DEFAULT NULL,
  `battle_num_vs_wan` int(11) DEFAULT NULL,
  `win_vs_wan` int(11) DEFAULT NULL,
  `battle_num_vs_lan` int(11) DEFAULT NULL,
  `win_vs_lan` int(11) DEFAULT NULL,
  `battle_num_vs_cpu` int(11) DEFAULT NULL,
  `win_cpu` int(11) DEFAULT NULL,
  `battle_all_num_tutorial` int(11) DEFAULT NULL,
  `battle_num_tutorial` int(11) DEFAULT NULL,
  `bp_point_atk` int(11) DEFAULT NULL,
  `bp_point_res` int(11) DEFAULT NULL,
  `bp_point_def` int(11) DEFAULT NULL,
  `bp_point_sp` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pokken_pokemon_uk` (`user`,`illustration_book_no`),
  CONSTRAINT `pokken_pokemon_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pokken_pokemon_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pokken_pokemon_data` WRITE;
/*!40000 ALTER TABLE `pokken_pokemon_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `pokken_pokemon_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pokken_profile`
--

DROP TABLE IF EXISTS `pokken_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pokken_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `trainer_name` varchar(14) DEFAULT NULL,
  `home_region_code` int(11) DEFAULT NULL,
  `home_loc_name` varchar(255) DEFAULT NULL,
  `pref_code` int(11) DEFAULT NULL,
  `navi_newbie_flag` tinyint(1) DEFAULT NULL,
  `navi_enable_flag` tinyint(1) DEFAULT NULL,
  `pad_vibrate_flag` tinyint(1) DEFAULT NULL,
  `trainer_rank_point` int(11) DEFAULT NULL,
  `wallet` int(11) DEFAULT NULL,
  `fight_money` int(11) DEFAULT NULL,
  `score_point` int(11) DEFAULT NULL,
  `grade_max_num` int(11) DEFAULT NULL,
  `extra_counter` int(11) DEFAULT NULL,
  `tutorial_progress_flag` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tutorial_progress_flag`)),
  `total_play_days` int(11) DEFAULT NULL,
  `play_date_time` int(11) DEFAULT NULL,
  `achievement_flag` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`achievement_flag`)),
  `lucky_box_fail_num` int(11) DEFAULT NULL,
  `event_reward_get_flag` int(11) DEFAULT NULL,
  `rank_pvp_all` int(11) DEFAULT NULL,
  `rank_pvp_loc` int(11) DEFAULT NULL,
  `rank_cpu_all` int(11) DEFAULT NULL,
  `rank_cpu_loc` int(11) DEFAULT NULL,
  `rank_event` int(11) DEFAULT NULL,
  `awake_num` int(11) DEFAULT NULL,
  `use_support_num` int(11) DEFAULT NULL,
  `rankmatch_flag` int(11) DEFAULT NULL,
  `rankmatch_max` int(11) DEFAULT NULL,
  `rankmatch_progress` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`rankmatch_progress`)),
  `rankmatch_success` int(11) DEFAULT NULL,
  `beat_num` int(11) DEFAULT NULL,
  `title_text_id` int(11) DEFAULT NULL,
  `title_plate_id` int(11) DEFAULT NULL,
  `title_decoration_id` int(11) DEFAULT NULL,
  `support_pokemon_list` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`support_pokemon_list`)),
  `support_set_1_1` int(11) DEFAULT NULL,
  `support_set_1_2` int(11) DEFAULT NULL,
  `support_set_2_1` int(11) DEFAULT NULL,
  `support_set_2_2` int(11) DEFAULT NULL,
  `support_set_3_1` int(11) DEFAULT NULL,
  `support_set_3_2` int(11) DEFAULT NULL,
  `navi_trainer` int(11) DEFAULT NULL,
  `navi_version_id` int(11) DEFAULT NULL,
  `aid_skill_list` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`aid_skill_list`)),
  `aid_skill` int(11) DEFAULT NULL,
  `comment_text_id` int(11) DEFAULT NULL,
  `comment_word_id` int(11) DEFAULT NULL,
  `latest_use_pokemon` int(11) DEFAULT NULL,
  `ex_ko_num` int(11) DEFAULT NULL,
  `wko_num` int(11) DEFAULT NULL,
  `timeup_win_num` int(11) DEFAULT NULL,
  `cool_ko_num` int(11) DEFAULT NULL,
  `perfect_ko_num` int(11) DEFAULT NULL,
  `record_flag` int(11) DEFAULT NULL,
  `continue_num` int(11) DEFAULT NULL,
  `avatar_body` int(11) DEFAULT NULL,
  `avatar_gender` int(11) DEFAULT NULL,
  `avatar_background` int(11) DEFAULT NULL,
  `avatar_head` int(11) DEFAULT NULL,
  `avatar_battleglass` int(11) DEFAULT NULL,
  `avatar_face0` int(11) DEFAULT NULL,
  `avatar_face1` int(11) DEFAULT NULL,
  `avatar_face2` int(11) DEFAULT NULL,
  `avatar_bodyall` int(11) DEFAULT NULL,
  `avatar_wear` int(11) DEFAULT NULL,
  `avatar_accessory` int(11) DEFAULT NULL,
  `avatar_stamp` int(11) DEFAULT NULL,
  `event_state` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `sp_bonus_category_id_1` int(11) DEFAULT NULL,
  `sp_bonus_key_value_1` int(11) DEFAULT NULL,
  `sp_bonus_category_id_2` int(11) DEFAULT NULL,
  `sp_bonus_key_value_2` int(11) DEFAULT NULL,
  `last_play_event_id` int(11) DEFAULT NULL,
  `event_achievement_flag` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`event_achievement_flag`)),
  `event_achievement_param` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`event_achievement_param`)),
  `battle_num_vs_wan` int(11) DEFAULT NULL,
  `win_vs_wan` int(11) DEFAULT NULL,
  `battle_num_vs_lan` int(11) DEFAULT NULL,
  `win_vs_lan` int(11) DEFAULT NULL,
  `battle_num_vs_cpu` int(11) DEFAULT NULL,
  `win_cpu` int(11) DEFAULT NULL,
  `battle_num_tutorial` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user` (`user`),
  CONSTRAINT `pokken_profile_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pokken_profile`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pokken_profile` WRITE;
/*!40000 ALTER TABLE `pokken_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `pokken_profile` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_end_sessions`
--

DROP TABLE IF EXISTS `sao_end_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_end_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `quest_id` int(11) NOT NULL,
  `play_result_flag` tinyint(1) NOT NULL,
  `reward_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`reward_data`)),
  `play_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `sao_end_sessions_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_end_sessions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_end_sessions` WRITE;
/*!40000 ALTER TABLE `sao_end_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_end_sessions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_equipment_data`
--

DROP TABLE IF EXISTS `sao_equipment_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_equipment_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `equipment_id` bigint(20) NOT NULL,
  `enhancement_value` int(11) NOT NULL,
  `enhancement_exp` int(11) NOT NULL,
  `awakening_exp` int(11) NOT NULL,
  `awakening_stage` int(11) NOT NULL,
  `possible_awakening_flag` int(11) NOT NULL,
  `is_shop_purchase` tinyint(1) NOT NULL DEFAULT 0,
  `is_protect` tinyint(1) NOT NULL DEFAULT 0,
  `property1_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property1_value1` int(11) NOT NULL DEFAULT 0,
  `property1_value2` int(11) NOT NULL DEFAULT 0,
  `property2_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property2_value1` int(11) NOT NULL DEFAULT 0,
  `property2_value2` int(11) NOT NULL DEFAULT 0,
  `property3_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property3_value1` int(11) NOT NULL DEFAULT 0,
  `property3_value2` int(11) NOT NULL DEFAULT 0,
  `property4_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property4_value1` int(11) NOT NULL DEFAULT 0,
  `property4_value2` int(11) NOT NULL DEFAULT 0,
  `converted_card_num` int(11) NOT NULL DEFAULT 0,
  `get_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_equipment_data_uk` (`user`,`equipment_id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `property1_property_id` (`property1_property_id`),
  KEY `property2_property_id` (`property2_property_id`),
  KEY `property3_property_id` (`property3_property_id`),
  KEY `property4_property_id` (`property4_property_id`),
  CONSTRAINT `sao_equipment_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_equipment_data_ibfk_2` FOREIGN KEY (`equipment_id`) REFERENCES `sao_static_equipment_list` (`EquipmentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_equipment_data_ibfk_3` FOREIGN KEY (`property1_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_equipment_data_ibfk_4` FOREIGN KEY (`property2_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_equipment_data_ibfk_5` FOREIGN KEY (`property3_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_equipment_data_ibfk_6` FOREIGN KEY (`property4_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_equipment_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_equipment_data` WRITE;
/*!40000 ALTER TABLE `sao_equipment_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_equipment_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_hero_log_data`
--

DROP TABLE IF EXISTS `sao_hero_log_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_hero_log_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `hero_log_id` bigint(20) NOT NULL,
  `log_level` int(11) NOT NULL,
  `log_exp` int(11) NOT NULL,
  `main_weapon` int(11) DEFAULT NULL,
  `sub_equipment` int(11) DEFAULT NULL,
  `skill_slot1_skill_id` bigint(20) DEFAULT NULL,
  `skill_slot2_skill_id` bigint(20) DEFAULT NULL,
  `skill_slot3_skill_id` bigint(20) DEFAULT NULL,
  `skill_slot4_skill_id` bigint(20) DEFAULT NULL,
  `skill_slot5_skill_id` bigint(20) DEFAULT NULL,
  `max_level_extend_num` int(11) NOT NULL DEFAULT 0,
  `is_awakenable` tinyint(1) NOT NULL DEFAULT 0,
  `awakening_stage` int(11) NOT NULL DEFAULT 0,
  `awakening_exp` int(11) NOT NULL DEFAULT 0,
  `is_shop_purchase` tinyint(1) NOT NULL DEFAULT 0,
  `is_protect` tinyint(1) NOT NULL DEFAULT 0,
  `property1_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property1_value1` int(11) NOT NULL DEFAULT 0,
  `property1_value2` int(11) NOT NULL DEFAULT 0,
  `property2_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property2_value1` int(11) NOT NULL DEFAULT 0,
  `property2_value2` int(11) NOT NULL DEFAULT 0,
  `property3_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property3_value1` int(11) NOT NULL DEFAULT 0,
  `property3_value2` int(11) NOT NULL DEFAULT 0,
  `property4_property_id` bigint(20) NOT NULL DEFAULT 2,
  `property4_value1` int(11) NOT NULL DEFAULT 0,
  `property4_value2` int(11) NOT NULL DEFAULT 0,
  `converted_card_num` int(11) NOT NULL DEFAULT 0,
  `get_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_hero_log_data_uk` (`user`,`hero_log_id`),
  KEY `hero_log_id` (`hero_log_id`),
  KEY `main_weapon` (`main_weapon`),
  KEY `sub_equipment` (`sub_equipment`),
  KEY `skill_slot1_skill_id` (`skill_slot1_skill_id`),
  KEY `skill_slot2_skill_id` (`skill_slot2_skill_id`),
  KEY `skill_slot3_skill_id` (`skill_slot3_skill_id`),
  KEY `skill_slot4_skill_id` (`skill_slot4_skill_id`),
  KEY `skill_slot5_skill_id` (`skill_slot5_skill_id`),
  KEY `property1_property_id` (`property1_property_id`),
  KEY `property2_property_id` (`property2_property_id`),
  KEY `property3_property_id` (`property3_property_id`),
  KEY `property4_property_id` (`property4_property_id`),
  CONSTRAINT `sao_hero_log_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_log_data_ibfk_10` FOREIGN KEY (`property1_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_log_data_ibfk_11` FOREIGN KEY (`property2_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_log_data_ibfk_12` FOREIGN KEY (`property3_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_log_data_ibfk_13` FOREIGN KEY (`property4_property_id`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_log_data_ibfk_2` FOREIGN KEY (`hero_log_id`) REFERENCES `sao_static_hero_list` (`HeroLogId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_log_data_ibfk_3` FOREIGN KEY (`main_weapon`) REFERENCES `sao_equipment_data` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sao_hero_log_data_ibfk_4` FOREIGN KEY (`sub_equipment`) REFERENCES `sao_equipment_data` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sao_hero_log_data_ibfk_5` FOREIGN KEY (`skill_slot1_skill_id`) REFERENCES `sao_static_skill` (`SkillId`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sao_hero_log_data_ibfk_6` FOREIGN KEY (`skill_slot2_skill_id`) REFERENCES `sao_static_skill` (`SkillId`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sao_hero_log_data_ibfk_7` FOREIGN KEY (`skill_slot3_skill_id`) REFERENCES `sao_static_skill` (`SkillId`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sao_hero_log_data_ibfk_8` FOREIGN KEY (`skill_slot4_skill_id`) REFERENCES `sao_static_skill` (`SkillId`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sao_hero_log_data_ibfk_9` FOREIGN KEY (`skill_slot5_skill_id`) REFERENCES `sao_static_skill` (`SkillId`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_hero_log_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_hero_log_data` WRITE;
/*!40000 ALTER TABLE `sao_hero_log_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_hero_log_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_hero_party`
--

DROP TABLE IF EXISTS `sao_hero_party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_hero_party` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `user_party_team_id` int(11) NOT NULL,
  `user_hero_log_id_1` int(11) NOT NULL,
  `user_hero_log_id_2` int(11) NOT NULL,
  `user_hero_log_id_3` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_hero_party_uk` (`user`,`user_party_team_id`),
  KEY `user_hero_log_id_1` (`user_hero_log_id_1`),
  KEY `user_hero_log_id_2` (`user_hero_log_id_2`),
  KEY `user_hero_log_id_3` (`user_hero_log_id_3`),
  CONSTRAINT `sao_hero_party_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_party_ibfk_2` FOREIGN KEY (`user_hero_log_id_1`) REFERENCES `sao_hero_log_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_party_ibfk_3` FOREIGN KEY (`user_hero_log_id_2`) REFERENCES `sao_hero_log_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_hero_party_ibfk_4` FOREIGN KEY (`user_hero_log_id_3`) REFERENCES `sao_hero_log_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_hero_party`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_hero_party` WRITE;
/*!40000 ALTER TABLE `sao_hero_party` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_hero_party` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_item_data`
--

DROP TABLE IF EXISTS `sao_item_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_item_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `get_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_item_data_uk` (`user`,`item_id`),
  CONSTRAINT `sao_item_data_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_item_data`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_item_data` WRITE;
/*!40000 ALTER TABLE `sao_item_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_item_data` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_play_sessions`
--

DROP TABLE IF EXISTS `sao_play_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_play_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `user_party_team_id` int(11) NOT NULL,
  `episode_id` int(11) NOT NULL,
  `play_mode` int(11) NOT NULL,
  `quest_drop_boost_apply_flag` int(11) NOT NULL,
  `play_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_play_sessions_uk` (`user`,`user_party_team_id`,`play_date`),
  CONSTRAINT `sao_play_sessions_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_play_sessions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_play_sessions` WRITE;
/*!40000 ALTER TABLE `sao_play_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_play_sessions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_player_beginner_mission`
--

DROP TABLE IF EXISTS `sao_player_beginner_mission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_player_beginner_mission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `beginner_mission_id` int(11) NOT NULL,
  `condition_id` int(11) NOT NULL,
  `is_seat` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_num` int(11) NOT NULL,
  `complete_flag` tinyint(1) NOT NULL DEFAULT 0,
  `complete_date` timestamp NULL DEFAULT NULL,
  `reward_received_flag` tinyint(1) NOT NULL DEFAULT 0,
  `reward_received_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_player_beginner_mission_uk` (`user`,`condition_id`),
  UNIQUE KEY `user` (`user`),
  CONSTRAINT `sao_player_beginner_mission_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_player_beginner_mission`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_player_beginner_mission` WRITE;
/*!40000 ALTER TABLE `sao_player_beginner_mission` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_player_beginner_mission` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_player_ex_bonus`
--

DROP TABLE IF EXISTS `sao_player_ex_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_player_ex_bonus` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `quest_scene_id` bigint(20) NOT NULL,
  `ex_bonus_table_id` bigint(20) NOT NULL,
  `quest_clear_flag` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_player_ex_bonus_uk` (`user`,`quest_scene_id`,`ex_bonus_table_id`),
  KEY `quest_scene_id` (`quest_scene_id`),
  KEY `ex_bonus_table_id` (`ex_bonus_table_id`),
  CONSTRAINT `sao_player_ex_bonus_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_player_ex_bonus_ibfk_2` FOREIGN KEY (`quest_scene_id`) REFERENCES `sao_static_quest` (`QuestSceneId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_player_ex_bonus_ibfk_3` FOREIGN KEY (`ex_bonus_table_id`) REFERENCES `sao_static_ex_bonus` (`ExBonusTableId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_player_ex_bonus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_player_ex_bonus` WRITE;
/*!40000 ALTER TABLE `sao_player_ex_bonus` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_player_ex_bonus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_player_hero_card`
--

DROP TABLE IF EXISTS `sao_player_hero_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_player_hero_card` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `user_hero_id` int(11) NOT NULL,
  `holographic_flag` tinyint(1) NOT NULL DEFAULT 0,
  `serial` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial` (`serial`),
  KEY `user` (`user`),
  KEY `user_hero_id` (`user_hero_id`),
  CONSTRAINT `sao_player_hero_card_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_player_hero_card_ibfk_2` FOREIGN KEY (`user_hero_id`) REFERENCES `sao_hero_log_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_player_hero_card`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_player_hero_card` WRITE;
/*!40000 ALTER TABLE `sao_player_hero_card` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_player_hero_card` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_player_quest`
--

DROP TABLE IF EXISTS `sao_player_quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_player_quest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `quest_type` int(11) NOT NULL DEFAULT 1,
  `quest_scene_id` bigint(20) NOT NULL,
  `quest_clear_flag` tinyint(1) NOT NULL,
  `clear_time` int(11) NOT NULL,
  `combo_num` int(11) NOT NULL,
  `total_damage` int(11) NOT NULL,
  `concurrent_destroying_num` int(11) NOT NULL,
  `play_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_player_quest_uk` (`user`,`quest_scene_id`),
  KEY `quest_scene_id` (`quest_scene_id`),
  CONSTRAINT `sao_player_quest_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_player_quest_ibfk_2` FOREIGN KEY (`quest_scene_id`) REFERENCES `sao_static_quest` (`QuestSceneId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_player_quest`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_player_quest` WRITE;
/*!40000 ALTER TABLE `sao_player_quest` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_player_quest` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_player_resource_card`
--

DROP TABLE IF EXISTS `sao_player_resource_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_player_resource_card` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `common_reward_type` int(11) NOT NULL,
  `common_reward_id` int(11) NOT NULL,
  `holographic_flag` tinyint(1) NOT NULL DEFAULT 0,
  `serial` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial` (`serial`),
  KEY `user` (`user`),
  CONSTRAINT `sao_player_resource_card_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_player_resource_card`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_player_resource_card` WRITE;
/*!40000 ALTER TABLE `sao_player_resource_card` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_player_resource_card` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_player_tutorial`
--

DROP TABLE IF EXISTS `sao_player_tutorial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_player_tutorial` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `tutorial_byte` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_player_tutorial_uk` (`user`,`tutorial_byte`),
  CONSTRAINT `sao_player_tutorial_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_player_tutorial`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_player_tutorial` WRITE;
/*!40000 ALTER TABLE `sao_player_tutorial` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_player_tutorial` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_profile`
--

DROP TABLE IF EXISTS `sao_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `user_type` int(11) DEFAULT 1,
  `nick_name` varchar(16) DEFAULT 'PLAYER',
  `rank_num` int(11) DEFAULT 1,
  `rank_exp` int(11) DEFAULT 0,
  `own_col` int(11) DEFAULT 0,
  `own_vp` int(11) DEFAULT 0,
  `own_yui_medal` int(11) DEFAULT 0,
  `setting_title_id` int(11) DEFAULT 20005,
  `my_shop` int(11) DEFAULT NULL,
  `fav_hero` int(11) DEFAULT NULL,
  `when_register` timestamp NULL DEFAULT current_timestamp(),
  `last_login_date` timestamp NULL DEFAULT NULL,
  `last_yui_medal_date` timestamp NULL DEFAULT NULL,
  `last_bonus_yui_medal_date` timestamp NULL DEFAULT NULL,
  `last_comeback_date` timestamp NULL DEFAULT NULL,
  `last_login_bonus_date` timestamp NULL DEFAULT NULL,
  `ad_confirm_date` timestamp NULL DEFAULT NULL,
  `login_ct` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user` (`user`),
  KEY `fav_hero` (`fav_hero`),
  CONSTRAINT `sao_profile_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_profile_ibfk_2` FOREIGN KEY (`fav_hero`) REFERENCES `sao_hero_log_data` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_profile`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_profile` WRITE;
/*!40000 ALTER TABLE `sao_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_profile` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_episode`
--

DROP TABLE IF EXISTS `sao_static_episode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_episode` (
  `EpisodeId` bigint(20) NOT NULL AUTO_INCREMENT,
  `EpisodeChapterId` int(11) NOT NULL,
  `ReleaseEpisodeId` int(11) NOT NULL,
  `Title` varchar(255) NOT NULL,
  `CommentSummary` varchar(255) NOT NULL,
  `ExBonusTableSubId` int(11) NOT NULL,
  `QuestSceneId` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`EpisodeId`),
  KEY `QuestSceneId` (`QuestSceneId`),
  CONSTRAINT `sao_static_episode_ibfk_1` FOREIGN KEY (`QuestSceneId`) REFERENCES `sao_static_quest` (`QuestSceneId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_episode`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_episode` WRITE;
/*!40000 ALTER TABLE `sao_static_episode` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_episode` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_equipment_list`
--

DROP TABLE IF EXISTS `sao_static_equipment_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_equipment_list` (
  `EquipmentId` bigint(20) NOT NULL AUTO_INCREMENT,
  `EquipmentType` int(11) NOT NULL,
  `WeaponTypeId` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Name_en` varchar(255) DEFAULT NULL,
  `Rarity` int(11) NOT NULL,
  `Power` int(11) NOT NULL,
  `StrengthIncrement` int(11) NOT NULL,
  `SkillCondition` int(11) NOT NULL,
  `Property1PropertyId` bigint(20) NOT NULL,
  `Property1Value1` int(11) NOT NULL,
  `Property1Value2` int(11) NOT NULL,
  `Property2PropertyId` bigint(20) NOT NULL,
  `Property2Value1` int(11) NOT NULL,
  `Property2Value2` int(11) NOT NULL,
  `Property3PropertyId` bigint(20) NOT NULL,
  `Property3Value1` int(11) NOT NULL,
  `Property3Value2` int(11) NOT NULL,
  `Property4PropertyId` bigint(20) NOT NULL,
  `Property4Value1` int(11) NOT NULL,
  `Property4Value2` int(11) NOT NULL,
  `SalePrice` int(11) NOT NULL,
  `CompositionExp` int(11) NOT NULL,
  `AwakeningExp` int(11) NOT NULL,
  `FlavorText` varchar(255) NOT NULL,
  `FlavorText_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`EquipmentId`),
  KEY `Property1PropertyId` (`Property1PropertyId`),
  KEY `Property2PropertyId` (`Property2PropertyId`),
  KEY `Property3PropertyId` (`Property3PropertyId`),
  KEY `Property4PropertyId` (`Property4PropertyId`),
  CONSTRAINT `sao_static_equipment_list_ibfk_1` FOREIGN KEY (`Property1PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_equipment_list_ibfk_2` FOREIGN KEY (`Property2PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_equipment_list_ibfk_3` FOREIGN KEY (`Property3PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_equipment_list_ibfk_4` FOREIGN KEY (`Property4PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_equipment_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_equipment_list` WRITE;
/*!40000 ALTER TABLE `sao_static_equipment_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_equipment_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_ex_bonus`
--

DROP TABLE IF EXISTS `sao_static_ex_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_ex_bonus` (
  `ExBonusTableId` bigint(20) NOT NULL AUTO_INCREMENT,
  `ExBonusTableSubId` int(11) NOT NULL,
  `ExBonusConditionId` int(11) NOT NULL,
  `ConditionValue1` int(11) NOT NULL,
  `ConditionValue2` int(11) NOT NULL,
  `CommonRewardType` int(11) NOT NULL,
  `CommonRewardId` int(11) NOT NULL,
  `CommonRewardNum` int(11) NOT NULL,
  `Strength` int(11) NOT NULL,
  `Property1PropertyId` bigint(20) NOT NULL,
  `Property1Value1` int(11) NOT NULL,
  `Property1Value2` int(11) NOT NULL,
  `Property2PropertyId` bigint(20) NOT NULL,
  `Property2Value1` int(11) NOT NULL,
  `Property2Value2` int(11) NOT NULL,
  `Property3PropertyId` bigint(20) NOT NULL,
  `Property3Value1` int(11) NOT NULL,
  `Property3Value2` int(11) NOT NULL,
  `Property4PropertyId` bigint(20) NOT NULL,
  `Property4Value1` int(11) NOT NULL,
  `Property4Value2` int(11) NOT NULL,
  PRIMARY KEY (`ExBonusTableId`),
  KEY `Property1PropertyId` (`Property1PropertyId`),
  KEY `Property2PropertyId` (`Property2PropertyId`),
  KEY `Property3PropertyId` (`Property3PropertyId`),
  KEY `Property4PropertyId` (`Property4PropertyId`),
  CONSTRAINT `sao_static_ex_bonus_ibfk_1` FOREIGN KEY (`Property1PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_ex_bonus_ibfk_2` FOREIGN KEY (`Property2PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_ex_bonus_ibfk_3` FOREIGN KEY (`Property3PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_ex_bonus_ibfk_4` FOREIGN KEY (`Property4PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_ex_bonus`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_ex_bonus` WRITE;
/*!40000 ALTER TABLE `sao_static_ex_bonus` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_ex_bonus` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_ex_tower`
--

DROP TABLE IF EXISTS `sao_static_ex_tower`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_ex_tower` (
  `ExTowerQuestId` bigint(20) NOT NULL AUTO_INCREMENT,
  `ExTowerId` int(11) NOT NULL,
  `ReleaseExTowerQuestId` int(11) NOT NULL,
  `Title` varchar(255) NOT NULL,
  `Title_en` varchar(255) DEFAULT NULL,
  `ExBonusTableSubId` int(11) NOT NULL,
  `QuestSceneId` bigint(20) NOT NULL,
  PRIMARY KEY (`ExTowerQuestId`),
  KEY `QuestSceneId` (`QuestSceneId`),
  CONSTRAINT `sao_static_ex_tower_ibfk_1` FOREIGN KEY (`QuestSceneId`) REFERENCES `sao_static_quest` (`QuestSceneId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_ex_tower`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_ex_tower` WRITE;
/*!40000 ALTER TABLE `sao_static_ex_tower` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_ex_tower` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_hero_list`
--

DROP TABLE IF EXISTS `sao_static_hero_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_hero_list` (
  `HeroLogId` bigint(20) NOT NULL AUTO_INCREMENT,
  `CharaId` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Nickname` varchar(255) NOT NULL,
  `Name_en` varchar(255) DEFAULT NULL,
  `Nickname_en` varchar(255) DEFAULT NULL,
  `Rarity` int(11) NOT NULL,
  `WeaponTypeId` int(11) NOT NULL,
  `HeroLogRoleId` int(11) NOT NULL,
  `CostumeTypeId` int(11) NOT NULL,
  `UnitId` int(11) NOT NULL,
  `DefaultEquipmentId1` bigint(20) DEFAULT NULL,
  `DefaultEquipmentId2` bigint(20) DEFAULT NULL,
  `SkillTableSubId` int(11) NOT NULL,
  `HpMin` int(11) NOT NULL,
  `HpMax` int(11) NOT NULL,
  `StrMin` int(11) NOT NULL,
  `StrMax` int(11) NOT NULL,
  `VitMin` int(11) NOT NULL,
  `VitMax` int(11) NOT NULL,
  `IntMin` int(11) NOT NULL,
  `IntMax` int(11) NOT NULL,
  `Property1PropertyId` bigint(20) NOT NULL,
  `Property1Value1` int(11) NOT NULL,
  `Property1Value2` int(11) NOT NULL,
  `Property2PropertyId` bigint(20) NOT NULL,
  `Property2Value1` int(11) NOT NULL,
  `Property2Value2` int(11) NOT NULL,
  `Property3PropertyId` bigint(20) NOT NULL,
  `Property3Value1` int(11) NOT NULL,
  `Property3Value2` int(11) NOT NULL,
  `Property4PropertyId` bigint(20) NOT NULL,
  `Property4Value1` int(11) NOT NULL,
  `Property4Value2` int(11) NOT NULL,
  `FlavorText` varchar(255) NOT NULL,
  `FlavorText_en` varchar(255) DEFAULT NULL,
  `SalePrice` int(11) NOT NULL,
  `CompositionExp` int(11) NOT NULL,
  `AwakeningExp` int(11) NOT NULL,
  `Slot4UnlockLevel` int(11) NOT NULL,
  `Slot5UnlockLevel` int(11) NOT NULL,
  `CollectionEmptyFrameDisplayFlag` tinyint(1) NOT NULL,
  PRIMARY KEY (`HeroLogId`),
  KEY `DefaultEquipmentId1` (`DefaultEquipmentId1`),
  KEY `DefaultEquipmentId2` (`DefaultEquipmentId2`),
  KEY `Property1PropertyId` (`Property1PropertyId`),
  KEY `Property2PropertyId` (`Property2PropertyId`),
  KEY `Property3PropertyId` (`Property3PropertyId`),
  KEY `Property4PropertyId` (`Property4PropertyId`),
  CONSTRAINT `sao_static_hero_list_ibfk_1` FOREIGN KEY (`DefaultEquipmentId1`) REFERENCES `sao_static_equipment_list` (`EquipmentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_hero_list_ibfk_2` FOREIGN KEY (`DefaultEquipmentId2`) REFERENCES `sao_static_equipment_list` (`EquipmentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_hero_list_ibfk_3` FOREIGN KEY (`Property1PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_hero_list_ibfk_4` FOREIGN KEY (`Property2PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_hero_list_ibfk_5` FOREIGN KEY (`Property3PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sao_static_hero_list_ibfk_6` FOREIGN KEY (`Property4PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_hero_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_hero_list` WRITE;
/*!40000 ALTER TABLE `sao_static_hero_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_hero_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_item_list`
--

DROP TABLE IF EXISTS `sao_static_item_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_item_list` (
  `ItemId` int(11) NOT NULL AUTO_INCREMENT,
  `ItemTypeId` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Name_en` varchar(255) DEFAULT NULL,
  `Rarity` int(11) NOT NULL,
  `Value` int(11) NOT NULL,
  `PropertyId` bigint(20) NOT NULL,
  `PropertyValue1Min` int(11) NOT NULL,
  `PropertyValue1Max` int(11) NOT NULL,
  `PropertyValue2Min` int(11) NOT NULL,
  `PropertyValue2Max` int(11) NOT NULL,
  `FlavorText` varchar(255) NOT NULL,
  `FlavorText_en` varchar(255) DEFAULT NULL,
  `SalePrice` int(11) NOT NULL,
  `ItemIcon` varchar(255) NOT NULL,
  PRIMARY KEY (`ItemId`),
  KEY `PropertyId` (`PropertyId`),
  CONSTRAINT `sao_static_item_list_ibfk_1` FOREIGN KEY (`PropertyId`) REFERENCES `sao_static_property` (`PropertyId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_item_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_item_list` WRITE;
/*!40000 ALTER TABLE `sao_static_item_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_item_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_property`
--

DROP TABLE IF EXISTS `sao_static_property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_property` (
  `PropertyId` bigint(20) NOT NULL AUTO_INCREMENT,
  `PropertyTargetType` int(11) NOT NULL,
  `PropertyName` varchar(255) NOT NULL,
  `PropertyName_en` varchar(255) DEFAULT NULL,
  `PropertyNameFormat` varchar(255) NOT NULL,
  `PropertyNameFormat_en` varchar(255) DEFAULT NULL,
  `PropertyTypeId` int(11) NOT NULL,
  `Value1Min` int(11) NOT NULL,
  `Value1Max` int(11) NOT NULL,
  `Value2Min` int(11) NOT NULL,
  `Value2Max` int(11) NOT NULL,
  PRIMARY KEY (`PropertyId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_property`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_property` WRITE;
/*!40000 ALTER TABLE `sao_static_property` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_property` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_quest`
--

DROP TABLE IF EXISTS `sao_static_quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_quest` (
  `QuestSceneId` bigint(20) NOT NULL AUTO_INCREMENT,
  `SortNo` int(11) NOT NULL,
  `Tutorial` tinyint(1) NOT NULL,
  `ColRate` decimal(10,0) NOT NULL,
  `LimitDefault` int(11) NOT NULL,
  `LimitResurrection` int(11) NOT NULL,
  `RewardTableSubId` int(11) NOT NULL,
  `PlayerTraceTableSubId` int(11) NOT NULL,
  `SuccessPlayerExp` int(11) NOT NULL,
  `FailedPlayerExp` int(11) NOT NULL,
  `PairExpRate` int(11) NOT NULL,
  `TrioExpRate` int(11) NOT NULL,
  `SingleRewardVp` int(11) NOT NULL,
  `PairRewardVp` int(11) NOT NULL,
  `TrioRewardVp` int(11) NOT NULL,
  PRIMARY KEY (`QuestSceneId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_quest`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_quest` WRITE;
/*!40000 ALTER TABLE `sao_static_quest` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_quest` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_rare_drop_list`
--

DROP TABLE IF EXISTS `sao_static_rare_drop_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_rare_drop_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) DEFAULT NULL,
  `questRareDropId` int(11) DEFAULT NULL,
  `commonRewardId` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_static_rare_drop_list_uk` (`version`,`questRareDropId`,`commonRewardId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_rare_drop_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_rare_drop_list` WRITE;
/*!40000 ALTER TABLE `sao_static_rare_drop_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_rare_drop_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_reward`
--

DROP TABLE IF EXISTS `sao_static_reward`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_reward` (
  `RewardTableId` bigint(20) NOT NULL AUTO_INCREMENT,
  `RewardTableSubId` int(11) NOT NULL,
  `UnanalyzedLogGradeId` int(11) NOT NULL,
  `CommonRewardType` int(11) NOT NULL,
  `CommonRewardId` int(11) NOT NULL,
  `CommonRewardNum` int(11) NOT NULL,
  `StrengthMin` int(11) NOT NULL,
  `StrengthMax` int(11) NOT NULL,
  `PropertyTableSubId` int(11) NOT NULL,
  `QuestInfoDisplayFlag` tinyint(1) NOT NULL,
  `Rate` int(11) NOT NULL,
  PRIMARY KEY (`RewardTableId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_reward`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_reward` WRITE;
/*!40000 ALTER TABLE `sao_static_reward` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_reward` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_side_quest`
--

DROP TABLE IF EXISTS `sao_static_side_quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_side_quest` (
  `SideQuestId` bigint(20) NOT NULL AUTO_INCREMENT,
  `DisplayName` varchar(255) NOT NULL,
  `DisplayName_en` varchar(255) DEFAULT NULL,
  `EpisodeNum` int(11) NOT NULL,
  `ExBonusTableSubId` int(11) NOT NULL,
  `QuestSceneId` bigint(20) NOT NULL,
  PRIMARY KEY (`SideQuestId`),
  UNIQUE KEY `SideQuestId` (`SideQuestId`),
  KEY `QuestSceneId` (`QuestSceneId`),
  CONSTRAINT `sao_static_side_quest_ibfk_1` FOREIGN KEY (`QuestSceneId`) REFERENCES `sao_static_quest` (`QuestSceneId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_side_quest`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_side_quest` WRITE;
/*!40000 ALTER TABLE `sao_static_side_quest` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_side_quest` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_skill`
--

DROP TABLE IF EXISTS `sao_static_skill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_skill` (
  `SkillId` bigint(20) NOT NULL AUTO_INCREMENT,
  `WeaponTypeId` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Name_en` varchar(255) DEFAULT NULL,
  `Attack` tinyint(1) NOT NULL,
  `Passive` tinyint(1) NOT NULL,
  `Pet` tinyint(1) NOT NULL,
  `Level` int(11) NOT NULL,
  `SkillCondition` int(11) NOT NULL,
  `CoolTime` int(11) NOT NULL,
  `SkillIcon` varchar(255) NOT NULL,
  `FriendSkillIcon` varchar(255) NOT NULL,
  `InfoText` varchar(255) NOT NULL,
  `InfoText_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`SkillId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_skill`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_skill` WRITE;
/*!40000 ALTER TABLE `sao_static_skill` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_skill` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_skill_table`
--

DROP TABLE IF EXISTS `sao_static_skill_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_skill_table` (
  `SkillTableId` bigint(20) NOT NULL AUTO_INCREMENT,
  `SkillId` bigint(20) NOT NULL,
  `SkillTableSubId` int(11) NOT NULL,
  `LevelObtained` int(11) NOT NULL,
  `AwakeningId` int(11) NOT NULL,
  PRIMARY KEY (`SkillTableId`),
  KEY `SkillId` (`SkillId`),
  CONSTRAINT `sao_static_skill_table_ibfk_1` FOREIGN KEY (`SkillId`) REFERENCES `sao_static_skill` (`SkillId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_skill_table`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_skill_table` WRITE;
/*!40000 ALTER TABLE `sao_static_skill_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_skill_table` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_support_log_list`
--

DROP TABLE IF EXISTS `sao_static_support_log_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_support_log_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) DEFAULT NULL,
  `supportLogId` int(11) DEFAULT NULL,
  `charaId` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `rarity` int(11) DEFAULT NULL,
  `salePrice` int(11) DEFAULT NULL,
  `skillName` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_static_support_log_list_uk` (`version`,`supportLogId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_support_log_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_support_log_list` WRITE;
/*!40000 ALTER TABLE `sao_static_support_log_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_support_log_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_title_list`
--

DROP TABLE IF EXISTS `sao_static_title_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_title_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) DEFAULT NULL,
  `titleId` int(11) DEFAULT NULL,
  `displayName` varchar(255) DEFAULT NULL,
  `requirement` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `imageFilePath` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sao_static_title_list_uk` (`version`,`titleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_title_list`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_title_list` WRITE;
/*!40000 ALTER TABLE `sao_static_title_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_title_list` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_tower`
--

DROP TABLE IF EXISTS `sao_static_tower`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_tower` (
  `TowerId` bigint(20) NOT NULL AUTO_INCREMENT,
  `ReleaseTowerId` int(11) NOT NULL,
  `ExBonusTableSubId` int(11) NOT NULL,
  `QuestSceneId` bigint(20) NOT NULL,
  PRIMARY KEY (`TowerId`),
  KEY `QuestSceneId` (`QuestSceneId`),
  CONSTRAINT `sao_static_tower_ibfk_1` FOREIGN KEY (`QuestSceneId`) REFERENCES `sao_static_quest` (`QuestSceneId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_tower`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_tower` WRITE;
/*!40000 ALTER TABLE `sao_static_tower` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_tower` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sao_static_trace_table`
--

DROP TABLE IF EXISTS `sao_static_trace_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sao_static_trace_table` (
  `PlayerTraceTableId` bigint(20) NOT NULL AUTO_INCREMENT,
  `PlayerTraceTableSubId` int(11) NOT NULL,
  `CommonRewardType` int(11) NOT NULL,
  `CommonRewardId` int(11) NOT NULL,
  `CommonRewardNum` int(11) NOT NULL,
  `Rate` int(11) NOT NULL,
  PRIMARY KEY (`PlayerTraceTableId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sao_static_trace_table`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sao_static_trace_table` WRITE;
/*!40000 ALTER TABLE `sao_static_trace_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `sao_static_trace_table` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_bingo`
--

DROP TABLE IF EXISTS `wacca_bingo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_bingo` (
  `user` int(11) NOT NULL,
  `page_number` int(11) NOT NULL,
  `page_progress` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`page_progress`)),
  PRIMARY KEY (`user`),
  UNIQUE KEY `wacca_bingo_uk` (`user`,`page_number`),
  CONSTRAINT `wacca_bingo_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_bingo`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_bingo` WRITE;
/*!40000 ALTER TABLE `wacca_bingo` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_bingo` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_favorite_song`
--

DROP TABLE IF EXISTS `wacca_favorite_song`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_favorite_song` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `song_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_favorite_song_uk` (`user`,`song_id`),
  CONSTRAINT `wacca_favorite_song_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_favorite_song`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_favorite_song` WRITE;
/*!40000 ALTER TABLE `wacca_favorite_song` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_favorite_song` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_friend`
--

DROP TABLE IF EXISTS `wacca_friend`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_friend` (
  `profile_sender` int(11) NOT NULL,
  `profile_reciever` int(11) NOT NULL,
  `is_accepted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`profile_sender`,`profile_reciever`),
  KEY `profile_reciever` (`profile_reciever`),
  CONSTRAINT `wacca_friend_ibfk_1` FOREIGN KEY (`profile_sender`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `wacca_friend_ibfk_2` FOREIGN KEY (`profile_reciever`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_friend`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_friend` WRITE;
/*!40000 ALTER TABLE `wacca_friend` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_friend` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_gate`
--

DROP TABLE IF EXISTS `wacca_gate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_gate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `gate_id` int(11) NOT NULL,
  `page` int(11) NOT NULL DEFAULT 0,
  `progress` int(11) NOT NULL DEFAULT 0,
  `loops` int(11) NOT NULL DEFAULT 0,
  `last_used` timestamp NOT NULL DEFAULT current_timestamp(),
  `mission_flag` int(11) NOT NULL DEFAULT 0,
  `total_points` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_gate_uk` (`user`,`gate_id`),
  CONSTRAINT `wacca_gate_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_gate`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_gate` WRITE;
/*!40000 ALTER TABLE `wacca_gate` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_gate` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_item`
--

DROP TABLE IF EXISTS `wacca_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `acquire_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `use_count` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_item_uk` (`user`,`item_id`,`type`),
  CONSTRAINT `wacca_item_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_item`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_item` WRITE;
/*!40000 ALTER TABLE `wacca_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_item` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_option`
--

DROP TABLE IF EXISTS `wacca_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `opt_id` int(11) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_option_uk` (`user`,`opt_id`),
  CONSTRAINT `wacca_option_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_option`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_option` WRITE;
/*!40000 ALTER TABLE `wacca_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_option` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_profile`
--

DROP TABLE IF EXISTS `wacca_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `username` varchar(8) NOT NULL,
  `xp` int(11) DEFAULT 0,
  `wp` int(11) DEFAULT 0,
  `wp_total` int(11) DEFAULT 0,
  `wp_spent` int(11) DEFAULT 0,
  `dan_type` int(11) DEFAULT 0,
  `dan_level` int(11) DEFAULT 0,
  `title_0` int(11) DEFAULT 0,
  `title_1` int(11) DEFAULT 0,
  `title_2` int(11) DEFAULT 0,
  `rating` int(11) DEFAULT 0,
  `vip_expire_time` timestamp NULL DEFAULT NULL,
  `always_vip` tinyint(1) DEFAULT 0,
  `login_count` int(11) DEFAULT 0,
  `login_count_consec` int(11) DEFAULT 0,
  `login_count_days` int(11) DEFAULT 0,
  `login_count_days_consec` int(11) DEFAULT 0,
  `login_count_today` int(11) DEFAULT 0,
  `playcount_single` int(11) DEFAULT 0,
  `playcount_multi_vs` int(11) DEFAULT 0,
  `playcount_multi_coop` int(11) DEFAULT 0,
  `playcount_stageup` int(11) DEFAULT 0,
  `playcount_time_free` int(11) DEFAULT 0,
  `friend_view_1` int(11) DEFAULT NULL,
  `friend_view_2` int(11) DEFAULT NULL,
  `friend_view_3` int(11) DEFAULT NULL,
  `last_game_ver` varchar(50) DEFAULT NULL,
  `last_song_id` int(11) DEFAULT 0,
  `last_song_difficulty` int(11) DEFAULT 0,
  `last_folder_order` int(11) DEFAULT 0,
  `last_folder_id` int(11) DEFAULT 0,
  `last_song_order` int(11) DEFAULT 0,
  `last_login_date` timestamp NULL DEFAULT current_timestamp(),
  `gate_tutorial_flags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gate_tutorial_flags`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_profile_uk` (`user`,`version`),
  CONSTRAINT `wacca_profile_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_profile`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_profile` WRITE;
/*!40000 ALTER TABLE `wacca_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_profile` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_score_best`
--

DROP TABLE IF EXISTS `wacca_score_best`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_score_best` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `song_id` int(11) DEFAULT NULL,
  `chart_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `play_ct` int(11) DEFAULT NULL,
  `clear_ct` int(11) DEFAULT NULL,
  `missless_ct` int(11) DEFAULT NULL,
  `fullcombo_ct` int(11) DEFAULT NULL,
  `allmarv_ct` int(11) DEFAULT NULL,
  `grade_d_ct` int(11) DEFAULT NULL,
  `grade_c_ct` int(11) DEFAULT NULL,
  `grade_b_ct` int(11) DEFAULT NULL,
  `grade_a_ct` int(11) DEFAULT NULL,
  `grade_aa_ct` int(11) DEFAULT NULL,
  `grade_aaa_ct` int(11) DEFAULT NULL,
  `grade_s_ct` int(11) DEFAULT NULL,
  `grade_ss_ct` int(11) DEFAULT NULL,
  `grade_sss_ct` int(11) DEFAULT NULL,
  `grade_master_ct` int(11) DEFAULT NULL,
  `grade_sp_ct` int(11) DEFAULT NULL,
  `grade_ssp_ct` int(11) DEFAULT NULL,
  `grade_sssp_ct` int(11) DEFAULT NULL,
  `best_combo` int(11) DEFAULT NULL,
  `lowest_miss_ct` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_score_uk` (`user`,`song_id`,`chart_id`),
  CONSTRAINT `wacca_score_best_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_score_best`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_score_best` WRITE;
/*!40000 ALTER TABLE `wacca_score_best` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_score_best` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_score_playlog`
--

DROP TABLE IF EXISTS `wacca_score_playlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_score_playlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `song_id` int(11) DEFAULT NULL,
  `chart_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `clear` int(11) DEFAULT NULL,
  `grade` int(11) DEFAULT NULL,
  `max_combo` int(11) DEFAULT NULL,
  `marv_ct` int(11) DEFAULT NULL,
  `great_ct` int(11) DEFAULT NULL,
  `good_ct` int(11) DEFAULT NULL,
  `miss_ct` int(11) DEFAULT NULL,
  `fast_ct` int(11) DEFAULT NULL,
  `late_ct` int(11) DEFAULT NULL,
  `season` int(11) DEFAULT NULL,
  `date_scored` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `wacca_score_playlog_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_score_playlog`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_score_playlog` WRITE;
/*!40000 ALTER TABLE `wacca_score_playlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_score_playlog` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_score_stageup`
--

DROP TABLE IF EXISTS `wacca_score_stageup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_score_stageup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `stage_id` int(11) DEFAULT NULL,
  `clear_status` int(11) DEFAULT NULL,
  `clear_song_ct` int(11) DEFAULT NULL,
  `song1_score` int(11) DEFAULT NULL,
  `song2_score` int(11) DEFAULT NULL,
  `song3_score` int(11) DEFAULT NULL,
  `play_ct` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_score_stageup_uk` (`user`,`stage_id`),
  CONSTRAINT `wacca_score_stageup_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_score_stageup`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_score_stageup` WRITE;
/*!40000 ALTER TABLE `wacca_score_stageup` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_score_stageup` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_song_unlock`
--

DROP TABLE IF EXISTS `wacca_song_unlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_song_unlock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `song_id` int(11) NOT NULL,
  `highest_difficulty` int(11) NOT NULL,
  `acquire_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_song_unlock_uk` (`user`,`song_id`),
  CONSTRAINT `wacca_song_unlock_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_song_unlock`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_song_unlock` WRITE;
/*!40000 ALTER TABLE `wacca_song_unlock` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_song_unlock` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_static_music`
--

DROP TABLE IF EXISTS `wacca_static_music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_static_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `songId` int(11) DEFAULT NULL,
  `chartId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `artist` varchar(255) DEFAULT NULL,
  `bpm` varchar(255) DEFAULT NULL,
  `difficulty` float DEFAULT NULL,
  `chartDesigner` varchar(255) DEFAULT NULL,
  `jacketFile` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_static_music_uk` (`version`,`songId`,`chartId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_static_music`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_static_music` WRITE;
/*!40000 ALTER TABLE `wacca_static_music` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_static_music` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_ticket`
--

DROP TABLE IF EXISTS `wacca_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_ticket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `acquire_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `expire_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `wacca_ticket_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_ticket`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_ticket` WRITE;
/*!40000 ALTER TABLE `wacca_ticket` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_ticket` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wacca_trophy`
--

DROP TABLE IF EXISTS `wacca_trophy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wacca_trophy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `trophy_id` int(11) NOT NULL,
  `season` int(11) NOT NULL,
  `progress` int(11) NOT NULL DEFAULT 0,
  `badge_type` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wacca_trophy_uk` (`user`,`trophy_id`,`season`),
  CONSTRAINT `wacca_trophy_ibfk_1` FOREIGN KEY (`user`) REFERENCES `aime_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wacca_trophy`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wacca_trophy` WRITE;
/*!40000 ALTER TABLE `wacca_trophy` DISABLE KEYS */;
/*!40000 ALTER TABLE `wacca_trophy` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Dumping events for database 'aime'
--

--
-- Dumping routines for database 'aime'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-09-17 18:25:24
