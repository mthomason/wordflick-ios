//
//  WFGameView.m
//  wordPuzzle
//
//  Created by Michael Thomason on 5/21/12.
//  Copyright (c) 2023 Michael Thomason. All rights reserved.
//

#import "WFGameView.h"
#import "WFTileView.h"
#import "WFTileData.h"
#import "MTGameBoard.h"
#import "UIColor+Wordflick.h"
#import "MNSUser.h"
#import "MNSGame.h"

__attribute__((unused))
static inline CGPoint MTCenterPoint(CGRect);
static inline double MTOffsetHorizontal(double);
static inline double MTOffsetVertical(double);

__attribute__((unused))
static inline CGPoint MTCenterPoint(CGRect rect) {
	return CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
}

static inline double MTOffsetHorizontal(double w) { return (w / ( ( 1.0 / 3.0 ) * 100.0 )) * 4.0; }
static inline double MTOffsetVertical(double w) { return (w / ( ( 1.0 / 3.0 ) * 100.0 )) * 4.0; }

@interface WFGameView() {
	CGGradientRef _gradient;
	CGRect _layoutSubviewBounds;
	CGRect _layoutSubviewTileBounds;
	CGPoint _gradientStartCenter;
	CGPoint _gradientEndCenter;
}

@end

@implementation WFGameView

@synthesize positionTilesOffscreen = _positionTilesOffscreen;

#pragma mark -
#pragma mark Static Functions

- (void)dealloc {
	CGGradientRelease(_gradient);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		_layoutSubviewBounds = _layoutSubviewTileBounds = CGRectZero;
		_gradientStartCenter = _gradientEndCenter = CGPointZero;
		_gradient = CGGradientCreateBackgroundGradientFadeToBlackRadial();
		self.opaque = NO;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_layoutSubviewBounds = _layoutSubviewTileBounds = CGRectZero;
		_gradientStartCenter = _gradientEndCenter = CGPointZero;
		_gradient = CGGradientCreateBackgroundGradientFadeToBlackRadial();
		self.opaque = NO;
	}
	return self;
}

- (BOOL)positionTilesOffscreen {
	return _positionTilesOffscreen;
}

- (void)setPositionTilesOffscreen:(BOOL)positionTilesOffscreen {
	if (_positionTilesOffscreen != positionTilesOffscreen) {
		_positionTilesOffscreen = positionTilesOffscreen;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	_layoutSubviewBounds.origin.x = 0.0;
	_layoutSubviewBounds.origin.y = 0.0;
	_layoutSubviewBounds.size.width = self.bounds.size.width;
	_layoutSubviewBounds.size.height = self.bounds.size.height - (34.0 + 10.0 + 64.0);

	_layoutSubviewTileBounds.origin.x = 0.0;
	_layoutSubviewTileBounds.origin.y = 0.0;
	_layoutSubviewTileBounds.size.width =
	_layoutSubviewTileBounds.size.height = [MTGameBoard tileLength: &_layoutSubviewBounds
												 verticalSizeClass: self.traitCollection.verticalSizeClass];

	CGAffineTransform scale = _positionTilesOffscreen ?
								CGAffineTransformMakeScale(3.2, 3.2) :
								CGAffineTransformIdentity;
	
	NSMutableDictionary <NSNumber *, WFTileData *> *gamePieceData = [MNSUser CurrentUser].game.gamePieceData;
	for (UIView *subview in self.subviews) {
		@autoreleasepool {
			if ([subview isKindOfClass:[WFTileView class]]) {
				__strong WFTileData *tileData = gamePieceData[((WFTileView *)subview).tileID];
				if ([subview isKindOfClass:[WFTileView class]] && tileData.inPlay && !tileData.isMoving) {
					subview.bounds = _layoutSubviewTileBounds;

					//if (_positionTilesOffscreen) {
					//	subview.transform = scale;
					//	subview.center = CGPointMakeRandomOffscreen();
					//} else {
						subview.transform = scale;
						subview.center = [MTGameBoard centerLocationForBoard: _layoutSubviewBounds
																	tileSize: _layoutSubviewTileBounds.size
																	position: tileData.position
														  userInterfaceIdiom: self.traitCollection.userInterfaceIdiom
														   verticalSizeClass: self.traitCollection.verticalSizeClass
														 horizontalSizeClass: self.traitCollection.horizontalSizeClass];
					//}
					[subview setNeedsDisplay];
				}
				tileData = nil;
			}
		}		
	}
}

- (void)drawRect:(CGRect)rect {
	//CGContextRef context = UIGraphicsGetCurrentContext();
	_gradientStartCenter.x = (rect.origin.x + rect.size.width / 2.0) - MTOffsetHorizontal(rect.size.width);
	_gradientStartCenter.y = (rect.origin.y + rect.size.height / 2.0) - MTOffsetVertical(rect.size.width);
	_gradientEndCenter.x = (rect.origin.x + rect.size.width / 2.0) + MTOffsetHorizontal(rect.size.width);
	_gradientEndCenter.y = (rect.origin.y + rect.size.height / 2.0) + MTOffsetVertical(rect.size.width);
	CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(),
								_gradient,
								_gradientStartCenter,
								rect.size.width / (3.4 / 3.0),
								_gradientEndCenter,
								0.0,
								(kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
}

@end
