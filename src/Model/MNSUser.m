//
//  MNSUser.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/23/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "MNSUser.h"
#import <GameKit/GameKit.h>
#import "sqlite3.h"
#import "Constants.h"
#import "wordPuzzleAppDelegate.h"
#import "MTWordValue.h"
#import "MTSqliteWrapper.h"
//#import "MTSqliteBoolean.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "DatabaseUsers.h"
#import "MNSAudio.h"
#import "WFUserStatistics.h"
#import "MNSMessage.h"
#import "MTFileController.h"


@interface MNSUser () {
	NSLock *_writeLock;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSURL *storedAchievementUrl;
@property (nonatomic, retain) NSMutableDictionary <NSString *, GKAchievement *> *earnedAchievementCache;
@property (nonatomic, retain) NSMutableDictionary <NSString *, GKAchievement *> *storedAchievements;
@property (nonatomic, retain, readwrite) NSMutableDictionary *restartData;

// resubmit any local instances of GKAchievement that was stored on a failed submission.
- (void)resubmitStoredAchievements;

// write all stored achievements for future resubmission
- (void)writeStoredAchievements;

// store an achievement for future resubmit
- (void)storeAchievement:(GKAchievement *)achievement;

@end


@implementation MNSUser

static MNSUser *_sharedInstanceUser = nil;
static NSString *_currentLocale = nil;

NSString * const kUsers =  @"users";

#pragma mark -
#pragma mark Static Functions

static GKAchievementDescription *achievementForIdentifier(NSArray<GKAchievementDescription *> **descriptions, NSString *identifier) {
	for (GKAchievementDescription *description in *descriptions) {
		if ([identifier hasSuffix: description.identifier] || [identifier isEqualToString: description.identifier]) {
			return description;
		}
	}
	return nil;
}

static void submitAchievementWithIdentifier(MNSUser *object, NSString *identifier) {
	GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
	achievement.percentComplete = 100.0;
	achievement.showsCompletionBanner = NO;
	[GKAchievement reportAchievements: @[achievement]
				withCompletionHandler: ^(NSError * _Nullable error) {
		if (error) {
			// Store achievement to be submitted at a later time.
			[object storeAchievement:achievement];
		} else {
			[MNSAudio playAchievement];
			[object displayAchievementToUser:identifier];
			
			if ([object.storedAchievements objectForKey:achievement.identifier]) {
				// Achievement is reported, remove from store.
				[object.earnedAchievementCache setObject:achievement forKey:[achievement identifier]];
				[object.storedAchievements removeObjectForKey:achievement.identifier];
				dispatch_queue_t queuePriorityMain = dispatch_get_main_queue();
				dispatch_queue_t queuePriorityLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
				dispatch_async(queuePriorityLow, ^{
					dispatch_async(queuePriorityMain, ^{
						[object resubmitStoredAchievements];
					});
				});
			}
		}
	}];
	achievement = nil;
}

#pragma mark -
#pragma mark Static Methods

+ (NSString *)AchievementIdentifierVocabulary:(long)level {
	//	Should return a string as follows for level 22:
	//		@"grp.com.everydayapps.game.wordflick.achievement.overall.vocabulary.022";
	return [@"grp.com.everydayapps.game.wordflick.achievement.overall" stringByAppendingFormat: @".vocabulary.%03ld", level];
}

+ (BOOL)operatingSystemSupportVersion:(NSString *)requiredVersion {
	return [[UIDevice currentDevice].systemVersion compare: requiredVersion options: NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)gameCenterApiIsAvailable {
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	BOOL systemVersionSupportsGameCenter = [MNSUser operatingSystemSupportVersion:@"4.1"];
	return (gcClass && systemVersionSupportsGameCenter);
}

+ (void)setupUser:(void(^)(UIViewController * __nullable viewController, NSError * __nullable error))setup { }

+ (NSString *)GameKitIdentifierOrDefault {
	return ([MNSUser gameCenterApiIsAvailable] && [GKLocalPlayer localPlayer].authenticated && [GKLocalPlayer localPlayer].playerID != nil) ? [GKLocalPlayer localPlayer].playerID : @"nogamekituser";
}

+ (MNSUser *)CurrentUser {
	if (_sharedInstanceUser == nil) {
		_currentLocale = [[NSString alloc] initWithString: [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
		_sharedInstanceUser = [[MNSUser alloc] initWithGameKitId:[MNSUser GameKitIdentifierOrDefault]];
		[[NSNotificationCenter defaultCenter] postNotificationName: @"MTUserDidUpdateNotification"
															object: appCoordinator()];
	}
	return _sharedInstanceUser;
}

+ (void)MakeCurrentUserDefaultUser {
	if (_sharedInstanceUser != nil) {
		_sharedInstanceUser = nil;
	}
	_sharedInstanceUser = [[MNSUser alloc] initWithGameKitId:@"nogamekituser"];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"MTUserDidUpdateNotification"
														object: appCoordinator()];
}

+ (void)MakeCurrentUserGameKitUser {
	if (_sharedInstanceUser != nil) {
		_sharedInstanceUser = nil;
	}
	_sharedInstanceUser = [[MNSUser alloc] initWithGameKitId:[MNSUser GameKitIdentifierOrDefault]];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"MTUserDidUpdateNotification"
														object: appCoordinator()];
}

+ (void)setDefaultUserWithString:(NSString *)user {
	const char *queryAdd = "UPDATE settings SET current_user = '%q' WHERE game = %q";
	char *sql = sqlite3_mprintf(queryAdd, user.UTF8String, "1");
	char *zErr;
	sqlite3_exec([[DatabaseUsers sharedInstance] database]->database, sql, nil, nil, &zErr);
	sqlite3_free(sql);
}

+ (NSUInteger)numberOfUsers {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:kUsers] count];
}

+ (BOOL)isUserInDatabase:(NSString *)user {
	BOOL result = NO;
	for (NSDictionary *userDetails in [[NSUserDefaults standardUserDefaults] objectForKey:kUsers]) {
		if ([[userDetails objectForKey:NSStringFromSelector(@selector(gameKitID))] isEqualToString:user]) {
			result = YES;
		}
	}
	return result;
}

+ (NSString *)displayUsername {
	if ([GKLocalPlayer localPlayer].alias != nil) {
		return [GKLocalPlayer localPlayer].alias;
	} else {
		return NSLocalizedString(@"Default", @"Default username displayed to user.");
	}
}

#pragma mark -
#pragma mark Instance Methods

- (void)dealloc {
	_earnedAchievementCache = nil;
	_writeLock = nil;
	_storedAchievementUrl = nil;
	_storedAchievements = nil;
	_username = nil;
	_game = nil;
	_statisticsUser = nil;
	_emailAddress = nil;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		_writeLock = [[NSLock alloc] init];
		self.username =              [decoder decodeObjectForKey:  NSStringFromSelector(@selector(username))];
		self.storedAchievements =    [decoder decodeObjectForKey:  NSStringFromSelector(@selector(storedAchievements))];
		self.emailAddress =          [decoder decodeObjectForKey:  NSStringFromSelector(@selector(emailAddress))];
		self.game =                  [decoder decodeObjectForKey:  NSStringFromSelector(@selector(game))];
		self.statisticsUser =        [decoder decodeObjectForKey:  NSStringFromSelector(@selector(statisticsUser))];
		self.userGameLevel =         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(userGameLevel))];
		self.age =                   [decoder decodeIntegerForKey: NSStringFromSelector(@selector(age))];
		self.topLevelAttained =      [decoder decodeIntegerForKey: NSStringFromSelector(@selector(topLevelAttained))];
		self.contactUser =           [decoder decodeBoolForKey:    NSStringFromSelector(@selector(contactUser))];
		self.submitHighScores =      [decoder decodeBoolForKey:    NSStringFromSelector(@selector(submitHighScores))];

		self.storedAchievementUrl = [MTFileController storedGameKitAchievementsForUser:self.username];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:  self.username           forKey: NSStringFromSelector(@selector(username))];
	[encoder encodeObject:  self.storedAchievements forKey: NSStringFromSelector(@selector(storedAchievements))];
	[encoder encodeObject:  self.emailAddress       forKey: NSStringFromSelector(@selector(emailAddress))];
	[encoder encodeObject:  self.game               forKey: NSStringFromSelector(@selector(game))];
	[encoder encodeObject:  self.statisticsUser     forKey: NSStringFromSelector(@selector(statisticsUser))];
	[encoder encodeInteger: self.userGameLevel      forKey: NSStringFromSelector(@selector(userGameLevel))];
	[encoder encodeInteger: self.age                forKey: NSStringFromSelector(@selector(age))];
	[encoder encodeInteger: self.topLevelAttained   forKey: NSStringFromSelector(@selector(topLevelAttained))];
	[encoder encodeBool:    self.contactUser        forKey: NSStringFromSelector(@selector(contactUser))];
	[encoder encodeBool:    self.submitHighScores   forKey: NSStringFromSelector(@selector(submitHighScores))];
}

- (instancetype)initWithGameKitId:(NSString *)gamekitId {
	if (self = [super init]) {

		//This is to save achievements that fail to submit to gamekit.
		//These motherfuckers are saved locally.  Don't waste time trying
		//  to get fancy here, you bitches!!!!
		_writeLock = [[NSLock alloc] init];

		self.storedAchievementUrl = [MTFileController storedGameKitAchievementsForUser:gamekitId];
		
		WFUserStatistics *u = [[WFUserStatistics alloc] init];
		self.statisticsUser = u;
		u = nil;
		
		self.username = gamekitId;
		
		self.dominateHand = MTDominantHandRight;
		[self setUserGameLevel: 1];
		[self setSubmitHighScores: YES];
		
		NSMutableArray *users = [[NSUserDefaults standardUserDefaults] objectForKey: kUsers];
		
		if (users == nil) {                                 //If first time run...
			NSMutableArray *usersDefault = [[NSMutableArray alloc] initWithCapacity: 1];
			
			NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
			[user setObject:gamekitId forKey:NSStringFromSelector(@selector(gameKitID))];
			[users addObject:user];
			[[NSUserDefaults standardUserDefaults] setObject:users forKey:kUsers];
			user = nil;
			users = usersDefault;
			usersDefault = nil;
		}
		
		if (![MNSUser isUserInDatabase:gamekitId]) {        //If user not in database...

			NSArray *usersUnmutable = [[NSUserDefaults standardUserDefaults] objectForKey:kUsers];
			NSMutableArray *usersArray = [[NSMutableArray alloc] initWithArray:usersUnmutable];

			NSMutableDictionary *userArray = [[NSMutableDictionary alloc] init];
			[userArray setObject: gamekitId
					 forKey: NSStringFromSelector(@selector(gameKitID))];
			[usersArray addObject:userArray];
			
			[[NSUserDefaults standardUserDefaults] setObject:usersArray forKey:kUsers];
			userArray = nil;
			usersArray = nil;
		}

	}
	return self;
}

- (NSString *)gameKitID {
	return self.username;
}

- (NSString *)idstring {
	return self.username;
}

- (int64_t)numberOfTimesWordWasUsed:(NSString *)word {
	int64_t result = 0;
	sqlite3_stmt *statement;
	const char *queryNumberWords = "SELECT usedctr "
									"FROM words "
									"WHERE word = '%q' AND username = '%q' AND lang = '%q'";
	char *sql = sqlite3_mprintf(queryNumberWords,
								word.UTF8String,
								self.username.UTF8String,
								_currentLocale.UTF8String);
	if (sqlite3_prepare_v2([[DatabaseUsers sharedInstance] database]->database, sql, -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			result = sqlite3_column_int64(statement, 0);
		}
	}
	sqlite3_finalize(statement);
	sqlite3_free(sql);
	return result;
}

- (void)addUsedWordStatistics:(NSString *)word {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			
			//This will add the word and track the number of times it was used.
			int64_t timesUsed = [self numberOfTimesWordWasUsed:word];
			timesUsed++;
			const char *sqlInsert = "INSERT OR REPLACE INTO words (username, word, usedctr, lang) "
									"VALUES ('%q', '%q', %lld, '%q')";
			char *sql = sqlite3_mprintf(sqlInsert,
										self.username.UTF8String,
										word.UTF8String,
										timesUsed,
										_currentLocale.UTF8String);
			char *zErr;
			sqlite3_exec([[DatabaseUsers sharedInstance] database]->database, sql, nil, nil, &zErr);
			if (zErr != nil) {
				//NSLog(@"sqlite3 says: \"%s\" about \"%s.\"", zErr, sql);
			}
			sqlite3_free(sql);
			
			NSInteger count = 0;
			//Check to see how many words the user has used.  Post an Achievement if it's good.
			zErr = nil;
			const char *sqlSelectCount = "SELECT COUNT(word) FROM words "
											"WHERE username = '%q' AND lang = '%q'";
			char *sel = sqlite3_mprintf(sqlSelectCount, self.username.UTF8String, _currentLocale.UTF8String);
			sqlite3_stmt *statement;
			if (sqlite3_prepare_v2([[DatabaseUsers sharedInstance] database]->database, sel, -1, &statement, NULL) == SQLITE_OK) {
				if (sqlite3_step(statement) == SQLITE_ROW) {
					count = sqlite3_column_int(statement, 0);
				}
			}
			sqlite3_finalize(statement);
			sqlite3_free(sel);

			NSString *achievementID = nil;
			switch (count) {
				case 1:
					achievementID = [MNSUser AchievementIdentifierVocabulary:0];
					break;
				case 10:
					achievementID = [MNSUser AchievementIdentifierVocabulary:1];
					break;
				case 20:
					achievementID = [MNSUser AchievementIdentifierVocabulary:2];
					break;
				case 50:
					achievementID = [MNSUser AchievementIdentifierVocabulary:3];
					break;
				case 100:
					achievementID = [MNSUser AchievementIdentifierVocabulary:4];
					break;
				case 150:
					achievementID = [MNSUser AchievementIdentifierVocabulary:5];
					break;
				case 200:
					achievementID = [MNSUser AchievementIdentifierVocabulary:6];
					break;
				case 250:
					achievementID = [MNSUser AchievementIdentifierVocabulary:7];
					break;
				case 300:
					achievementID = [MNSUser AchievementIdentifierVocabulary:8];
					break;
				case 350:
					achievementID = [MNSUser AchievementIdentifierVocabulary:9];
					break;
				case 400:
					achievementID = [MNSUser AchievementIdentifierVocabulary:10];
					break;
				case 450:
					achievementID = [MNSUser AchievementIdentifierVocabulary:11];
					break;
				case 500:
					achievementID = [MNSUser AchievementIdentifierVocabulary:12];
					break;
				case 750:
					achievementID = [MNSUser AchievementIdentifierVocabulary:13];
					break;
				case 1000:
					achievementID = [MNSUser AchievementIdentifierVocabulary:14];
					break;
				case 1500:
					achievementID = [MNSUser AchievementIdentifierVocabulary:15];
					break;
					/*
				case 2000:
					[self submitAchievement:kAchievementTotalWords16];
					break;
				case 3000:
					[self submitAchievement:kAchievementTotalWords17];
					break;
				case 4000:
					[self submitAchievement:kAchievementTotalWords18];
					break;
				case 5000:
					[self submitAchievement:kAchievementTotalWords19];
					break;
				case 6000:
					[self submitAchievement:kAchievementTotalWords20];
					break;
				case 7000:
					[self submitAchievement:kAchievementTotalWords21];
					break;
				case 8000:
					[self submitAchievement:kAchievementTotalWords22];
					break;
				case 9000:
					[self submitAchievement:kAchievementTotalWords23];
					break;
				case 10000:
					[self submitAchievement:kAchievementTotalWords24];
					break;
					 */
				default:
					break;
			}
			if (achievementID != nil) {
				[self submitAchievement:achievementID];
			}
		});
	});
/*
    if (timesUsed == 1) {
    } else {
        char *sql = sqlite3_mprintf((char *) [@"UPDATE words SET usedctr = %q WHERE username = '%q' AND lang = '%q' AND word = '%q'" UTF8String],
                                    [NSString stringWithFormat:@"%d", timesUsed],
                                    [[MNSUser CurrentUser] idstring],
                                    [[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] UTF8String],
                                    word);
        char *zErr;
        sqlite3_exec([[DatabaseUsers sharedInstance] database]->database, sql, nil, nil, &zErr);
        if (zErr != nil) {
            //NSLog(@"Failed to track word.  This is bad.  DB missing?");
        }
        sqlite3_free(sql);
    }
 */
}

- (void)addEndOfLevelStatistics:(WFStatisticsBase *)statistics withGameOver:(BOOL)isGameOver {

	[self.statisticsUser addNewStatistics:statistics];
	
	NSInteger topwordpoints = 0;
	NSInteger totalpoints = 0;
	NSInteger totalpointsfrombonustiles = 0;
	int totaltime = 0;
	NSInteger totaltimeextra = 0;
	NSInteger countbonustileseenshuffle = 0;
	NSInteger countbonustileseenpoints = 0;
	NSInteger countbonustileseentimer = 0;
	NSInteger countbonustileseenspecial = 0;
	NSInteger countbonustileseenspecialshuffle = 0;
	NSInteger countbonustileusedshuffle = 0;
	NSInteger countbonustileusedpoints = 0;
	NSInteger countbonustileusedspecial = 0;
	NSInteger countbonustileusedspecialshuffle = 0;
	NSInteger countbonustileusedtimer = 0;
	NSInteger countfreeshakesused = 0;
	NSInteger countclearedboard = 0;
	unsigned long toplevelattained = 1;
	NSInteger gamesplayed = 0;
	NSInteger levelsplayed = 0;
	NSString *topword = nil;
	NSInteger rowCounter = 0;

	const char *selectFormat = "SELECT topwordpoints, totalpoints, totalpointsfrombonustiles, "
								"totaltime, totaltimeextra, countbonustileseenshuffle, "
								"countbonustileseenpoints, countbonustileseentimer, "
								"countbonustileseenspecial, countbonustileseenspecialshuffle, "
								"countbonustileusedshuffle, countbonustileusedpoints, "
								"countbonustileusedspecial, countbonustileusedspecialshuffle, "
								"countbonustileusedtimer, countfreeshakesused, countclearedboard, "
								"toplevelattained, gamesplayed, levelsplayed, topword "
								"FROM statistics WHERE username = '%q' AND game = %d";
	if (self.username != nil) {
		char *sql = sqlite3_mprintf(selectFormat, self.username.UTF8String, self.game.gameType);
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2([[DatabaseUsers sharedInstance] database]->database, sql, -1, &statement, NULL) == SQLITE_OK) {
			if (sqlite3_step(statement) == SQLITE_ROW) {
				topwordpoints						= sqlite3_column_int(statement, 0);		//@"topwordpoints,"
				totalpoints							= sqlite3_column_int(statement, 1);		//@"totalpoints,"
				totalpointsfrombonustiles			= sqlite3_column_int(statement, 2);		//@"totalpointsfrombonustiles"
				totaltime							= sqlite3_column_int(statement, 3);		//@"totaltime,"
				totaltimeextra						= sqlite3_column_int(statement, 4);		//@"totaltimeextra,"
				countbonustileseenshuffle			= sqlite3_column_int(statement, 5);		//@"countbonustileseenshuffle,"
				countbonustileseenpoints			= sqlite3_column_int(statement, 6);		//@"countbonustileseenpoints,"
				countbonustileseentimer				= sqlite3_column_int(statement, 7);		//@"countbonustileseentimer,"
				countbonustileseenspecial			= sqlite3_column_int(statement, 8);		//@"countbonustileseenspecial,"
				countbonustileseenspecialshuffle	= sqlite3_column_int(statement, 9);		//@"countbonustileseenspecialshuffle,"
				countbonustileusedshuffle			= sqlite3_column_int(statement, 10);	//@"countbonustileusedshuffle,"
				countbonustileusedpoints			= sqlite3_column_int(statement, 11);	//@"countbonustileusedpoints,"
				countbonustileusedspecial			= sqlite3_column_int(statement, 12);	//@"countbonustileusedspecial,"
				countbonustileusedspecialshuffle	= sqlite3_column_int(statement, 13);	//@"countbonustileusedspecialshuffle,"
				countbonustileusedtimer				= sqlite3_column_int(statement, 14);	//@"countbonustileusedtimer,"
				countfreeshakesused					= sqlite3_column_int(statement, 15);	//@"countfreeshakesused,"
				countclearedboard					= sqlite3_column_int(statement, 16);	//@"countclearedboard,"
				//toplevelattained					= sqlite3_column_int(statement, 17);	//@"toplevelattained,"
				gamesplayed							= sqlite3_column_int(statement, 18);	//@"gamesplayed,"
				levelsplayed						= sqlite3_column_int(statement, 19);	//@"levelsplayed"
				topword								= [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
				rowCounter = rowCounter + 1;
				toplevelattained                    = self.highestLevelUnlocked;
			}
		} else {
			//NSLog(@"Caught %s",  sqlite3_errmsg([[DatabaseUsers sharedInstance] database]->database));
		}
		//gameTypeString = nil;
		//[gameTypeString release];
		sqlite3_finalize(statement);
		sqlite3_free(sql);
	}

	if (!isGameOver) toplevelattained++;
	//toplevelattained = (toplevelattained > ([statistics level] + 1)) ? toplevelattained : ([statistics level] + 1);
	
	char *sql2 = NULL;

	if (topword == nil) {
		topword = @"";
	}
	
	//Check for time played achievement
	int startTimeInterval = totaltime;
	long long endTimeInterval = totaltime + [statistics totalTime];
	
	if (startTimeInterval <= 120 && endTimeInterval >= 120) {
		[self submitAchievement: @"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.twominutes"];
	}
	if (startTimeInterval <= 600 && endTimeInterval >= 600) {
		[self submitAchievement: @"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.tenminutes"];
	}
	if (startTimeInterval <= 3600 && endTimeInterval >= 3600) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.hour"];
	}
	if (startTimeInterval <= 14400 && endTimeInterval >= 14400) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.fourhours"];
	}
	if (startTimeInterval <= 28800 && endTimeInterval >= 28800) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.eighthours"];
	}
	if (startTimeInterval <= 86400 && endTimeInterval >= 86400) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.day"];
	}
	if (startTimeInterval <= 114000 && endTimeInterval >= 114000) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.fortyhours"];
	}
	if (startTimeInterval <= 604800 && endTimeInterval >= 604800) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.solidweek"];
	}
	if (startTimeInterval <= 2592000 && endTimeInterval >= 2592000) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.month"];
	}
	if (startTimeInterval <= 31536000 && endTimeInterval >= 31536000) {
		[self submitAchievement:@"grp.com.everydayapps.game.wordflick.achievement.overall.timeplayed.year"];
	}
	NSString *percentD = @"%d";
	if (rowCounter == 0) {
		NSString *totalPoints = [[NSString alloc] initWithFormat:percentD, statistics.totalPoints];
		
		NSString *totalPointsFromBonusTiles = [[NSString alloc] initWithFormat:percentD, statistics.totalPointsFromBonusTiles];
		NSString *totalTime = [[NSString alloc] initWithFormat:percentD, statistics.totalTime];
		NSString *totalTimeExtra = [[NSString alloc] initWithFormat:percentD, statistics.totalTimeExtra];
		NSString *countBonusTileSeenShuffle = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileSeenShuffle];
		NSString *countBonusTileSeenPoints = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileSeenPoints];
		NSString *countBonusTileSeenTimer = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileSeenTimer];
		NSString *countBonusTileSeenSpecial = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileSeenSpecial];
		NSString *countBonusTileSeenSpecialShuffle = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileSeenSpecialShuffle];
		NSString *countBonusTileUsedShuffle = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileUsedShuffle];
		NSString *countBonusTileUsedPoints = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileUsedPoints];
		NSString *countBonusTileUsedSpecial = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileUsedSpecial];
		NSString *countBonusTileUsedSpecialShuffle = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileUsedSpecialShuffle];
		NSString *countBonusTileUsedTimer = [[NSString alloc] initWithFormat:percentD, statistics.countBonusTileUsedTimer];
		NSString *countFreeShakesUsed = [[NSString alloc] initWithFormat:percentD, statistics.countFreeShakesUsed];
		NSString *countClearedBoard = [[NSString alloc] initWithFormat:percentD, statistics.countClearedBoard];
		
		NSString *topLevelAttained = [[NSString alloc] initWithFormat:percentD, toplevelattained];
		NSString *gamesPlayed = [[NSString alloc] initWithFormat:percentD, isGameOver ? gamesplayed + 1 : gamesplayed];
		NSString *levelsPlayed = [[NSString alloc] initWithFormat:percentD, levelsplayed + 1];

		NSString *newTopWord;
		NSString *newTopWordPoints;
		if (statistics.topWord.points.integerValue > topwordpoints) {
			newTopWord = [statistics.topWord.word copy];
			newTopWordPoints = [[NSString alloc] initWithFormat:percentD, statistics.topWord.points.integerValue];
		} else {
			newTopWord = [topword copy];
			newTopWordPoints = [[NSString alloc] initWithFormat:percentD, topwordpoints];
		}

		const char *sqlFormatString = "INSERT INTO statistics ("
										"game, "
										"username, "
										"topword, "
										"topwordpoints, "
										"totalpoints, "
										"totalpointsfrombonustiles, "
										"totaltime, "
										"totaltimeextra, "
										"countbonustileseenshuffle, "
										"countbonustileseenpoints, "
										"countbonustileseentimer, "
										"countbonustileseenspecial, "
										"countbonustileseenspecialshuffle, "
										"countbonustileusedshuffle, "
										"countbonustileusedpoints, "
										"countbonustileusedspecial, "
										"countbonustileusedspecialshuffle, "
										"countbonustileusedtimer, "
										"countfreeshakesused, "
										"countclearedboard, "
										"toplevelattained, "
										"gamesplayed, "
										"levelsplayed) "
										"VALUES ("
										"%d, '%q', '%q', %q, %q, %q, %q, %q, "
										"%q, %q, %q, %q, %q, %q, %q, %q, %q, %q, %q, "
										"%q, %q, %q, %q)";
		sql2 = sqlite3_mprintf(sqlFormatString,
							   self.game.gameType,
							   self.username.UTF8String,
							   newTopWord.UTF8String,
							   newTopWordPoints.UTF8String,
							   totalPoints.UTF8String,
							   totalPointsFromBonusTiles.UTF8String,
							   totalTime.UTF8String, totalTimeExtra.UTF8String,
							   countBonusTileSeenShuffle.UTF8String,
							   countBonusTileSeenPoints.UTF8String,
							   countBonusTileSeenTimer.UTF8String,
							   countBonusTileSeenSpecial.UTF8String,
							   countBonusTileSeenSpecialShuffle.UTF8String,
							   countBonusTileUsedShuffle.UTF8String,
							   countBonusTileUsedPoints.UTF8String,
							   countBonusTileUsedSpecial.UTF8String,
							   countBonusTileUsedSpecialShuffle.UTF8String,
							   countBonusTileUsedTimer.UTF8String,
							   countFreeShakesUsed.UTF8String, countClearedBoard.UTF8String,
							   topLevelAttained.UTF8String, gamesPlayed.UTF8String,
							   levelsPlayed.UTF8String);
		
		levelsPlayed = nil;
		gamesPlayed = nil;
		topLevelAttained = nil;
		totalPointsFromBonusTiles = nil;
		totalTime = nil;
		totalTimeExtra = nil;
		countBonusTileSeenShuffle = nil;
		countBonusTileSeenPoints = nil;
		countBonusTileSeenTimer = nil;
		countBonusTileSeenSpecial = nil;
		countBonusTileSeenSpecialShuffle = nil;
		countBonusTileUsedShuffle = nil;
		countBonusTileUsedPoints = nil;
		countBonusTileUsedSpecial = nil;
		countBonusTileUsedSpecialShuffle = nil;
		countBonusTileUsedTimer = nil;
		countFreeShakesUsed = nil;
		countClearedBoard = nil;
		
		totalPoints = nil;
		newTopWordPoints = nil;
		newTopWord = nil;

	} else if (rowCounter == 1) {
		NSInteger twp = (statistics.topWord.points.integerValue > topwordpoints) ? statistics.topWord.points.integerValue : topwordpoints;
		const char *topWordTotal = (statistics.topWord.points.integerValue > topwordpoints) ? statistics.topWord.word.UTF8String : topword.UTF8String;
		int64_t ttp = totalpoints + statistics.totalPoints;
		int64_t tpfbt = totalpointsfrombonustiles + statistics.totalPointsFromBonusTiles;
		int64_t tt = totaltime + statistics.totalTime;
		int64_t tte = totaltimeextra + statistics.totalTimeExtra;
		
		int64_t cbtss = countbonustileseenshuffle + statistics.countBonusTileSeenShuffle;
		int64_t cbtsp = countbonustileseenpoints + statistics.countBonusTileSeenPoints;
		int64_t cbtst = countbonustileseentimer + statistics.countBonusTileSeenTimer;
		int64_t cbtsspecial = countbonustileseenspecial + statistics.countBonusTileSeenSpecial;
		int64_t cbtsss = countbonustileseenspecialshuffle + statistics.countBonusTileSeenSpecialShuffle;
		int64_t cbtus = countbonustileusedshuffle + statistics.countBonusTileUsedShuffle;
		int64_t cbtup = countbonustileusedpoints + statistics.countBonusTileUsedPoints;
		int64_t cbtuspecial = countbonustileusedspecial+ statistics.countBonusTileUsedSpecial;
		int64_t cbtuss = countbonustileusedspecialshuffle + statistics.countBonusTileUsedSpecialShuffle;
		int64_t cbtut = countbonustileusedtimer + statistics.countBonusTileUsedTimer;
		int64_t cfsu = countfreeshakesused + statistics.countFreeShakesUsed;
		int64_t ccb = countclearedboard + statistics.countClearedBoard;
		NSInteger totalGamesPlayed = isGameOver? gamesplayed + 1 : gamesplayed;
		NSInteger totalLevelsPlayed = levelsplayed + 1;
		
		NSString *topWordPoints = [[NSString alloc] initWithFormat:percentD, twp];
		NSString *totalPoints = [[NSString alloc] initWithFormat:percentD, ttp];
		NSString *totalPointsFromBonus = [[NSString alloc] initWithFormat:percentD, tpfbt];

		NSString *totalTime = [[NSString alloc] initWithFormat:percentD, tt];
		NSString *totalTimeExtra = [[NSString alloc] initWithFormat:percentD, tte];
		
		NSString *countBonusShuffle = [[NSString alloc] initWithFormat:percentD, cbtss];
		NSString *countBonusPoints = [[NSString alloc] initWithFormat:percentD, cbtsp];
		NSString *countBonusTime = [[NSString alloc] initWithFormat:percentD, cbtst];
		NSString *countBonusSeenExtra = [[NSString alloc] initWithFormat:percentD, cbtsspecial];
		NSString *countBonusSeenShuffle = [[NSString alloc] initWithFormat:percentD, cbtsss];
		NSString *countBonusUsedShuffle = [[NSString alloc] initWithFormat:percentD, cbtus];
		
		NSString *countBonusUsedPoints = [[NSString alloc] initWithFormat:percentD, cbtup];
		NSString *countBonusUsedExtra = [[NSString alloc] initWithFormat:percentD, cbtuspecial];
		NSString *countBonusUsedSpecialShuffle = [[NSString alloc] initWithFormat:percentD, cbtuss];
		
		NSString *countBonusUsedTime = [[NSString alloc] initWithFormat:percentD, cbtut];
		NSString *countBonusUsedFreeShuffle = [[NSString alloc] initWithFormat:percentD, cfsu];
		NSString *countClearedBoard = [[NSString alloc] initWithFormat:percentD, ccb];
		
		NSString *topLevelReached = [[NSString alloc] initWithFormat:percentD, toplevelattained];
		NSString *countGamesPlayed = [[NSString alloc] initWithFormat:percentD, totalGamesPlayed];
		NSString *countLevelsPlayed = [[NSString alloc] initWithFormat:percentD, totalLevelsPlayed];
		NSString *gameType = [[NSString alloc] initWithFormat:percentD, self.game.gameType];
		
		const char *updateFormat = "UPDATE statistics SET topword = '%q', topwordpoints = %q, "
									"totalpoints = %q, totalpointsfrombonustiles = %q, "
									"totaltime = %q, totaltimeextra = %q, "
									"countbonustileseenshuffle = %q, "
									"countbonustileseenpoints = %q, countbonustileseentimer = %q, "
									"countbonustileseenspecial = %q, "
									"countbonustileseenspecialshuffle = %q, "
									"countbonustileusedshuffle = %q, "
									"countbonustileusedpoints = %q, "
									"countbonustileusedspecial = %q, "
									"countbonustileusedspecialshuffle = %q, "
									"countbonustileusedtimer = %q, countfreeshakesused = %q, "
									"countclearedboard = %q, toplevelattained = %q, "
									"gamesplayed = %q, levelsplayed = %q "
									"WHERE username = '%q' AND game = %q";
		sql2 = sqlite3_mprintf(updateFormat, topWordTotal, topWordPoints.UTF8String,
							   totalPoints.UTF8String, totalPointsFromBonus.UTF8String,
							   totalTime.UTF8String, totalTimeExtra.UTF8String,
							   countBonusShuffle.UTF8String, countBonusPoints.UTF8String,
							   countBonusTime.UTF8String, countBonusSeenExtra.UTF8String,
							   countBonusSeenShuffle.UTF8String, countBonusUsedShuffle.UTF8String,
							   countBonusUsedPoints.UTF8String, countBonusUsedExtra.UTF8String,
							   countBonusUsedSpecialShuffle.UTF8String,
							   countBonusUsedTime.UTF8String, countBonusUsedFreeShuffle.UTF8String,
							   countClearedBoard.UTF8String, topLevelReached.UTF8String,
							   countGamesPlayed.UTF8String, countLevelsPlayed.UTF8String,
							   self.username.UTF8String, gameType.UTF8String);
		gameType = nil;
		totalTime = nil;
		totalTimeExtra = nil;
		countBonusShuffle = nil;
		countBonusPoints = nil;
		countBonusTime = nil;
		countBonusSeenExtra = nil;
		countBonusSeenShuffle = nil;
		countBonusUsedShuffle = nil;
		countBonusUsedPoints = nil;
		countBonusUsedExtra = nil;
		countBonusUsedSpecialShuffle = nil;
		countBonusUsedTime = nil;
		countBonusUsedFreeShuffle = nil;
		countClearedBoard = nil;
		topLevelReached = nil;
		countGamesPlayed = nil;
		countLevelsPlayed = nil;
		totalPointsFromBonus = nil;
		totalPoints = nil;
		topWordPoints = nil;
	}
	topword = nil;
	char *zErr;
	sqlite3_exec([[DatabaseUsers sharedInstance] database]->database, sql2, nil, nil, &zErr);
	sqlite3_free(sql2);

	[self setTopLevelAttained: toplevelattained];
	[self setHighestLevelUnlocked: self.topLevelAttained];
}

- (BOOL)askToResume {
	return [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(@selector(askToResume))];
}

- (void)setAskToResume:(BOOL)ask {
	[[NSUserDefaults standardUserDefaults] setBool:ask forKey:NSStringFromSelector(@selector(askToResume))];
}

- (BOOL)desiresSoundEffects {
	// If not set, default to YES.
	NSNumber *sfxEnabled = [[NSUserDefaults standardUserDefaults] objectForKey: NSStringFromSelector(@selector(desiresSoundEffects))];
	if (sfxEnabled == nil) {
		[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES]
												  forKey: NSStringFromSelector(@selector(desiresSoundEffects))];
		return YES;
	} else {
		return sfxEnabled.boolValue;
	}
}

- (void)setDesiresSoundEffects:(BOOL)desiresSoundEffects {
	[[NSUserDefaults standardUserDefaults] setBool: desiresSoundEffects
											forKey: NSStringFromSelector(@selector(desiresSoundEffects))];
}

- (BOOL)desiresBackgroundMusic {
	return [[NSUserDefaults standardUserDefaults] boolForKey: NSStringFromSelector(@selector(desiresBackgroundMusic))];
}

- (void)setDesiresBackgroundMusic:(BOOL)desiresBackgroundMusic {
	[[NSUserDefaults standardUserDefaults] setBool: desiresBackgroundMusic
											forKey: NSStringFromSelector(@selector(desiresBackgroundMusic))];
}

- (BOOL)desiresStylizedFonts {
	return [[NSUserDefaults standardUserDefaults] boolForKey: NSStringFromSelector(@selector(desiresStylizedFonts))];
}

- (void)setDesiresStylizedFonts:(BOOL)desiresStylizedFonts {
	[[NSUserDefaults standardUserDefaults] setBool: desiresStylizedFonts
											forKey: NSStringFromSelector(@selector(desiresStylizedFonts))];
}

- (double)desiredVolume {
	NSNumber *n = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromSelector(@selector(desiredVolume))];
	if (n == nil) {
		[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithDouble: 0.5]
												  forKey: NSStringFromSelector(@selector(desiredVolume))];
		return 0.5;
	} else {
		return n.doubleValue;
	}
}

- (void)setDesiredVolume:(double)desiredVolume {
	[[NSUserDefaults standardUserDefaults] setDouble: desiredVolume
											  forKey: NSStringFromSelector(@selector(desiredVolume))];
}

- (MTDominantHand)dominateHand {
	NSNumber *n = [[NSUserDefaults standardUserDefaults] valueForKey: NSStringFromSelector(@selector(dominateHand))];
	if (n == nil) {
		[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithShort:MTDominantHandRight]
												 forKey: NSStringFromSelector(@selector(dominateHand))];
		return MTDominantHandRight;
	} else {
		return n.shortValue;
	}
}

- (void)setDominateHand:(MTDominantHand)hand {
	[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithShort:hand]
											 forKey: NSStringFromSelector(@selector(dominateHand))];
}

- (unsigned long)highestLevelUnlocked {
	NSNumber *n = [[NSUserDefaults standardUserDefaults] valueForKey:NSStringFromSelector(@selector(highestLevelUnlocked))];
	unsigned long result = 1;
	if (n != nil) {
		result = n.unsignedLongValue;
	}
	if (result <= 0) {
		result = 1;
	}
	return result;
}

- (void)setHighestLevelUnlocked:(unsigned long)highestLevelUnlocked {
	NSNumber *n = [NSNumber numberWithUnsignedLong:highestLevelUnlocked];
	[[NSUserDefaults standardUserDefaults] setValue: n
											 forKey: NSStringFromSelector(@selector(highestLevelUnlocked))];
}

- (NSString *)usernameForDisplay {
	return [GKLocalPlayer localPlayer].displayName;
}

#pragma mark - Game Kit

// Try to submit all stored achievements to update any achievements that were not successful.
- (void)resubmitStoredAchievements {
	if (self.storedAchievements) {
		
		NSDictionary *storedAchievementsCopy = [[NSDictionary alloc] initWithDictionary:self.storedAchievements];
		[self.storedAchievements removeAllObjects];
		[self writeStoredAchievements];
		for (NSString *key in storedAchievementsCopy){
			[self submitAchievement:key];
		}
		storedAchievementsCopy = nil;
	}
}

// Load stored achievements and attempt to submit them
- (void)loadStoredAchievements {
	if (!self.storedAchievements) {
		NSError *error = nil;
		NSData *data = [NSData dataWithContentsOfFile: self.storedAchievementUrl.path
											  options: 0
												error: &error];
		
		if (error) {
			NSLog(@"Error reading data from file: %@", [error localizedDescription]);
			return;
		}

		if (data) {
			NSDictionary *unarchivedObj = [NSKeyedUnarchiver unarchivedObjectOfClass: [NSDictionary class]
																			fromData: data
																			   error: &error];
			if (error) {
				NSLog(@"Error unarchiving data: %@", [error localizedDescription]);
				return;
			}

			if (unarchivedObj) {
				NSMutableDictionary *ach = [[NSMutableDictionary alloc] initWithDictionary:unarchivedObj];
				[self setStoredAchievements: ach];
				ach = nil;
				[self resubmitStoredAchievements];
			}
		} else {
			NSMutableDictionary *ach = [[NSMutableDictionary alloc] init];
			[self setStoredAchievements: ach];
			ach = nil;
		}
	}
}

// Store achievements to disk to submit at a later time.
- (void)writeStoredAchievements {
	[_writeLock lock];
	NSError *error = nil;
	NSData *archivedAchievements = [NSKeyedArchiver archivedDataWithRootObject: self.storedAchievements
														 requiringSecureCoding: YES
																		 error: &error];
	if (error) {
		NSLog(@"Error archiving data: %@", [error localizedDescription]);
		[_writeLock unlock];
		return;
	}

	BOOL success = [archivedAchievements writeToURL:self.storedAchievementUrl
											options:NSDataWritingAtomic | NSDataWritingFileProtectionNone
											  error:&error];
	if (!success || error) {
		NSLog(@"Error saving achievements to disk: %@.", [error localizedDescription]);
		// Consider handling the error, e.g., by retrying.
	}
	[_writeLock unlock];
}

// Submit an achievement to the server and store if submission fails
- (void)submitAchievement:(NSString *)identifier allowResubmit:(BOOL)allowResubmit {
	if(self.earnedAchievementCache == nil) {
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error == nil) {
				
				NSMutableDictionary <NSString *, GKAchievement *> *tempCache;
				tempCache = [[NSMutableDictionary alloc] initWithCapacity: scores.count];
				
				for (GKAchievement *score in scores) {
					[tempCache setObject: score forKey: score.identifier];
				}
				
				self.earnedAchievementCache = tempCache;
				tempCache = nil;
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
					dispatch_async(dispatch_get_main_queue(), ^{
						[self resubmitStoredAchievements];
					});
				});
				
			}
			GKAchievement * achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
			achievement.percentComplete = 100.0;
			achievement.showsCompletionBanner = YES;
			[self storeAchievement:achievement];
			achievement = nil;
		}];
	} else {
		if (self.storedAchievements) {
			if (allowResubmit || ![self.earnedAchievementCache objectForKey:identifier]) {     //If not yet submitted.
				GKAchievement *achievement = [self.storedAchievements objectForKey:identifier];
				if (achievement) {
					NSArray *achievements = @[achievement];
					achievement.percentComplete = 100.0;
					achievement.showsCompletionBanner = NO;
					[GKAchievement reportAchievements: achievements
								withCompletionHandler: ^(NSError * _Nullable error) {
						if (error) {
							// Store achievement to be submitted at a later time.
							[self storeAchievement:achievement];
						} else {
							//[appReviewManager userDidSignificantEvent:YES];
							[MNSAudio playAchievement];
							[self displayAchievementToUser:identifier];
							if ([self.storedAchievements objectForKey:achievement.identifier]) {
								// Achievement is reported, remove from store.
								[self.earnedAchievementCache setObject:achievement forKey:[achievement identifier]];
								[self.storedAchievements removeObjectForKey:achievement.identifier];
								dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
									dispatch_async(dispatch_get_main_queue(), ^{
										[self resubmitStoredAchievements];
									});
								});
							}
						}
					}];
				} else {
					submitAchievementWithIdentifier(self, identifier);
				}
			}
		}
	}
}

- (void)submitAchievement:(NSString *)identifier {
	[self submitAchievement:identifier allowResubmit:NO];
}

- (void)displayAchievementToUser:(NSString *)identifier {
	if (self.game == nil) return;

	[GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray<GKAchievementDescription *> * __nullable descriptions, NSError * __nullable error) {
		if (error != nil || descriptions == nil) return;
		GKAchievementDescription *description = achievementForIdentifier(&descriptions, identifier);
		if (description == nil) return;

		[GKNotificationBanner showBannerWithTitle: description.title message: description.achievedDescription completionHandler:^{
			
			[description loadImageWithCompletionHandler:^(UIImage *image, NSError *error) {
				if (error != nil) return;
				NSMutableArray *tweetMessageYo = [[NSMutableArray alloc] init];
				NSString *wordflickAchievement = NSLocalizedString(@"Wordflick Achievement: ", @"Wordflick Achievement: ");
				NSString *message = [[NSString alloc] initWithFormat:@"%@ \"%@\" - %@", wordflickAchievement, description.title, description.achievedDescription];
				[tweetMessageYo addObject:message];
				message = nil;
				if (image != nil) {
					[tweetMessageYo addObject:image];
				}
#warning Dead URL
				NSString *achievementUrl = @"https://www.example.com/applications/games/wordflick/achievements/";
				NSMutableString *s = [[NSMutableString alloc] initWithString:achievementUrl];
				[s appendString:description.identifier];
				[s appendString:@"/complete"];
				NSString *path = [[NSBundle mainBundle] pathForResource:@"achievementlinks" ofType:@"plist"];
				NSData *data = [NSData dataWithContentsOfFile:path];
				NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
				error = nil;
				NSMutableDictionary* myDict = [NSPropertyListSerialization propertyListWithData: data
																						options: NSPropertyListImmutable
																						 format: &format
																						  error: &error];
				data = nil;
				path = nil;
				if (error == nil) {
					if (myDict) {
						NSString *idd = [myDict objectForKey:[description identifier]];
						if (idd != nil) {
							[tweetMessageYo addObject:[NSURL URLWithString:idd]];
						}
						idd = nil;
					}
				}
				myDict = nil;

				s = nil;
				
#warning Dead URL
				NSURL *url = [[NSURL alloc] initWithString: @"https://www.example.com/applications/games/wordflick"];
				[tweetMessageYo addObject:url];
				[[MNSUser CurrentUser].game.gameLevel.tweetableMessages addObject:tweetMessageYo];
				url = nil;
				tweetMessageYo = nil;
				
			}];


		}];
		dispatch_queue_t queuePriorityMain = dispatch_get_main_queue();
		dispatch_async(queuePriorityMain, ^{
			if (self.game != nil) {
				MNSMessage *achievementMessage = [[MNSMessage alloc] initWithString: description.title
																			andType: MNSMessageFun];
				
				[self.game.delegate game: self.game
						  displayMessage: achievementMessage];
				achievementMessage = nil;
			}
		});
	}];
}

// Create an entry for an achievement that hasn't been submitted to the server
- (void)storeAchievement:(GKAchievement *)achievement {
	GKAchievement *currentStorage = [self.storedAchievements objectForKey:achievement.identifier];
	if (!currentStorage || (currentStorage && currentStorage.percentComplete < achievement.percentComplete)) {
		[self.storedAchievements setObject:achievement forKey:achievement.identifier];
		[self writeStoredAchievements];
	}
}

// Reset all the achievements for local player
- (void)resetAchievements {
	[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) {
		 if (!error) {
			 [self.storedAchievements removeAllObjects];
			 
			 // overwrite any previously stored file
			 [self writeStoredAchievements];
		 } else {
			 // Error clearing achievements.
		 }
	 }];
}

- (nullable NSMutableDictionary *)restartData {
	if (!self.askToResume) return nil;
	
	NSString *plistPath = [MTFileController restartPlistDocumentDirectoryPath];
	BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath: plistPath];
	if (fileExist) {
		NSError *error = nil;
		NSData *readData = [NSData dataWithContentsOfFile: plistPath options: 0 error: &error];
		if (error) {
			NSLog(@"Error reading data from file: %@", [error localizedDescription]);
			return nil;
		}

		if (readData) {
			NSError *plistError = nil;
			NSDictionary *serializedData = [NSPropertyListSerialization propertyListWithData: readData
																					 options: 0
																					  format: nil
																					   error: &plistError];
			if (plistError) {
				NSLog(@"Error deserializing property list data: %@", [plistError localizedDescription]);
				return nil;
			}

			NSData *data = [serializedData objectForKey:@"51103"];
			if (data) {
				NSError *unarchiveError = nil;
				NSMutableDictionary *result = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableDictionary class]
																				 fromData:data
																					error:&unarchiveError];
				if (unarchiveError) {
					NSLog(@"Error unarchiving data: %@", [unarchiveError localizedDescription]);
					return nil;
				}
				return result;
			}
		}
	}
	return nil;
}

- (void)setRestartData:(NSMutableDictionary *)restartData {
	
}

- (void)saveYourGame {
	if (self.game == nil || self.game.isGameOver) return;
	
	NSNumber *currentGameScreen = [[NSNumber alloc] initWithInteger:self.game.currentGameScreen];
	[[NSUserDefaults standardUserDefaults] setObject: currentGameScreen
											  forKey: @"currentscreen"];

	self.askToResume = YES;

	NSString *plistPath = [MTFileController restartPlistDocumentDirectoryPath];
	NSError *fileError = nil;
	//Delete old save file, which could be large file
	if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		[[NSFileManager defaultManager] removeItemAtPath: plistPath error: &fileError];
		if (fileError != nil) {
			NSLog(@"removeItemAtPath failed with '%@.'", fileError.localizedDescription);
		}
	}
	
	// ???: OK, so we deleted any one that might have already existed... then we copy the stock one...
	// ???: Why the run around.  Why all this copying, and deleting.

	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {	//Copy empty verison of that file
		NSError *copyError = nil;
		NSString *bundlePath = [MTFileController restartPlistApplicationBundlePath];
		[[NSFileManager defaultManager] copyItemAtPath: bundlePath
												toPath: plistPath
												 error: &copyError];
		if (copyError != nil) {
			NSLog(@"copyItemAtPath failed wtih '%@.'", copyError.localizedDescription);
		}
	}

	NSMutableDictionary *restartPlist = [[NSMutableDictionary alloc] initWithCapacity:1];
	NSError *archiveError = nil;
	//NSData *gameData = [NSKeyedArchiver archivedDataWithRootObject: self.game];
	NSData *gameData = [NSKeyedArchiver archivedDataWithRootObject: self.game
											 requiringSecureCoding: YES error:&archiveError];
	if (archiveError) {
		NSLog(@"archivedDataWithRootObject failed with '%@.'", archiveError.localizedDescription);
		return;
	}
	
	[restartPlist setValue:gameData forKey:@"51103"];
	
	
	NSError *serializeError = nil;
	NSData *serializedPlist = [NSPropertyListSerialization dataWithPropertyList: restartPlist
																		 format: NSPropertyListBinaryFormat_v1_0
																		options: 0
																		  error: &serializeError];
	if (serializeError != nil) {
		NSLog(@"dataWithPropertyList failed wtih '%@.'", serializeError.localizedDescription);
	} else {
		[serializedPlist writeToFile:plistPath atomically:YES];
	}

	restartPlist = nil;
}

/*

- (void)awardCoins:(NSInteger)count ofType:(MNSCoinType)coinType {
	NSString *key;
	keyForCoinType(coinType, &key);
	NSInteger numberTokens = 0;// [[MKStoreManager numberForKey:key] integerValue];
	numberTokens = numberTokens + count;
	//NSNumber *co = [NSNumber numberWithInteger:numberTokens];
	//[MKStoreManager setObject:co forKey:key];
}

*/

@end
