//
//  MNSGame.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/24/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "MNSGame.h"
#import "sqlite3.h"
#import <math.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DatabaseWords.h"
#import "MNSUser.h"
#import "DatabaseUsers.h"
#import "MTWordValue.h"
#import "MTSqliteWrapper.h"
#import "MNSAudio.h"
#import "WFTileView.h"
#import "MNSTimer.h"
#import "DatabaseUsers.h"
#import "WFLevelStatistics.h"
#import "WFGameView.h"
#import "WFTileData.h"
#import "WFGameStatistics.h"
#import "MNSMessage.h"
#import "Constants.h"

static const unsigned char _primes[] = {0, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
							  67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137,
							  139, 149, 151, 157};

static inline CGPoint CGPointCenterOfTileInsideRect(CGSize, CGRect, NSInteger, NSInteger, NSInteger, NSInteger, CGFloat, CGFloat);
static inline CGFloat HorizontalMoveDistance(CGFloat, CGFloat, NSUInteger, NSUInteger);
static inline CGFloat VerticalMoveDistance(CGFloat, CGFloat, NSUInteger, NSUInteger);
static inline CGFloat MoveDistance(CGFloat, CGFloat, NSUInteger);

static inline CGPoint CGPointCenterOfTileInsideRect(CGSize tileSize, CGRect containerRect, NSInteger onRow, NSInteger ofRows, NSInteger andOnCol, NSInteger ofCols, CGFloat withPaddingTop, CGFloat andPaddingBottom) {
	return CGPointMake((tileSize.width * andOnCol) + HorizontalMoveDistance(containerRect.size.width, tileSize.width, andOnCol + 1, ofCols),
					   (tileSize.height * onRow) + VerticalMoveDistance(containerRect.size.height, tileSize.height, onRow + 1, ofRows) + withPaddingTop);
}

static inline CGFloat HorizontalMoveDistance(CGFloat containerWidth, CGFloat itemWidth, NSUInteger onColumn, NSUInteger ofColumns) {
	return (MoveDistance(containerWidth, itemWidth, ofColumns) * (double)onColumn * 2.0) + MoveDistance(containerWidth, itemWidth, ofColumns);
}

static inline CGFloat VerticalMoveDistance(CGFloat containerHeight, CGFloat itemHeight, NSUInteger onRow, NSUInteger ofRows) {
	return (MoveDistance(containerHeight, itemHeight, ofRows) * (double)onRow * 2.0) + MoveDistance(containerHeight, itemHeight, ofRows);
}

static inline CGFloat MoveDistance(CGFloat containerLength, CGFloat itemLength, NSUInteger totalItems) {
	return (containerLength - (itemLength * (double)totalItems)) / (((double)(totalItems - 1) * 2.0) + 2.0);
}

#pragma mark -
#pragma mark Static

static long pointsForWord(MNSGame *, NSString *);
static long pointsForLetter(MNSGame *, NSString *);

static long pointsForWord(MNSGame *object, NSString *word) {
	long points = 0;
	//NSRange range = NSMakeRange(0, 1);
	if (word != nil) {
		for (NSUInteger i=0; i<word.length; i++) {
			@autoreleasepool {
				points += [[object.pointsDictionary objectForKey: [word substringWithRange: NSMakeRange(i, 1)]] longValue];
			}
		}
		points *= _primes[word.length];
	} else {
		points = 0;
	}
	return points;
}

static long pointsForLetter(MNSGame *game, NSString *letter) {
	return [[game.pointsDictionary objectForKey:
			 [letter substringWithRange: NSMakeRange(0, 1)]
			 ] longValue];
}

static void submitAchievementLevelCompleteWordflickClassic(int64_t level) {
	// Submit achevement scrting for level finished.
	//		Result should look like for level 15:
	//		@"com.everydayapps.game.wordflick.classic.achievement.finishedlevel.0015"
	if (level > 20) return;
	[[MNSUser CurrentUser] submitAchievement:
	 [@"com.everydayapps.game.wordflick.classic.achievement.finishedlevel" stringByAppendingFormat:
	  @".%04lld", level]];
}

static void submitAchievementLevelCompleteWordflick(int64_t level) {
	assert(level >= 1);
	assert(level <= 50);
	if (level > 50) return;
	[[MNSUser CurrentUser] submitAchievement:
	 [@"grp.com.everydayapps.game.wordflick.achievement.finishedlevel" stringByAppendingFormat:
	  @".%04lld", level]];
}

static void enableShuffleButton(MNSGame *game) {
	game.allowShuffle = YES;
	[game.delegate game: game enableShuffleButton: true];
}

static void displayMessage(MNSGame *game, id<MTGameProtocol> delegate, NSString *message,
						   MNSMessageType messageType) {
	MNSMessage *m = [[MNSMessage alloc] initWithString: message
											   andType: messageType];
	[delegate game: game displayMessage: m];
	m = nil;
}

static void checkForBonusMultipliers(MNSGame *game, MNSTileType *bestTileType, BOOL checkForRewards,
									 int *ctrExtraPoints, int *ctrExtraShuffle,
									 int *ctrExtraSpecial, int *ctrExtraTime,
									 id<MTGameProtocol> delegate, int *pointsGiven, WFTileData *tileT,
									 int *timeGiven) {
	if (checkForRewards && game.timer.seconds > 0) {
		switch ([tileT tileType]) {
			case MNSTileExtraPoints:
				*ctrExtraPoints = *ctrExtraPoints + 1;
				[game.gameLevel addBonusTileUsedPoints:1];
				*pointsGiven += [game bonusGivePointsMultiplier: tileT.characterValue];
				if (*bestTileType != MNSTileExtraSpecial) *bestTileType = MNSTileExtraPoints;
				break;
			case MNSTileExtraTime:
				*ctrExtraTime = *ctrExtraTime + 1;
				[game.gameLevel addBonusTileUsedTimer:1];
				*timeGiven += [game bonusExtendTimer: tileT.characterValue];
				if (*bestTileType != MNSTileExtraSpecial) *bestTileType = MNSTileExtraTime;
				break;
			case MNSTileExtraShuffle:
				*ctrExtraShuffle = *ctrExtraShuffle + 1;
				[game.gameLevel addBonusTileUsedShuffle:1];
				[game bonusGiveExtraShake];
				if (*bestTileType != MNSTileExtraShuffle) *bestTileType = MNSTileExtraShuffle;
				break;
			case MNSTileExtraSpecial:
				*ctrExtraSpecial = *ctrExtraSpecial + 1;
				[game.gameLevel addBonusTileUsedSpecial:1];
				*bestTileType = MNSTileExtraSpecial;
				[game bonusGivePointsMultiplier: tileT.characterValue];
				[game bonusGiveExtraShake];
				break;
			case MNSTileExtraNormal:
			default:
				break;
		}
	}
}

static void submitAchivementsForWordLength(NSUInteger length) {
	if (length < 6) return;
	if (length > 20) return;
	
	NSString *format = @"grp.com.everydayapps.game.wordflick.achievement.wordlength.%04d";
	NSString *achievement = [NSString stringWithFormat:format, length - 5];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[[MNSUser CurrentUser] submitAchievement:achievement allowResubmit:YES];
		});
	});
}

@interface MNSGame ()

@property (readwrite, assign) int32_t numberOfShakes;
@property (nonatomic, strong) NSDictionary <NSString *, NSNumber *> *dictionaryPoints;
@property (nonatomic, readwrite, assign) BOOL gamePlayHasBegun;
@property (nonatomic, assign) CGRect gameRect;

@property (readwrite, nonatomic, strong) NSMutableDictionary <NSNumber *, WFTileData *> *gamePieceData;
@property (readwrite, nonatomic, strong) NSMutableArray <NSNumber *> *gamePieceIndex;
@property (readwrite, nonatomic, strong) NSMutableOrderedSet <NSNumber *> *gamePieceInGoalIndex;

+ (void)addBestWordOfGame:(MTWordValue *)word forUser:(NSString *)user onGame:(MNSGame *)game;
+ (BOOL)addScoreForUser:(NSString *)user onGame:(MNSGame *)game;
+ (void)postScoreForUser:(NSString *)user onGame:(MNSGame *)game;

- (void)bonusForUsingMultipleSpecialTiles: (NSInteger)timeTileCount
							   pointTiles: (NSInteger)pointTileCount
							 shuffleTiles: (NSInteger)shuffleTileCount
							   extraTiles: (NSInteger)extraTileCount
							  extraPoints: (NSInteger)extraPointsCount
								extraTime: (NSInteger)extraTimeCount;

@end

@implementation MNSGame

#pragma mark -
#pragma mark Standard Overrides

- (void)dealloc {
	[_timer deallocTimer];
}

- (instancetype)init {
	return [self initWithType:Wordflick userID:@"" andStartingLevel:1];
}

- (instancetype)initWithType:(MNSGameType)type
					  userID:(NSString *)gameKitUserOrDefaultIdentifier
			andStartingLevel:(long)l {
	
	if (self = [super init]) {
		_gameKitUserOrDefaultIdentifier = gameKitUserOrDefaultIdentifier.copy;
		self.gameOver = YES;
		self.gameType = type;
		self.numberOfShakes = 0;

		WFGameStatistics *statisticsGame = [[WFGameStatistics alloc] init];
		self.statisticsGame = statisticsGame;
		statisticsGame = nil;

		WFLevelStatistics *level = [[WFLevelStatistics alloc] initWithLevel: ( l - 1 )
																andGameType: self.gameType];
		self.gameLevel = level;
		level = nil;

		NSMutableArray *gameLevelArchive = [[NSMutableArray alloc] initWithCapacity: 10];
		[self setGameLevelArchive: gameLevelArchive];
		gameLevelArchive = nil;

		MNSTimer *timer = [[MNSTimer alloc] init];
		[timer setDelegate: self];
		[self setTimer: timer];
		timer = nil;

		_gamePieceData = [[NSMutableDictionary alloc] initWithCapacity: WF_TILE_COUNT * 2];
		_gamePieceIndex = [[NSMutableArray alloc] initWithCapacity: WF_TILE_COUNT];
		_gamePieceInGoalIndex = [[NSMutableOrderedSet alloc] initWithCapacity: WF_TILE_COUNT];
		
		[self setGamePlayHasBegun:NO];
	}
	return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.game =					[decoder decodeObjectForKey:  NSStringFromSelector(@selector(game))];
		self.currentGameScreen =	[decoder decodeIntForKey:     NSStringFromSelector(@selector(currentGameScreen))];
		//self.gamePieces =			[decoder decodeObjectForKey:  NSStringFromSelector(@selector(gamePieces))];
		//self.gamePiecesInGoal =		[decoder decodeObjectForKey:  NSStringFromSelector(@selector(gamePiecesInGoal))];

		if (@available(iOS 14.0, *)) {
			self.gamePieceData =		[[decoder decodeDictionaryWithKeysOfClass: [NSNumber class]
																   objectsOfClass: [WFTileData class]
																		   forKey: NSStringFromSelector(@selector(gamePieceData))]
										 mutableCopy];
			self.gamePieceIndex =		[[decoder decodeArrayOfObjectsOfClass: [NSNumber class]
																	   forKey: NSStringFromSelector(@selector(gamePieceIndex))]
										 mutableCopy];
			//self.gamePieceInGoalIndex = [[decoder decodeArrayOfObjectsOfClass: [NSNumber class]
			//														   forKey: NSStringFromSelector(@selector(gamePieceInGoalIndex))]
			//							 mutableCopy];
		} else {
			self.gamePieceData =	[[decoder decodeObjectForKey: NSStringFromSelector(@selector(gamePieceData))] mutableCopy];
			self.gamePieceIndex =	[[decoder decodeObjectForKey: NSStringFromSelector(@selector(gamePieceIndex))] mutableCopy];
		}
		self.gamePieceInGoalIndex = [[decoder decodeObjectForKey: NSStringFromSelector(@selector(gamePieceInGoalIndex))] mutableCopy];

		self.gameType =			[decoder decodeIntForKey:		NSStringFromSelector(@selector(gameType))];
		self.gameOver =			[decoder decodeBoolForKey:		NSStringFromSelector(@selector(isGameOver))];
		self.statisticsGame =	[decoder decodeObjectForKey:	NSStringFromSelector(@selector(statisticsGame))];
		self.gameLevel =		[decoder decodeObjectForKey:	NSStringFromSelector(@selector(gameLevel))];
		self.gameLevelArchive =	[decoder decodeObjectForKey:	NSStringFromSelector(@selector(gameLevelArchive))];
		self.timer =			[decoder decodeObjectForKey:	NSStringFromSelector(@selector(timer))];
		self.allowShuffle =		[decoder decodeBoolForKey:		NSStringFromSelector(@selector(allowShuffle))];
		self.numberOfShakes =	[decoder decodeInt32ForKey: NSStringFromSelector(@selector(numberOfShakes))];
		self.gamePlayHasBegun =	[decoder decodeBoolForKey:		NSStringFromSelector(@selector(gamePlayHasBegun))];
		self.dictionaryPoints =	[decoder decodeObjectForKey:	NSStringFromSelector(@selector(dictionaryPoints))];
		self.gameRect =			[decoder decodeCGRectForKey:	NSStringFromSelector(@selector(gameRect))];
		self.timer.delegate = self;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:		self.game					forKey: NSStringFromSelector(@selector(game))];
	[encoder encodeInt:			[self currentGameScreen]	forKey: NSStringFromSelector(@selector(currentGameScreen))];
	
	//[encoder encodeObject:		self.gamePieces				forKey: NSStringFromSelector(@selector(gamePieces))];
	//[encoder encodeObject:		self.gamePiecesInGoal		forKey: NSStringFromSelector(@selector(gamePiecesInGoal))];
	
	[encoder encodeObject:		self.gamePieceData			forKey: NSStringFromSelector(@selector(gamePieceData))];
	[encoder encodeObject:		self.gamePieceIndex			forKey: NSStringFromSelector(@selector(gamePieceIndex))];
	[encoder encodeObject:		self.gamePieceInGoalIndex	forKey: NSStringFromSelector(@selector(gamePieceInGoalIndex))];

	[encoder encodeInt:			[self gameType]				forKey: NSStringFromSelector(@selector(gameType))];
	[encoder encodeBool:		[self isGameOver]			forKey: NSStringFromSelector(@selector(isGameOver))];
	[encoder encodeObject:		[self statisticsGame]		forKey: NSStringFromSelector(@selector(statisticsGame))];
	[encoder encodeObject:		self.gameLevel				forKey: NSStringFromSelector(@selector(gameLevel))];
	[encoder encodeObject:		[self gameLevelArchive]		forKey: NSStringFromSelector(@selector(gameLevelArchive))];
	[encoder encodeObject:		self.timer					forKey: NSStringFromSelector(@selector(timer))];
	[encoder encodeBool:		self.allowShuffle			forKey: NSStringFromSelector(@selector(allowShuffle))];
	[encoder encodeInt32: [self numberOfShakes]		forKey: NSStringFromSelector(@selector(numberOfShakes))];
	[encoder encodeBool:		[self gamePlayHasBegun]		forKey: NSStringFromSelector(@selector(gamePlayHasBegun))];
	[encoder encodeObject:		[self dictionaryPoints]		forKey: NSStringFromSelector(@selector(dictionaryPoints))];
	[encoder encodeCGRect:		[self gameRect]				forKey: NSStringFromSelector(@selector(gameRect))];
}

- (NSDictionary *)pointsDictionary {
	if (self.dictionaryPoints == nil) {
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource: @"points"
															   ofType: @"plist"];
		if (bundlePath != nil) {
			NSDictionary *nsd = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
			self.dictionaryPoints = nsd;
			nsd = nil;
		}
	}
	return self.dictionaryPoints;
}

#pragma mark -
#pragma mark Actions

- (void)pressedPauseButton {
	if (self.currentGameScreen != MUIGameScreenPause &&
		self.currentGameScreen == MUIGameScreenGameOn &&
		self.timer != nil &&
		self.timer.seconds > 0 && !self.timer.isPaused) {
		self.currentGameScreen = MUIGameScreenPause;
		[self.timer pause];
		self.allowShuffle = NO;
		[self.delegate game: self didPressPauseButton: nil];
	}
}

- (void)endLevel {
	//Disable all buttons
	[MNSUser CurrentUser].askToResume = NO;
//TODO: End background music here.
	//[self endAllSongs];
	[self setAllowShuffle: NO];
	
	__strong id <MTGameProtocol> delegate = self.delegate;
	[delegate game: self didDisableCheckButtonAnimated: true];
	[delegate game: self didDisableShuffleButtonAnimated: true];
	[delegate game: self didDisablePauseButtonAnimated: true];
	[delegate showControlScreenBackground: NO animated: YES];
	
	//Game over
	NSInteger totalNumberOfLevelsInGame = 50;
	BOOL go = ([self.gameLevel totalPoints] < self.gameLevel.goal) || [self.gameLevel levelNumberMinusOne] == totalNumberOfLevelsInGame;
	[self setGameOver: go];

	[self.timer setSeconds:0];
	[self.timer pause];
	[self removeAllTiles];

	[NSTimer scheduledTimerWithTimeInterval: 1.0
									 target: self
								   selector: @selector(timerRequestDisableAndRemoveAllTiles:)
								   userInfo: self
									repeats: NO];

	//Level was completeled successfully, so lets post an Achievement for finishing the level.
	[self checkForEndOfLevelAchievements];

	NSNumber *coinsToAward = [[NSNumber alloc] initWithInteger:0];
	NSNumber *coinsToAwardSilver = [[NSNumber alloc] initWithInteger:0];
	NSNumber *coinsToAwardGold = [[NSNumber alloc] initWithInteger:0];
	[self.gameLevel coinsForLevelChad:&coinsToAward silver:&coinsToAwardSilver gold:&coinsToAwardGold];

	//[[MNSUser CurrentUser] awardCoins: [coinsToAward integerValue]
	//                           ofType: MNSCoinTypeChad];
	//[[MNSUser CurrentUser] awardCoins: [coinsToAwardSilver integerValue]
	//                           ofType: MNSCoinTypeSilver];
	//[[MNSUser CurrentUser] awardCoins: [coinsToAwardGold integerValue]
	//                           ofType: MNSCoinTypeGold];
	
	[self.gameLevel setTotalTime: [self.timer secondsCounterForLevel]];
	[self.timer setSecondsCounterForLevel: 0];
	[[self gameLevelArchive] addObject:self.gameLevel];
	[[self statisticsGame] addNewStatistics:self.gameLevel];
	[self setCurrentGameScreen: [self isGameOver] ? MUIGameScreenGameOver : MUIGameScreenLevelStats];
	
	[delegate levelDidEnd: self];
	if ([self isGameOver]) {
		[self setCurrentGameScreen: MUIGameScreenGameOver];
	} else {
		WFLevelStatistics *newLevel = [[WFLevelStatistics alloc] initWithLevel: ([self.gameLevel levelNumberMinusOne] + 1)
																   andGameType: [self gameType]];
		[self setGameLevel: newLevel];
		newLevel = nil;
	}
	
	WFLevelStatistics *statistics = self.gameLevelArchive.lastObject;
	[[MNSUser CurrentUser] addEndOfLevelStatistics: statistics
									  withGameOver: [self isGameOver]];
	
	delegate = nil;
}

- (void)checkForEndOfLevelAchievements {
	if (!self.isGameOver) {
		switch (self.gameType) {
			case WordflickDebug:
			case Wordflick: {
				submitAchievementLevelCompleteWordflick(self.gameLevel.levelNumber);
				break;
			} case WordflickClassic: {
				submitAchievementLevelCompleteWordflickClassic(self.gameLevel.levelNumberMinusOne);
				break;
			} case WordflickFastBreak: {
				//Achievements Removed
				break;
			} case WordflickFreePlay: {
				//Achievements Removed
				break;
			} case WordflickJr: {
				//Achievements Removed
				break;
			} default: {
				break;
			}
		}
	}
}

- (void)playLevelSong {
#ifdef WORDNERD_BACKGROUND_MUSIC
	if ([MNSUser CurrentUser].desiresBackgroundMusic) {
		if ([MPMusicPlayerController systemMusicPlayer].playbackState != MPMusicPlaybackStatePlaying) {
			switch (self.gameLevel.levelNumberMinusOne % 3) {
				case 0:
					[self playSouthernSong];
					break;
				case 1:
					[self playBluesSong];
					break;
				case 2:
					[self playTechnoSong];
					break;
				//case 3:
				//    [self playMysterySong];
				//    break;
				default:
					[self playBluesSong];
					break;
			}
		}
	}
#endif
}

//Called to start the game and to start the next level.
- (void)startNextLevel {
	[self setGameOver:NO];
	[self playLevelSong];
	self.gamePlayHasBegun = YES;
	self.currentGameScreen = MUIGameScreenGameOn;
	self.timer.seconds = [self.gameLevel levelTime];
	self.numberOfShakes = [self.gameLevel initalNumberOfShuffles];
	self.allowShuffle = YES;
	[self.timer resume];
	[self.timer startTimer: self.timer.seconds];
	enableShuffleButton(self);
}

- (void)restartLevel {
	__strong id <MTGameProtocol> delegate = self.delegate;

	self.gameOver = NO;
	[self playLevelSong];
	self.gamePlayHasBegun = YES;
	[delegate updateControlScreen: self];
	self.timer.seconds = [self.gameLevel levelTime];
	self.allowShuffle = YES;
	[self.timer resume];
	[delegate game: self enablePauseButton: true];
	[delegate showControlScreenBackground: YES animated: YES];
	enableShuffleButton(self);
	[delegate game: self enableCheckButton: true];
	[delegate updateGameBoardBackground: self];
	[delegate updateControlScreen: self];
	delegate = nil;
}

- (void)pressedDismissPauseScreenButton {
	[self setCurrentGameScreen:MUIGameScreenGameOn];
	if (self.timer.isPaused) {
		[self.timer resume];
		self.allowShuffle = YES;
		[self.delegate game: self dismissPauseScreen: true];
	}
}

//Called when the user presses the check button
- (void)pressedCheckButton {
	__strong id <MTGameProtocol> delegate = self.delegate;

	[MNSAudio playButtonPress];
	
	[delegate game: self didDisableCheckButtonAnimated: true];
	switch (self.currentGameScreen) {
		case MUIGameScreenGameOn: {	//Check to see if the word is correct
			NSString *word = [[self wordInGameGoal] copy];
			if ([[DatabaseWords sharedInstance] validateWord: word]) {
				[MNSAudio playChimesPos];
				
				submitAchivementsForWordLength(word.length);
				[[MNSUser CurrentUser] addUsedWordStatistics:word];
				
				NSInteger points = pointsForWord(self, word);
				[self.gameLevel addPoints: points];
				[delegate updateControlScreen: self];

				MTWordValue *thisWord = [[MTWordValue alloc] initWithString: word
																 andInteger: points];
				NSString *pointsMessageText = [[NSString alloc] initWithFormat:NSLocalizedString(@" %@: +%ld points",
																								 @"Short Message"),
											   thisWord.kidFriendlyWord.capitalizedString, thisWord.points.integerValue];

				displayMessage(self, delegate, pointsMessageText, MNSMessageStandard);

				[self.gameLevel addWord: thisWord];
				[self wordCleanUp:YES];
				[delegate game: self didDisableShuffleButtonAnimated: YES];
				[NSTimer scheduledTimerWithTimeInterval: 0.2
												 target: self
											   selector: @selector(timerEnableShuffleButton:)
											   userInfo: self
												repeats: NO];
				thisWord = nil;
				pointsMessageText = nil;
				
			} else {
				NSString *notValidWord = NSLocalizedString(@"Not a word.", @"Short Message");
				displayMessage(self, delegate, notValidWord, MNSMessageStandard);
				notValidWord = nil;
				[MNSAudio playChimesNo];
				[delegate animatePlayFailed: self];
			}
			word = nil;
			break;
		}
		default:
			break;
	}
	[NSTimer scheduledTimerWithTimeInterval: 0.2
									 target: self
								   selector: @selector(timerEnableCheckButton:)
								   userInfo: self
									repeats: NO];
	delegate = nil;
}

//Called when user presses the shuffle button
- (void)pressedShuffleButton {
	if ([self currentGameScreen] == MUIGameScreenGameOn) {
		if (self.allowShuffle) {
			
			__strong id <MTGameProtocol> delegate = self.delegate;

			UIColor *highlight = [[UIColor alloc] initWithRed: 0.0f green: 0.0f
														 blue: 1.0f alpha: 0.5f];
			[delegate flashIndicatorsToColor: highlight
								 forDuration: 0.6];
			highlight = nil;
			
			[self setAllowShuffle:NO];
			[delegate game: self didDisableShuffleButtonAnimated: true];
			[NSTimer scheduledTimerWithTimeInterval: 0.9 target: self
										   selector: @selector(timerEnableShuffleButton:)
										   userInfo: self repeats: NO];

			[MNSAudio playButtonPress];

			BOOL makeSomeNoise = NO;
			@synchronized(self) {
				if (self.numberOfShakes > 0) {
					self.numberOfShakes--;
				} else {
					makeSomeNoise = YES;
				}
			}
			if (makeSomeNoise) {
				NSTimeInterval secs = -(10 + self.gameLevel.countFreeShakesUsed);
				secs = (secs >= -60) ? secs : -60;
				long points = -(100 + (100 * self.gameLevel.countFreeShakesUsed));
				points = (points >= -900)? points : -500;
				if (self.timer.seconds >= (5.0 + fabs(secs))) {
					[self.timer extendTimer:secs];
					[self.gameLevel addTime:secs];
					[self.gameLevel addPoints:points];
					[self setNumberOfShakes: 0];
					
					[delegate updateControlScreen: self];

					displayMessage(self,
								   delegate,
								   [NSString stringWithFormat: NSLocalizedString(@"Extra shuffle: %d seconds!",
																				 @"Displayed to user."), (int)secs],
								   MNSMessageRed);

					displayMessage(self,
								   delegate,
								   [NSString stringWithFormat: NSLocalizedString(@"Extra shuffle: %ld points!",
																				 @"Displayed to user."), points],
								   MNSMessageRed);

					[self removeAllTiles];
					[delegate game: self didPressShuffleButton: nil];
					
					[self.gameLevel setCountFreeShakesUsed: ([self.gameLevel countFreeShakesUsed] + 1)];
					[MNSAudio playChimesNeg];
				} else {
					NSString *extraShuffleTimeMessage = [[NSString alloc] initWithFormat: NSLocalizedString(@"Extra shuffle requires %d seconds!",
																											@"Short Message"), (5 + (int)fabs(secs))];
					MNSMessage *message = [[MNSMessage alloc] initWithString: extraShuffleTimeMessage
																	 andType: MNSMessageYellow];
					[delegate game: self displayMessage: message];
					message = nil;
					extraShuffleTimeMessage = nil;
				}
			} else {
				[delegate updateControlScreen: self];
				
				[self removeAllTiles];
				[delegate game: self didPressShuffleButton: nil];
				
			}
			delegate = nil;
		}
	}
}

//Called when users wants to abort the level.
- (void)pressedAbortButton {
	[MNSAudio playButtonPress];
	[self endLevel];
}

#pragma mark - Helpers

- (NSString *)wordInGameGoal {
	NSString *result = @"";
	for (NSNumber *i in self.gamePieceInGoalIndex) {
		result = [result stringByAppendingString: self.gamePieceData[i].characterValue];
	}
	return result;
}

#pragma mark - Timer Delegate

- (void)setTime:(long long)t {
	if (self.currentGameScreen == MUIGameScreenGameOn) {
		if (t <= 10) {
			if (t >= 6) {
				[MNSAudio playTimeTickClock];
			} else {
				[MNSAudio playTimeTickHeartbeat];
			}
		}
	}
	[self.delegate updateControlScreen: self];
}

- (void)timeIsUp {
	[self endLevel];
}

//Called when the user is finished looking at the post level stats.

- (void)postLevelIsDone {
	__strong id <MTGameProtocol> delegate = self.delegate;

	[self setCurrentGameScreen:MUIGameScreenPreLevel];

	if ([self isGameOver]) {

		self.currentGameScreen = MUIGameScreenGameOver;
		[delegate gameDidEnd: self];

		//[self.delegate enableCheckButton: self];
		[MNSGame addScoreForUser:[MNSUser CurrentUser].idstring onGame:self];
		[MNSGame addBestWordOfGame: self.statisticsGame.topWord
						   forUser: [[MNSUser CurrentUser] idstring]
							onGame: self];

		self.statisticsGame.topWord = [[MTWordValue alloc] init];

	} else {
		[delegate game: self showPreLevelScreen: nil];
	}
	delegate = nil;
}

#pragma mark - Private

- (void)wordCleanUp:(BOOL)checkForRewards {
	__strong id <MTGameProtocol> delegate = self.delegate;
	
	MNSTileType bestTileType = MNSTileExtraNormal;
	int ctrExtraPoints = 0, ctrExtraTime = 0, ctrExtraShuffle = 0, ctrExtraSpecial = 0, timeGiven = 0, pointsGiven = 0;

	for (NSNumber *i in self.gamePieceInGoalIndex) {
		WFTileData *gamePiece = self.gamePieceData[i];
		checkForBonusMultipliers(self, &bestTileType, checkForRewards, &ctrExtraPoints, &ctrExtraShuffle, &ctrExtraSpecial, &ctrExtraTime, delegate, &pointsGiven, gamePiece, &timeGiven);
		[delegate game: self removeGameTile: gamePiece animated: true];
		[self.gamePieceData removeObjectForKey:i];
	}
	
	[self bonusForUsingMultipleSpecialTiles:ctrExtraTime
								 pointTiles:ctrExtraPoints
							   shuffleTiles:ctrExtraShuffle
								 extraTiles:ctrExtraSpecial
								extraPoints:pointsGiven
								  extraTime:timeGiven];
	
	if (checkForRewards) {
		switch (bestTileType) {	//Play positive sound
			case MNSTileExtraNormal:
				[delegate animatePlaySucceeded: self withBonusModifier: MNSTileExtraNormal];
				break;
			case MNSTileExtraPoints:
				[delegate animatePlaySucceeded: self withBonusModifier: MNSTileExtraPoints];
				[MNSAudio playBonusCoins];
				//TODO: Using audio props, background music used to change when these were played.
				//self.audioPropsLevel4 = YES;
				break;
			case MNSTileExtraShuffle:
				[delegate animatePlaySucceeded: self withBonusModifier: MNSTileExtraShuffle];
				[MNSAudio playBonusSaucer];
				//TODO: Using audio props, background music used to change when these were played.
				//self.audioPropsLevel3 = YES;
				break;
			case MNSTileExtraSpecial:
				[delegate animatePlaySucceeded: self withBonusModifier: MNSTileExtraSpecial];
				[MNSAudio playBonusThunder];
				//TODO: Using audio props, background music used to change when these were played.
				//self.audioPropsLevel2 = YES;
				break;
			case MNSTileExtraTime:
				[delegate animatePlaySucceeded: self withBonusModifier: MNSTileExtraTime];
				[MNSAudio playBonusLife];
				//TODO: Using audio props, background music used to change when these were played.
				//self.audioPropsLevel1 = YES;
				break;
			default:
				break;
		}
	}

	[self.gamePieceInGoalIndex removeAllObjects];

	//Check to see if there are any game pieces left.
	//  If they cleared the board, give them a bonus
	if (checkForRewards && self.gamePieceData.count <= 0) {	//The [[MNSUser CurrentUser].game decrementNumberOfShakes] calls wordCleanUp,
		//	so checkForRewards prevents recurssion
		//To do, play level cleared sound...
		[self.gameLevel setCountClearedBoard:[self.gameLevel countClearedBoard] + 1];
		long bonusPoints = 100 * [self.gameLevel countClearedBoard];
		[self.gameLevel addPointsFromBonusTiles:bonusPoints];
		//NSString *clearedStringFormat = NSLocalizedString(@"Cleared screen %d times!",
		//												  @"Must be a short message so it can fit in the space.  You can use abbreviations.  Counts the number of times they cleared the screen.");
		NSString *clearedStringMessage = [[NSString alloc] initWithFormat: NSLocalizedString(@"Cleared screen %ld times!",
																							 @"Short Message"),
										  self.gameLevel.countClearedBoard];
		
		MNSMessage *message = [[MNSMessage alloc] initWithString: clearedStringMessage
														 andType: MNSMessageYellow];
		[delegate game: self displayMessage: message];
		message = nil;
		clearedStringMessage = nil;
		
		clearedStringMessage = [[NSString alloc] initWithFormat: NSLocalizedString(@"Cleared the board! +%ld points!",
																				   @"Short Message"),
								bonusPoints];
		MNSMessage *message2 = [[MNSMessage alloc] initWithString: clearedStringMessage
														  andType: MNSMessageYellow];
		[delegate game: self displayMessage: message2];
		message2 = nil;
		
		clearedStringMessage = nil;
		
		[delegate updateControlScreen: self];
		
		if (self.gameLevel.countClearedBoard % 5 == 0) {
			long extraShuffles = ceill((self.gameLevel.countClearedBoard / 5) + 2);
			for (int i=0; i<extraShuffles; i++) {
				[[MNSUser CurrentUser].game incrementNumberOfShakes];
			}
			
			clearedStringMessage = [[NSString alloc] initWithFormat: NSLocalizedString(@"%ld Extra Shuffles!",
																					   @"Short Message"),
									extraShuffles];
			MNSMessage *message3 = [[MNSMessage alloc] initWithString: clearedStringMessage
															  andType: MNSMessageRed];
			[delegate game: self displayMessage: message3];
			message3 = nil;
			clearedStringMessage = nil;
		}
		[delegate updateControlScreen: self];
		[self pressedShuffleButton];
	}
	delegate = nil;
}

- (void)bonusForUsingMultipleSpecialTiles: (NSInteger)timeTileCount
							   pointTiles: (NSInteger)pointTileCount
							 shuffleTiles: (NSInteger)shuffleTileCount
							   extraTiles: (NSInteger)extraTileCount
							  extraPoints: (NSInteger)extraPointsCount
								extraTime: (NSInteger)extraTimeCount {
	NSInteger totalSpecialTileCount = timeTileCount + pointTileCount + shuffleTileCount + extraTileCount;
	if (totalSpecialTileCount > 1) {
		__strong id <MTGameProtocol> delegate = self.delegate;
		BOOL gotBonus = NO;
		if (timeTileCount > 1) {
			int extraSeconds = ceil(extraTimeCount * timeTileCount * 1.3);
			[self.timer extendTimer:extraSeconds];
			[self.gameLevel addTimeExtra:extraSeconds];
			NSString *messageText = [[NSString alloc] initWithFormat: NSLocalizedString(@"Timer Multiplier: +%d seconds",
																						@"Short Message"), extraSeconds];
			MNSMessage *message = [[MNSMessage alloc] initWithString: messageText andType: MNSMessageYellow];
			[delegate game: self displayMessage: message];
			gotBonus = YES;
			messageText = nil;
			message = nil;
		}
		if (pointTileCount > 1) {
			long extraPointsMultiplier = ceill((extraPointsCount * pointTileCount) / 2);
			[self.gameLevel addPointsFromBonusTiles:extraPointsMultiplier];
			NSString *pointsMessage = [[NSString alloc] initWithFormat:NSLocalizedString(@"Points Multiplier: +%ld bonus points",
																						 @"Short Message"), extraPointsMultiplier];
			MNSMessage *message = [[MNSMessage alloc] initWithString: pointsMessage andType: MNSMessageYellow];
			[delegate game: self displayMessage: message];
			gotBonus = YES;
			message = nil;
			pointsMessage = nil;
		}
		if (shuffleTileCount > 1) {
			long extraShuffles = ceill(shuffleTileCount / 2);
			for (NSInteger i=0; i<extraShuffles; i++) {
				[self incrementNumberOfShakes];
			}
			NSString *shuffleString = [[NSString alloc] initWithFormat:NSLocalizedString(@"Shuffle Multiplier: +%ld shuffles",
																						 @"Short Message"), extraShuffles];
			MNSMessage *message = [[MNSMessage alloc] initWithString: shuffleString andType: MNSMessageYellow];
			[delegate game: self displayMessage: message];
			gotBonus = YES;
			message = nil;
			shuffleString = nil;
		}
		if (!gotBonus) {
			long pointsBonus = ceill(totalSpecialTileCount * 2);
			[self.gameLevel addPointsFromBonusTiles:pointsBonus];
			NSString *bonusString = [[NSString alloc] initWithFormat: NSLocalizedString(@"Bonus: +%ld bonus points",
																						@"Short Message"), pointsBonus];
			MNSMessage *message = [[MNSMessage alloc] initWithString: bonusString andType: MNSMessageYellow];
			[delegate game: self displayMessage: message];
			message = nil;
			bonusString = nil;
		}
		[delegate updateControlScreen: self];
		delegate = nil;
	}
}

- (NSInteger)bonusGivePointsMultiplier:(NSString *)letter {
	__strong id <MTGameProtocol> delegate = self.delegate;

	long points = ceill((pointsForLetter(self, letter) + 1.0) * 2.3);
	[self.gameLevel addPointsFromBonusTiles:points];
	[delegate updateControlScreen: self];
	NSString *text = [[NSString alloc] initWithFormat:NSLocalizedString(@"Letter %@: +%01ld bonus points",
																		@"Short Message"), letter, points];
	MNSMessage *message = [[MNSMessage alloc] initWithString: text andType: MNSMessageGreen];
	[delegate game: self displayMessage: message];
	message = nil;
	text = nil;
	delegate = nil;
	return points;
}

- (NSInteger)bonusExtendTimer:(NSString *)letter {
	__strong id <MTGameProtocol> delegate = self.delegate;

	int time = ceil(((pointsForLetter(self, letter) + 1.0) * 1.6));
	
	[self.timer extendTimer:time];
	[self.gameLevel addTimeExtra:time];
	[delegate updateControlScreen: self];
	NSString *messagePart1Format = NSLocalizedString(@"Letter %@", @"Letter %@");
	NSString *messagePart2Format = NSLocalizedString(@"Timer: +%ld seconds",
													 @"Must be a short message so it can fit in the space.  You can use abbreviations.  A message that tells the user they got a number of bonus seconds, denoted as %d, added to the game clock.");
	NSString *messagePart1 = [[NSString alloc] initWithFormat:messagePart1Format, letter];
	NSString *messagePart2 = [[NSString alloc] initWithFormat:messagePart2Format, time];
	NSString *displayMessage = [[NSString alloc] initWithFormat:@"%@ - %@", messagePart1, messagePart2];
	MNSMessage *message = [[MNSMessage alloc] initWithString: displayMessage
													 andType: MNSMessagePurple];
	[delegate game: self displayMessage: message];
	message = nil;
	displayMessage = nil;
	messagePart2 = nil;
	messagePart1 = nil;
	return time;
}

- (void)bonusGiveExtraShake {
	__strong id <MTGameProtocol> delegate = self.delegate;
	[self incrementNumberOfShakes];
	[delegate updateControlScreen: self];
	NSString *text = NSLocalizedString(@"Extra shuffle",
									   @"Must be a short message so it can fit in the space.  You can use abbreviations.  A message that tells the user they got one extra shuffle of the game tiles.");
	MNSMessage *message = [[MNSMessage alloc] initWithString: text
													 andType: MNSMessageRed];
	[delegate game: self displayMessage:message];
	message = nil;
}

- (void)incrementNumberOfShakes {
	@synchronized(self) {
		self.numberOfShakes++;
	}
}

- (void)removeAllTiles {
	
	[self wordCleanUp: NO];

	__strong id <MTGameProtocol> delegate = self.delegate;
	[delegate game: self removeAllTilesFromScreen: true];
		
	if (self.gamePieceData.count > 0) {
		[NSTimer scheduledTimerWithTimeInterval: 0.1
										 target: self
									   selector: @selector(timerPlayAudioShuffle:)
									   userInfo: nil
										repeats: NO];
	}
	[self.gamePieceData removeAllObjects];
	[self.gamePieceIndex removeAllObjects];
}

- (long long)level { return self.gameLevelArchive.lastObject.levelNumber; }

- (NSMutableArray <MTWordValue *> *)wordsAndPoints {
	NSMutableArray <MTWordValue *> *wordsAndPoints = nil;
	if (self.gameOver) {
		wordsAndPoints = [self.statisticsGame.wordsAndPoints mutableCopy];
	} else {
		wordsAndPoints = [self.gameLevelArchive.lastObject.wordsAndPoints mutableCopy];
	}
	if (wordsAndPoints.count > 0) {
		[wordsAndPoints sortUsingComparator:^NSComparisonResult(MTWordValue *val1, MTWordValue *val2) {
			if (val1.points.longValue > val2.points.longValue) return NSOrderedAscending;
			else if (val1.points.longValue < val2.points.longValue) return NSOrderedDescending;
			else return NSOrderedSame;
		}];

		MTWordValue *wordAndPoints = [wordsAndPoints objectAtIndex:0];
		if (self.statisticsGame.topWord.points.integerValue < wordAndPoints.points.integerValue) {
			[self.statisticsGame setTopWord:wordAndPoints];
		}
	} else {
		MTWordValue *tmpWord = [[MTWordValue alloc] init];
		[wordsAndPoints addObject:tmpWord];
		tmpWord = nil;
	}
	return wordsAndPoints;
}

- (NSString *)displayName { return @"Wordflick"; }

- (NSString *)levelName {
	return [NSString stringWithFormat:
			NSLocalizedString(@"Level %ld", @"Level %d"),
			(long)self.level];
}

- (NSUInteger)levelNumber { return self.gameLevel.levelNumber; }

#pragma mark -
#pragma mark Score Related Static Functions

+ (void)addBestWordOfGame:(MTWordValue *)word forUser:(NSString *)user onGame:(MNSGame *)game {
#warning Missing feature.  Used to be able to save the best word to game center.
}

+ (NSInteger)costForGame:(MNSGameType)chosenGameType andLevel:(NSInteger)level {
	switch (chosenGameType) {
		case WordflickFreePlay:
			return 0;
		case Wordflick:
			return level < 10 ? 0 : 1;
		case WordflickClassic:
		case WordflickDebug:
		case WordflickJr:
			return level < 10 ? 0 : 1;
		case WordflickFastBreak:
			return level < 10 ? 0 : 1;
		default:
			return 1;
	}
}

+ (void)postScoreForUser:(NSString *)user onGame:(MNSGame *)game {
	//NSLog(@"\t%s", __PRETTY_FUNCTION__);

	NSString * _Nonnull scoreListID = game.gameKitHighScoreLeaderboardID;
	NSString * _Nonnull scoreArrayID = game.gameKitUnsavedScoreArrayIdentifier;

	if (!scoreListID || !scoreArrayID) return;

	// First Time Setup of Standard User Defaults
	if ([[NSUserDefaults standardUserDefaults] objectForKey: scoreArrayID] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject: [NSArray new]
												  forKey: scoreArrayID];
	}
	NSArray <NSNumber *> *scoreArrayFromUserDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:scoreArrayID];
	
	NSNumber *totalPoints = [[NSNumber alloc] initWithLongLong: game.statisticsGame.totalPoints];

	NSMutableArray <NSNumber *> *unsavedScores = [[NSMutableArray alloc] initWithArray:scoreArrayFromUserDefaults];
	[unsavedScores addObject:totalPoints];

	scoreArrayFromUserDefaults = nil;

	NSArray <NSNumber *> *unsavedScoresCopy = [[NSArray alloc] initWithArray:unsavedScores];
	[unsavedScores removeAllObjects];

	[[NSUserDefaults standardUserDefaults] setObject:unsavedScores forKey:scoreArrayID];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if (unsavedScoresCopy.count > 0) {
		NSMutableArray <GKScore *> *scores = [[NSMutableArray alloc] initWithCapacity: unsavedScoresCopy.count];

		for (NSNumber *unsavedScore in unsavedScoresCopy) {
			GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:scoreListID];
			if (unsavedScore.integerValue > 0) {
				score.value = unsavedScore.integerValue;
				[scores addObject: score];
			}
			score = nil;
		}

		if (scores.count > 0) {
			[GKScore reportScores:scores withCompletionHandler:^(NSError * _Nullable error) {
				if (error) {
					[[NSUserDefaults standardUserDefaults] setObject:unsavedScoresCopy forKey:scoreArrayID];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}];
		}
		scores = nil;
	}

	unsavedScoresCopy = nil;
	totalPoints = nil;
	unsavedScores = nil;
}

+ (BOOL)addScoreForUser:(NSString *)user onGame:(MNSGame *)game {
	BOOL isUsernameInDatabase = [MNSUser isUserInDatabase:user];
	if (isUsernameInDatabase) {
		char *sql2 = sqlite3_mprintf("INSERT INTO scores (username, game, score) "
									 "VALUES ('%q', %d, %lld)",
									 user.UTF8String,
									 game.gameType,
									 game.statisticsGame.totalPoints);
		char *zErr;
		sqlite3_exec([[DatabaseUsers sharedInstance] database]->database, sql2, nil, nil, &zErr);
		sqlite3_free(sql2);
	}
	[self postScoreForUser:user onGame:game];
	return (isUsernameInDatabase);
}

+ (void)playTouchesBeganSound:(MNSTileType)tileType {
	switch (tileType) {
		case MNSTileExtraNormal:
			switch (arc4random_uniform(2)) {
				case 0:
					[MNSAudio playTileHitWood1];
					break;
				case 1:
					[MNSAudio playTileHitWood2];
					break;
				default:
					break;
			}
			break;
		case MNSTileExtraPoints:
			switch (arc4random_uniform(2)) {
				case 0:
					[MNSAudio playTileHit1];
					break;
				case 1:
					[MNSAudio playTileHit2];
					break;
				default:
					break;
			}
			break;
		case MNSTileExtraShuffle:
			switch (arc4random_uniform(2)) {
				case 0:
					[MNSAudio playTileHit1];
					break;
				case 1:
					[MNSAudio playTileHit2];
					break;
				default:
					break;
			}
			break;
		case MNSTileExtraSpecial:
			[MNSAudio playTileHit3];
			break;
		case MNSTileExtraTime:
			switch (arc4random_uniform(2)) {
				case 0:
					[MNSAudio playTileHit1];
					break;
				case 1:
					[MNSAudio playTileHit2];
					break;
				default:
					break;
			}
			break;
		default:
			[MNSAudio playTileHitWood1];
			break;
	}
}

#pragma mark -
#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)success {
	if (success) {
		if (![self isGameOver]) {
			[self playLevelSong];
		}
	}
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error { }

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)p { }

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)p { }

#pragma mark -
#pragma mark Identifiers

- (NSString *)gameKitHighScoreLeaderboardID {
	switch (_gameType) {
		case Wordflick:
			return @"grp.com.everydayapps.game.wordflick.highscores";
			break;
		default:
			return nil;
			break;
	}
}

- (NSString *)gameKitUnsavedScoreArrayIdentifier {
	switch (_gameType) {
		case Wordflick:
			return @"wordflickUnsavedHighScoresArray";
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark -
#pragma mark Timers

#pragma mark Time Properties

- (NSUInteger)levelDuration { return self.gameLevel.levelTime; }
- (NSUInteger)remainingTime { return self.timer.seconds; }
- (BOOL)isPaused { return self.timer.isPaused; }

- (NSString *)timerDisplay {
	long seconds = self.timer.seconds;
	return [NSString stringWithFormat:@"%ld:%02ld", (seconds / 60), labs(seconds % 60)];
}
- (NSString *)totalPointsDisplay {
	return [NSString stringWithFormat: @"%ld", self.gameLevel.totalPoints];
}
- (NSString *)shufflesRemainingDisplay {
	return [NSString stringWithFormat: @"%d", self.numberOfShakes];
}
- (NSString *)goalPointsDisplay {
	return [NSString stringWithFormat: @"%ld", self.gameLevel.goal];
}

#pragma mark Timer Handlers

- (void)timerPlayAudioShuffle:(NSTimer *)timer {
	[MNSAudio playShuffle];
}

- (void)timerEnableShuffleButton:(NSTimer *)timer {
	//game.allowShuffle = YES;
	//[game.delegate game: game enableShuffleButton: true];
	enableShuffleButton(self);
}

- (void)timerEnableCheckButton:(NSTimer *)timer {
	[self.delegate game: self enableCheckButton: true];
}

- (void)timerRequestDisableAndRemoveAllTiles:(NSTimer *)timer {
	[self removeAllTiles];
	__strong id <MTGameProtocol> delegate = self.delegate;
	[delegate game: self didDisableCheckButtonAnimated: false];
	[delegate game: self didDisableShuffleButtonAnimated: false];
	[delegate game: self didDisablePauseButtonAnimated: false];
}

#pragma mark -
#pragma mark Unused

#pragma mark Unused Static

+ (NSArray <MTWordValue *> *)getScoresForGame:(NSInteger)game __attribute__((unused)) {
	NSMutableArray <MTWordValue *> *scoresForGame = [[NSMutableArray alloc] init];
	NSString *queryStart = @"SELECT score, username FROM scores WHERE game = %q "
						   @"ORDER BY score DESC LIMIT 100";
	NSString *gameType = [[NSString alloc] initWithFormat:@"%ld", (long)game];
	sqlite3_stmt *statement;
	char *sql = sqlite3_mprintf(queryStart.UTF8String, gameType.UTF8String);
	gameType = nil;
	
	if (sqlite3_prepare_v2([[DatabaseUsers sharedInstance] database]->database, sql, -1, &statement, NULL) == SQLITE_OK) {
		MTWordValue *stringNumberWrapper = nil;
		while (sqlite3_step(statement) == SQLITE_ROW) {
			stringNumberWrapper = [[MTWordValue alloc] initWithCString: (char *)sqlite3_column_text(statement, 1)
															andInteger: sqlite3_column_int(statement, 0)];
			[scoresForGame addObject:stringNumberWrapper];
			stringNumberWrapper = nil;
		}
		stringNumberWrapper = nil;
	}
	sqlite3_finalize(statement);
	sqlite3_free(sql);
	return scoresForGame;
}

+ (NSTimeInterval)standardTick { return [MNSTimer standardTick]; }

#pragma mark Unused Properties

- (CGPoint)centerOfTile:(NSUInteger)position
			   withSize:(CGSize)tileSize
				 inRect:(CGRect)rect __attribute__((unused)) {
	char numberOfRows = 4, numberOfColumns = 5;
	return CGPointCenterOfTileInsideRect(tileSize, rect, position / numberOfColumns,
										 numberOfRows, position % numberOfColumns, numberOfColumns,
										 CGSizeZero.width, CGSizeZero.height);
}

@end
