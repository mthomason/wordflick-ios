//
//  WFShuffleButton.m
//  wordPuzzle
//
//  Created by Michael on 2/19/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "WFShuffleButton.h"

@implementation WFShuffleButton

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		UIImage *shuffleImage;
		if (@available(iOS 13.0, *)) {
			UIImageSymbolConfiguration *symbolConfiguration =
			[UIImageSymbolConfiguration configurationWithPointSize: 18.0
															weight: UIImageSymbolWeightBold
															 scale: UIImageSymbolScaleLarge];
			shuffleImage = [UIImage systemImageNamed:@"shuffle" withConfiguration:symbolConfiguration];
		} else {
			NSAssert(NO, @"Add a shuffle iamge here.");
			shuffleImage = [UIImage imageNamed:@"shuffle"];
		}
		CALayer *maskLayer = [CALayer layer];
		maskLayer.frame = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
									 (self.bounds.size.height - shuffleImage.size.height) / 2.0,
									 shuffleImage.size.width, shuffleImage.size.height);

		maskLayer.contents = (__bridge id)shuffleImage.CGImage;
		self.button.layer.mask = maskLayer;
		self.button.layer.shadowOpacity = 0.5;
		self.button.layer.shadowRadius = 1.0;
		self.button.layer.shadowOffset = CGSizeMake(1.0, -1.0);
		self.button.layer.shadowColor = [UIColor blackColor].CGColor;

	}
	return self;
}

- (WFButtonType)buttonType { return WFButtonTypeShuffle; }
- (WFButtonColor)buttonColor { return WFButtonColorBlue; }

+ (void)BackgroundGradient:(CGGradientRef _Nullable * _Nonnull)gradient alpha:(CGFloat)a {
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

@end
