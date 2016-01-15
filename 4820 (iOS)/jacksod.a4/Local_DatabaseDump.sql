CREATE TABLE videoCodecs (
	vidCodec_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	vidCodecName VARCHAR(15) NOT NULL
);
INSERT INTO videoCodecs VALUES(1,'H.264');
INSERT INTO videoCodecs VALUES(2,'ProRes 422');
INSERT INTO videoCodecs VALUES(3,'MPEG2');
INSERT INTO videoCodecs VALUES(4,'MPEG4');
INSERT INTO videoCodecs VALUES(5,'Quicktime');
INSERT INTO videoCodecs VALUES(6,'FFmpeg');

CREATE TABLE settingsTable (
	setting_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	name VARCHAR(20) NOT NULL,
	resolution VARCHAR(15),
	bitrate INTEGER,
	framerate INTEGER,
	vidCodec INTEGER,
	audioCodec INTEGER,
	GID INTEGER,
	is_deleted BOOLEAN,
	FOREIGN KEY(vidCodec) REFERENCES videoCodecs(vidCodec_ID),
	FOREIGN KEY(audioCodec) REFERENCES audioCodecs(audioCodec_ID)
);
INSERT INTO `settingsTable` VALUES(1,'Sample H.264','1920x1080',8000,30,1,1,'-1',0);

CREATE TABLE audioCodecs (
	audioCodec_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	audioCodecName VARCHAR(15) NOT NULL
);

INSERT INTO audioCodecs VALUES(1,'AAC');
INSERT INTO audioCodecs VALUES(2,'mp3');
INSERT INTO audioCodecs VALUES(3,'LPCM');
INSERT INTO audioCodecs VALUES(4,'FLAC');
INSERT INTO audioCodecs VALUES(5,'Apple Lossless');
