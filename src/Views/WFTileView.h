//
//  WFTileView.h
//  wordPuzzle
//
//  Created by Michael Thomason on 5/29/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MUIViewGameTile_h
#define MUIViewGameTile_h

#import "MTTileType.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class WFTileData, MTWobbleState, WFTileData, WFTileView;

@protocol WFTileViewDataSource <NSObject>
@required
- (bool)hasInitalRotationForTileView:(WFTileView *)tileView;
- (CGFloat)initalRotationAngleForTileView:(WFTileView *)tileView;
- (MNSTileType)typeTypeForTileView:(WFTileView *)tileView;
- (NSString *)characterValueForTileView:(WFTileView *)tileView;
- (bool)isTileFlipping:(WFTileView *)tileView;
@optional
@end

@protocol WFTileViewDelegate <NSObject>
@required
- (void)tileViewTouchBegan:(WFTileView *)tileView;
@optional
@end

@interface WFTileView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, readonly, assign) BOOL touched;
@property (nonatomic, assign) BOOL removed;
@property (nonatomic, weak) id <WFTileViewDataSource> dataSource;
@property (nonatomic, weak) id <WFTileViewDelegate> delegate;
@property (nonatomic, copy) NSNumber *tileID;

- (nullable instancetype)initWithCoder: (NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithFrame: (CGRect)frame
							identifier: (NSInteger)identifier NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithFrame: (CGRect)frame
								  tile: (WFTileData *)tile NS_DESIGNATED_INITIALIZER;

- (void)startWobble: (NSInteger)count;
- (void)stopWobble;

@end

NS_ASSUME_NONNULL_END

#endif
