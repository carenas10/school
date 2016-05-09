# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: mysql1.cs.clemson.edu (MySQL 5.5.40-0ubuntu0.12.04.1)
# Database: vtk_db_zrrm
# Generation Time: 2014-10-21 00:31:13 +0000
# ************************************************************

# Dump of table audioCodecs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `audioCodecs`;

CREATE TABLE `audioCodecs` (
  `audioCodec_ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `audioCodecName` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`audioCodec_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

LOCK TABLES `audioCodecs` WRITE;

INSERT INTO `audioCodecs` (`audioCodec_ID`, `audioCodecName`)
VALUES
	(1,'AAC'),
	(2,'mp3'),
	(3,'LPCM'),
	(4,'FLAC'),
	(5,'Apple Lossless');

UNLOCK TABLES;

# Dump of table settingsTable
# ------------------------------------------------------------

DROP TABLE IF EXISTS `settingsTable`;

CREATE TABLE `settingsTable` (
  `setting_ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `resolution` varchar(15) DEFAULT NULL,
  `bitrate` int(11) DEFAULT NULL,
  `framerate` int(11) DEFAULT NULL,
  `vidCodec` int(11) unsigned DEFAULT NULL,
  `audioCodec` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`setting_ID`),
  KEY `vidCodecRelation` (`vidCodec`),
  KEY `audioCodecRelation` (`audioCodec`),
  CONSTRAINT `audioCodecRelation` FOREIGN KEY (`audioCodec`) REFERENCES `audioCodecs` (`audioCodec_ID`),
  CONSTRAINT `vidCodecRelation` FOREIGN KEY (`vidCodec`) REFERENCES `videoCodecs` (`vidCodec_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

LOCK TABLES `settingsTable` WRITE;

INSERT INTO `settingsTable` (`setting_ID`, `name`, `resolution`, `bitrate`, `framerate`, `vidCodec`, `audioCodec`)
VALUES
	(1,'Sample H.264','1920x1080',8000,30,1,1);

UNLOCK TABLES;


# Dump of table videoCodecs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `videoCodecs`;

CREATE TABLE `videoCodecs` (
  `vidCodec_ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `vidCodecName` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`vidCodec_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

LOCK TABLES `videoCodecs` WRITE;

INSERT INTO `videoCodecs` (`vidCodec_ID`, `vidCodecName`)
VALUES
	(1,'H.264'),
	(2,'ProRes 422'),
	(3,'MPEG2'),
	(4,'MPEG4'),
	(5,'Quicktime'),
	(6,'FFmpeg');

UNLOCK TABLES;
