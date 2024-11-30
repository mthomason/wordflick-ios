//
//  UIColor+Wordflick.hMoreColors.m
//  wordPuzzle
//
//  Created by Michael Thomason on 2/26/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "UIColor+Wordflick.h"
#import "WFMath_Extras.h"

#define vendColor(r, g, b) return [UIColor colorWithRed:(CGFloat)r/255.0f green:(CGFloat)g/255.0f blue:(CGFloat)b/255.0f alpha:1.0f]

@implementation UIColor(MoreColors)

+ (instancetype)everydayBlue {
	return [UIColor colorWithRed: 2.0f / 255.0f
						   green: 108.0f / 255.0f
							blue: 182.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)washedOutRed {
	return [UIColor colorWithRed: 255.0f / 255.0f
						   green: 153.0f / 255.0f
							blue: 153.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)washedOutPurple {
	return [UIColor colorWithRed: 204.0f / 255.0f
						   green: 153.0f / 255.0f
							blue: 204.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)washedOutGreen {
	return [UIColor colorWithRed: 102.0f / 255.0f
						   green: 255.0f / 255.0f
							blue: 102.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)washedOutYellow {
	return [UIColor colorWithRed: 250.0f / 255.0f
						   green: 240.0f / 255.0f
							blue: 109.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)cornflowerBlue {
	return [UIColor colorWithRed: 100.0f / 255.0f
						   green: 149.0f / 255.0f
							blue: 237.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)light {
	return [UIColor colorWithRed: 252.0f / 255.0f
						   green: 251.0f / 255.0f
							blue: 251.0f / 255.0f
						   alpha: 1.0f];
}
+ (instancetype)highlight {
	return [UIColor colorWithRed: 2.0f / 255.0f
						   green: 197.0f / 255.0f
							blue: 204.0f / 255.0f
						   alpha: 1.0f];
}

+ (instancetype)gradientBlue {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControl"]];}

+ (instancetype)psychedelicPurpleAlpha5 {
	return [UIColor colorWithRed: 223.0 / 255.0
						   green: 000.0 / 255.0
							blue: 255.0 / 255.0
						   alpha: 0.5];
}
+ (instancetype)cottenCandyAlpha5 {
	return [UIColor colorWithRed: 255.0 / 255.0
						   green: 183.0 / 255.0
							blue: 213.0 / 255.0
						   alpha: 0.5];
}
+ (instancetype)richElectricBlueAlpha5 {
	return [UIColor colorWithRed: 008.0 / 255.0
						   green: 146.0 / 255.0
							blue: 208.0 / 255.0
						   alpha: 0.5];
}
+ (instancetype)lightGreenAlpha5 __unused {
	return [UIColor colorWithRed: 144.0 / 255.0
						   green: 238.0 / 255.0
							blue: 144.0 / 255.0
						   alpha: 0.5];
}

+ (instancetype)patternUIImagePatternRetroBlueCircles     {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"UIImageRetroBlueCircles"]];}
+ (instancetype)patternGradentCarbonFiber                 {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"UIImagePatternCarbonFiber"]];}
+ (instancetype)patternUIImagePatternGearsBlue            {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"UIImageGearsBlue"]];}
+ (instancetype)patternUIImagePatternClouds3 { return [UIColor colorWithPatternImage:[UIImage imageNamed:@"UIImagePatternClouds3"]]; }
+ (instancetype)patternGradentCarbonFiberYellow           {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"UIImagePatternCarbonFiberYellow"]];}
+ (instancetype)gradientYellow                            {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControlYellow"]];}
+ (instancetype)gradientRed                               {return [UIColor colorWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControlRed"]];}

+ (instancetype)randomPattern { return [UIColor patternForId:(arc4random_uniform(51))]; }

+ (instancetype)patternForId:(int64_t)level {
	CGSize tileSize = CGSizeMake(400, 400); // Define tile size
	UIGraphicsBeginImageContext(tileSize);
	CGContextRef context = UIGraphicsGetCurrentContext();

	// **Background Color**
	UIColor *backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.98 alpha:1];
	[backgroundColor setFill];
	CGContextFillRect(context, CGRectMake(0, 0, tileSize.width, tileSize.height));

	// **Draw Circles**
	NSInteger circleCount = 10 + level / 5; // More circles for higher levels
	for (NSInteger i = 0; i < circleCount; i++) {
		[self drawSeamlessCircleInTileSize:tileSize
								 withLevel:level
								 circleIdx:i
								   context:context];
	}

	// Generate UIImage from the context
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [UIColor colorWithPatternImage:image];
}

+ (void)drawSeamlessCircleInTileSize:(CGSize)tileSize
						   withLevel:(NSInteger)level
						   circleIdx:(NSInteger)circleIdx
							 context:(CGContextRef)context {
	// Randomize position
	CGFloat x = arc4random_uniform(tileSize.width);
	CGFloat y = arc4random_uniform(tileSize.height);

	// Randomize size (proportional to tile size and level)
	CGFloat minRadius = 10;
	CGFloat maxRadius = 50 - level / 2.0; // Smaller circles for higher levels
	if (maxRadius < minRadius) maxRadius = minRadius;
	CGFloat radius = minRadius + arc4random_uniform((uint32_t)(maxRadius - minRadius));

	// Circle Color (unique for each circle)
	CGFloat hue = fmod((circleIdx * 37 + level * 5) / 100.0, 1.0); // Spread across the hue spectrum
	UIColor *circleColor = [UIColor colorWithHue:hue saturation:0.7 brightness:0.9 alpha:1];
	CGContextSetFillColorWithColor(context, circleColor.CGColor);

	// Draw Circle
	CGRect circleRect = CGRectMake(x - radius, y - radius, radius * 2, radius * 2);
	CGContextFillEllipseInRect(context, circleRect);

	// Wrap for seamless tiling
	[self wrapCircleAtRect:circleRect tileSize:tileSize context:context color:circleColor];
}

+ (void)wrapCircleAtRect:(CGRect)rect tileSize:(CGSize)tileSize context:(CGContextRef)context color:(UIColor *)color {
	CGContextSetFillColorWithColor(context, color.CGColor);

	// Wrap horizontally
	if (CGRectGetMaxX(rect) > tileSize.width) {
		CGRect wrappedRect = rect;
		wrappedRect.origin.x -= tileSize.width;
		CGContextFillEllipseInRect(context, wrappedRect);
	}
	if (CGRectGetMinX(rect) < 0) {
		CGRect wrappedRect = rect;
		wrappedRect.origin.x += tileSize.width;
		CGContextFillEllipseInRect(context, wrappedRect);
	}

	// Wrap vertically
	if (CGRectGetMaxY(rect) > tileSize.height) {
		CGRect wrappedRect = rect;
		wrappedRect.origin.y -= tileSize.height;
		CGContextFillEllipseInRect(context, wrappedRect);
	}
	if (CGRectGetMinY(rect) < 0) {
		CGRect wrappedRect = rect;
		wrappedRect.origin.y += tileSize.height;
		CGContextFillEllipseInRect(context, wrappedRect);
	}

	// Wrap diagonally
	if (CGRectGetMaxX(rect) > tileSize.width && CGRectGetMaxY(rect) > tileSize.height) {
		CGRect wrappedRect = rect;
		wrappedRect.origin.x -= tileSize.width;
		wrappedRect.origin.y -= tileSize.height;
		CGContextFillEllipseInRect(context, wrappedRect);
	}
	if (CGRectGetMinX(rect) < 0 && CGRectGetMinY(rect) < 0) {
		CGRect wrappedRect = rect;
		wrappedRect.origin.x += tileSize.width;
		wrappedRect.origin.y += tileSize.height;
		CGContextFillEllipseInRect(context, wrappedRect);
	}
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientBlackShine(void) {
	CGGradientRef _backgroundGradientBlackShine = NULL;
	CGFloat colors[16] = {
		175.0 / 255.0, 189.0 / 255.0, 192.0 / 255.0, 0.5,
		109.0 / 255.0, 118.0f / 255.0, 115.0 / 255.0, 0.5,
		10.0 / 255.0, 15.0f / 255.0, 11.0 / 255.0, 0.5,
		10.0 / 255.0, 8.0f / 255.0, 9.0 / 255.0, 0.5
	};
	CGFloat colorStops[4] = {0.0, 0.49, 0.5, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientBlackShine = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientBlackShine;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientBlackReverse(void) {
	CGFloat colors[16] = {
		175.0 / 255.0, 189.0 / 255.0, 192.0 / 255.0, 1.0,
		109.0 / 255.0, 118.0 / 255.0, 115.0 / 255.0, 1.0,
		10.0 / 255.0, 15.0 / 255.0, 11.0 / 255.0, 1.0,
		10.0 / 255.0, 8.0 / 255.0, 9.0 / 255.0, 1.0
	};
	CGFloat colorStops[4] = {0.0, 0.42, 0.43, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
	return gradientRef;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientWhite(void) {
	CGGradientRef _backgroundGradientTileWhite = NULL;
	CGFloat colors[20] = {
		225.0 / 255.0, 225.0 / 255.0, 225.0 / 255.0, 1.0,
		1.0, 1.0, 1.0, 1.0,
		253.0 / 255.0, 253.0 / 255.0, 253.0 / 255.0, 1.0,
		237.0 / 255.0, 237.0 / 255.0, 237.0 / 255.0, 1.0,
		222.0 / 255.0, 222.0 / 255.0, 222.0 / 255.0, 1.0
	};
	CGFloat colorStops[5] = {0.0, 0.4, 0.6, 0.98, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientTileWhite = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 5);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientTileWhite;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientGray(void) {
	CGGradientRef _backgroundGradientTileGray = NULL;
	CGFloat colors[20] = {
		181.0 / 255.0, 195.0 / 255.0, 203.0 / 255.0, 1.0,
		216.0 / 255.0, 225.0 / 255.0, 231.0 / 255.0, 1.0,
		181.0 / 255.0, 198.0 / 255.0, 208.0 / 255.0, 1.0,
		194.0 / 255.0, 212.0 / 255.0, 224.0 / 255.0, 1.0,
		214.0 / 255.0, 234.0 / 255.0, 247.0 / 255.0, 1.0
	};
	CGFloat colorStops[5] = {0.0, 0.5, 0.5, 0.75, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientTileGray = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 5);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientTileGray;
}

CGGradientRef CGGradientCreateBackgroundGradientBlack(void) {
	CGGradientRef _backgroundGradientTileBlack = NULL;
	CGFloat colors[16] = {
		10.0 / 255.0, 8.0 / 255.0, 9.0 / 255.0, 1.0,
		10.0 / 255.0, 15.0 / 255.0, 11.0 / 255.0, 1.0,
		109.0 / 255.0, 118.0 / 255.0, 115.0 / 255.0, 1.0,
		175.0 / 255.0, 189.0 / 255.0, 192.0 / 255.0, 1.0
	};
	CGFloat colorStops[4] = {0.0, 0.42, 0.43, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientTileBlack = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientTileBlack;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientBlue(void) {
	CGGradientRef _backgroundGradientTileBlue = NULL;
	CGFloat colors[16] = {
		112.0 / 255.0, 182.0 / 255.0, 242.0 / 255.0, 1.0,
		84.0 / 255.0, 163.0 / 255.0, 238.0 / 255.0, 1.0,
		54.0 / 255.0, 112.0 / 144.0, 240.0 / 255.0, 1.0,
		26.0 / 255.0, 98.0 / 255.0, 219.0 / 255.0, 1.0
	};
	CGFloat colorStops[4] = {0.0, 0.5, 0.5, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientTileBlue = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientTileBlue;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientFadeFromBlackRadial(void) {
	CGGradientRef _backgroundGradientFadeFromBlack = NULL;
	CGFloat colors[12] = {
		0.0f, 0.0f, 0.0f, 0.3f,
		0.0f, 0.0f, 0.0f, 0.6f,
		0.0f, 0.0f, 0.0f, 0.9f
	};
	CGFloat colorStops[3] = {0.0f, 0.5f, 1.0f};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientFadeFromBlack = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientFadeFromBlack;
}

CGGradientRef CGGradientCreateBackgroundGradientFadeToBlackRadial(void) {
	CGGradientRef _backgroundGradientFadeFromBlack = NULL;
	CGFloat colors[12] = {
		0.0, 0.0, 0.0, 0.9,
		0.0, 0.0, 0.0, 0.6,
		0.0, 0.0, 0.0, 0.3
	};
	CGFloat colorStops[3] = {0.0, 0.9, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientFadeFromBlack = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientFadeFromBlack;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientFadeToBlackRadialIcon(void) {
	CGGradientRef _backgroundGradientFadeFromBlack = NULL;
		CGFloat colors[12] = {
			0.0f, 0.0f, 0.0f, 1.0f,
			0.0f, 0.0f, 0.0f, 0.05f,
			0.0f, 0.0f, 0.0f, 0.0f
		};
		CGFloat colorStops[3] = {0.0f, 2.0f/3.0f, 1.0f};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		_backgroundGradientFadeFromBlack = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
		CGColorSpaceRelease(colorSpace);
	return _backgroundGradientFadeFromBlack;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientGreenToRedIcon(void) {
	CGGradientRef _backgroundGradientFadeFromBlack = NULL;
	CGFloat colors[12] = {
		150.0f  / 255.0f, 255.0f / 255.0f, 155.0f / 255.0f, 1.0f,
		015.0f  / 255.0f, 185.0f / 255.0f, 030.0f / 255.0f, 1.0f,
		015.0f  / 255.0f, 185.0f / 255.0f, 030.0f / 255.0f, 1.0f,
	};
	CGFloat colorStops[3] = {0.0f, 0.75f, 1.0f};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_backgroundGradientFadeFromBlack = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
	CGColorSpaceRelease(colorSpace);
	return _backgroundGradientFadeFromBlack;
}

__attribute__((unused))
CGGradientRef CGGradientCreateBackgroundGradientFadeFromRandom(void) {
	double redLevel	= RandomFractionalValue(), greenLevel = RandomFractionalValue(), blueLevel = RandomFractionalValue();
	CGFloat colors[12] = {
		redLevel, greenLevel, blueLevel, 0.9f,
		redLevel, greenLevel, blueLevel, 0.5f,
		redLevel, greenLevel, blueLevel, 0.9f
	};
	CGFloat colorStops[3] = {0.0f, 0.5f, 1.0f};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef result = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
	CGColorSpaceRelease(colorSpace);
	return result;
}

@end
