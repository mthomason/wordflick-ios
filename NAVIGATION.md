# Project Navigation

_Here's some details to help you out._

* The file `index.dat` contains the word database
	* It's a sqlite3 database
	* The words must be ordered, as it's searched using a binary lookup
	* The file `dat.plist` contains information about the sqlite3 database
		* It contains the number of words in the dictionary
			* English has about 9k words
			* Spanish has about 64k words
		* It contains the number of characters in the language (the app is localized)
* The file `points.plist` contains the scrabble values for each character in the language
	* Note some languages have more characters than others
	* The languages that have more characters than English have those character values represented as numbers.
* The file `letters.plist` should be considered a fresh bag of tiles for the game.  Each language has a different starting set of game pieces.
* The game should allow you to resume when the user quits early.  This feature didn't survive the last major refactoring, and needs to be reimplemented.  It should be fairly easy to do.  You need to save the game state: what tiles are on the board, what tiles are on the bottom of the board, time remaining, points, level number, and shuffles remaining should be enough.
* The file `users.db` is to track multiple users on iOS.  It should be reevaluated.
* This project was origionally created in 2008 or 2009.  Lots of features were removed when I started updating it, and that may've caused some regressions.
