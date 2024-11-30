//
//  UIColor+Wordflick.h
//  wordPuzzle
//
//  Created by Michael Thomason on 2/26/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(Wordflick)

+ (instancetype)patternUIImagePatternRetroBlueCircles;
+ (instancetype)patternGradentCarbonFiber;
+ (instancetype)patternUIImagePatternGearsBlue;
+ (instancetype)patternUIImagePatternClouds3;

+ (instancetype)richElectricBlueAlpha5;
+ (instancetype)psychedelicPurpleAlpha5;
+ (instancetype)cottenCandyAlpha5;

+ (instancetype)everydayBlue;
+ (instancetype)washedOutRed;
+ (instancetype)washedOutPurple;
+ (instancetype)washedOutGreen;
+ (instancetype)washedOutYellow;
+ (instancetype)cornflowerBlue;

+ (instancetype)light;
+ (instancetype)highlight;
+ (instancetype)gradientBlue;

+ (instancetype)patternGradentCarbonFiberYellow;
+ (instancetype)patternForId:(int64_t)idnumber;
+ (instancetype)randomPattern;

CGGradientRef CGGradientCreateBackgroundGradientFadeToBlackRadial(void);

@end
