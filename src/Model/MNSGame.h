//
//  MNSGame.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/24/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MNSGame_h
#define MNSGame_h

#ifndef WF_TILE_COUNT
#define WF_TILE_COUNT	20
#endif

#import <UIKit/UIKit.h>
#import "MTGameProtocol.h"
#import "MTTimerProtocol.h"
#import "MTGameType.h"
#import "MTGameScreen.h"

@class MNSGame, WFLevelStatistics, WFTileData, WFGameStatistics, WFTileView, WFGameView,
	   MTWordValue, MNSTimer;

@interface MNSGame : NSObject
	<NSCoding, MTTimerDelegate>

	+ (void)playTouchesBeganSound:(MNSTileType)tileType;

	@property (nonatomic, weak) id <MTGameProtocol> delegate;


@property (nonatomic, assign) MUIGameScreen currentGameScreen;

@property (nonatomic, assign) MNSGameType gameType;
@property (nonatomic, assign, getter=isGameOver) BOOL gameOver;

@property (nonatomic, assign) BOOL allowShuffle;
@property (nonatomic, readonly, assign) int32_t numberOfShakes;
@property (nonatomic, readonly, assign) BOOL gamePlayHasBegun;

@property (readonly) NSUInteger levelNumber;
@property (readonly) NSUInteger levelDuration;
@property (readonly) NSUInteger remainingTime;
@property (readonly) BOOL isPaused;

@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy, readonly) NSString *gameKitHighScoreLeaderboardID;
@property (nonatomic, copy, readonly) NSString *gameKitUnsavedScoreArrayIdentifier;
@property (nonatomic, copy, readonly) NSString *gameKitUserOrDefaultIdentifier;
@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, copy, readonly) NSString *levelName;

@property (readonly, nonatomic, strong) NSMutableDictionary <NSNumber *, WFTileData *> *gamePieceData;
@property (readonly, nonatomic, strong) NSMutableArray <NSNumber *> *gamePieceIndex;
@property (readonly, nonatomic, strong) NSMutableOrderedSet <NSNumber *> *gamePieceInGoalIndex;

@property (nonatomic, strong) NSMutableArray <WFLevelStatistics *> *gameLevelArchive;
@property (nonatomic, strong) WFGameStatistics *statisticsGame;
@property (nonatomic, strong) WFLevelStatistics *gameLevel;
@property (nonatomic, strong) MNSTimer *timer;

- (instancetype)initWithType:(MNSGameType)type
					  userID:(NSString *)gameKitUserOrDefaultIdentifier
			andStartingLevel:(long)l;

+ (NSInteger)costForGame:(MNSGameType)chosenGameType andLevel:(NSInteger)level;
+ (NSTimeInterval)standardTick;

- (void)restartLevel;
- (void)postLevelIsDone;
- (void)startNextLevel;

- (void)pressedCheckButton;
- (void)pressedShuffleButton;
- (void)pressedDismissPauseScreenButton;
- (void)pressedAbortButton;
- (void)pressedPauseButton;

- (void)incrementNumberOfShakes;
- (void)removeAllTiles;

- (void)bonusGiveExtraShake;
- (NSInteger)bonusGivePointsMultiplier:(NSString *)letter;
- (NSInteger)bonusExtendTimer:(NSString *)letter;

- (long long)level;

- (NSMutableArray <MTWordValue *> *)wordsAndPoints;		//Sorted wordsAndPoints for level, or if game is over, for the whole game.
- (NSDictionary *)pointsDictionary;

- (void)playLevelSong;

- (NSString *)timerDisplay;
- (NSString *)totalPointsDisplay;
- (NSString *)shufflesRemainingDisplay;
- (NSString *)goalPointsDisplay;

@end

#endif
