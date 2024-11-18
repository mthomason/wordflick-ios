//
//  MTLevelStatistics.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "WFLevelStatistics.h"
#import "UIColor+Wordflick.h"

@interface WFLevelStatistics ()
    @property (nonatomic, assign, readonly) NSInteger levelGoalMultiplier;
@end

@implementation WFLevelStatistics

static NSString *formatSecondsLocalized = nil;

+ (void)initialize {
	if (self == [WFLevelStatistics self]) {
	  formatSecondsLocalized = NSLocalizedString(@"%@ seconds",
												 @"A display of seconds.  For example: '100 seconds' where %@ is the number of seconds.");
	}
}

- (void)dealloc {
	_tweetableMessages = nil;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.tweetableMessages = [decoder decodeObjectForKey:NSStringFromSelector(@selector(tweetableMessages))];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeObject: self.tweetableMessages
				   forKey: NSStringFromSelector(@selector(tweetableMessages))];
}

- (instancetype)init {
	return [self initWithLevel:0 andGameType:Wordflick];
}

- (instancetype)initWithLevel:(long)l andGameType:(MNSGameType)t {
	if (self = [super init]) {
		_tweetableMessages = [[NSMutableArray alloc] init];
		self.type = t;
		self.levelNumberMinusOne = l;
		[self setNumberOfShakes: [self initalNumberOfShuffles]];
	}
	return self;
}

- (long)levelNumber {
	return self.levelNumberMinusOne + 1;
}

- (NSString *)levelNumberDisplay {
	return [NSString stringWithFormat:@"%ld", self.levelNumberMinusOne];
}

- (NSString *)levelGoalDisplay {
	return [NSString stringWithFormat: @"%ld", (long)self.goal];
}

- (NSString *)levelTimeDetailDisplay {
	return [NSString stringWithFormat: formatSecondsLocalized, [NSString stringWithFormat:@"%ld", self.levelTime]];
}

- (NSString *)levelShuffleDetailDisplay {
	return [NSString stringWithFormat:@"%ld", (long)self.numberOfShakes];
}

- (NSInteger)levelGoalMultiplier {
	switch (self.type) {
		case Wordflick:
			return 400;
			break;
		case WordflickClassic:
			return 400;
			break;
		case WordflickJr:
			return 150;
			break;
		case WordflickFastBreak:
			return 200;
			break;
		case WordflickDebug:
			return 2;
			break;
		case WordflickFreePlay:
			return 400;
			break;
		default:
			return 400;
			break;
	}
}

- (long)levelTime {
	switch (self.type) {
		case Wordflick:
			switch (self.levelNumberMinusOne % 3) {
				case 0:
					return 225;
				case 1:
					return 225;
				case 2:
					return 75 + 10 * self.levelNumberMinusOne;
				default:
					return 210;
			}
		case WordflickClassic:
			return (((self.levelNumberMinusOne + 1) % 3) == 0)?60:210;
		case WordflickJr:
			return 300;
		case WordflickFastBreak:
			return 60;
		case WordflickDebug:
			return 25;
		case WordflickFreePlay:
			return 1800;
		default:
			return (((self.levelNumberMinusOne + 1) % 3) == 0) ? 30 : 180;
	}
}

- (long)goal {
	switch (self.type) {
		case Wordflick:
			switch (self.levelNumberMinusOne % 3) {
				case 0:
					return 33 * (self.levelNumberMinusOne + 7) + 13 * (pow(self.levelNumberMinusOne + 7, 2));
				case 1:
					return 33 * (self.levelNumberMinusOne + 7) + 13 * (pow(self.levelNumberMinusOne + 7, 2));
				case 2:
					return 70 + self.levelNumberMinusOne * ([self levelGoalMultiplier] / 10);
				default:
					return 800 + self.levelNumberMinusOne * ([self levelGoalMultiplier] / 2);
			}
			break;
		case WordflickClassic:
			return (((self.levelNumberMinusOne + 1) % 3) == 0) ?
						(70 + ((self.levelNumberMinusOne) * ([self levelGoalMultiplier] / 10))):
						(800 + (((self.levelNumberMinusOne) * [self levelGoalMultiplier]) / 2));
		case WordflickJr:
			return (300 + ((self.levelNumberMinusOne - 1) * [self levelGoalMultiplier]));
		case WordflickFastBreak:
			return 75 + self.levelNumberMinusOne * [self levelGoalMultiplier];
		case WordflickDebug:
			return (5 + ((self.levelNumberMinusOne - 1) * [self levelGoalMultiplier]));
		case WordflickFreePlay:
			return 1000000;
		default:
			return (((self.levelNumberMinusOne + 1) % 3) == 0)?
				(70 + (self.levelNumberMinusOne * ([self levelGoalMultiplier] / 10))):
				(800 + ((self.levelNumberMinusOne * [self levelGoalMultiplier]) / 2));
	}
}

- (int32_t)initalNumberOfShuffles {
	switch (self.type) {
		case Wordflick: {
			switch ([self levelNumber] % 3) {
				case 0:
					return 3;
					break;
				case 1:
					return (ceil((5 - ((self.levelNumberMinusOne + 1) / 3))) > 3) ?
						ceil((5 - ((self.levelNumberMinusOne + 1) / 3))) : 3;
				case 2:
					return (ceil((5 - ((self.levelNumberMinusOne + 1) / 3))) > 3) ?
						ceil((5 - ((self.levelNumberMinusOne + 1) / 3))) : 3;
				default:
					return 5;
			}
		}
		case WordflickClassic: {
			int32_t i = (((self.levelNumberMinusOne + 1) % 3) == 0) ? 3 : ceil((5 - ((self.levelNumberMinusOne + 1) / 3)));
			return (i < 3) ? 3 : i;
		}
		case WordflickJr: {
			return ceil((7 - ((self.levelNumberMinusOne + 1) / 3))) + 3;
		}
		case WordflickFastBreak:
			return 3;
			break;
		case WordflickDebug:
			return 25;
		case WordflickFreePlay:
			return 1000;
		default: {
			int32_t i = (((self.levelNumberMinusOne + 1) % 3) == 0) ? 3 : ceil((5 - ((self.levelNumberMinusOne + 1) / 3)));
			return (i < 3) ? 3 : i;
		}
	}
}

- (UIColor *)backgroundColor {
	switch (self.type) {
		case Wordflick:
			return [UIColor patternForId:self.levelNumberMinusOne];
		case WordflickDebug:
			return [UIColor patternForId:self.levelNumberMinusOne];
		default:
			return [UIColor patternUIImagePatternRetroBlueCircles];
	}
}

- (void)coinsForLevelChad:(NSNumber * __strong *)chadCoins
				   silver:(NSNumber * __strong *)silverCoins
					 gold:(NSNumber * __strong *)goldCoins {
	if (self.totalPoints > 0) {                   //Don't want to give them negitive loot
		if (self.levelNumberMinusOne < 30) {
			*chadCoins = [NSNumber numberWithLongLong: self.totalPoints * 10];
			*silverCoins = [NSNumber numberWithLongLong:0];
			*goldCoins = [NSNumber numberWithLongLong:0];
		} else if (self.levelNumberMinusOne < 40) {
			*chadCoins = [NSNumber numberWithLongLong: self.totalPoints * 10];
			*silverCoins = [NSNumber numberWithLongLong: 0];
			*goldCoins = [NSNumber numberWithLongLong: 0];
		} else {
			*chadCoins = [NSNumber numberWithLongLong: 0];
			*silverCoins = [NSNumber numberWithLongLong: 0];
			*goldCoins = [NSNumber numberWithLongLong: 0];
		}
	} else {
		*chadCoins = [NSNumber numberWithLongLong: 0];
		*silverCoins = [NSNumber numberWithLongLong: 0];
		*goldCoins = [NSNumber numberWithLongLong: 0];
	}
}

- (void)reset {
	[super reset];
	[self setLevelNumberMinusOne: 0];
}

- (void)addPoints:(long)points {
	[self setTotalPoints: self.totalPoints + points];
}

- (void)addPointsFromBonusTiles:(long)points {
	[self addPoints:points];
	[self setTotalPointsFromBonusTiles: self.totalPointsFromBonusTiles + points];
}

- (void)addTime:(NSInteger)time {
	[self setTotalTime: [self totalTime] + time];
}

- (void)addTimeExtra:(NSInteger)time {
	[self addTime:time];
	[self setTotalTimeExtra: [self totalTimeExtra] + time];
}

- (void)addBonusTileSeenShuffle:(NSInteger)i {
	[self setCountBonusTileSeenShuffle: self.countBonusTileSeenShuffle + i];
}

- (void)addBonusTileSeenPoints:(NSInteger)i {
	[self setCountBonusTileSeenPoints: self.countBonusTileSeenPoints + i];
}

- (void)addBonusTileSeenTimer:(NSInteger)i {
	[self setCountBonusTileSeenTimer: self.countBonusTileSeenTimer + i];
}

- (void)addBonusTileSeenSpecial:(NSInteger)i {
	[self setCountBonusTileSeenSpecial: self.countBonusTileSeenSpecial + i];	
}

- (void)addBonusTileUsedShuffle:(NSInteger)i {
	[self setCountBonusTileUsedShuffle: self.countBonusTileUsedShuffle + i];
}

- (void)addBonusTileUsedPoints:(NSInteger)i {
	[self setCountBonusTileUsedPoints: self.countBonusTileUsedPoints + i];
}

- (void)addBonusTileUsedTimer:(NSInteger)i {
	[self setCountBonusTileUsedTimer: self.countBonusTileUsedTimer + i];
}

- (void)addBonusTileUsedSpecial:(NSInteger)i {
	[self setCountBonusTileUsedSpecial: self.countBonusTileUsedSpecial + i];	
}

- (void)addBonusTileUsedSpecialShuffle:(NSInteger)i {
	[self setCountBonusTileUsedSpecialShuffle: self.countBonusTileUsedSpecialShuffle + i];	
}

- (void)addFreeShakesUsed:(NSInteger)i {
	[self setCountFreeShakesUsed: self.countFreeShakesUsed + i];
}

- (void)addClearedBoard:(NSInteger)i {
	[self setCountClearedBoard: self.countClearedBoard + i];
}

@end
