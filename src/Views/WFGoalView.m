//
//  WFGoalView.m
//  wordPuzzle
//
//  Created by Michael Thomason on 5/31/09.
//  Copyright 2023 Michael Thomason. All rights reserved.
//

#import "WFGoalView.h"
#import "WFTileView.h"
#import "WFTileData.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "MTGameBoard.h"
#import "UIColor+Wordflick.h"

@interface WFGoalView () {
	CGPoint _endPoint;
}

CGGradientRef CGGradientCreateBackgroundGradientFadeFromBlack(void);

@end

@implementation WFGoalView

CGGradientRef CGGradientCreateBackgroundGradientFadeFromBlack(void) {
	CGGradientRef _backgroundGradientFadeFromBlack = NULL;
	CGFloat colors[12] = {
		0.0f, 0.0f, 0.0f, 0.9f,
		0.0f, 0.0f, 0.0f, 0.3f,
		0.0f, 0.0f, 0.0f, 0.9f
	};
	CGFloat colorStops[3] = {0.0f, 0.5f, 1.0f};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientFadeFromBlack = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientFadeFromBlack;
}

- (void)dealloc { }

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		_endPoint = CGPointZero;
		self.backgroundColor = [UIColor patternGradentCarbonFiber];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		_endPoint = CGPointZero;
		self.backgroundColor = [UIColor patternGradentCarbonFiber];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGGradientRef gradient = CGGradientCreateBackgroundGradientFadeFromBlack();
	_endPoint.x = rect.origin.x;
	_endPoint.y = rect.origin.y + rect.size.height;
	CGContextDrawLinearGradient(context, gradient, rect.origin, _endPoint, 0);
	CGGradientRelease(gradient);
}

@end
