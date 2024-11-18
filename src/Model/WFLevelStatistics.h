//
//  MTLevelStatistics.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MTLevelStatistics_h
#define MTLevelStatistics_h

#import "WFStatisticsBase.h"

@interface WFLevelStatistics : WFStatisticsBase <NSCoding>

@property (nonatomic, retain) NSMutableArray <NSString *> *tweetableMessages;
@property (nonatomic, readonly) long goal;
@property (nonatomic, readonly) long levelNumber;

@property (nonatomic, copy, readonly) NSString *levelNumberDisplay;
@property (nonatomic, copy, readonly) NSString *levelGoalDisplay;
@property (nonatomic, copy, readonly) NSString *levelTimeDetailDisplay;
@property (nonatomic, copy, readonly) NSString *levelShuffleDetailDisplay;

- (instancetype)init;
- (instancetype)initWithLevel:(long)l andGameType:(MNSGameType)t;
- (int32_t)initalNumberOfShuffles;
- (void)reset;
- (long)levelTime;
- (UIColor *)backgroundColor;

- (void)coinsForLevelChad:(NSNumber * __strong *)chadCoins
				   silver:(NSNumber * __strong *)silverCoins
					 gold:(NSNumber * __strong *)goldCoins;

- (void)addPoints:(long)points;
- (void)addTime:(NSInteger)time;
- (void)addPointsFromBonusTiles:(long)points;
- (void)addTimeExtra:(NSInteger)time;
- (void)addBonusTileSeenShuffle:(NSInteger)i;
- (void)addBonusTileSeenPoints:(NSInteger)i;
- (void)addBonusTileSeenTimer:(NSInteger)i;
- (void)addBonusTileSeenSpecial:(NSInteger)i;
- (void)addBonusTileUsedShuffle:(NSInteger)i;
- (void)addBonusTileUsedPoints:(NSInteger)i;
- (void)addBonusTileUsedTimer:(NSInteger)i;
- (void)addBonusTileUsedSpecial:(NSInteger)i;
- (void)addBonusTileUsedSpecialShuffle:(NSInteger)i __unused;
- (void)addFreeShakesUsed:(NSInteger)i __unused;
- (void)addClearedBoard:(NSInteger)i __unused;

@end

#endif
