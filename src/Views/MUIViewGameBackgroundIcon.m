//
//  MUIViewGameBackgroundIcon.m
//  wordPuzzle
//
//  Created by Michael Thomason on 5/21/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUIViewGameBackgroundIcon.h"
#import "UIColor+Wordflick.h"

#if WORDFLICKICONS == TRUE
#import <CoreImage/CoreImage.h>
#import "CIImage+CommonFilters.h"
#endif

@implementation MUIViewGameBackgroundIcon

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
	}
	return self;
}

#if WORDFLICKICONS == TRUE
- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();

	if (YES) {   //Draw sunburst for edu app
		UIImage *img = [[[self wordflickClassroomIconForRect:rect] retain] autorelease];
		CGContextDrawImage(context, rect, img.CGImage);
	} else {
		UIColor *color = [UIColor everydayBlue];
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, rect);
	}
}

- (UIImage *)wordflickClassroomIconForRect:(CGRect)rect {
	CIImage *colorBlack = [[CIImage alloc] initWithColor:[CIColor colorWithRed:0.0000f green:0.0000f blue:0.0000f]];
	
	CGPoint ccenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CIVector *vector = [CIVector vectorWithX:ccenter.x Y:ccenter.y];
	
	CIColor *lightGreenColor = [CIColor colorWithRed:150.0000f / 255.0000f
													green:225.0000f / 255.0000f
													 blue:155.0000f / 255.0000f
													alpha:001.0000f / 001.0000f];
	
	CIColor *darkGreenColor = [CIColor colorWithRed:015.0000f / 255.0000f
													green:185.0000f / 255.0000f
													 blue:030.0000f / 255.0000f
													alpha:1.0000f];
	/*

	CIColor *darkGreenColor = [CIColor colorWithRed:009.0000f / 255.0000f
													green:057.0000f / 255.0000f
													 blue:048.0000f / 255.0000f
													alpha:001.0000f / 001.0000f];
	
	CIColor *lightGreenColor = [CIColor colorWithRed:120.0000f / 255.0000f
													green:169.0000f / 255.0000f
													 blue:118.0000f / 255.0000f
													alpha:1.0000f];
	*/

	CIColor *darkPurpleColor = [CIColor colorWithRed:131.0000f / 255.0000f
											  green:101.0000f / 255.0000f
											   blue:155.0000f / 255.0000f
											  alpha:001.0000f / 001.0000f];
	CIColor *lightPurpleColor = [CIColor colorWithRed:255.0000f / 255.0000f
											   green:255.0000f / 255.0000f
												blue:000.0000f / 255.0000f
											   alpha:1.0000f];
	
	
	
	CIImage *radialGradient = [CIImage radialGradient:vector
														   inputRadius0:[NSNumber numberWithFloat:0.0000f]
														   inputRadius1:[NSNumber numberWithFloat:rect.size.width]
															inputColor0:lightGreenColor
															inputColor1:darkGreenColor];

	CIImage *purpleGradient = [CIImage radialGradient:vector
										 inputRadius0:[NSNumber numberWithFloat:0.0000f]
										 inputRadius1:[NSNumber numberWithFloat:rect.size.width]
										  inputColor0:lightPurpleColor
										  inputColor1:darkPurpleColor];
	
	NSNumber *crossOpacity =    [NSNumber numberWithFloat: -1.9666f];
	NSNumber *crossScale =      [NSNumber numberWithFloat: 17.0000f];
	NSNumber *radius =          [NSNumber numberWithFloat: rect.size.width / 22.131313f];

	CGFloat offsetValue = 1.3161f;

	NSInteger angleOffset = 1;
	
	NSNumber *crossAngle =      [NSNumber numberWithFloat: 1 * M_PI / 36.0000f];
	CIImage *star0 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	
	angleOffset += 2;
	crossAngle =                [NSNumber numberWithFloat: 3 * M_PI / 36.0000f];
	
	radius = [NSNumber numberWithFloat:radius.floatValue * offsetValue];
	
	star0 = [CIImage additionCompositing:star0 andBackgroundImage:radialGradient];
	
	CIImage *star1 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	CIImage *output = [CIImage additionCompositing:star1 andBackgroundImage:star0];

	radius = [NSNumber numberWithFloat:radius.floatValue / offsetValue];

	angleOffset += 2;
	crossAngle =    [NSNumber numberWithFloat: 5 * M_PI / 36.0000f];
	star1 =         [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output =        [CIImage additionCompositing:star1 andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue * offsetValue];
  
	angleOffset += 2;
	crossAngle =    [NSNumber numberWithFloat: 7 * M_PI / 36.0000f];
	star1 =         [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output =        [CIImage additionCompositing:star1 andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue / offsetValue];
	
	angleOffset += 2;
	crossAngle =                [NSNumber numberWithFloat: 9 * M_PI / 36.0000f];
	star1 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output = [CIImage additionCompositing:star1 andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue * offsetValue];
	
	angleOffset += 2;
	crossAngle =                [NSNumber numberWithFloat: 11 * M_PI / 36.0000f];
	star1 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output = [CIImage additionCompositing:star1 andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue / offsetValue];

	angleOffset += 2;
	crossAngle =                [NSNumber numberWithFloat: 13 * M_PI / 36.0000f];
	star1 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output = [CIImage additionCompositing:star1 andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue * offsetValue];

	angleOffset += 2;
	crossAngle =                [NSNumber numberWithFloat: 15 * M_PI / 36.0000f];
	star1 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output = [CIImage additionCompositing:star1 andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue / offsetValue];
	
	angleOffset += 2;
	crossAngle =                [NSNumber numberWithFloat: 17 * M_PI / 36.0000f];
	star1 =            [CIImage starShineWithCenter:vector radius:radius crossScale:crossScale crossAngle:crossAngle crossOpacity:crossOpacity inputColor:lightGreenColor];
	output = [CIImage additionCompositing:star1 andBackgroundImage:output];

//    output = [CIImage luminosityBlendMode:purpleGradient andBackgroundImage:output];
	output = [CIImage colorBurnBlendMode:purpleGradient andBackgroundImage:output];

	radius = [NSNumber numberWithFloat:radius.floatValue * offsetValue];
	
	CIImage *resultImage = nil;

	CIContext *cicontext = [CIContext contextWithOptions: nil];
	CGImageRef cgImage = [cicontext createCGImage:output fromRect:rect];
	[resultImage autorelease];
	[colorBlack autorelease];
	return [UIImage imageWithCGImage:cgImage];
}
#endif

@end
