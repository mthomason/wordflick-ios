//
//  CIImage+CommonFilters.m
//  wordPuzzle
//
//  Created by Michael Thomason on 10/19/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import "CIImage+CommonFilters.h"

@implementation CIImage (CommonFilters)

+ (CIImage *)colorMap:(CIImage *)image andGradientImage:(CIImage *)backgroundImage {
	CIImage *imgF = [image retain];
	CIImage *imgB = [backgroundImage retain];
	return [CIFilter filterWithName: @"CIColorMap"
					  keysAndValues: @"inputImage", image,
									 @"inputGradientImage", backgroundImage, nil].outputImage;
}

+ (CIImage *)maskToAlpha:(CIImage *)image {
	return [CIFilter filterWithName: @"CIMaskToAlpha"
					  keysAndValues: @"inputImage", image, nil].outputImage;
}

+ (CIImage *)additionCompositing:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage {
	return [[CIFilter filterWithName: @"CIAdditionCompositing"
					   keysAndValues: @"inputImage", image,
									  @"inputBackgroundImage", backgroundImage, nil] outputImage];
}

+ (CIImage *)colorBurnBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage {
	return [CIFilter filterWithName: @"CIColorBurnBlendMode"
					  keysAndValues: @"inputImage", image,
									 @"inputBackgroundImage", backgroundImage, nil].outputImage;
}

+ (CIImage *)hueBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage {
	return [CIFilter filterWithName: @"CIHueBlendMode"
					  keysAndValues: @"inputImage", image,
									 @"inputBackgroundImage", backgroundImage, nil].outputImage;
}

+ (CIImage *)luminosityBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage {
	return [CIFilter filterWithName: @"CILuminosityBlendMode"
					  keysAndValues: @"inputImage", image,
									 @"inputBackgroundImage", backgroundImage, nil].outputImage;
}

+ (CIImage *)exclusionBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage {
	return [CIFilter filterWithName: @"CIExclusionBlendMode"
					  keysAndValues: @"inputImage", image,
									 @"inputBackgroundImage", backgroundImage, nil].outputImage;
}

+ (CIImage *)differenceBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage {
	return [CIFilter filterWithName: @"CIDifferenceBlendMode"
					  keysAndValues: @"inputImage", image,
									 @"inputBackgroundImage", backgroundImage, nil].outputImage;
}

+ (CIImage *)radialGradient:(CIVector *)inputCenter
			   inputRadius0:(NSNumber *)inputRadius0
			   inputRadius1:(NSNumber *)inputRadius1
				inputColor0:(CIColor *)inputColor0
				inputColor1:(CIColor *)inputColor1 {
	return [CIFilter filterWithName: @"CIRadialGradient"
					  keysAndValues: @"inputCenter", inputCenter,
									 @"inputRadius0", inputRadius0,
									 @"inputRadius1", inputRadius1,
									 @"inputColor0", inputColor0,
									 @"inputColor1", inputColor1, nil].outputImage;
}

+ (CIImage *)hueAdjust:(CIImage *)image andAngle:(NSNumber *)angle {
	return [CIFilter filterWithName: @"CIHueAdjust"
					  keysAndValues: @"inputImage", image,
									 @"inputAngle", angle, nil].outputImage;
}

+ (CIImage *)starShineForRect:(CGRect)rect atAngle:(CGFloat)angle {
	CGPoint ccenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	return [CIFilter filterWithName: @"CIStarShineGenerator"
					  keysAndValues: @"inputColor", [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],
									 @"inputCenter", [CIVector vectorWithX:ccenter.x Y:ccenter.y],
									 @"inputRadius", [NSNumber numberWithFloat: rect.size.width / 20.0000f ],
									 @"inputCrossScale", [ NSNumber numberWithFloat: 15.0000f ],
									 @"inputCrossAngle", [ NSNumber numberWithFloat: angle * M_PI / 36.0000f],
									 @"inputCrossOpacity", [ NSNumber numberWithFloat: -1.9666f], nil].outputImage;
}

+ (CIImage *)starShineWithCenter:(CIVector *)center
						  radius:(NSNumber *)radius
					  crossScale:(NSNumber *)crossScale
					  crossAngle:(NSNumber *)crossAngle
					crossOpacity:(NSNumber *)crossOpacity
					  inputColor:(CIColor *)inputColor {
	return [CIFilter filterWithName: @"CIStarShineGenerator"
					  keysAndValues: @"inputColor", inputColor,
									 @"inputCenter", center,
									 @"inputRadius", radius,
									 @"inputCrossScale", crossScale,
									 @"inputCrossAngle", crossAngle,
									 @"inputCrossOpacity", crossOpacity, nil].outputImage;
}

@end
