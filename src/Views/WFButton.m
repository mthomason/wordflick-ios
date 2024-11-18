//
//  WFButton.m
//  wordPuzzle
//
//  Created by Michael on 2/19/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "WFButton.h"

typedef NS_ENUM(short, WFCorner) {
	WFCornerTopLeft = 0,
	WFCornerTopRight = 1,
	WFCornerBottomRight = 2,
	WFCornerBottomLeft = 3,
};

@class WFCheckButton, WFPauseButton, WFShuffleButton;

@interface WFButton()

@end

@implementation WFButton

#pragma mark -
#pragma mark Static

+ (void)BackgroundGradient:(CGGradientRef *)gradient alpha:(CGFloat)a {
	CGFloat colors[16] = {
		252.0 / 255.0, 90.0 / 255.0, 64.0 / 255.0, 1.0,
		239.0 / 255.0, 112.0 / 255.0, 96.0 / 255.0, 1.0,
		243.0 / 255.0, 44.0 / 255.0, 32.0 / 255.0, 1.0,
		232.0 / 255.0, 61.0 / 255.0, 51.0 / 255.0, 1.0
	};
	CGFloat colorStops[4] = {0.0, 0.5, 0.5, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	*gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
}

__attribute__((unused))
static void WFButtonSetRedGradient(CGGradientRef *gradient, CGFloat a) {
	CGFloat colors[20] = {
		252.0 / 255.0, 90.0 / 255.0, 64.0 / 255.0, 1.0,
		239.0 / 255.0, 112.0 / 255.0, 96.0 / 255.0, 1.0,
		243.0 / 255.0, 44.0 / 255.0, 32.0 / 255.0, 1.0,
		232.0 / 255.0, 61.0 / 255.0, 51.0 / 255.0, 1.0
	};
	CGFloat colorStops[5] = {0.0, 0.5, 0.5, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	*gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
}

__attribute__((unused))
static void WFButtonSetBlueGradient(CGGradientRef *gradient, CGFloat a) {
	CGFloat colors[16] = {
		114.0 / 255.0, 183.0 / 255.0, 240.0 / 255.0, a,
		89.0 / 255.0, 165.0 / 255.0, 235.0 / 255.0, a,
		58.0 / 255.0, 143.0 / 255.0, 236.0 / 255.0, a,
		34.0 / 255.0, 104.0 / 255.0, 217.0 / 255.0, a
	};
	CGFloat colorStops[4] = {0.0, 0.49, 0.51, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	*gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
}

__attribute__((unused))
static void WFButtonSetGreenGradient(CGGradientRef *gradient, CGFloat a) {
	CGFloat colors[20] = {
		185.0 / 255.0, 206.0 / 255.0, 68.0 / 255.0, a,
		168.0 / 255.0, 199.0 / 255.0, 50.0 / 255.0, a,
		142.0 / 255.0, 185.0 / 255.0, 42.0 / 255.0, a,
		114.0 / 255.0, 170.0 / 255.0, 0.0 / 255.0, a,
		148.0 / 255.0, 197.0 / 255.0, 22.0 / 255.0, a
	};
	CGFloat colorStops[5] = {0.0, 0.08, 0.5, 0.5, 0.96};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	*gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 5);
	CGColorSpaceRelease(colorSpace);
}

static void bezierPathForPauseButton(const double *cornerRadius,
									 double lineWidth,
									 const CGSize *size,
									 UIBezierPath **bezierPath) {
	CGFloat lineCenter = lineWidth / 2.0;
	*bezierPath = [UIBezierPath bezierPath];
	
	// topLeft
	[*bezierPath moveToPoint: CGPointMake(cornerRadius[WFCornerTopLeft], lineCenter)];
	[*bezierPath addArcWithCenter: CGPointMake(cornerRadius[WFCornerTopLeft], cornerRadius[WFCornerTopLeft])
							radius: cornerRadius[WFCornerTopLeft] - lineCenter
						startAngle: M_PI * 1.5
						  endAngle: M_PI
						 clockwise: NO];

	// bottomLeft
	[*bezierPath addLineToPoint: CGPointMake(lineCenter, size->height - cornerRadius[WFCornerBottomLeft])];
	[*bezierPath addArcWithCenter: CGPointMake(cornerRadius[WFCornerBottomLeft], size->height - cornerRadius[WFCornerBottomLeft])
							radius: cornerRadius[WFCornerBottomLeft] - lineCenter
						startAngle: M_PI
						  endAngle: M_PI * 0.5
						 clockwise: NO];

	// bottomRight
	[*bezierPath addLineToPoint: CGPointMake(size->width - cornerRadius[WFCornerBottomRight], size->height - lineCenter)];
	[*bezierPath addArcWithCenter: CGPointMake(size->width - cornerRadius[WFCornerBottomRight], size->height - cornerRadius[WFCornerBottomRight])
							radius: cornerRadius[WFCornerBottomRight] - lineCenter
						startAngle: M_PI * 0.5
						  endAngle: 0.0
						 clockwise: NO];

	// topRight
	[*bezierPath addLineToPoint: CGPointMake((size->width * (6.0/8.0)) - lineCenter, cornerRadius[WFCornerTopRight])];
	[*bezierPath addArcWithCenter: CGPointMake((size->width * (6.0/8.0)) - cornerRadius[WFCornerTopRight], cornerRadius[WFCornerTopRight])
							radius: cornerRadius[WFCornerTopRight] - lineCenter
						startAngle: 0.0
						  endAngle: M_PI * 1.5
						 clockwise: NO];

	[*bezierPath closePath];
}

__attribute__((unused))
static UIBezierPath *bezierPathForPauseButtonOld(const CGSize *size, CGFloat cornerRadius, UIBezierPath **bezierPath) {
	*bezierPath = [UIBezierPath bezierPath];
	[*bezierPath moveToPoint: CGPointMake(0.0, 0.0)];									//	Point 1 - Top left
	[*bezierPath addLineToPoint: CGPointMake(0.0 + (size->width * (7.0/8.0)), 0.0)];	//	Point 2 - Top right
	[*bezierPath addLineToPoint: CGPointMake(0.0 + size->width, 0.0 + size->height)];	//	Point 3 - Bottom right
	[*bezierPath addLineToPoint: CGPointMake(0.0, 0.0 + size->height)];					//	Point 4 - Bottom Left
	[*bezierPath addLineToPoint: CGPointMake(0.0, 0.0)];								//	Point 1 - Top left
	return *bezierPath;
}


#pragma mark -
#pragma mark UIView Overrides

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		
		self.backgroundColor = [UIColor clearColor];
		
		UIButton *button = [[UIButton alloc] initWithFrame:self.bounds];
		button.autoresizingMask = UIViewAutoresizingFlexibleWidth |
								  UIViewAutoresizingFlexibleHeight;
		
		CAGradientLayer *gradientLayer = [CAGradientLayer layer];
		gradientLayer.frame = self.bounds;
		gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed: 225.0 / 255.0
															  green: 225.0 / 255.0
															   blue: 225.0 / 255.0
															  alpha: 1.0].CGColor,
								 (__bridge id)[UIColor colorWithRed: 253.0 / 255.0
															  green: 253.0 / 255.0
															   blue: 253.0 / 255.0
															  alpha: 1.0].CGColor,
								 (__bridge id)[UIColor colorWithRed: 237.0 / 255.0
															  green: 237.0 / 255.0
															   blue: 237.0 / 255.0
															  alpha: 1.0].CGColor,
								 (__bridge id)[UIColor colorWithRed: 222.0 / 255.0
															  green: 222.0 / 255.0
															   blue: 222.0 / 255.0
															  alpha: 1.0].CGColor];
		[button.layer addSublayer:gradientLayer];
		[self addSubview:button];
		self.button = button;
		button = nil;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	
}

- (void)drawRect:(CGRect)rect {
	CGGradientRef gradient = NULL;
	[self.class BackgroundGradient:&gradient alpha:self.alpha];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	UIBezierPath *roundedRect;

	static const double cornerRadius[] = {4.0, 4.0, 4.0, 4.0};
	static const double lineWidth = 2.0;

	switch (self.buttonType) {
		case WFButtonTypePause:
			bezierPathForPauseButton(cornerRadius, lineWidth, &rect.size, &roundedRect);
			break;
		case WFButtonTypeDefault:
		case WFButtonTypeCheck:
		case WFButtonTypeShuffle:
		default:
			roundedRect = [UIBezierPath bezierPathWithRoundedRect: rect
													 cornerRadius: 4.0];
			break;
	}

	[roundedRect addClip];

	CGContextDrawLinearGradient(context, gradient, CGPointZero,
								CGPointMake(0.0, rect.size.height), 0);
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);

}

@end
