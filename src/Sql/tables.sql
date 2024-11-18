BEGIN TRANSACTION;
CREATE TEMPORARY TABLE users_backup(
	username TEXT PRIMARY KEY,
	emailaddress TEXT,
	age INTEGER,
	contact_user INTEGER,
	dominate_hand INTEGER,
	submit_highscores INTEGER
);
							   
INSERT INTO users_backup
SELECT
	username,
	emailaddress,
	age,
	contact_user,
	dominate_hand,
	submit_highscores
FROM users;
							   
DROP TABLE users;
							   
CREATE TABLE users (
	username TEXT PRIMARY KEY,
	emailaddress TEXT,
	age INTEGER,
	contact_user INTEGER,
	dominate_hand INTEGER,
	submit_highscores INTEGER
);
							   
INSERT INTO users
SELECT
	username,
	emailaddress,
	age,
	contact_user,
	dominate_hand,
	submit_highscores
	FROM users_backup;

DROP TABLE users_backup;

CREATE TABLE words (
	username TEXT,
	word TEXT,
	usedctr INTEGER,
	PRIMARY KEY(username,word)
);

COMMIT;	