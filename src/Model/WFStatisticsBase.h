//
//  MTStatisticsBase.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MTStatisticsBase_h
#define MTStatisticsBase_h

#import "MTGameType.h"

@class MTWordValue;

@interface WFStatisticsBase : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray <MTWordValue *> *wordsAndPoints;
@property (nonatomic, strong) MTWordValue *topWord;
@property (readonly,  copy)   NSString *totalPointsValue;

@property (nonatomic, assign) long totalPoints;
@property (nonatomic, assign) long totalPointsFromBonusTiles;
@property (nonatomic, assign) long totalTime;
@property (nonatomic, assign) long totalTimeExtra;
@property (nonatomic, assign) long countBonusTileSeenShuffle;
@property (nonatomic, assign) long countBonusTileSeenPoints;
@property (nonatomic, assign) long countBonusTileSeenTimer;
@property (nonatomic, assign) long countBonusTileSeenSpecial;
@property (nonatomic, assign) long countBonusTileSeenSpecialShuffle;
@property (nonatomic, assign) long countBonusTileUsedShuffle;
@property (nonatomic, assign) long countBonusTileUsedPoints;
@property (nonatomic, assign) long countBonusTileUsedTimer;
@property (nonatomic, assign) long countBonusTileUsedSpecial;
@property (nonatomic, assign) long countBonusTileUsedSpecialShuffle;
@property (nonatomic, assign) long countFreeShakesUsed;
@property (nonatomic, assign) long countClearedBoard;

@property (nonatomic, assign) long levelNumberMinusOne;
@property (nonatomic, assign) int numberOfShakes;
@property (nonatomic, assign) MNSGameType type;

- (void)reset;
- (void)addNewStatistics:(WFStatisticsBase *)statistics;
- (void)addWord:(MTWordValue *)word;

@end

#endif
