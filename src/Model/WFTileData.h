//
//  MNSTile.h
//  wordPuzzle
//
//  Created by Michael Thomason on 3/26/12.
//  Copyright (c) 2020 Michael Thomason. All rights reserved.
//

#ifndef MNSTile_h
#define MNSTile_h

#import <Foundation/Foundation.h>
#import "MTTileType.h"
#import "MTSize.h"

@class WFTileData, UIView;

@protocol MTTileDataProtocol <NSObject>
- (bool)isTouched:(WFTileData *)tileData;
- (void)tileWithDataUpdateDisplay:(WFTileData *)tileData;
@end

@interface WFTileData : NSObject <NSCoding>

@property (nonatomic, weak) id <MTTileDataProtocol> delegate;

//Used for tracking direction
@property (nonatomic, assign) CGPoint lastPointPlusOne;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGPoint currentPoint;

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval lastTimePlusOne;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) MNSTileType tileType;

@property (nonatomic, readwrite, copy) NSString *characterValue;
@property (nonatomic, readwrite, copy) NSString *lastCharacterValue;

@property (assign) BOOL isMoving;
@property (assign) BOOL inPlay;
@property (assign) BOOL useExtendsTime;
@property (assign) BOOL useGivePointsMultiplier;
@property (assign) BOOL useGivesExtraShake;
@property (assign) BOOL beginMoveInGoal;

@property (assign, readonly) bool tileIsFlipping;

@property (nonatomic, readonly, assign) NSInteger position;
@property (nonatomic, readonly, copy) NSNumber *tileID;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCharacter:(char)c
							 type:(MNSTileType)type
					   identifier:(NSInteger)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCharacter:(char)initalCharacter
						 position:(NSInteger)position
					  levelNumber:(int64_t)levelNumber
						levelTime:(double)levelTime
				 andRemainingTime:(double)remainingTime NS_DESIGNATED_INITIALIZER;

- (void)reversePieceChange;
- (void)invalidate;

@end

#endif
