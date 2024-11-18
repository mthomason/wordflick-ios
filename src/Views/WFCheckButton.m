//
//  WFCheckButton.m
//  wordPuzzle
//
//  Created by Michael on 2/19/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "WFCheckButton.h"

@implementation WFCheckButton

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		UIImage *shuffleImage;
		if (@available(iOS 13.0, *)) {
			UIImageSymbolConfiguration *symbolConfiguration =
			[UIImageSymbolConfiguration configurationWithPointSize: 18.0
															weight: UIImageSymbolWeightBold
															 scale: UIImageSymbolScaleLarge];
			shuffleImage = [UIImage systemImageNamed:@"checkmark" withConfiguration:symbolConfiguration];
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

- (WFButtonType)buttonType { return WFButtonTypeCheck; }
- (WFButtonColor)buttonColor { return WFButtonColorGreen; }

+ (void)BackgroundGradient:(CGGradientRef _Nullable * _Nonnull)gradient alpha:(CGFloat)a {
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

@end
