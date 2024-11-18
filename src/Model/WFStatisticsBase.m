//
//  MTStatisticsBase.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "WFStatisticsBase.h"
#import "MTWordValue.h"

@implementation WFStatisticsBase


- (instancetype)init {
    if (self = [super init]) {
        _topWord = [[MTWordValue alloc] init];
        _wordsAndPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.wordsAndPoints =                    [decoder decodeObjectForKey:  NSStringFromSelector(@selector(wordsAndPoints))];
		self.topWord =                           [decoder decodeObjectForKey:  NSStringFromSelector(@selector(topWord))];
		self.totalPoints =                       [decoder decodeIntegerForKey: NSStringFromSelector(@selector(totalPoints))];
		self.totalPointsFromBonusTiles =         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(totalPointsFromBonusTiles))];
		self.totalTime =                         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(totalTime))];
		self.totalTimeExtra =                    [decoder decodeIntegerForKey: NSStringFromSelector(@selector(totalTimeExtra))];
		self.countBonusTileSeenShuffle =         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileSeenShuffle))];
		self.countBonusTileSeenPoints =          [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileSeenPoints))];
		self.countBonusTileSeenTimer =           [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileSeenTimer))];
		self.countBonusTileSeenSpecial =         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileSeenSpecial))];
		self.countBonusTileSeenSpecialShuffle =  [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileSeenSpecialShuffle))];
		self.countBonusTileUsedShuffle =         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileUsedShuffle))];
		self.countBonusTileUsedPoints =          [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileUsedPoints))];
		self.countBonusTileUsedTimer =           [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileUsedTimer))];
		self.countBonusTileUsedSpecial =         [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileUsedSpecial))];
		self.countBonusTileUsedSpecialShuffle =  [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countBonusTileUsedSpecialShuffle))];
		self.countFreeShakesUsed =               [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countFreeShakesUsed))];
		self.countClearedBoard =                 [decoder decodeIntegerForKey: NSStringFromSelector(@selector(countClearedBoard))];
		self.levelNumberMinusOne =               [decoder decodeIntegerForKey: NSStringFromSelector(@selector(levelNumberMinusOne))];
		self.numberOfShakes =                    [decoder decodeInt32ForKey: NSStringFromSelector(@selector(numberOfShakes))];
		self.type =                              [decoder decodeInt32ForKey: NSStringFromSelector(@selector(type))];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:  self.wordsAndPoints                    forKey: NSStringFromSelector(@selector(wordsAndPoints))];
    [encoder encodeObject:  self.topWord                           forKey: NSStringFromSelector(@selector(topWord))];
	[encoder encodeInteger: self.totalPoints                       forKey: NSStringFromSelector(@selector(totalPoints))];
	[encoder encodeInteger: self.totalPointsFromBonusTiles         forKey: NSStringFromSelector(@selector(totalPointsFromBonusTiles))];
	[encoder encodeInteger: self.totalTime                         forKey: NSStringFromSelector(@selector(totalTime))];
	[encoder encodeInteger: self.totalTimeExtra                    forKey: NSStringFromSelector(@selector(totalTimeExtra))];
	[encoder encodeInteger: self.countBonusTileSeenShuffle         forKey: NSStringFromSelector(@selector(countBonusTileSeenShuffle))];
	[encoder encodeInteger: self.countBonusTileSeenPoints          forKey: NSStringFromSelector(@selector(countBonusTileSeenPoints))];
	[encoder encodeInteger: self.countBonusTileSeenTimer           forKey: NSStringFromSelector(@selector(countBonusTileSeenTimer))];
	[encoder encodeInteger: self.countBonusTileSeenSpecial         forKey: NSStringFromSelector(@selector(countBonusTileSeenSpecial))];
	[encoder encodeInteger: self.countBonusTileSeenSpecialShuffle  forKey: NSStringFromSelector(@selector(countBonusTileSeenSpecialShuffle))];
	[encoder encodeInteger: self.countBonusTileUsedShuffle         forKey: NSStringFromSelector(@selector(countBonusTileUsedShuffle))];
	[encoder encodeInteger: self.countBonusTileUsedPoints          forKey: NSStringFromSelector(@selector(countBonusTileUsedPoints))];
	[encoder encodeInteger: self.countBonusTileUsedTimer           forKey: NSStringFromSelector(@selector(countBonusTileUsedTimer))];
	[encoder encodeInteger: self.countBonusTileUsedSpecial         forKey: NSStringFromSelector(@selector(countBonusTileUsedSpecial))];
	[encoder encodeInteger: self.countBonusTileUsedSpecialShuffle  forKey: NSStringFromSelector(@selector(countBonusTileUsedSpecialShuffle))];
	[encoder encodeInteger: self.countFreeShakesUsed               forKey: NSStringFromSelector(@selector(countFreeShakesUsed))];
	[encoder encodeInteger: self.countClearedBoard                 forKey: NSStringFromSelector(@selector(countClearedBoard))];
	[encoder encodeInteger: self.levelNumberMinusOne               forKey: NSStringFromSelector(@selector(levelNumberMinusOne))];
	[encoder encodeInt32: self.numberOfShakes                    forKey: NSStringFromSelector(@selector(numberOfShakes))];
	[encoder encodeInt32: self.type                              forKey: NSStringFromSelector(@selector(type))];
}

- (void)addNewStatistics:(WFStatisticsBase *)statistics {
	for (MTWordValue *wordAndPoints in statistics.wordsAndPoints) {
		[self.wordsAndPoints addObject:wordAndPoints];
	}
	self.totalPoints							+= statistics.totalPoints;
	self.totalPointsFromBonusTiles              += statistics.totalPointsFromBonusTiles;
	self.totalTime                              += statistics.totalTime;
	self.totalTimeExtra                         += statistics.totalTimeExtra;
	self.countBonusTileSeenShuffle              += statistics.countBonusTileSeenShuffle;
	self.countBonusTileSeenPoints               += statistics.countBonusTileSeenPoints;
	self.countBonusTileSeenTimer				+= statistics.countBonusTileSeenTimer;
	self.countBonusTileSeenSpecial              += statistics.countBonusTileSeenSpecial;
	self.countBonusTileSeenSpecialShuffle       += statistics.countBonusTileSeenSpecialShuffle;
	self.countBonusTileUsedShuffle              += statistics.countBonusTileUsedShuffle;
	self.countBonusTileUsedPoints               += statistics.countBonusTileUsedPoints;
	self.countBonusTileUsedTimer				+= statistics.countBonusTileUsedTimer;
	self.countBonusTileUsedSpecial              += statistics.countBonusTileUsedTimer;
	self.countBonusTileUsedSpecialShuffle       += statistics.countBonusTileUsedTimer;
	self.countFreeShakesUsed					+= statistics.countFreeShakesUsed;
	self.countClearedBoard                      += statistics.countClearedBoard;
}

- (void)reset {
	[self.wordsAndPoints removeAllObjects];
	self.totalPoints = 0;
	self.totalPointsFromBonusTiles = 0;
	self.totalTime = 0;
	self.totalTimeExtra = 0;
	self.countBonusTileSeenShuffle = 0;
	self.countBonusTileSeenPoints = 0;
	self.countBonusTileSeenTimer = 0;	
	self.countBonusTileUsedShuffle = 0;
	self.countBonusTileUsedPoints = 0;
	self.countBonusTileUsedTimer = 0;
	self.countFreeShakesUsed = 0;
	self.countClearedBoard = 0;
}

- (void)addWord:(MTWordValue *)word {
	[self.wordsAndPoints addObject:word];
}

- (NSString *)totalPointsValue {
	return [NSString stringWithFormat: NSLocalizedString(@"%ld points", @"A display of points."),
			_totalPoints];
}

@end
