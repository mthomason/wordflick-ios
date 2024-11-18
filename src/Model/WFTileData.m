//
//  MNSTile.m
//  wordPuzzle
//
//  Created by Michael Thomason on 3/26/12.
//  Copyright (c) 2020 Michael Thomason. All rights reserved.
//

#import "WFTileData.h"
#import "DatabaseWords.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "WFTileView.h"
#import "wordPuzzleAppDelegate.h"
#import "Constants.h"

@interface WFTileData () {
	MNSTileType _previousTileType;
}

@property (nonatomic, readwrite, assign) NSInteger position;
@property (assign) NSTimer *pieceChangeTimer;
@property (nonatomic, copy) NSDate *lastFireDate;
@property (nonatomic, copy, readonly) NSDate *lastFlipEndDate;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (NSTimeInterval)intervalForLevel;

@end

@implementation WFTileData

static void updateTileType(WFTileData *object) {
	switch (getRandomTileType()) {
		case MNSTileExtraNormal:
			object->_useGivePointsMultiplier = NO;
			object->_useExtendsTime = NO;
			object->_useGivesExtraShake = NO;
			object->_tileType = MNSTileExtraNormal;
			break;
		case MNSTileExtraTime:
			object->_useGivePointsMultiplier = NO;
			object->_useExtendsTime = YES;
			object->_useGivesExtraShake = NO;
			object->_tileType = MNSTileExtraTime;
			break;
		case MNSTileExtraPoints:
			object->_useGivePointsMultiplier = YES;
			object->_useExtendsTime = NO;
			object->_useGivesExtraShake = NO;
			object->_tileType = MNSTileExtraPoints;
			break;
		case MNSTileExtraShuffle:
			object->_useGivePointsMultiplier = NO;
			object->_useExtendsTime = NO;
			object->_useGivesExtraShake = YES;
			object->_tileType = MNSTileExtraShuffle;
			break;
		case MNSTileExtraSpecial:
			object->_useGivePointsMultiplier = YES;
			object->_useExtendsTime = YES;
			object->_useGivesExtraShake = YES;
			object->_tileType = MNSTileExtraSpecial;
			break;
		default:
			object->_useGivePointsMultiplier = NO;
			object->_useExtendsTime = NO;
			object->_useGivesExtraShake = NO;
			object->_tileType = MNSTileExtraNormal;
			break;
	}
}

static double tileFlipInterval(long long levelNumber, double levelTime, double remainingTime) {
	uint32_t i = (ceil(80.0 / (levelNumber * ((0.65 + (remainingTime / ( (levelTime < 2.0) ? 1.0 : (levelTime / 3.0))) * 0.1000001))))
				+ ((arc4random_uniform(UINT32_MAX) % 2) == 0 ? 4.0 : 5.0));
	//NSLog(@"timeFlipInterval: %f", (0.001 * ((double)arc4random_uniform(1000))) + ((double)arc4random_uniform(i)));
	return (0.001 * ((double)arc4random_uniform(1000))) + ((double)arc4random_uniform(i));
}

static MNSTileType getRandomTileType() {
	if (arc4random_uniform(8) == 0) {
		switch (arc4random_uniform(14)) {
			case 0:
				return MNSTileExtraSpecial;
				break;
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
				return MNSTileExtraShuffle;
				break;
			case 6:
			case 7:
			case 8:
				return MNSTileExtraTime;
				break;
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			default:
				return MNSTileExtraPoints;
				break;
		}
	} else {
		return MNSTileExtraNormal;
	}
}

__attribute__((unused))
bool AlmostEqual2sComplement(float A, float B, int maxUlps) {
	// Make sure maxUlps is non-negative and small enough that the
	// default NAN won't compare as equal to anything.
	assert(maxUlps > 0 && maxUlps < 4 * 1024 * 1024);
	int aInt = *(int*)&A;
	// Make aInt lexicographically ordered as a twos-complement int
	if (aInt < 0)
		aInt = 0x80000000 - aInt;
	// Make bInt lexicographically ordered as a twos-complement int
	int bInt = *(int*)&B;
	if (bInt < 0)
		bInt = 0x80000000 - bInt;
	int intDiff = abs(aInt - bInt);
	if (intDiff <= maxUlps)
		return true;
	return false;
}

- (void)dealloc {
	_delegate = nil;
	_pieceChangeTimer = nil;
	_characterValue = nil;
	_lastCharacterValue = nil;
	_lastFireDate = nil;
}

- (instancetype)init {
	if (self = [super init]) {
		_characterValue = @"";
		_lastCharacterValue = @"";
		_tileType = MNSTileExtraNormal;
		_position = 0;
		if (@available(iOS 13.0, *)) {
			self.lastFireDate = [NSDate now];
		} else {
			self.lastFireDate = [NSDate date];
		}
	}
	return self;
}

- (instancetype)initWithCharacter: (char)c
							 type: (MNSTileType)type
					   identifier: (NSInteger)identifier {
	if (self = [super init]) {
		char s[2] = { c, '\0' };
		_characterValue = [[NSString alloc] initWithCString:s encoding: NSUTF8StringEncoding];
		_lastCharacterValue = [[NSString alloc] initWithCString:s encoding: NSUTF8StringEncoding];
		_tileType = type;
		_position = identifier;
		if (@available(iOS 13.0, *)) {
			self.lastFireDate = [NSDate now];
		} else {
			self.lastFireDate = [NSDate date];
		}
	}
	return self;
}

- (instancetype)initWithCharacter:(char)initalCharacter
						 position:(NSInteger)position
					  levelNumber:(int64_t)levelNumber
						levelTime:(double)levelTime
				 andRemainingTime:(double)remainingTime {
	if (self = [super init]) {
		char s[2] = { initalCharacter, '\0' };
		_position = position;
		_characterValue = [[NSString alloc] initWithCString:s encoding: NSUTF8StringEncoding];
		_lastCharacterValue = [[NSString alloc] initWithCString:s encoding: NSUTF8StringEncoding];
		_inPlay = YES;
		_pieceChangeTimer = [NSTimer scheduledTimerWithTimeInterval: tileFlipInterval(levelNumber, levelTime, remainingTime)
															 target: self
														   selector: @selector(timerChangePiece:)
														   userInfo: nil
															repeats: YES];

		if (@available(iOS 13.0, *)) {
			self.lastFireDate = [NSDate now];
		} else {
			self.lastFireDate = [NSDate date];
		}

		updateTileType(self);
	}
	return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.position = 					[decoder decodeIntegerForKey:	NSStringFromSelector(@selector(position))];
		self.characterValue =				[decoder decodeObjectForKey:	NSStringFromSelector(@selector(characterValue))];
		self.tileType =						[decoder decodeIntegerForKey:	NSStringFromSelector(@selector(tileType))];
		self.inPlay =						[decoder decodeBoolForKey:		NSStringFromSelector(@selector(inPlay))];
		self.beginMoveInGoal =				[decoder decodeBoolForKey: 		NSStringFromSelector(@selector(beginMoveInGoal))];
		self.useExtendsTime =				[decoder decodeBoolForKey: 		NSStringFromSelector(@selector(useExtendsTime))];
		self.useGivePointsMultiplier =		[decoder decodeBoolForKey: 		NSStringFromSelector(@selector(useGivePointsMultiplier))];
		self.useGivesExtraShake =			[decoder decodeBoolForKey: 		NSStringFromSelector(@selector(useGivesExtraShake))];
		self.isMoving =						[decoder decodeBoolForKey: 		NSStringFromSelector(@selector(isMoving))];
		self.pieceChangeTimer = [NSTimer scheduledTimerWithTimeInterval: [self intervalForLevel]
																 target: self
															   selector: @selector(timerChangePiece:)
															   userInfo: nil
																repeats: YES];

		if (@available(iOS 13.0, *)) {
			self.lastFireDate = [NSDate now];
		} else {
			self.lastFireDate = [NSDate date];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInteger:	self.position 					forKey: NSStringFromSelector(@selector(position))];
	[encoder encodeObject:	self.characterValue				forKey: NSStringFromSelector(@selector(characterValue))];
	[encoder encodeInteger:	self.tileType					forKey: NSStringFromSelector(@selector(tileType))];
	[encoder encodeBool:	self.inPlay						forKey: NSStringFromSelector(@selector(inPlay))];
	[encoder encodeBool:	self.beginMoveInGoal			forKey: NSStringFromSelector(@selector(beginMoveInGoal))];
	[encoder encodeBool:	self.useExtendsTime				forKey: NSStringFromSelector(@selector(useExtendsTime))];
	[encoder encodeBool:	self.useGivePointsMultiplier 	forKey: NSStringFromSelector(@selector(useGivePointsMultiplier))];
	[encoder encodeBool:	self.useGivesExtraShake 		forKey: NSStringFromSelector(@selector(useGivesExtraShake))];
	[encoder encodeBool:	self.isMoving 					forKey: NSStringFromSelector(@selector(isMoving))];
}

- (NSTimeInterval)intervalForLevel {
	MNSGame *game = [MNSUser CurrentUser].game;
	return tileFlipInterval(game.levelNumber, game.levelDuration, game.remainingTime);
}

- (NSDate *)lastFlipEndDate {
	return [self.lastFireDate dateByAddingTimeInterval: (5.7 / 9.0) * (7.0 / 8.0)];;
}

- (void)timerChangePiece:(NSTimer *)theTimer {
	id <MTTileDataProtocol> delegate = self.delegate;
	if (delegate != nil && ![delegate isTouched:self] && self.inPlay && !self.isMoving && ![MNSUser CurrentUser].game.isPaused) {

		self.lastCharacterValue = self.characterValue;
		_previousTileType = self.tileType;
		self.characterValue = [[DatabaseWords sharedInstance] randomLetterAvoiding:self.characterValue];
		updateTileType(self);

		self.pieceChangeTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:[self intervalForLevel]];
		if (@available(iOS 13.0, *)) {
			self.lastFireDate = [NSDate now];
		} else {
			self.lastFireDate = [NSDate date];
		}

		[delegate tileWithDataUpdateDisplay:self];
	}
}

- (void)reversePieceChange {
	self.tileType = _previousTileType;
	self.characterValue = _lastCharacterValue;
}

- (bool)tileIsFlipping {
	return [self.lastFlipEndDate compare:[NSDate date]] == NSOrderedDescending;
}

- (NSNumber *) tileID {
	return @(_position);
}

- (NSString *)description {
	NSMutableString *description = [[NSMutableString alloc] initWithString: [super description]];

	[description appendFormat:@"\n%@: %@", NSStringFromSelector(@selector(lastPointPlusOne)), NSStringFromCGPoint(self.lastPointPlusOne)];
	[description appendFormat:@"\n%@: %@", NSStringFromSelector(@selector(lastPoint)), NSStringFromCGPoint(self.lastPoint)];
	[description appendFormat:@"\n%@: %@", NSStringFromSelector(@selector(currentPoint)), NSStringFromCGPoint(self.currentPoint)];

	[description appendFormat:@"\n%@: %@", NSStringFromSelector(@selector(characterValue)), self.characterValue];
	[description appendFormat:@"\n%@: %@", NSStringFromSelector(@selector(lastCharacterValue)), self.lastCharacterValue];
	
	[description appendFormat:@"\n%@: %lu", NSStringFromSelector(@selector(characterValue)), (unsigned long)self.position];

	return description;
}

- (void)invalidate {
	if (_pieceChangeTimer != nil) {
		[_pieceChangeTimer invalidate];
	}
}

@end
