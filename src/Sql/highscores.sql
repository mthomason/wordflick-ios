BEGIN TRANSACTION;

CREATE TABLE statistics (
	game INTEGER,
	username TEXT,
	topword TEXT,
	topwordpoints INTEGER,
	totalpoints INTEGER,
	totalpointsfrombonustiles INTEGER,
	totaltime INTEGER,
	totaltimeextra INTEGER,
	countbonustileseenshuffle INTEGER,
	countbonustileseenpoints INTEGER,
	countbonustileseentimer INTEGER,
	countbonustileseenspecial INTEGER,
	countbonustileseenspecialshuffle INTEGER,
	countbonustileusedshuffle INTEGER,
	countbonustileusedpoints INTEGER,
	countbonustileusedspecial INTEGER,
	countbonustileusedspecialshuffle INTEGER,
	countbonustileusedtimer INTEGER,
	countfreeshakesused INTEGER,
	countclearedboard INTEGER,
	toplevelattained INTEGER,
	gamesplayed INTEGER,
	levelsplayed INTEGER,
	PRIMARY KEY (game, username)
);

CREATE TABLE words (
	username TEXT,
	word TEXT,
	usedctr INTEGER,
	PRIMARY KEY (username, word)
);

CREATE TABLE game (
	game INTEGER,
	level INTEGER,
	stage INTEGER,
	intensity INTEGER,
	game_name TEXT,
	level_name TEXT,
	stage_name TEXT,
	intensity_name TEXT,
	PRIMARY KEY (game, level, stage, intensity)
);

INSERT INTO game (game, level, stage, intensity, game_name) VALUES (1, 1, 1, 1, "Word Nerd");

CREATE TABLE scores (
	game INTEGER,
	level INTEGER,
	stage INTEGER,
	intensity INTEGER,
	score INTEGER,
	username TEXT
);

INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 10000, "Godric");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 9000, "Blade");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 8000, "Lilith");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 7000, "Nosferatu");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 6000, "Lothos");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 5000, "Jessica");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 4000, "Selene");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 3000, "Spike");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 2000, "Lestat");
INSERT INTO scores (game, level, stage, intensity, score, username) VALUES (1, 1, 1, 1, 1000, "Akasha");

CREATE TABLE settings (
	game INTEGER PRIMARY KEY,
	current_user TEXT,
	sound_on INTEGER,
	vibrate_on INTEGER
);

INSERT INTO settings (game, sound_on, vibrate_on) VALUES (1, 0, 0);

CREATE TABLE users (
	username TEXT PRIMARY KEY,
	emailaddress TEXT,
	age INTEGER,
	contact_user INTEGER,
	dominate_hand INTEGER,
	submit_highscores INTEGER
);

CREATE INDEX high_scores ON scores (
	score DESC,
	game ASC
);

COMMIT;
