//
//  CIImage+CommonFilters.h
//  wordPuzzle
//
//  Created by Michael Thomason on 10/19/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#ifndef CIImage_CommonFilters_h
#define CIImage_CommonFilters_h

#import <CoreImage/CoreImage.h>

@interface CIImage (CommonFilters)

+ (CIImage *)additionCompositing:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage;
+ (CIImage *)colorBurnBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage;
+ (CIImage *)luminosityBlendMode:(CIImage *)image andBackgroundImage:(CIImage *)backgroundImage;
+ (CIImage *)radialGradient:(CIVector *)inputCenter
			   inputRadius0:(NSNumber *)inputRadius0
			   inputRadius1:(NSNumber *)inputRadius1
				inputColor0:(CIColor *)inputColor0
				inputColor1:(CIColor *)inputColor1;
+ (CIImage *)starShineWithCenter:(CIVector *)center
						  radius:(NSNumber *)radius
					  crossScale:(NSNumber *)crossScale
					  crossAngle:(NSNumber *)crossAngle
					crossOpacity:(NSNumber *)crossOpacity
					  inputColor:(CIColor *)inputColor;

@end

#endif
