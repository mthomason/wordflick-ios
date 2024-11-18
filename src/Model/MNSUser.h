//
//  MNSUser.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/23/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MNSUser_h
#define MNSUser_h

#import "MTGameType.h"
#import "MTGameLevel.h"

typedef NS_ENUM(short, MTDominantHand) {
	MTDominantHandUnknown = 0,
	MTDominantHandLeft = 1,
	MTDominantHandRight = 2
};

@class MNSGame, WFStatisticsBase, WFUserStatistics;

@interface MNSUser : NSObject <NSCoding>

	@property (nonatomic, assign) MNSUserGameLevel userGameLevel;
	@property (nonatomic, assign) NSInteger age;
	@property (nonatomic, assign) NSInteger topLevelAttained;
	@property (nonatomic, assign) BOOL contactUser;
	@property (nonatomic, assign) BOOL submitHighScores;
	@property (nonatomic, copy)   NSString *emailAddress;
	@property (nonatomic, retain) MNSGame *game;
	@property (nonatomic, retain) WFUserStatistics *statisticsUser;
	@property (readonly,  copy)   NSString *idstring;
	@property (readwrite, assign) BOOL askToResume;
	@property (readonly,  retain) NSDictionary *restartData;			// Can be null
	@property (readonly)          BOOL firstTimePlaying;

	@property (readwrite, nonatomic, assign) BOOL desiresSoundEffects;
	@property (readwrite, nonatomic, assign) BOOL desiresBackgroundMusic;
	@property (readwrite, nonatomic, assign) BOOL desiresStylizedFonts;
	@property (readwrite, nonatomic, assign) double desiredVolume;
	@property (readwrite, nonatomic, assign) MTDominantHand dominateHand;
	@property (readwrite, nonatomic, assign) unsigned long highestLevelUnlocked;

	+ (MNSUser *)CurrentUser;
	+ (void)MakeCurrentUserDefaultUser;
	+ (void)MakeCurrentUserGameKitUser;

	- (instancetype)initWithGameKitId:(NSString *)gameKitID;

	- (void)loadStoredAchievements;
	- (void)submitAchievement:(NSString *)identifier;
	- (void)submitAchievement:(NSString *)identifier allowResubmit:(BOOL)allowResubmit;
	- (void)resetAchievements;

	- (void)addEndOfLevelStatistics:(WFStatisticsBase *)statistics withGameOver:(BOOL)isGameOver;
	- (void)addUsedWordStatistics:(NSString *)word;  //Call this function to log the use of a word.
	- (void)saveYourGame;

	+ (NSString *)displayUsername;
	+ (void)setDefaultUserWithString:(NSString *)user;
	+ (NSUInteger)numberOfUsers;
	+ (BOOL)isUserInDatabase:(NSString *)user;

@end

#endif
