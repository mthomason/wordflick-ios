//
//  MUIViewLabelGlowBackground.m
//  wordPuzzle
//
//  Created by Michael Thomason on 4/12/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import "WFGlowLabelBackgroundView.h"
#import "UIColor+Wordflick.h"

@interface WFGlowLabelBackgroundView() {
	CGPoint _destination;
}

@end

@implementation WFGlowLabelBackgroundView

static CGGradientRef _backgroundGradient;

+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		CGFloat colors[16] = {
			175.0 / 255.0, 189.0 / 255.0, 192.0 / 255.0, 0.5,
			109.0 / 255.0, 118.0f / 255.0, 115.0 / 255.0, 0.5,
			10.0 / 255.0, 15.0f / 255.0, 11.0 / 255.0, 0.5,
			10.0 / 255.0, 8.0f / 255.0, 9.0 / 255.0, 0.5
		};

		CGFloat colorStops[4] = {0.0, 0.49, 0.5, 1.0};

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		_backgroundGradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
		CGColorSpaceRelease(colorSpace);

	});
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		_destination = CGPointZero;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		_destination = CGPointZero;
	}
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	_destination.x = rect.origin.x; _destination.y = rect.origin.y + rect.size.height;
	CGContextDrawLinearGradient(context, _backgroundGradient, rect.origin, _destination, 0);
}

@end
